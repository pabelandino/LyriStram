import type { SignalingMessage } from '@/types/protocol';
import { log } from '@/utils/logger';

/** Newline-delimited JSON — matches `SignalingCodec` in EasyStreamTransport. */
export function encodeSignalingMessage(message: SignalingMessage): string {
  return `${JSON.stringify(message)}\n`;
}

export function decodeSignalingMessages(buffer: string): {
  messages: SignalingMessage[];
  rest: string;
} {
  const messages: SignalingMessage[] = [];
  let rest = buffer;

  while (true) {
    const newlineIndex = rest.indexOf('\n');
    if (newlineIndex === -1) {
      break;
    }

    const line = rest.slice(0, newlineIndex).trim();
    rest = rest.slice(newlineIndex + 1);

    if (!line) {
      continue;
    }

    try {
      messages.push(JSON.parse(line) as SignalingMessage);
    } catch (error) {
      log.signaling.warn('JSON decode failed (Director may skip this line too)', {
        preview: line.slice(0, 160),
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  return { messages, rest };
}
