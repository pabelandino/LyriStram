import { useMemo } from 'react';
import { ScrollView, StyleSheet, Text, useWindowDimensions, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { CameraControlBar } from '@/components/CameraControlBar';
import { CameraLensPicker } from '@/components/CameraLensPicker';
import { CameraPreviewSurface } from '@/components/CameraPreviewSurface';
import { ConnectionStatusBadge } from '@/components/ConnectionStatusBadge';
import { DirectorPickerList } from '@/components/DirectorPickerList';
import { ManualDirectorConnect } from '@/components/ManualDirectorConnect';
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

  const { width, height } = useWindowDimensions();
  const landscape = width > height;
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

  const headerTitle =
    session.streamState === 'connected' && session.preferredDirector
      ? session.preferredDirector.displayName
      : 'EasyStream Cámara';

  const headerSubtitle =
    session.streamState === 'connected'
      ? `Esta cámara: ${identity.displayName}`
      : session.statusMessage;

  const controls = (
    <>
      {session.lastError ? <Text style={styles.error}>{session.lastError}</Text> : null}

      <Text style={styles.sectionTitle}>Cámara</Text>
      <CameraLensPicker
        cameras={session.cameras}
        activeKey={session.activeCameraKey}
        onSelect={session.selectCamera}
      />

      <Text style={styles.sectionTitle}>Directores en la red</Text>
      <DirectorPickerList
        directors={session.directors}
        selectedDirectorID={session.selectedDirectorID}
        onSelect={session.selectDirector}
      />

      <Text style={styles.sectionTitle}>Conexión manual</Text>
      <ManualDirectorConnect
        initialHost={session.preferredDirector?.host ?? ''}
        initialPort={session.preferredDirector ? String(session.preferredDirector.port) : ''}
        onConnect={session.connectManual}
      />

      <View style={styles.sectionSpacing}>
        <CameraControlBar
          isMuted={session.isMuted}
          canReconnect
          onToggleMute={session.toggleMute}
          onReconnect={session.reconnect}
        />
      </View>

      <Text style={styles.footerHint}>
        Compatible con el Director de EasyStream en iPad/iPhone (protocolo v1, WebRTC LAN).
      </Text>
    </>
  );

  return (
    <SafeAreaView style={styles.root}>
      <View style={landscape ? styles.landscape : styles.portrait}>
        <View style={landscape ? styles.stage : undefined}>
          <View style={styles.header}>
            <View style={styles.headerText}>
              <Text style={styles.title} numberOfLines={1}>
                {headerTitle}
              </Text>
              <Text style={styles.subtitle} numberOfLines={2}>
                {headerSubtitle}
              </Text>
            </View>
            <ConnectionStatusBadge
              label={badgeText}
              isLive={session.streamState === 'connected'}
            />
          </View>

          <View style={landscape ? styles.previewFlex : [styles.previewShell, { height: Math.min(280, height * 0.36) }]}>
            <CameraPreviewSurface stream={session.localStream} statusMessage={session.statusMessage} />
          </View>
        </View>

        <ScrollView
          style={landscape ? styles.side : styles.sheet}
          contentContainerStyle={styles.sheetContent}
        >
          {controls}
        </ScrollView>
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
  landscape: {
    flex: 1,
    flexDirection: 'row',
  },
  portrait: {
    flex: 1,
  },
  stage: {
    flex: 1.45,
    minWidth: 0,
  },
  side: {
    flex: 1,
    minWidth: 280,
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerText: {
    flex: 1,
    minWidth: 0,
    paddingRight: 12,
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
    marginHorizontal: 16,
    borderRadius: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: colors.border,
  },
  previewFlex: {
    flex: 1,
    marginHorizontal: 12,
    marginBottom: 12,
    borderRadius: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: colors.border,
  },
  sheet: {
    flex: 1,
  },
  sheetContent: {
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
