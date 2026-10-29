import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { MediaStream } from 'react-native-webrtc';

import {
  freshDirectorEndpoint,
  sharedDiscoveryService,
} from '@/services/discovery/EasyStreamDiscoveryService';
import { CameraStreamSession } from '@/services/webrtc/CameraStreamSession';
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
        }),
      );
      reportSettings();
    },
    [applyTransportForAssignment, reportSettings],
  );

  const applyConnectionState = useCallback((state: StreamConnectionState, directorName: string) => {
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

      sessionRef.current.connectToDirector(director.host, director.port, identity, {
        onConnectionState: (state) => {
          applyConnectionState(state, director.displayName);
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
      .then((stream) => {
        setLocalStream(stream);
      })
      .catch((error: unknown) => {
        const message = error instanceof Error ? error.message : 'No se pudo abrir la cámara';
        log.media.error('prepareLocalMedia failed', { message });
        setLastError(message);
      });

    return () => {
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
      assignmentIsActive: assignmentIsActive(assignment),
      selectDirector,
      reconnect,
      toggleMute,
    }),
    [
      assignment,
      directors,
      imaging,
      isMuted,
      lastError,
      localStream,
      preferredDirector,
      reconnect,
      selectDirector,
      selectedDirectorID,
      statusMessage,
      streamState,
      toggleMute,
    ],
  );
}
