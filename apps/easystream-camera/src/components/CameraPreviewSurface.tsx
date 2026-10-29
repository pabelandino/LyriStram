import { memo, useEffect } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { RTCView, type MediaStream } from 'react-native-webrtc';

import { colors } from '@/theme/colors';
import { log } from '@/utils/logger';

type Props = {
  stream: MediaStream | null;
  statusMessage: string;
};

function CameraPreviewSurfaceComponent({ stream, statusMessage }: Props) {
  useEffect(() => {
    if (!stream) {
      log.media.debug('Preview waiting for stream', { statusMessage });
      return;
    }
    log.media.info('Preview stream ready', {
      streamId: stream.id,
      url: stream.toURL(),
      videoTracks: stream.getVideoTracks().length,
    });
  }, [statusMessage, stream]);

  if (!stream) {
    return (
      <View style={styles.placeholder}>
        <Text style={styles.placeholderTitle}>Preparando cámara…</Text>
        <Text style={styles.placeholderSubtitle}>{statusMessage}</Text>
      </View>
    );
  }

  return (
    <RTCView
      streamURL={stream.toURL()}
      style={styles.preview}
      objectFit="cover"
      mirror={false}
    />
  );
}

export const CameraPreviewSurface = memo(CameraPreviewSurfaceComponent);

const styles = StyleSheet.create({
  preview: {
    flex: 1,
    backgroundColor: '#000',
  },
  placeholder: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#000',
  },
  placeholderTitle: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  placeholderSubtitle: {
    color: colors.subtleText,
    fontSize: 14,
    textAlign: 'center',
  },
});
