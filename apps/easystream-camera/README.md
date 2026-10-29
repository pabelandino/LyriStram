# EasyStream Camera (Android / Expo)

Android-only **camera mode** for EasyStream, built with **Expo prebuild**, **expo-router**, and native modules for **mDNS discovery**, **TCP signaling**, and **WebRTC** — wire-compatible with the iOS/macOS Director (`protocolVersion = 1`).

## Architecture

```
app/                 # expo-router entry
src/
  views/             # screen composition
  components/        # presentational UI (memoized)
  hooks/             # session, discovery, identity
  services/          # discovery, signaling, WebRTC (single responsibility)
  utils/             # codec, transport tiers, remote commands
  types/             # protocol mirrors of EasyStreamCore
  constants/         # Bonjour + TXT keys
```

## Requirements

- Node 20+
- Android device or emulator on the **same Wi‑Fi** as the iPad Director
- **Development build** (not Expo Go) because of WebRTC + TCP + Zeroconf native modules

## Setup

```bash
cd apps/easystream-camera
npm install
npx expo prebuild --platform android
npx expo run:android
```

## Protocol compatibility

| Feature | iOS camera | Android Expo camera |
|--------|------------|---------------------|
| Browse `_easystream-director._tcp` | ✅ | ✅ |
| Advertise `_easystream-camera._tcp` | ✅ | ✅ |
| TXT `deviceID`, `displayName`, `protocolVersion`, `platform`, `role` | ✅ | ✅ |
| TCP newline JSON signaling (`hello`, `offer`, `answer`, `ice`, `control`, `settingsState`) | ✅ | ✅ |
| WebRTC offer → Director answer (LAN, no STUN) | ✅ | ✅ |
| Remote commands (`setSwitcherAssignment`, `setMuted`, …) | ✅ | ✅ (core set) |

## Notes

- UI strings are **Spanish** (matches EasyStream Director).
- Use **prebuild** after changing native dependencies or `app.config.ts` plugins (icon/splash live under `assets/images/`; splash via `expo-splash-screen` in `app.config.ts`).
- Intercom (`_easystream-intercom._udp`) is not included in this camera-only app.

## Debugging (Metro / Logcat)

In development builds, logs are prefixed with `[EasyStream:<scope>]`:

| Scope | What to look for |
|-------|------------------|
| `discovery` | Director `host` / `port` from mDNS |
| `signaling` | `TX hello`, `TX offer`, **`RX answer`** (missing → iOS did not decode or reply) |
| `webrtc` | `Local offer ready`, `Remote answer applied`, `iceConnectionState` |
| `media` | `getUserMedia ok` — preview needs `videoTracks: 1` |

Filter Android logs:

```bash
adb logcat '*:S' ReactNativeJS:V
```

Typical stuck-on-“Negociando WebRTC” patterns:

1. **No `TX offer`** after `TCP connected` → camera permission / `getUserMedia` failed (`media` scope).
2. **`TX offer` but no `RX answer`** → Director TCP decode failed (check iOS Console for “Signaling decode skipped”) or wrong port/host.
3. **`RX answer` but `iceConnectionState: failed`** → LAN / ICE / firewall between devices.
