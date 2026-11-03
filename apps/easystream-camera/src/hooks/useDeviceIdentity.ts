import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Device from 'expo-device';
import { useEffect, useState } from 'react';

import { PLATFORM } from '@/constants/network';
import type { DeviceIdentity } from '@/types/protocol';
import {
  createEasyStreamDeviceID,
  isValidEasyStreamDeviceID,
  normalizeEasyStreamDeviceID,
} from '@/utils/deviceId';
import { log } from '@/utils/logger';

const STORAGE_KEY = 'com.easystream.deviceID';
const DISPLAY_NAME_KEY = 'com.easystream.displayName';

async function loadOrCreateDeviceID(): Promise<string> {
  const stored = await AsyncStorage.getItem(STORAGE_KEY);
  if (stored && isValidEasyStreamDeviceID(stored)) {
    return normalizeEasyStreamDeviceID(stored);
  }

  if (stored) {
    log.session.warn('Replacing invalid stored deviceID (iOS requires UUID)', { stored });
  }

  const created = normalizeEasyStreamDeviceID(createEasyStreamDeviceID());
  await AsyncStorage.setItem(STORAGE_KEY, created);
  return created;
}

async function loadOrCreateDisplayName(): Promise<string> {
  const stored = await AsyncStorage.getItem(DISPLAY_NAME_KEY);
  if (stored?.trim()) {
    return stored.trim();
  }

  const deviceName = Device.deviceName?.trim();
  const modelName = Device.modelName?.trim();
  const name = deviceName || modelName || 'Android';
  await AsyncStorage.setItem(DISPLAY_NAME_KEY, name);
  return name;
}

export function useDeviceIdentity() {
  const [identity, setIdentity] = useState<DeviceIdentity | null>(null);

  useEffect(() => {
    let cancelled = false;

    void (async () => {
      const [deviceID, displayName] = await Promise.all([
        loadOrCreateDeviceID(),
        loadOrCreateDisplayName(),
      ]);
      if (cancelled) {
        return;
      }
      setIdentity({
        deviceID,
        displayName,
        platform: PLATFORM.android,
      });
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  return identity;
}
