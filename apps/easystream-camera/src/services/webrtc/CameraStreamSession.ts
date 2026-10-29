import {
  mediaDevices,
  RTCIceCandidate,
  RTCPeerConnection,
  RTCSessionDescription,
  type MediaStream,
  type RTCIceCandidate as RtcIceCandidateType,
} from 'react-native-webrtc';

import type { DeviceIdentity, SignalingMessage, StreamConnectionState } from '@/types/protocol';
import { TcpSignalingClient } from '@/services/signaling/TcpSignalingClient';
import { createEasyStreamDeviceID, normalizeEasyStreamDeviceID } from '@/utils/deviceId';
import { log } from '@/utils/logger';
import type { TransportProfile } from '@/utils/transportProfile';

function peerConnectionConfig() {
  return {
    iceServers: [],
    bundlePolicy: 'max-bundle' as const,
    rtcpMuxPolicy: 'require' as const,
  };
}

function normalizedSessionID(sessionID: string): string {
  return normalizeEasyStreamDeviceID(sessionID);
}

export type CameraStreamListener = {
  onConnectionState: (state: StreamConnectionState) => void;
  onLocalStream: (stream: MediaStream | null) => void;
  onSignalingMessage: (message: SignalingMessage) => void;
  onError: (message: string) => void;
};

export class CameraStreamSession {
  private sessionID = '';
  private peer: RTCPeerConnection | null = null;
  private localStream: MediaStream | null = null;
  private signaling = new TcpSignalingClient();
  private listener: CameraStreamListener | null = null;
  private hasCreatedOffer = false;
  private transportProfile: TransportProfile | null = null;

  getLocalStream(): MediaStream | null {
    return this.localStream;
  }

  async prepareLocalMedia(): Promise<MediaStream> {
    if (this.localStream) {
      log.media.debug('Reusing existing local MediaStream');
      return this.localStream;
    }

    log.media.info('getUserMedia start');
    const stream = await mediaDevices.getUserMedia({
      audio: true,
      video: {
        facingMode: 'environment',
        width: 1280,
        height: 720,
        frameRate: 30,
      },
    });

    this.localStream = stream;
    log.media.info('getUserMedia ok', {
      streamId: stream.id,
      videoTracks: stream.getVideoTracks().length,
      audioTracks: stream.getAudioTracks().length,
      videoEnabled: stream.getVideoTracks()[0]?.enabled ?? false,
    });
    this.listener?.onLocalStream(stream);
    return stream;
  }

  setAudioMuted(muted: boolean): void {
    this.localStream?.getAudioTracks().forEach((track) => {
      track.enabled = !muted;
    });
  }

  updateTransportProfile(profile: TransportProfile): void {
    this.transportProfile = profile;
    const videoTrack = this.localStream?.getVideoTracks()[0];
    if (!videoTrack) {
      return;
    }

    videoTrack.applyConstraints({
      width: profile.width,
      height: profile.height,
      frameRate: profile.frameRate,
    }).catch(() => undefined);
  }

  resetConnection(): void {
    this.signaling.disconnect();
    this.peer?.close();
    this.peer = null;
    this.hasCreatedOffer = false;
  }

  connectToDirector(
    host: string,
    port: number,
    identity: DeviceIdentity,
    listener: CameraStreamListener,
  ): void {
    this.resetConnection();
    this.listener = listener;
    this.sessionID = createEasyStreamDeviceID();
    this.hasCreatedOffer = false;
    log.session.info('connectToDirector', {
      host,
      port,
      sessionID: this.sessionID,
      deviceID: identity.deviceID,
    });
    listener.onConnectionState('connecting');

    this.signaling.connect(host, port, (event) => {
      switch (event.type) {
        case 'connected':
          listener.onConnectionState('signaling');
          this.signaling.send({
            type: 'hello',
            deviceID: normalizeEasyStreamDeviceID(identity.deviceID),
            displayName: identity.displayName,
            role: 'camera',
          });
          void this.startOffer();
          break;
        case 'message':
          void this.handleSignalingMessage(event.message);
          listener.onSignalingMessage(event.message);
          break;
        case 'disconnected':
          log.session.warn('Signaling disconnected');
          listener.onConnectionState('disconnected');
          break;
        case 'failed':
          log.session.error('Signaling failed', { error: event.error });
          listener.onConnectionState('failed');
          listener.onError(event.error);
          break;
      }
    });
  }

  private async startOffer(): Promise<void> {
    if (this.hasCreatedOffer) {
      return;
    }
    this.hasCreatedOffer = true;
    log.webrtc.info('startOffer');

    try {
      const stream = await this.prepareLocalMedia();
      const pc = new RTCPeerConnection(peerConnectionConfig());
      this.peer = pc;

      stream.getTracks().forEach((track) => {
        log.webrtc.debug('addTrack', { kind: track.kind, id: track.id, enabled: track.enabled });
        pc.addTrack(track, stream);
      });

      let iceSent = 0;
      pc.onicecandidate = (rawEvent) => {
        const event = rawEvent as { candidate?: RtcIceCandidateType | null };
        if (!event.candidate) {
          log.webrtc.info('ICE gathering complete', { iceSent });
          return;
        }
        iceSent += 1;
        this.signaling.send({
          type: 'ice',
          sessionID: normalizedSessionID(this.sessionID),
          candidate: event.candidate.candidate,
          sdpMid: event.candidate.sdpMid,
          sdpMLineIndex: event.candidate.sdpMLineIndex,
        });
      };

      pc.onicegatheringstatechange = () => {
        log.webrtc.debug('iceGatheringState', { state: pc.iceGatheringState });
      };

      pc.oniceconnectionstatechange = () => {
        log.webrtc.info('iceConnectionState', { state: pc.iceConnectionState });
      };

      pc.onsignalingstatechange = () => {
        log.webrtc.debug('signalingState', { state: pc.signalingState });
      };

      pc.onconnectionstatechange = () => {
        const state = pc.connectionState;
        log.webrtc.info('connectionState', { state });
        if (state === 'connected') {
          this.listener?.onConnectionState('connected');
        } else if (state === 'failed') {
          this.listener?.onConnectionState('failed');
        } else if (state === 'disconnected') {
          this.listener?.onConnectionState('disconnected');
        }
      };

      if (this.transportProfile) {
        this.updateTransportProfile(this.transportProfile);
      }

      const offer = await pc.createOffer({
        offerToReceiveAudio: false,
        offerToReceiveVideo: false,
      });

      if (!offer.sdp?.trim()) {
        throw new Error('WebRTC createOffer returned empty SDP');
      }

      // RN WebRTC requires setLocalDescription with the native offer object unchanged.
      await pc.setLocalDescription(offer);

      const outboundSdp = offer.sdp;

      log.webrtc.info('Local offer ready', {
        sessionID: this.sessionID,
        sdpChars: outboundSdp.length,
        signalingState: pc.signalingState,
        hasH264: /H264/i.test(outboundSdp),
      });

      this.signaling.send({
        type: 'offer',
        sessionID: normalizedSessionID(this.sessionID),
        sdp: outboundSdp,
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'WebRTC offer failed';
      log.webrtc.error('startOffer failed', { message });
      this.listener?.onError(message);
      this.listener?.onConnectionState('failed');
    }
  }

  private async handleSignalingMessage(message: SignalingMessage): Promise<void> {
    const pc = this.peer;
    if (!pc) {
      log.webrtc.warn('Signaling message ignored (no peer)', { type: message.type });
      return;
    }

    if (message.type === 'answer') {
      if (normalizedSessionID(message.sessionID) !== normalizedSessionID(this.sessionID)) {
        log.webrtc.warn('Answer sessionID mismatch', {
          expected: this.sessionID,
          received: message.sessionID,
        });
        return;
      }
      try {
        await pc.setRemoteDescription(new RTCSessionDescription({ type: 'answer', sdp: message.sdp }));
        log.webrtc.info('Remote answer applied', {
          signalingState: pc.signalingState,
          sdpChars: message.sdp.length,
        });
      } catch (error) {
        log.webrtc.error('setRemoteDescription(answer) failed', {
          error: error instanceof Error ? error.message : String(error),
        });
        this.listener?.onError('No se pudo aplicar la respuesta WebRTC del Director');
      }
      return;
    }

    if (message.type === 'ice') {
      if (normalizedSessionID(message.sessionID) !== normalizedSessionID(this.sessionID)) {
        log.webrtc.debug('ICE ignored (session mismatch)', {
          expected: this.sessionID,
          received: message.sessionID,
        });
        return;
      }
      try {
        await pc.addIceCandidate(
          new RTCIceCandidate({
            candidate: message.candidate,
            sdpMid: message.sdpMid ?? undefined,
            sdpMLineIndex: message.sdpMLineIndex ?? undefined,
          }),
        );
        log.webrtc.debug('Remote ICE candidate added');
      } catch (error) {
        log.webrtc.warn('addIceCandidate failed', {
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }
  }

  async reconnectOffer(): Promise<void> {
    this.peer?.close();
    this.peer = null;
    this.hasCreatedOffer = false;
    this.listener?.onConnectionState('signaling');
    await this.startOffer();
  }

  sendSettingsState(deviceID: string, settings: import('@/types/protocol').RemoteCameraSettings): void {
    this.signaling.send({ type: 'settingsState', deviceID, settings });
  }

  sendSignaling(message: SignalingMessage): void {
    this.signaling.send(message);
  }

  disconnect(): void {
    const listener = this.listener;
    this.listener = null;
    this.resetConnection();
    this.localStream?.getTracks().forEach((track) => track.stop());
    this.localStream = null;
    listener?.onLocalStream(null);
    listener?.onConnectionState('idle');
  }
}
