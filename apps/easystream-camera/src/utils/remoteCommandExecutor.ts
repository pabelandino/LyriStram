import type {
  CameraSwitcherAssignment,
  RemoteCameraCommand,
  RemoteCameraSettings,
} from '@/types/protocol';

export type LocalImagingState = {
  zoomFactor: number;
  exposureBias: number;
  whiteBalance: string;
  activeLens: string;
};

export type CommandExecutorCallbacks = {
  onAssignmentChange: (assignment: CameraSwitcherAssignment) => void;
  onReconnectStream: () => void;
  onImagingChange: (state: LocalImagingState) => void;
  onMuteChange: (muted: boolean) => void;
};

export function defaultImagingState(): LocalImagingState {
  return {
    zoomFactor: 1,
    exposureBias: 0,
    whiteBalance: 'auto',
    activeLens: 'wide',
  };
}

export function snapshotSettings(
  imaging: LocalImagingState,
  isMuted: boolean,
): RemoteCameraSettings {
  return {
    isMuted,
    zoomFactor: imaging.zoomFactor,
    exposureBias: imaging.exposureBias,
    whiteBalance: imaging.whiteBalance,
    activeLens: imaging.activeLens,
  };
}

export function applyRemoteCameraCommand(
  command: RemoteCameraCommand,
  imaging: LocalImagingState,
  callbacks: CommandExecutorCallbacks,
): LocalImagingState {
  const next = { ...imaging };

  if ('setMuted' in command) {
    callbacks.onMuteChange(command.setMuted);
    return next;
  }

  if ('setZoom' in command) {
    next.zoomFactor = Math.max(1, Math.min(command.setZoom, 8));
    callbacks.onImagingChange(next);
    return next;
  }

  if ('setExposureBias' in command) {
    next.exposureBias = command.setExposureBias;
    callbacks.onImagingChange(next);
    return next;
  }

  if ('setWhiteBalance' in command) {
    next.whiteBalance = command.setWhiteBalance;
    callbacks.onImagingChange(next);
    return next;
  }

  if ('setLens' in command) {
    next.activeLens = command.setLens;
    callbacks.onImagingChange(next);
    return next;
  }

  if ('applySavedSettings' in command) {
    const saved = command.applySavedSettings;
    next.zoomFactor = saved.zoomFactor;
    next.exposureBias = saved.exposureBias;
    next.whiteBalance = saved.whiteBalance;
    next.activeLens = saved.activeLens;
    callbacks.onMuteChange(saved.isMuted);
    callbacks.onImagingChange(next);
    return next;
  }

  if ('setSwitcherAssignment' in command) {
    callbacks.onAssignmentChange(command.setSwitcherAssignment);
    return next;
  }

  if ('setDirectorMonitorQuality' in command) {
    return next;
  }

  if ('reconnectStream' in command) {
    callbacks.onReconnectStream();
    return next;
  }

  return next;
}
