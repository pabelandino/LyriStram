import TcpSocket from 'react-native-tcp-socket';

import type { SignalingMessage } from '@/types/protocol';
import { log } from '@/utils/logger';
import { decodeSignalingMessages, encodeSignalingMessage } from '@/utils/signalingCodec';

export type SignalingEvent =
  | { type: 'connected' }
  | { type: 'message'; message: SignalingMessage }
  | { type: 'disconnected' }
  | { type: 'failed'; error: string };

export type SignalingListener = (event: SignalingEvent) => void;

export class TcpSignalingClient {
  private socket: TcpSocket.Socket | null = null;
  private buffer = '';
  private listener: SignalingListener | null = null;

  connect(host: string, port: number, listener: SignalingListener): void {
    this.disconnect();
    this.listener = listener;
    this.buffer = '';

    log.signaling.info('TCP connect', { host, port });

    const socket = TcpSocket.createConnection({ port, host }, () => {
      if (this.socket !== socket) {
        return;
      }
      log.signaling.info('TCP connected', { host, port });
      listener({ type: 'connected' });
    });

    socket.on('data', (data: string | Uint8Array) => {
      if (this.socket !== socket) {
        return;
      }
      const chunk = typeof data === 'string' ? data : new TextDecoder().decode(data);
      log.signaling.debug('TCP data', { bytes: chunk.length });
      this.buffer += chunk;
      const { messages, rest } = decodeSignalingMessages(this.buffer);
      this.buffer = rest;
      for (const message of messages) {
        log.signaling.info('RX signaling', summarizeMessage(message));
        listener({ type: 'message', message });
      }
    });

    socket.on('error', (error: unknown) => {
      if (this.socket !== socket) {
        return;
      }
      const message = formatSocketError(error);
      log.signaling.error('TCP error', { message, raw: summarizeSocketError(error) });
      listener({ type: 'failed', error: message });
    });

    socket.on('close', () => {
      if (this.socket !== socket) {
        return;
      }
      log.signaling.info('TCP closed');
      listener({ type: 'disconnected' });
    });

    this.socket = socket;
  }

  send(message: SignalingMessage): void {
    const socket = this.socket;
    if (!socket) {
      log.signaling.warn('TX skipped (no socket)', summarizeMessage(message));
      return;
    }
    try {
      log.signaling.info('TX signaling', summarizeMessage(message));
      socket.write(encodeSignalingMessage(message));
    } catch (error) {
      log.signaling.error('TX failed', {
        ...summarizeMessage(message),
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  disconnect(): void {
    const socket = this.socket;
    this.socket = null;
    this.buffer = '';
    this.listener = null;
    if (socket) {
      log.signaling.info('TCP disconnect');
    }
    socket?.destroy();
  }
}

function formatSocketError(error: unknown): string {
  if (error instanceof Error && error.message.trim()) {
    return error.message;
  }
  if (typeof error === 'string' && error.trim()) {
    return error;
  }
  if (error && typeof error === 'object') {
    const record = error as Record<string, unknown>;
    const parts: string[] = [];
    for (const key of ['message', 'code', 'errno', 'syscall', 'address', 'port'] as const) {
      const value = record[key];
      if (value !== undefined && value !== null && String(value).length > 0) {
        parts.push(`${key}=${String(value)}`);
      }
    }
    if (parts.length > 0) {
      return parts.join(' ');
    }
    try {
      const json = JSON.stringify(error);
      if (json && json !== '{}') {
        return json;
      }
    } catch {
      // ignore
    }
  }
  return 'TCP connection failed';
}

function summarizeSocketError(error: unknown): Record<string, unknown> {
  if (error && typeof error === 'object') {
    return { ...(error as Record<string, unknown>) };
  }
  return { value: String(error) };
}

function summarizeMessage(message: SignalingMessage): Record<string, unknown> {
  switch (message.type) {
    case 'hello':
      return { type: message.type, deviceID: message.deviceID, role: message.role };
    case 'offer':
    case 'answer':
      return { type: message.type, sessionID: message.sessionID, sdpChars: message.sdp.length };
    case 'ice':
      return {
        type: message.type,
        sessionID: message.sessionID,
        sdpMLineIndex: message.sdpMLineIndex,
        candidatePreview: message.candidate.slice(0, 80),
      };
    case 'control':
      return { type: message.type, command: message.command };
    case 'settingsState':
      return { type: message.type, deviceID: message.deviceID };
    case 'tileSnapshot':
      return { type: message.type, deviceID: message.deviceID, sequence: message.sequence };
    default:
      return { type: (message as SignalingMessage).type };
  }
}
