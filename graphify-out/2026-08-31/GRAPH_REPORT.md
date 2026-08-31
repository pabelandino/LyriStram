# Graph Report - EasyStream  (2026-08-31)

## Corpus Check
- 89 files · ~27,612 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1441 nodes · 3183 edges · 67 communities (64 shown, 3 thin omitted)
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 237 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a86c6ca8`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- H264VideoEncoder
- RTMPPublisher
- WebRTCVideoView
- FacebookAuthError
- BroadcastStreamPublisher
- SignalingMessage
- PlayoutTapAudioDevice
- Foundation
- DirectorStreamReceiver
- CameraSessionViewModel
- DirectorSessionViewModel
- UIKit
- .persistAndSend
- CameraSourceID
- CameraCaptureService
- StreamDestination
- SignalingChannel
- DiscoveryService
- ProgramAudioEncoderPipeline
- Identifiable
- DirectorSessionView
- AppRole
- ConnectedCameraSource
- DiscoveredDevice
- CameraStreamClient
- WhiteBalanceModeOption
- .apply
- Sendable
- SwitchTransition
- CameraLensKind
- DirectorRemoteControlsView
- FacebookGraphClient
- FacebookSession
- .startOffer
- CameraSessionView
- StreamConnectionState
- DeviceIdentity
- PeerConnectionDelegateBridge
- CodingKeys
- CameraClientControlsView
- SwiftUI
- DirectorSessionViewModel.swift
- EasyStreamUITests
- RemoteCameraSettings
- FacebookConfiguration
- RTCPeerConnection
- .current
- Error
- PackageDescription
- PreviewMonitorLayoutMode
- Testing
- .application
- DiscoveryEvent
- Event
- WebRTCProgramFrameSink
- View
- Event
- .decode
- FacebookLivePanel
- DiscoveryViews.swift
- .reportSettingsState
- .save
- RemoteWhiteBalanceOption
- MessageType
- .handleOffer
- WebRTCConfiguration
- CameraPermissionStatus

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 79 edges
2. `CameraSourceID` - 62 edges
3. `EasyStreamCore` - 42 edges
4. `CameraCaptureService` - 38 edges
5. `DirectorSessionView` - 37 edges
6. `DiscoveryService` - 37 edges
7. `PlayoutTapAudioDevice` - 34 edges
8. `AppRole` - 33 edges
9. `CameraSessionViewModel` - 32 edges
10. `CameraLensKind` - 28 edges

## Surprising Connections (you probably didn't know these)
- `.body` --calls--> `ConnectionStatusBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift
- `.body` --calls--> `LocalNetworkPermissionView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift
- `.sessionContent` --calls--> `CameraClientControlsView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraClientControlsView.swift
- `.sessionContent` --calls--> `CameraPreviewView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/VideoPreviewViews.swift
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift

## Import Cycles
- None detected.

## Communities (67 total, 3 thin omitted)

### Community 0 - "H264VideoEncoder"
Cohesion: 0.05
Nodes (42): OSStatus, EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data, Int, Int32 (+34 more)

### Community 1 - "RTMPPublisher"
Cohesion: 0.08
Nodes (27): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, RTMPStreamError, commandFailed, connectionFailed (+19 more)

### Community 2 - "WebRTCVideoView"
Cohesion: 0.07
Nodes (32): AVCaptureVideoPreviewLayer, CGRect, Context, NSCoder, NSSize, NSView, NSViewRepresentable, boundedSize() (+24 more)

### Community 3 - "FacebookAuthError"
Cohesion: 0.06
Nodes (36): CheckedContinuation, Notification, NSRect, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession, Bool (+28 more)

### Community 4 - "BroadcastStreamPublisher"
Cohesion: 0.06
Nodes (31): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+23 more)

### Community 5 - "SignalingMessage"
Cohesion: 0.14
Nodes (12): Decoder, Encoder, SignalingMessage, answer, control, hello, ice, offer (+4 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (26): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+18 more)

### Community 7 - "Foundation"
Cohesion: 0.16
Nodes (7): CoreMedia, CoreVideo, EasyStreamCore, Foundation, Network, StreamDestinationFacebookParsing, VideoToolbox

### Community 8 - "DirectorStreamReceiver"
Cohesion: 0.15
Nodes (11): DirectorStreamReceiver, SessionContext, AsyncStream, Int32, NWConnection, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection (+3 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.20
Nodes (10): .body, CameraSessionViewModel, .isMuted, AVCaptureSession, Bool, Never, String, Task (+2 more)

### Community 10 - "DirectorSessionViewModel"
Cohesion: 0.17
Nodes (10): DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing, .programDisplayTrack, .selectedFacebookPageID, Never, Task (+2 more)

### Community 11 - "UIKit"
Cohesion: 0.13
Nodes (8): AppTrackingTransparency, AVFoundation, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin, facebookSecureStreamURLParsing(), UIKit

### Community 12 - ".persistAndSend"
Cohesion: 0.26
Nodes (7): .inspectorPanel, .inspectorSection, Bool, Double, Float, String, Void

### Community 13 - "CameraSourceID"
Cohesion: 0.13
Nodes (15): EasyStreamSwitcher, CameraSourceID, .id, UUID, Set, SwitcherEngine, .state, SwitcherEvent (+7 more)

### Community 14 - "CameraCaptureService"
Cohesion: 0.16
Nodes (9): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, NSObjectProtocol, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer (+1 more)

### Community 15 - "StreamDestination"
Cohesion: 0.11
Nodes (17): .streamDestination, LocalizedError, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL (+9 more)

### Community 16 - "SignalingChannel"
Cohesion: 0.19
Nodes (11): Event, connected, disconnected, failed, message, SignalingChannel, AsyncStream, Bool (+3 more)

### Community 17 - "DiscoveryService"
Cohesion: 0.14
Nodes (16): NWBrowser, NWListener, EasyStreamLog, DiscoveryService, .discoveredDevices, Bool, NWConnection, NWEndpoint (+8 more)

### Community 18 - "ProgramAudioEncoderPipeline"
Cohesion: 0.07
Nodes (34): AVAudioConverter, AACAudioEncoder, AsyncStream, AVAudioFormat, Data, Double, Int64, UInt32 (+26 more)

### Community 19 - "Identifiable"
Cohesion: 0.15
Nodes (14): CodingKey, Identifiable, CodingKeys, accessToken, id, name, secureStreamURL, FacebookGraphError (+6 more)

### Community 20 - "DirectorSessionView"
Cohesion: 0.07
Nodes (30): CGFloat, .sessionContent, DirectorSessionView, .canTake, .compactLayout, .directorWorkspaceLayout, .mainSwitcherArea, .previewGrid (+22 more)

### Community 21 - "AppRole"
Cohesion: 0.08
Nodes (26): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+18 more)

### Community 22 - "ConnectedCameraSource"
Cohesion: 0.21
Nodes (8): .keyboardShortcuts, ConnectedCameraSource, .outgoingProgramVideoTrack, .previewVideoTrack, .programVideoTrack, Int, RTCAudioTrack, RTCVideoTrack

### Community 23 - "DiscoveredDevice"
Cohesion: 0.10
Nodes (21): AppRoute, roleSelection, session, Hashable, Hasher, BonjourServiceType, camera, director (+13 more)

### Community 24 - "CameraStreamClient"
Cohesion: 0.15
Nodes (9): CameraStreamClient, .isAudioMuted, .localVideoTrack, AsyncStream, Bool, RTCAudioTrack, RTCPeerConnection, RTCVideoTrack (+1 more)

### Community 25 - "WhiteBalanceModeOption"
Cohesion: 0.21
Nodes (11): CameraImagingState, Double, Float, WhiteBalanceModeOption, auto, cool, .displayName, .id (+3 more)

### Community 26 - ".apply"
Cohesion: 0.38
Nodes (3): Double, Float, RemoteCameraCommandExecutor

### Community 27 - "Sendable"
Cohesion: 0.36
Nodes (10): Codable, Equatable, AvailableCameraLens, PreviewMonitorAppearance, PreviewMonitorOverlayOptions, PreviewMonitorRGBColor, PreviewMonitorSettings, Bool (+2 more)

### Community 28 - "SwitchTransition"
Cohesion: 0.12
Nodes (10): .takeBar, .takeSection, .transitionSection, .selectedTransition, TimeInterval, SwitcherSnapshot, SwitchTransition, TransitionPreferencesStore (+2 more)

### Community 29 - "CameraLensKind"
Cohesion: 0.20
Nodes (10): CameraLensKind, .deviceType, .displayName, front, .id, .position, telephoto, ultraWide (+2 more)

### Community 30 - "DirectorRemoteControlsView"
Cohesion: 0.06
Nodes (48): .previewGridSection, .programVideoContent, .switcherDetailColumn, RemoteLensOption, .displayName, front, .id, telephoto (+40 more)

### Community 31 - "FacebookGraphClient"
Cohesion: 0.24
Nodes (11): Decodable, FacebookGraphClient, GraphAPIErrorResponse, GraphError, Data, String, URL, T (+3 more)

### Community 32 - "FacebookSession"
Cohesion: 0.15
Nodes (9): .destinationPanel, .destinationSection, FacebookLiveService, String, FacebookPage, FacebookSession, .isSignedIn, Bool (+1 more)

### Community 34 - "CameraSessionView"
Cohesion: 0.18
Nodes (12): CameraSessionView, .cameraPermissionView, .exposureBinding, .lensLabel, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, Binding (+4 more)

### Community 35 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.14
Nodes (16): CaseIterable, DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac (+8 more)

### Community 37 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 38 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 39 - "CameraClientControlsView"
Cohesion: 0.21
Nodes (13): ClosedRange, CameraClientControlsView, .body, .exposureControl, .lensPicker, .muteControl, .whiteBalancePicker, .zoomControl (+5 more)

### Community 40 - "SwiftUI"
Cohesion: 0.18
Nodes (4): EasyStreamCameraCapture, EasyStreamUIComponents, SwiftUI, WebRTC

### Community 41 - "DirectorSessionViewModel.swift"
Cohesion: 0.18
Nodes (7): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamTransport, EasyStreamVideoPipeline, Observation, OSLog

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "RemoteCameraSettings"
Cohesion: 0.26
Nodes (12): RemoteCameraCommand, applySavedSettings, setExposureBias, setLens, setMuted, setWhiteBalance, setZoom, RemoteCameraSettings (+4 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "RTCPeerConnection"
Cohesion: 0.47
Nodes (3): RTCPeerConnection, RTCMediaConstraints, RTCSessionDescription

### Community 46 - ".current"
Cohesion: 0.29
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "Error"
Cohesion: 0.11
Nodes (18): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+10 more)

### Community 49 - "PreviewMonitorLayoutMode"
Cohesion: 0.20
Nodes (10): PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5, .id (+2 more)

### Community 50 - "Testing"
Cohesion: 0.18
Nodes (3): EasyStreamTests, deviceIdentityPersistsID(), Testing

### Community 51 - ".application"
Cohesion: 0.09
Nodes (19): AccessToken, App, Any, Bool, UIApplication, URL, EasyStreamApp, .body (+11 more)

### Community 52 - "DiscoveryEvent"
Cohesion: 0.15
Nodes (13): DiscoveryViewModel, Never, String, Task, Void, DiscoveryEvent, advertisingFailed, browsingFailed (+5 more)

### Community 53 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 54 - "WebRTCProgramFrameSink"
Cohesion: 0.12
Nodes (14): AppDelegate, NSObject, CVPixelBuffer, Int64, CGSize, CMTime, CVPixelBuffer, Sendable (+6 more)

### Community 55 - "View"
Cohesion: 0.05
Nodes (50): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, .totalPages, Int, Never, String (+42 more)

### Community 56 - "Event"
Cohesion: 0.22
Nodes (7): Event, connectionState, failed, localVideoTrackReady, Int32, RTCIceCandidate, String

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "FacebookLivePanel"
Cohesion: 0.33
Nodes (8): FacebookLivePanel, .body, .pageSelection, .signedInContent, Binding, Bool, String, Void

### Community 59 - "DiscoveryViews.swift"
Cohesion: 0.25
Nodes (3): AppKit, PlatformSettings, WebKit

### Community 61 - ".save"
Cohesion: 0.36
Nodes (3): CameraSettingsStore, UUID, Void

### Community 62 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 63 - "MessageType"
Cohesion: 0.29
Nodes (7): MessageType, answer, control, hello, ice, offer, settingsState

### Community 64 - ".handleOffer"
Cohesion: 0.52
Nodes (3): RTCPeerConnection, RTCMediaConstraints, RTCSessionDescription

### Community 65 - "WebRTCConfiguration"
Cohesion: 0.43
Nodes (3): WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 66 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

## Knowledge Gaps
- **273 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.cameraPermissionView`, `.lensLabel` (+268 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `FacebookSession`, `H264VideoEncoder`, `BroadcastStreamPublisher`, `DirectorStreamReceiver`, `DirectorSessionViewModel.swift`, `.persistAndSend`, `CameraSourceID`, `StreamDestination`, `DiscoveryService`, `ProgramAudioEncoderPipeline`, `DirectorSessionView`, `ConnectedCameraSource`, `DiscoveredDevice`, `SwitchTransition`?**
  _High betweenness centrality (0.139) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `RTMPPublisher`, `FacebookAuthError`, `UIKit`, `CameraSourceID`, `StreamDestination`, `ProgramAudioEncoderPipeline`, `Identifiable`, `DirectorSessionView`, `AppRole`, `DiscoveredDevice`, `Sendable`, `SwitchTransition`, `FacebookSession`, `StreamConnectionState`, `DeviceIdentity`, `SwiftUI`, `DirectorSessionViewModel.swift`, `FacebookConfiguration`, `View`, `DiscoveryViews.swift`?**
  _High betweenness centrality (0.109) - this node is a cross-community bridge._
- **Why does `CameraSourceID` connect `CameraSourceID` to `.handleOffer`, `DirectorStreamReceiver`, `CameraSessionViewModel`, `DirectorSessionViewModel`, `.persistAndSend`, `SwitchTransition`, `Identifiable`, `DirectorSessionView`, `DiscoveredDevice`, `ConnectedCameraSource`, `View`, `Event`, `Sendable`, `.reportSettingsState`, `.save`?**
  _High betweenness centrality (0.095) - this node is a cross-community bridge._
- **Are the 11 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 11 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `CameraSourceID` (e.g. with `.persistAndReport()` and `.reportSettingsState()`) actually correct?**
  _`CameraSourceID` has 7 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _273 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `H264VideoEncoder` be split into smaller, more focused modules?**
  _Cohesion score 0.052884615384615384 - nodes in this community are weakly interconnected._