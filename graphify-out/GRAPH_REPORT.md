# Graph Report - EasyStream  (2026-08-31)

## Corpus Check
- 93 files · ~29,322 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1516 nodes · 3359 edges · 77 communities (74 shown, 3 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 257 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a86c6ca8`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- H264VideoEncoder
- RTMPPublisher
- WebRTCVideoView
- FacebookWebLoginSession
- FLVBuilder
- SignalingMessage
- PlayoutTapAudioDevice
- Foundation
- DirectorStreamReceiver
- CameraSessionViewModel
- Task
- CameraSwitcherAssignment
- DirectorSessionViewModel
- CameraSourceID
- CameraCaptureService
- StreamDestination
- PreviewMonitorCamera
- DiscoveryService
- ProgramAudioEncoderPipeline
- FacebookPage
- DirectorSessionView
- AppRole
- BonjourServiceType
- DiscoveredDevice
- CameraStreamClient
- WhiteBalanceModeOption
- BroadcastStreamPublisher
- Sendable
- TransitionPreferencesStore
- CameraLensKind
- SwitchTransitionKind
- FacebookGraphClient
- FacebookSession
- .write
- CameraSessionView
- AppCoordinator
- DeviceIdentity
- FacebookAuthError
- CameraSourceTile
- CameraClientControlsView
- View
- PreviewMonitorCellView
- EasyStreamUITests
- RemoteCameraSettings
- FacebookConfiguration
- .startOffer
- .current
- Error
- PackageDescription
- PreviewMonitorLayoutMode
- BroadcastSectionHeader
- FacebookPlatformAuth.swift
- DiscoveryViewModel
- DirectorSourceListRow
- PeerConnectionDelegateBridge
- DirectorPreviewMonitorStore
- DirectorInspectorSection
- .decode
- FacebookLivePanel
- StreamDestinationPanel
- DiscoveredDeviceRow
- StreamPublisherState
- RemoteWhiteBalanceOption
- Data
- DirectorRemoteControlsView
- WebRTCConfiguration
- CameraPermissionStatus
- .configureSession
- PreviewMultiviewGridSpec
- RemoteLensOption
- DirectorStatusBar
- RTMPStreamError
- BroadcastPanelModifier
- .applyExternalDisplayPreference
- BoundedWebRTCVideoView
- ConnectionStatusBadge
- LocalNetworkPermissionView

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 81 edges
2. `CameraSourceID` - 63 edges
3. `EasyStreamCore` - 45 edges
4. `CameraCaptureService` - 38 edges
5. `DirectorSessionView` - 37 edges
6. `DiscoveryService` - 37 edges
7. `PlayoutTapAudioDevice` - 34 edges
8. `CameraSessionViewModel` - 33 edges
9. `AppRole` - 33 edges
10. `CameraLensKind` - 28 edges

## Surprising Connections (you probably didn't know these)
- `.body` --calls--> `ConnectionStatusBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift
- `.body` --calls--> `LocalNetworkPermissionView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift
- `.phoneSessionContent` --calls--> `CameraPreviewView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/VideoPreviewViews.swift
- `.previewHeader` --calls--> `CameraAssignmentBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift
- `.controlsSheet` --calls--> `CameraClientControlsView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraClientControlsView.swift

## Import Cycles
- None detected.

## Communities (77 total, 3 thin omitted)

### Community 0 - "H264VideoEncoder"
Cohesion: 0.05
Nodes (40): OSStatus, EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data, Int, Int32 (+32 more)

### Community 1 - "RTMPPublisher"
Cohesion: 0.19
Nodes (8): RTMPPublisher, Bool, Data, Double, NWConnection, String, UInt32, UInt8

### Community 2 - "WebRTCVideoView"
Cohesion: 0.07
Nodes (32): AVCaptureVideoPreviewLayer, CGRect, Context, NSCoder, NSSize, NSView, NSViewRepresentable, boundedSize() (+24 more)

### Community 3 - "FacebookWebLoginSession"
Cohesion: 0.08
Nodes (25): CheckedContinuation, Notification, NSRect, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession, Bool (+17 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.20
Nodes (8): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8, Int

### Community 5 - "SignalingMessage"
Cohesion: 0.05
Nodes (41): Decoder, Encoder, CodingKeys, candidate, command, deviceID, displayName, role (+33 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (26): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+18 more)

### Community 7 - "Foundation"
Cohesion: 0.05
Nodes (30): AppKit, AVFoundation, CoreMedia, CoreVideo, EasyStreamAudioPipeline, EasyStreamCameraCapture, EasyStreamCore, EasyStreamDiscovery (+22 more)

### Community 8 - "DirectorStreamReceiver"
Cohesion: 0.06
Nodes (35): DirectorStreamReceiver, Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated (+27 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.19
Nodes (10): .body, CameraSessionViewModel, .isMuted, AVCaptureSession, Bool, Never, String, Task (+2 more)

### Community 10 - "Task"
Cohesion: 0.17
Nodes (5): Task, AudioEncoderStats, Bool, VideoEncoderStats, .estimatedBitrateKbps

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.12
Nodes (17): .phoneSessionContent, .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram (+9 more)

### Community 12 - "DirectorSessionViewModel"
Cohesion: 0.15
Nodes (20): .inspectorPanel, .inspectorSection, ConnectedCameraSource, DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing, .outgoingProgramVideoTrack (+12 more)

### Community 13 - "CameraSourceID"
Cohesion: 0.13
Nodes (17): TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID, .id, UUID, Set, SwitcherEngine (+9 more)

### Community 14 - "CameraCaptureService"
Cohesion: 0.14
Nodes (12): AVCaptureVideoDataOutputSampleBufferDelegate, NSObjectProtocol, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Double (+4 more)

### Community 15 - "StreamDestination"
Cohesion: 0.13
Nodes (15): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+7 more)

### Community 16 - "PreviewMonitorCamera"
Cohesion: 0.29
Nodes (10): .previewDisplayName, .programDisplayName, PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CGSize (+2 more)

### Community 17 - "DiscoveryService"
Cohesion: 0.14
Nodes (16): NWBrowser, NWListener, EasyStreamLog, DiscoveryService, .discoveredDevices, Bool, NWConnection, NWEndpoint (+8 more)

### Community 18 - "ProgramAudioEncoderPipeline"
Cohesion: 0.07
Nodes (34): AVAudioConverter, AACAudioEncoder, AsyncStream, AVAudioFormat, Data, Double, Int64, UInt32 (+26 more)

### Community 19 - "FacebookPage"
Cohesion: 0.14
Nodes (17): CodingKey, Identifiable, LocalizedError, String, CodingKeys, accessToken, id, name (+9 more)

### Community 20 - "DirectorSessionView"
Cohesion: 0.07
Nodes (25): DirectorSessionView, .canTake, .compactLayout, .directorWorkspaceLayout, .keyboardShortcuts, .mainSwitcherArea, .previewGrid, .previewSelection (+17 more)

### Community 21 - "AppRole"
Cohesion: 0.10
Nodes (22): RoleSelectionScreen, .body, AppRole, .advertisedServiceType, .browsedServiceTypes, camera, director, .displayName (+14 more)

### Community 22 - "BonjourServiceType"
Cohesion: 0.13
Nodes (13): CaseIterable, BonjourServiceType, camera, director, .networkType, .plistEntry, NetworkConstants, TXTKey (+5 more)

### Community 23 - "DiscoveredDevice"
Cohesion: 0.12
Nodes (18): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, DiscoveryEvent (+10 more)

### Community 24 - "CameraStreamClient"
Cohesion: 0.11
Nodes (15): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, AsyncStream (+7 more)

### Community 25 - "WhiteBalanceModeOption"
Cohesion: 0.25
Nodes (8): WhiteBalanceModeOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.20
Nodes (8): BroadcastStreamPublisher, Event, failed, stateChanged, AsyncStream, Bool, CMTime, String

### Community 27 - "Sendable"
Cohesion: 0.41
Nodes (9): Codable, Equatable, PreviewMonitorAppearance, PreviewMonitorOverlayOptions, PreviewMonitorRGBColor, PreviewMonitorSettings, Bool, Double (+1 more)

### Community 29 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 30 - "SwitchTransitionKind"
Cohesion: 0.17
Nodes (12): .programVideoContent, SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, RTCVideoTrack (+4 more)

### Community 31 - "FacebookGraphClient"
Cohesion: 0.24
Nodes (11): Decodable, FacebookGraphClient, GraphAPIErrorResponse, GraphError, Data, String, URL, T (+3 more)

### Community 32 - "FacebookSession"
Cohesion: 0.15
Nodes (7): .destinationPanel, .destinationSection, FacebookLiveService, FacebookSession, .isSignedIn, Bool, FacebookSessionStore

### Community 33 - ".write"
Cohesion: 0.30
Nodes (7): RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Int, UInt32, UInt8

### Community 34 - "CameraSessionView"
Cohesion: 0.14
Nodes (15): CameraSessionView, .cameraPermissionView, .controlsSheet, .exposureBinding, .lensLabel, .streamBadgeLabel, .tabletSessionContent, .whiteBalanceBinding (+7 more)

### Community 35 - "AppCoordinator"
Cohesion: 0.21
Nodes (8): AppCoordinator, .selectedRole, AppRoute, roleSelection, session, RootView, .body, Hashable

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (10): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+2 more)

### Community 37 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 38 - "CameraSourceTile"
Cohesion: 0.24
Nodes (10): .previewGridSection, CameraSourceTile, .body, .borderColor, .videoContent, Bool, Color, Void (+2 more)

### Community 39 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 40 - "View"
Cohesion: 0.20
Nodes (14): View, PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, .body, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel (+6 more)

### Community 41 - "PreviewMonitorCellView"
Cohesion: 0.24
Nodes (9): PreviewMonitorCellView, .body, .borderColor, .bottomBar, .leadingLabels, .overlayLayer, .safeAreaGuides, .tallyBadges (+1 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "RemoteCameraSettings"
Cohesion: 0.15
Nodes (16): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, setExposureBias, setLens, setMuted, setSwitcherAssignment, setWhiteBalance (+8 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - ".startOffer"
Cohesion: 0.22
Nodes (5): RTCPeerConnection, Int32, RTCIceCandidate, RTCMediaConstraints, RTCSessionDescription

### Community 46 - ".current"
Cohesion: 0.27
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "Error"
Cohesion: 0.17
Nodes (12): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+4 more)

### Community 49 - "PreviewMonitorLayoutMode"
Cohesion: 0.20
Nodes (10): PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5, .id (+2 more)

### Community 50 - "BroadcastSectionHeader"
Cohesion: 0.25
Nodes (8): BroadcastSectionHeader, .body, BroadcastTallyPill, .body, Color, String, .body, .body

### Community 51 - "FacebookPlatformAuth.swift"
Cohesion: 0.06
Nodes (28): AccessToken, App, AppTrackingTransparency, Any, Bool, UIApplication, URL, EasyStreamApp (+20 more)

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "DirectorSourceListRow"
Cohesion: 0.24
Nodes (10): BroadcastTheme, .lensPicker, DirectorSourceListRow, .accentBarColor, .rowBackground, .rowBorder, Bool, Color (+2 more)

### Community 54 - "PeerConnectionDelegateBridge"
Cohesion: 0.07
Nodes (27): AppDelegate, NSObject, CVPixelBuffer, Int64, PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection (+19 more)

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.14
Nodes (12): DirectorPreviewMonitorStore, .settings, Int, Never, String, Task, Void, DirectorPreviewMonitorWindowView (+4 more)

### Community 56 - "DirectorInspectorSection"
Cohesion: 0.33
Nodes (7): DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorSourcesPanel, .body, Content, String

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "FacebookLivePanel"
Cohesion: 0.33
Nodes (8): FacebookLivePanel, .body, .pageSelection, .signedInContent, Binding, Bool, String, Void

### Community 59 - "StreamDestinationPanel"
Cohesion: 0.24
Nodes (8): StreamDestinationPanel, .body, .publisherStatus, Binding, Bool, Int, String, Void

### Community 60 - "DiscoveredDeviceRow"
Cohesion: 0.22
Nodes (8): .connectionSummary, .sourceSidebar, .sourceSidebarSection, DiscoveredDeviceRow, .body, SignalStrengthView, .body, Int

### Community 61 - "StreamPublisherState"
Cohesion: 0.24
Nodes (8): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int

### Community 62 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 63 - "Data"
Cohesion: 0.49
Nodes (4): AMF0, Data, Double, String

### Community 64 - "DirectorRemoteControlsView"
Cohesion: 0.31
Nodes (9): DirectorRemoteControlsView, .body, .exposureControl, .lensPicker, .whiteBalancePicker, .zoomControl, Binding, Double (+1 more)

### Community 65 - "WebRTCConfiguration"
Cohesion: 0.25
Nodes (4): RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 66 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 68 - "PreviewMultiviewGridSpec"
Cohesion: 0.47
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 69 - "RemoteLensOption"
Cohesion: 0.25
Nodes (8): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, .activeLens

### Community 70 - "DirectorStatusBar"
Cohesion: 0.52
Nodes (5): .switcherDetailColumn, DirectorStatusBar, .body, Int, String

### Community 71 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 72 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, ViewModifier

### Community 73 - ".applyExternalDisplayPreference"
Cohesion: 0.53
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 74 - "BoundedWebRTCVideoView"
Cohesion: 0.40
Nodes (4): BoundedWebRTCVideoView, .body, RTCVideoTrack, .videoLayer

### Community 75 - "ConnectionStatusBadge"
Cohesion: 0.60
Nodes (3): ConnectionStatusBadge, Bool, String

### Community 76 - "LocalNetworkPermissionView"
Cohesion: 0.67
Nodes (3): LocalNetworkPermissionView, .body, Void

## Knowledge Gaps
- **286 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.cameraPermissionView`, `.lensLabel` (+281 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `FacebookSession`, `H264VideoEncoder`, `Foundation`, `DirectorStreamReceiver`, `Task`, `CameraSourceID`, `StreamDestination`, `DiscoveryService`, `ProgramAudioEncoderPipeline`, `FacebookPage`, `DirectorSessionView`, `DiscoveredDevice`, `BroadcastStreamPublisher`, `TransitionPreferencesStore`, `StreamPublisherState`?**
  _High betweenness centrality (0.109) - this node is a cross-community bridge._
- **Why does `CameraCaptureService` connect `CameraCaptureService` to `CameraPermissionStatus`, `.configureSession`, `Foundation`, `CameraSessionViewModel`, `.current`, `PeerConnectionDelegateBridge`, `Sendable`, `CameraLensKind`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `CameraSwitcherAssignment`, `PreviewMonitorCamera`, `DirectorSessionView`, `AppRole`, `SwitchTransitionKind`, `CameraSessionView`, `AppCoordinator`, `CameraSourceTile`, `CameraClientControlsView`, `PreviewMonitorCellView`, `BroadcastSectionHeader`, `DirectorSourceListRow`, `DirectorPreviewMonitorStore`, `DirectorInspectorSection`, `FacebookLivePanel`, `StreamDestinationPanel`, `DiscoveredDeviceRow`, `DirectorRemoteControlsView`, `DirectorStatusBar`, `BroadcastPanelModifier`, `BoundedWebRTCVideoView`, `ConnectionStatusBadge`, `LocalNetworkPermissionView`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Are the 11 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 11 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `CameraSourceID` (e.g. with `.persistAndReport()` and `.reportSettingsState()`) actually correct?**
  _`CameraSourceID` has 7 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _286 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `H264VideoEncoder` be split into smaller, more focused modules?**
  _Cohesion score 0.0546448087431694 - nodes in this community are weakly interconnected._