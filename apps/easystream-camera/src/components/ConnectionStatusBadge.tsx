import { memo } from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { colors } from '@/theme/colors';

type Props = {
  label: string;
  isLive: boolean;
};

function ConnectionStatusBadgeComponent({ label, isLive }: Props) {
  return (
    <View style={[styles.badge, isLive ? styles.live : styles.idle]}>
      <View style={[styles.dot, isLive ? styles.dotLive : styles.dotIdle]} />
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

export const ConnectionStatusBadge = memo(ConnectionStatusBadgeComponent);

const styles = StyleSheet.create({
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    borderWidth: 1,
  },
  live: {
    borderColor: colors.live,
    backgroundColor: '#2A1408',
  },
  idle: {
    borderColor: colors.border,
    backgroundColor: colors.panel,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  dotLive: {
    backgroundColor: colors.live,
  },
  dotIdle: {
    backgroundColor: colors.subtleText,
  },
  label: {
    color: colors.text,
    fontSize: 13,
    fontWeight: '600',
  },
});
