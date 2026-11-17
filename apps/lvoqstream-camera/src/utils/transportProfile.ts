import type { CameraSwitcherAssignment } from '@/types/protocol';

export type TransportProfile = {
  width: number;
  height: number;
  frameRate: number;
  maxBitrateKbps: number;
};

const STANDBY: TransportProfile = {
  width: 640,
  height: 360,
  frameRate: 15,
  maxBitrateKbps: 500,
};

/** Same tier as program so selecting PREV does not ramp quality after the cut. */
const PREVIEW: TransportProfile = {
  width: 1280,
  height: 720,
  frameRate: 30,
  maxBitrateKbps: 2_500,
};

const PROGRAM: TransportProfile = {
  width: 1280,
  height: 720,
  frameRate: 30,
  maxBitrateKbps: 2_500,
};

/**
 * One encode for every role. Preview and program only pick a feed that is already running,
 * so a switch never restarts the camera (that restart was the HD blink).
 */
export function webRTCProfileForAssignment(
  _assignment: CameraSwitcherAssignment,
): TransportProfile {
  return PROGRAM;
}

export function assignmentIsActive(assignment: CameraSwitcherAssignment): boolean {
  return assignment !== 'idle';
}
