export type StreamConnectionState =
  | 'idle'
  | 'connecting'
  | 'signaling'
  | 'connected'
  | 'disconnected'
  | 'failed';

export type CameraSwitcherAssignment =
  | 'idle'
  | 'preview'
  | 'program'
  | 'previewAndProgram';

export type RemoteCameraSettings = {
  isMuted: boolean;
  zoomFactor: number;
  exposureBias: number;
  whiteBalance: string;
  activeLens: string;
};

export type RemoteCameraCommand =
  | { setMuted: boolean }
  | { setZoom: number }
  | { setExposureBias: number }
  | { setWhiteBalance: string }
  | { setLens: string }
  | { applySavedSettings: RemoteCameraSettings }
  | { setSwitcherAssignment: CameraSwitcherAssignment }
  | { setDirectorMonitorQuality: Record<string, unknown> }
  | { reconnectStream: true };

export type SignalingMessage =
  | { type: 'hello'; deviceID: string; displayName: string; role: string }
  | { type: 'offer'; sessionID: string; sdp: string }
  | { type: 'answer'; sessionID: string; sdp: string }
  | {
      type: 'ice';
      sessionID: string;
      candidate: string;
      sdpMid?: string | null;
      sdpMLineIndex?: number | null;
    }
  | { type: 'control'; command: RemoteCameraCommand }
  | { type: 'settingsState'; deviceID: string; settings: RemoteCameraSettings }
  | { type: 'tileSnapshot'; deviceID: string; sequence: number; jpegBase64: string };

export type DiscoveredDirector = {
  id: string;
  name: string;
  host: string;
  port: number;
  protocolVersion: string;
  displayName: string;
};

export type DeviceIdentity = {
  deviceID: string;
  displayName: string;
  platform: typeof import('@/constants/network').PLATFORM.android;
};
