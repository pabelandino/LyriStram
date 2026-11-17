import { memo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { colors } from '@/theme/colors';
import type { DiscoveredDirector } from '@/types/protocol';

type Props = {
  directors: DiscoveredDirector[];
  selectedDirectorID: string | null;
  onSelect: (director: DiscoveredDirector) => void;
};

function DirectorPickerListComponent({ directors, selectedDirectorID, onSelect }: Props) {
  if (directors.length === 0) {
    return (
      <View style={styles.empty}>
        <Text style={styles.emptyText}>Buscando directores en la red local…</Text>
      </View>
    );
  }

  return (
    <View style={styles.list}>
      {directors.map((item) => {
        const selected = item.id === selectedDirectorID;
        return (
          <Pressable
            key={item.id}
            onPress={() => onSelect(item)}
            style={[styles.row, selected && styles.rowSelected]}
          >
            <Text style={styles.title}>{item.displayName}</Text>
            <Text style={styles.subtitle}>
              {item.host}:{item.port}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

export const DirectorPickerList = memo(DirectorPickerListComponent);

const styles = StyleSheet.create({
  list: {
    gap: 8,
  },
  row: {
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.panel,
    borderRadius: 12,
    padding: 14,
  },
  rowSelected: {
    borderColor: colors.accent,
  },
  title: {
    color: colors.text,
    fontSize: 16,
    fontWeight: '600',
  },
  subtitle: {
    color: colors.subtleText,
    fontSize: 12,
    marginTop: 4,
  },
  empty: {
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.panel,
  },
  emptyText: {
    color: colors.subtleText,
    fontSize: 14,
  },
});
