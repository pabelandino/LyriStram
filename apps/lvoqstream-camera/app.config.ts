import type { ExpoConfig } from 'expo/config';

const config: ExpoConfig = {
  name: 'Lvoq Stream',
  slug: 'lvoqstream-camera',
  version: '1.0.0',
  orientation: 'default',
  icon: './assets/images/icon.png',
  scheme: 'lvoqstreamcamera',
  userInterfaceStyle: 'dark',
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.lvoqstream.camera',
  },
  android: {
    package: 'com.lvoqstream.camera',
    adaptiveIcon: {
      backgroundColor: '#FFFFFF',
      foregroundImage: './assets/images/android-icon-foreground.png',
      backgroundImage: './assets/images/android-icon-background.png',
      monochromeImage: './assets/images/android-icon-monochrome.png',
    },
    permissions: [
      'android.permission.CAMERA',
      'android.permission.RECORD_AUDIO',
      'android.permission.INTERNET',
      'android.permission.ACCESS_NETWORK_STATE',
      'android.permission.ACCESS_WIFI_STATE',
      'android.permission.CHANGE_WIFI_MULTICAST_STATE',
    ],
  },
  plugins: [
    'expo-router',
    [
      'expo-splash-screen',
      {
        image: './assets/images/splash-icon.png',
        imageWidth: 220,
        resizeMode: 'contain',
        backgroundColor: '#FFFFFF',
      },
    ],
    'expo-dev-client',
    [
      'expo-camera',
      {
        cameraPermission: 'Lvoq Stream necesita la cámara para enviar video al director.',
        microphonePermission: 'Lvoq Stream necesita el micrófono para enviar audio al director.',
        recordAudioAndroid: true,
      },
    ],
    '@config-plugins/react-native-webrtc',
  ],
  experiments: {
    typedRoutes: true,
  },
  extra: {
    eas: {
      projectId: 'lvoqstream-camera-local',
    },
  },
};

export default config;
