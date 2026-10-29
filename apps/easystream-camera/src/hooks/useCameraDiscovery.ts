import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import {
  acquireDiscoverySubscriber,
  releaseDiscoverySubscriber,
  sharedDiscoveryService,
} from '@/services/discovery/EasyStreamDiscoveryService';
import type { DeviceIdentity, DiscoveredDirector } from '@/types/protocol';

export function useCameraDiscovery(identity: DeviceIdentity | null) {
  const deviceID = identity?.deviceID ?? null;
  const identityRef = useRef<DeviceIdentity | null>(null);
  identityRef.current = identity;

  const [directors, setDirectors] = useState<DiscoveredDirector[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!deviceID || !identityRef.current) {
      return;
    }

    acquireDiscoverySubscriber();
    const service = sharedDiscoveryService();
    const snapshot = identityRef.current;

    service.start(snapshot, {
      onDirectorsChanged: (list) => {
        setDirectors(list);
      },
      onError: setError,
    });

    return () => {
      service.detachListener();
      releaseDiscoverySubscriber();
    };
  }, [deviceID]);

  const refresh = useCallback(() => {
    setError(null);
  }, []);

  return useMemo(
    () => ({
      directors,
      error,
      refresh,
    }),
    [directors, error, refresh],
  );
}
