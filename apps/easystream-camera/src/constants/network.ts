/** Matches `EasyStreamCore.NetworkConstants` on iOS/macOS. */
export const PROTOCOL_VERSION = '1';

export const BONJOUR_DOMAIN = 'local.';

export const SERVICE_TYPES = {
  camera: '_easystream-camera._tcp',
  director: '_easystream-director._tcp',
} as const;

export const TXT_KEYS = {
  deviceID: 'deviceID',
  displayName: 'displayName',
  protocolVersion: 'protocolVersion',
  platform: 'platform',
  role: 'role',
} as const;

export const APP_ROLE = {
  camera: 'camera',
  director: 'director',
} as const;

export const PLATFORM = {
  android: 'android',
} as const;
