import Zeroconf from 'react-native-zeroconf';

import {
  APP_ROLE,
  BONJOUR_DOMAIN,
  PLATFORM,
  PROTOCOL_VERSION,
  SERVICE_TYPES,
  TXT_KEYS,
} from '@/constants/network';
import type { DeviceIdentity, DiscoveredDirector } from '@/types/protocol';
import { log } from '@/utils/logger';

type DiscoveryListener = {
  onDirectorsChanged: (directors: DiscoveredDirector[]) => void;
  onError?: (message: string) => void;
};

function stripServicePrefix(type: string): string {
  return type.replace(/^_?/, '').replace(/\._tcp$/, '');
}

function parseTxt(txt: Record<string, string> | undefined) {
  if (!txt) {
    return null;
  }

  const deviceID = txt[TXT_KEYS.deviceID];
  const displayName = txt[TXT_KEYS.displayName];
  const protocolVersion = txt[TXT_KEYS.protocolVersion] ?? PROTOCOL_VERSION;
  const role = txt[TXT_KEYS.role];

  if (!deviceID || !displayName || role !== APP_ROLE.director) {
    return null;
  }

  if (protocolVersion !== PROTOCOL_VERSION) {
    return null;
  }

  return { deviceID, displayName, protocolVersion };
}

function directorsFingerprint(directors: DiscoveredDirector[]): string {
  return directors
    .map((d) => `${d.id}:${d.host}:${d.port}:${d.displayName}`)
    .sort()
    .join('|');
}

function pickHost(service: ZeroconfService): string | null {
  const addresses = service.addresses ?? [];
  const ipv4 = addresses.find((address) => !address.includes(':'));
  if (ipv4) {
    return ipv4;
  }
  if (service.host && !service.host.includes(':')) {
    return service.host;
  }
  return addresses[0] ?? service.host ?? null;
}

function dedupeDirectors(directors: DiscoveredDirector[]): DiscoveredDirector[] {
  const byEndpoint = new Map<string, DiscoveredDirector>();
  for (const director of directors) {
    const key = `${director.id.toLowerCase()}@${director.host}:${director.port}`;
    byEndpoint.set(key, director);
  }
  return Array.from(byEndpoint.values()).sort((a, b) =>
    a.displayName.localeCompare(b.displayName, undefined, { sensitivity: 'base' }),
  );
}

let sharedInstance: EasyStreamDiscoveryService | null = null;
let subscriberCount = 0;

/** One Zeroconf instance per app — Android NSD limits concurrent browse/register operations. */
export function sharedDiscoveryService(): EasyStreamDiscoveryService {
  if (!sharedInstance) {
    sharedInstance = new EasyStreamDiscoveryService();
  }
  return sharedInstance;
}

export function acquireDiscoverySubscriber(): void {
  subscriberCount += 1;
}

export function releaseDiscoverySubscriber(): void {
  subscriberCount = Math.max(0, subscriberCount - 1);
  if (subscriberCount === 0) {
    sharedInstance?.shutdown();
  }
}

/** Latest Bonjour endpoint for a director (host/port may change after Director restart). */
export function freshDirectorEndpoint(director: DiscoveredDirector): DiscoveredDirector {
  const live = sharedDiscoveryService().directorById(director.id);
  return live ?? director;
}

export class EasyStreamDiscoveryService {
  private zeroconf = new Zeroconf();
  private directors = new Map<string, DiscoveredDirector>();
  private listener: DiscoveryListener | null = null;
  private publishPort = 0;
  private publishedBonjourName: string | null = null;
  private lastDirectorsFingerprint = '';
  private activeDeviceID: string | null = null;
  private handlersAttached = false;
  private scanning = false;

  private emitDirectorsIfChanged(): void {
    const listener = this.listener;
    if (!listener) {
      return;
    }
    const list = dedupeDirectors(Array.from(this.directors.values()));
    const fingerprint = directorsFingerprint(list);
    if (fingerprint === this.lastDirectorsFingerprint) {
      return;
    }
    this.lastDirectorsFingerprint = fingerprint;
    listener.onDirectorsChanged(list);
  }

  private attachHandlers(): void {
    if (this.handlersAttached) {
      return;
    }
    this.handlersAttached = true;

    this.zeroconf.on('error', (error: unknown) => {
      const message = error instanceof Error ? error.message : 'Error de descubrimiento';
      log.discovery.error('Zeroconf error', { message });
      this.listener?.onError?.(message);
    });

    this.zeroconf.on('resolved', (service: ZeroconfService) => {
      const parsed = parseTxt(service.txt);
      if (!parsed) {
        log.discovery.debug('Director resolved but TXT invalid', {
          name: service.name,
          txt: service.txt,
        });
        return;
      }

      const host = pickHost(service);
      const port = service.port;
      if (!host || !port) {
        return;
      }

      const director: DiscoveredDirector = {
        id: parsed.deviceID,
        name: service.name,
        host,
        port,
        protocolVersion: parsed.protocolVersion,
        displayName: parsed.displayName,
      };

      const previous = this.directors.get(director.id);
      const changed =
        !previous ||
        previous.host !== director.host ||
        previous.port !== director.port ||
        previous.displayName !== director.displayName;

      if (changed) {
        log.discovery.info('Director resolved', {
          displayName: director.displayName,
          host,
          port,
          deviceID: director.id,
          addresses: service.addresses,
        });
      }

      this.directors.set(director.id, director);
      this.emitDirectorsIfChanged();
    });

    this.zeroconf.on('removed', (service: ZeroconfService) => {
      const parsed = parseTxt(service.txt);
      const key = parsed?.deviceID ?? service.name;
      if (this.directors.delete(key)) {
        log.discovery.info('Director removed', { key });
        this.emitDirectorsIfChanged();
      }
    });
  }

  start(identity: DeviceIdentity, listener: DiscoveryListener): void {
    this.listener = listener;

    if (this.scanning && this.activeDeviceID === identity.deviceID) {
      log.discovery.debug('Discovery already running — syncing directors to UI', {
        count: this.directors.size,
      });
      this.lastDirectorsFingerprint = '';
      this.emitDirectorsIfChanged();
      return;
    }

    if (this.scanning) {
      this.teardownNetwork();
    }

    this.activeDeviceID = identity.deviceID;
    this.attachHandlers();

    const directorType = stripServicePrefix(SERVICE_TYPES.director);
    log.discovery.info('Starting director browse', { type: directorType });
    this.zeroconf.scan(directorType, 'tcp', BONJOUR_DOMAIN);
    this.scanning = true;

    this.publishPort = 9_500 + Math.floor(Math.random() * 500);
    const bonjourName = `ES-${identity.deviceID.slice(0, 8)}`;
    this.publishedBonjourName = bonjourName;

    log.discovery.info('Publishing camera service', {
      bonjourName,
      port: this.publishPort,
      deviceID: identity.deviceID,
    });

    void this.zeroconf
      .publishService({
        type: stripServicePrefix(SERVICE_TYPES.camera),
        protocol: 'tcp',
        domain: BONJOUR_DOMAIN,
        name: bonjourName,
        port: this.publishPort,
        txt: {
          [TXT_KEYS.deviceID]: identity.deviceID,
          [TXT_KEYS.displayName]: identity.displayName,
          [TXT_KEYS.protocolVersion]: PROTOCOL_VERSION,
          [TXT_KEYS.platform]: PLATFORM.android,
          [TXT_KEYS.role]: APP_ROLE.camera,
        },
      })
      .catch((error: unknown) => {
        const message = error instanceof Error ? error.message : 'Publish failed';
        log.discovery.warn('Camera publish failed', { message });
      });
  }

  directorById(id: string): DiscoveredDirector | null {
    return this.directors.get(id) ?? null;
  }

  /** Re-run mDNS browse so host/port update quickly after Director restart. */
  refreshDirectorBrowse(): void {
    if (!this.scanning) {
      return;
    }
    const directorType = stripServicePrefix(SERVICE_TYPES.director);
    log.discovery.info('Refreshing director browse');
    this.zeroconf.stop();
    this.zeroconf.scan(directorType, 'tcp', BONJOUR_DOMAIN);
  }

  /** Detach UI listener only (keeps browse/publish alive for Strict Mode remounts). */
  detachListener(): void {
    this.listener = null;
  }

  shutdown(): void {
    this.teardownNetwork();
    this.directors.clear();
    this.lastDirectorsFingerprint = '';
    this.activeDeviceID = null;
    this.listener = null;
  }

  private teardownNetwork(): void {
    if (this.scanning) {
      log.discovery.info('Stopping director browse');
      this.zeroconf.stop();
      this.scanning = false;
    }

    if (this.publishedBonjourName) {
      const name = this.publishedBonjourName;
      this.publishedBonjourName = null;
      void this.zeroconf.unpublishService(name).catch(() => undefined);
    }
  }
}

type ZeroconfService = {
  name: string;
  host?: string;
  addresses?: string[];
  port?: number;
  txt?: Record<string, string>;
};
