import { memo } from 'react';
import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';

import type { LocalCameraOption } from '@/services/webrtc/CameraStreamSession';
import { colors } from '@/theme/colors';

type Props = {
  cameras: LocalCameraOption[];
  activeKey: string | null;
  onSelect: (camera: LocalCameraOption) => void;
};

function CameraLensPickerComponent({ cameras, activeKey, onSelect }: Props) {
  if (cameras.length === 0) {
    return null;
  }

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.row}>
      {cameras.map((camera) => {
        const key = camera.deviceId || camera.facingMode;
        const selected = key === activeKey;
        return (
          <Pressable
            key={`${camera.label}-${key}`}
            onPress={() => onSelect(camera)}
            style={[styles.chip, selected && styles.chipSelected]}
          >
            <Text style={[styles.label, selected && styles.labelSelected]}>{camera.label}</Text>
          </Pressable>
        );
      })}
    </ScrollView>
  );
}

export const CameraLensPicker = memo(CameraLensPickerComponent);

const styles = StyleSheet.create({
  row: {
    gap: 8,
  },
  chip: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.panel,
    paddingHorizontal: 14,
    paddingVertical: 8,
  },
  chipSelected: {
    backgroundColor: colors.text,
    borderColor: colors.text,
  },
  label: {
    color: colors.text,
    fontSize: 13,
    fontWeight: '600',
  },
  labelSelected: {
    color: colors.background,
  },
});
