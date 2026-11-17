import { memo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { colors } from '@/theme/colors';

type Props = {
  isMuted: boolean;
  canReconnect: boolean;
  onToggleMute: () => void;
  onReconnect: () => void;
};

function CameraControlBarComponent({ isMuted, canReconnect, onToggleMute, onReconnect }: Props) {
  return (
    <View style={styles.bar}>
      <Pressable style={styles.button} onPress={onToggleMute}>
        <Text style={styles.buttonLabel}>{isMuted ? 'Activar audio' : 'Silenciar'}</Text>
      </Pressable>
      <Pressable
        style={[styles.button, !canReconnect && styles.buttonDisabled]}
        disabled={!canReconnect}
        onPress={onReconnect}
      >
        <Text style={styles.buttonLabel}>Reconectar</Text>
      </Pressable>
    </View>
  );
}

export const CameraControlBar = memo(CameraControlBarComponent);

const styles = StyleSheet.create({
  bar: {
    flexDirection: 'row',
    gap: 10,
  },
  button: {
    flex: 1,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.panel,
    paddingVertical: 12,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.45,
  },
  buttonLabel: {
    color: colors.text,
    fontSize: 14,
    fontWeight: '600',
  },
});
