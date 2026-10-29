import { useMemo } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { CameraControlBar } from '@/components/CameraControlBar';
import { CameraPreviewSurface } from '@/components/CameraPreviewSurface';
import { ConnectionStatusBadge } from '@/components/ConnectionStatusBadge';
import { DirectorPickerList } from '@/components/DirectorPickerList';
import { useCameraDiscovery } from '@/hooks/useCameraDiscovery';
import { useCameraSession } from '@/hooks/useCameraSession';
import { useDeviceIdentity } from '@/hooks/useDeviceIdentity';
import { colors } from '@/theme/colors';
import type { StreamConnectionState } from '@/types/protocol';

function badgeLabel(state: StreamConnectionState, fallback: string): string {
  switch (state) {
    case 'connected':
      return 'En vivo';
    case 'connecting':
    case 'signaling':
      return 'Conectando';
    default:
      return fallback;
  }
}

export function CameraSessionView() {
  const identity = useDeviceIdentity();
  const { directors } = useCameraDiscovery(identity);
  const session = useCameraSession({ identity, directors });

  const badgeText = useMemo(
    () => badgeLabel(session.streamState, session.statusMessage),
    [session.statusMessage, session.streamState],
  );

  if (!identity) {
    return (
      <SafeAreaView style={styles.root}>
        <Text style={styles.loading}>Preparando identidad del dispositivo…</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.root}>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>EasyStream Cámara</Text>
          <Text style={styles.subtitle}>{session.statusMessage}</Text>
        </View>
        <ConnectionStatusBadge
          label={badgeText}
          isLive={session.streamState === 'connected'}
        />
      </View>

      <View style={styles.previewShell}>
        <CameraPreviewSurface stream={session.localStream} statusMessage={session.statusMessage} />
      </View>

      <View style={styles.sheet}>
        {session.lastError ? <Text style={styles.error}>{session.lastError}</Text> : null}

        <Text style={styles.sectionTitle}>Directores en la red</Text>
        <DirectorPickerList
          directors={session.directors}
          selectedDirectorID={session.selectedDirectorID}
          onSelect={session.selectDirector}
        />

        <View style={styles.sectionSpacing}>
          <CameraControlBar
            isMuted={session.isMuted}
            canReconnect={session.streamState !== 'connecting' && session.streamState !== 'signaling'}
            onToggleMute={session.toggleMute}
            onReconnect={session.reconnect}
          />
        </View>

        <Text style={styles.footerHint}>
          Compatible con el Director de EasyStream en iPad/iPhone (protocolo v1, WebRTC LAN).
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.background,
  },
  loading: {
    color: colors.text,
    padding: 24,
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 12,
  },
  title: {
    color: colors.text,
    fontSize: 20,
    fontWeight: '700',
  },
  subtitle: {
    color: colors.subtleText,
    fontSize: 13,
    marginTop: 2,
    maxWidth: 240,
  },
  previewShell: {
    height: 280,
    marginHorizontal: 16,
    borderRadius: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: colors.border,
  },
  sheet: {
    flex: 1,
    padding: 16,
    gap: 12,
    paddingBottom: 32,
  },
  sectionTitle: {
    color: colors.text,
    fontSize: 15,
    fontWeight: '600',
    marginTop: 8,
  },
  sectionSpacing: {
    marginTop: 8,
  },
  error: {
    color: colors.danger,
    fontSize: 13,
  },
  footerHint: {
    color: colors.subtleText,
    fontSize: 12,
    lineHeight: 18,
    marginTop: 8,
  },
});
