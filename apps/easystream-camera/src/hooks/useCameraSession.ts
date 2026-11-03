import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { MediaStream } from 'react-native-webrtc';

import {
  freshDirectorEndpoint,
  sharedDiscoveryService,
} from '@/services/discovery/EasyStreamDiscoveryService';
import { CameraStreamSession, type LocalCameraOption } from '@/services/webrtc/CameraStreamSession';
import type {
  CameraSwitcherAssignment,
  DeviceIdentity,
  DiscoveredDirector,
  RemoteCameraCommand,
  StreamConnectionState,
} from '@/types/protocol';
import {
  applyRemoteCameraCommand,
  defaultImagingState,
  snapshotSettings,
  type LocalImagingState,
} from '@/utils/remoteCommandExecutor';
import {
  assignmentIsActive,
  webRTCProfileForAssignment,
} from '@/utils/transportProfile';
import { log } from '@/utils/logger';

type UseCameraSessionArgs = {
  identity: DeviceIdentity | null;
  directors: DiscoveredDirector[];
};

function directorListKey(directors: DiscoveredDirector[]): string {
  return directors.map((d) => `${d.id}:${d.host}:${d.port}`).join('|');
}

export function useCameraSession({ identity, directors }: UseCameraSessionArgs) {
  const sessionRef = useRef(new CameraStreamSession());
  const autoConnectDirectorIDRef = useRef<string | null>(null);
  const activeDirectorIDRef = useRef<string | null>(null);
  const streamStateRef = useRef<StreamConnectionState>('idle');
  const [streamState, setStreamState] = useState<StreamConnectionState>('idle');
  const [statusMessage, setStatusMessage] = useState('Iniciando…');
  const [localStream, setLocalStream] = useState<MediaStream | null>(null);
  const [selectedDirectorID, setSelectedDirectorID] = useState<string | null>(null);
  const [userChoseDirector, setUserChoseDirector] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [assignment, setAssignment] = useState<CameraSwitcherAssignment>('idle');
  const [imaging, setImaging] = useState<LocalImagingState>(defaultImagingState);
  const [lastError, setLastError] = useState<string | null>(null);
  const [cameras, setCameras] = useState<LocalCameraOption[]>([]);
  const [activeCameraKey, setActiveCameraKey] = useState<string | null>(null);
  const camerasRef = useRef<LocalCameraOption[]>([]);
  const connectGenerationRef = useRef(0);
  const connectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const preferredDirector = useMemo(() => {
    if (selectedDirectorID) {
      return directors.find((director) => director.id === selectedDirectorID) ?? null;
    }
    if (directors.length === 1) {
      return directors[0] ?? null;
    }
    return null;
  }, [directors, selectedDirectorID]);

  const reportSettings = useCallback(() => {
    if (!identity || streamStateRef.current !== 'connected') {
      return;
    }
    const settings = snapshotSettings(imaging, isMuted);
    sessionRef.current.sendSettingsState(identity.deviceID, settings);
  }, [identity, imaging, isMuted]);

  const applyTransportForAssignment = useCallback((next: CameraSwitcherAssignment) => {
    setAssignment(next);
    sessionRef.current.updateTransportProfile(webRTCProfileForAssignment(next));
  }, []);

  const handleRemoteCommand = useCallback(
    (command: RemoteCameraCommand) => {
      setImaging((current) =>
        applyRemoteCameraCommand(command, current, {
          onAssignmentChange: applyTransportForAssignment,
          onReconnectStream: () => {
            void sessionRef.current.reconnectOffer();
          },
          onImagingChange: setImaging,
          onMuteChange: (muted) => {
            setIsMuted(muted);
            sessionRef.current.setAudioMuted(muted);
          },
          onLensChange: (lens) => {
            const facing = lens === 'front' ? 'user' : 'environment';
            const match =
              camerasRef.current.find((camera) => camera.facingMode === facing) ??
              camerasRef.current[0];
            if (match) {
              void sessionRef.current.selectCamera(match);
              setActiveCameraKey(match.deviceId || match.facingMode);
            }
          },
        }),
      );
      reportSettings();
    },
    [applyTransportForAssignment, reportSettings],
  );

  const applyConnectionState = useCallback((state: StreamConnectionState, directorName: string) => {
    if (state === 'connected' || state === 'failed' || state === 'disconnected' || state === 'idle') {
      if (connectTimeoutRef.current) {
        clearTimeout(connectTimeoutRef.current);
        connectTimeoutRef.current = null;
      }
    }
    if (streamStateRef.current === state) {
      return;
    }
    streamStateRef.current = state;
    setStreamState(state);

    if (state === 'connected') {
      setStatusMessage(`En vivo con ${directorName}`);
    } else if (state === 'signaling') {
      setStatusMessage('Negociando WebRTC…');
    } else if (state === 'connecting') {
      setStatusMessage(`Conectando a ${directorName}…`);
    } else if (state === 'failed') {
      setStatusMessage('Error de conexión');
    } else if (state === 'disconnected') {
      setStatusMessage('Desconectado del Director');
    }

    if (state === 'failed' || state === 'disconnected') {
      autoConnectDirectorIDRef.current = null;
    }
  }, []);

  const connectToDirector = useCallback(
    (director: DiscoveredDirector, options?: { force?: boolean }) => {
      if (!identity) {
        return;
      }

      if (
        !options?.force &&
        activeDirectorIDRef.current === director.id &&
        (streamStateRef.current === 'connecting' ||
          streamStateRef.current === 'signaling' ||
          streamStateRef.current === 'connected')
      ) {
        log.session.debug('connect skipped (already active)', {
          directorID: director.id,
          streamState: streamStateRef.current,
        });
        return;
      }

      log.session.info('connectToDirector (hook)', {
        director: director.displayName,
        host: director.host,
        port: director.port,
        force: options?.force ?? false,
      });

      activeDirectorIDRef.current = director.id;
      setSelectedDirectorID(director.id);
      setLastError(null);
      applyConnectionState('connecting', director.displayName);
      connectGenerationRef.current += 1;
      const generation = connectGenerationRef.current;
      if (connectTimeoutRef.current) {
        clearTimeout(connectTimeoutRef.current);
      }
      connectTimeoutRef.current = setTimeout(() => {
        if (generation !== connectGenerationRef.current) {
          return;
        }
        if (streamStateRef.current !== 'connecting' && streamStateRef.current !== 'signaling') {
          return;
        }
        sessionRef.current.resetConnection();
        activeDirectorIDRef.current = null;
        setLastError('Sin conexión con el Director');
        applyConnectionState('failed', director.displayName);
        void sessionRef.current.ensureLocalPreview().then(setLocalStream).catch(() => undefined);
      }, 12_000);

      sessionRef.current.connectToDirector(director.host, director.port, identity, {
        onConnectionState: (state) => {
          applyConnectionState(state, director.displayName);
          if (state === 'failed' || state === 'disconnected') {
            void sessionRef.current.ensureLocalPreview().then(setLocalStream).catch(() => undefined);
          }
        },
        onLocalStream: setLocalStream,
        onSignalingMessage: (message) => {
          if (message.type === 'control') {
            handleRemoteCommand(message.command);
          }
        },
        onError: (message) => {
          const detail = message.trim() || 'Error de señalización TCP';
          log.session.error('Session error', { message: detail });
          setLastError(detail);
        },
      });
    },
    [applyConnectionState, handleRemoteCommand, identity],
  );

  const connectManual = useCallback(
    (host: string, port: number) => {
      const trimmed = host.trim();
      if (!trimmed || !Number.isFinite(port) || port <= 0) {
        setLastError('Escribe la IP y el puerto del Director');
        return;
      }
      const director: DiscoveredDirector = {
        id: `manual-${trimmed}:${port}`,
        name: 'manual',
        host: trimmed,
        port,
        protocolVersion: '1',
        displayName: `${trimmed}:${port}`,
      };
      setUserChoseDirector(true);
      connectToDirector(director, { force: true });
    },
    [connectToDirector],
  );

  const selectCamera = useCallback((camera: LocalCameraOption) => {
    setActiveCameraKey(camera.deviceId || camera.facingMode);
    setImaging((current) => ({
      ...current,
      activeLens: camera.facingMode === 'user' ? 'front' : 'wide',
    }));
    void sessionRef.current.selectCamera(camera).catch((error: unknown) => {
      const message = error instanceof Error ? error.message : 'No se pudo cambiar de cámara';
      setLastError(message);
    });
  }, []);

  const selectDirector = useCallback(
    (director: DiscoveredDirector) => {
      setUserChoseDirector(true);
      connectToDirector(director, { force: true });
    },
    [connectToDirector],
  );

  const reconnect = useCallback(() => {
    autoConnectDirectorIDRef.current = null;
    activeDirectorIDRef.current = null;
    streamStateRef.current = 'idle';
    setStreamState('idle');

    const discovery = sharedDiscoveryService();
    discovery.refreshDirectorBrowse();

    const targetID = selectedDirectorID ?? preferredDirector?.id ?? null;
    const resolved =
      (targetID ? discovery.directorById(targetID) : null) ??
      preferredDirector ??
      (directors.length === 1 ? directors[0] : null);

    if (!resolved) {
      setStatusMessage('Buscando Director…');
      setLastError(null);
      return;
    }

    const director = freshDirectorEndpoint(resolved);
    log.session.info('reconnect with fresh endpoint', {
      directorID: director.id,
      host: director.host,
      port: director.port,
    });
    connectToDirector(director, { force: true });
  }, [connectToDirector, directors, preferredDirector, selectedDirectorID]);

  useEffect(() => {
    if (!identity) {
      return;
    }

    void sessionRef.current
      .prepareLocalMedia()
      .then(async (stream) => {
        setLocalStream(stream);
        const list = await sessionRef.current.listVideoCameras();
        camerasRef.current = list;
        setCameras(list);
        const current = list.find((camera) => camera.facingMode === 'environment') ?? list[0];
        if (current) {
          setActiveCameraKey(current.deviceId || current.facingMode);
        }
      })
      .catch((error: unknown) => {
        const message = error instanceof Error ? error.message : 'No se pudo abrir la cámara';
        log.media.error('prepareLocalMedia failed', { message });
        setLastError(message);
      });

    return () => {
      if (connectTimeoutRef.current) {
        clearTimeout(connectTimeoutRef.current);
        connectTimeoutRef.current = null;
      }
      autoConnectDirectorIDRef.current = null;
      activeDirectorIDRef.current = null;
      streamStateRef.current = 'idle';
      sessionRef.current.disconnect();
    };
  }, [identity]);

  const directorsKey = useMemo(() => directorListKey(directors), [directors]);

  useEffect(() => {
    if (!identity || userChoseDirector) {
      return;
    }

    if (directors.length === 0) {
      autoConnectDirectorIDRef.current = null;
      if (streamStateRef.current === 'idle') {
        setStatusMessage('Buscando Director…');
      }
      return;
    }

    if (directors.length > 1) {
      autoConnectDirectorIDRef.current = null;
      setStatusMessage('Elige un Director para transmitir');
      log.session.info('Multiple directors — manual pick required', {
        count: directors.length,
        names: directors.map((d) => d.displayName),
      });
      return;
    }

    const sole = directors[0];
    if (!sole) {
      return;
    }

    const needsSession =
      streamStateRef.current === 'idle' ||
      streamStateRef.current === 'failed' ||
      streamStateRef.current === 'disconnected' ||
      activeDirectorIDRef.current !== sole.id;

    if (!needsSession) {
      return;
    }

    log.session.info('Auto-connecting to sole director', {
      name: sole.displayName,
      host: sole.host,
      port: sole.port,
    });
    autoConnectDirectorIDRef.current = sole.id;
    connectToDirector(sole, { force: true });
  }, [connectToDirector, directorsKey, identity, userChoseDirector]);

  useEffect(() => {
    if (streamState === 'connected') {
      reportSettings();
    }
  }, [reportSettings, streamState]);

  useEffect(() => {
    sessionRef.current.setAudioMuted(isMuted);
  }, [isMuted]);

  const toggleMute = useCallback(() => {
    setIsMuted((value) => !value);
    reportSettings();
  }, [reportSettings]);

  return useMemo(
    () => ({
      streamState,
      statusMessage,
      localStream,
      directors,
      preferredDirector,
      selectedDirectorID,
      isMuted,
      assignment,
      imaging,
      lastError,
      cameras,
      activeCameraKey,
      assignmentIsActive: assignmentIsActive(assignment),
      selectDirector,
      connectManual,
      selectCamera,
      reconnect,
      toggleMute,
    }),
    [
      activeCameraKey,
      assignment,
      cameras,
      connectManual,
      directors,
      imaging,
      isMuted,
      lastError,
      localStream,
      preferredDirector,
      reconnect,
      selectCamera,
      selectDirector,
      selectedDirectorID,
      statusMessage,
      streamState,
      toggleMute,
    ],
  );
}
