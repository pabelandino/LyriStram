import { memo, useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

import { colors } from '@/theme/colors';

type Props = {
  initialHost: string;
  initialPort: string;
  onConnect: (host: string, port: number) => void;
};

function ManualDirectorConnectComponent({ initialHost, initialPort, onConnect }: Props) {
  const [host, setHost] = useState(initialHost);
  const [port, setPort] = useState(initialPort);

  useEffect(() => {
    if (initialHost) {
      setHost(initialHost);
    }
  }, [initialHost]);

  useEffect(() => {
    if (initialPort) {
      setPort(initialPort);
    }
  }, [initialPort]);

  return (
    <View style={styles.box}>
      <Text style={styles.hint}>
        Si no entra sola, escribe la IP y el puerto que muestra el Director.
      </Text>
      <TextInput
        value={host}
        onChangeText={setHost}
        placeholder="IP del Director"
        placeholderTextColor={colors.subtleText}
        autoCapitalize="none"
        autoCorrect={false}
        keyboardType="numbers-and-punctuation"
        style={styles.input}
      />
      <TextInput
        value={port}
        onChangeText={setPort}
        placeholder="Puerto"
        placeholderTextColor={colors.subtleText}
        keyboardType="number-pad"
        style={styles.input}
      />
      <Pressable
        style={styles.button}
        onPress={() => onConnect(host.trim(), Number(port))}
      >
        <Text style={styles.buttonLabel}>Conectar con esta IP</Text>
      </Pressable>
    </View>
  );
}

export const ManualDirectorConnect = memo(ManualDirectorConnectComponent);

const styles = StyleSheet.create({
  box: {
    gap: 8,
  },
  hint: {
    color: colors.subtleText,
    fontSize: 12,
    lineHeight: 18,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.panel,
    color: colors.text,
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
  },
  button: {
    borderRadius: 12,
    backgroundColor: colors.accent,
    paddingVertical: 12,
    alignItems: 'center',
  },
  buttonLabel: {
    color: '#041014',
    fontSize: 14,
    fontWeight: '700',
  },
});
