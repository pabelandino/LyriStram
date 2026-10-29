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
  frameRate: 12,
  maxBitrateKbps: 450,
};

const PREVIEW: TransportProfile = {
  width: 960,
  height: 540,
  frameRate: 24,
  maxBitrateKbps: 1_200,
};

const PROGRAM: TransportProfile = {
  width: 1280,
  height: 720,
  frameRate: 30,
  maxBitrateKbps: 2_500,
};

/** Mirrors `CameraTransportProfile.webRTCProfile(for:)` tiers on iOS. */
export function webRTCProfileForAssignment(
  assignment: CameraSwitcherAssignment,
): TransportProfile {
  switch (assignment) {
    case 'program':
    case 'previewAndProgram':
      return PROGRAM;
    case 'preview':
      return PREVIEW;
    case 'idle':
    default:
      return STANDBY;
  }
}

export function assignmentIsActive(assignment: CameraSwitcherAssignment): boolean {
  return assignment !== 'idle';
}
