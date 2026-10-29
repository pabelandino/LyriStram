import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect, useState } from 'react';
import { Platform } from 'react-native';

import { PLATFORM } from '@/constants/network';
import type { DeviceIdentity } from '@/types/protocol';
import {
  createEasyStreamDeviceID,
  isValidEasyStreamDeviceID,
  normalizeEasyStreamDeviceID,
} from '@/utils/deviceId';
import { log } from '@/utils/logger';

const STORAGE_KEY = 'com.easystream.deviceID';

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

function defaultDisplayName(): string {
  const model =
    (Platform.constants as { Model?: string } | undefined)?.Model ?? 'Android';
  return `EasyStream ${model}`;
}

export function useDeviceIdentity() {
  const [identity, setIdentity] = useState<DeviceIdentity | null>(null);

  useEffect(() => {
    let cancelled = false;

    void (async () => {
      const deviceID = await loadOrCreateDeviceID();
      if (cancelled) {
        return;
      }
      setIdentity({
        deviceID,
        displayName: defaultDisplayName(),
        platform: PLATFORM.android,
      });
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  return identity;
}
