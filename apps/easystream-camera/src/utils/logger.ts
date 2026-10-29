type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LOG_ENABLED = typeof __DEV__ !== 'undefined' ? __DEV__ : true;

function serialize(data: unknown): string {
  if (data === undefined) {
    return '';
  }
  try {
    return JSON.stringify(data, (_, value) => {
      if (typeof value === 'string' && value.length > 240) {
        return `${value.slice(0, 240)}…(${value.length} chars)`;
      }
      return value;
    });
  } catch {
    return String(data);
  }
}

function write(level: LogLevel, scope: string, message: string, data?: unknown): void {
  if (!LOG_ENABLED) {
    return;
  }
  const tag = `[EasyStream:${scope}]`;
  const payload = data === undefined ? message : `${message} ${serialize(data)}`;
  switch (level) {
    case 'debug':
      console.debug(tag, payload);
      break;
    case 'info':
      console.log(tag, payload);
      break;
    case 'warn':
      console.warn(tag, payload);
      break;
    case 'error':
      console.error(tag, payload);
      break;
  }
}

function scope(name: string) {
  return {
    debug: (message: string, data?: unknown) => write('debug', name, message, data),
    info: (message: string, data?: unknown) => write('info', name, message, data),
    warn: (message: string, data?: unknown) => write('warn', name, message, data),
    error: (message: string, data?: unknown) => write('error', name, message, data),
  };
}

/** Metro / Logcat-friendly diagnostics for camera ↔ director debugging. */
export const log = {
  session: scope('session'),
  discovery: scope('discovery'),
  signaling: scope('signaling'),
  webrtc: scope('webrtc'),
  media: scope('media'),
};
