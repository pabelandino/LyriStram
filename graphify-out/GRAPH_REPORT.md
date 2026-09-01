# Graph Report - EasyStream  (2026-08-31)

## Corpus Check
- 128 files · ~54,779 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2471 nodes · 5866 edges · 135 communities (123 shown, 12 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 529 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9fb458a0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- H264VideoEncoder
- RTMPPublisher
- ClippingRTCVideoContainer
- FacebookWebLoginSession
- FLVBuilder
- BroadcastWidgetRenderer.swift
- PlayoutTapAudioDevice
- IntercomPushToTalkButton
- BroadcastResource
- CameraSessionViewModel
- LogoAnimationModifier
- RoundedRectangle
- DirectorSwitcherColumnView
- CameraSourceID
- BroadcastGlowButtonStyle
- CachedWidgetLogoView
- PreviewMonitorCamera
- DiscoveryService
- .inspectorPanel
- DirectorStreamReceiver
- PreviewMonitorSettings
- AppRole
- Task
- View
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- Equatable
- DirectorSidebarTab
- CameraLensKind
- BroadcastMediaViewModel
- EasyStreamUIComponents
- Sendable
- ProgramAudioEncoderPipeline
- DirectorStatusBar
- BroadcastTheme
- DeviceIdentity
- BroadcastWidgetStudioPanel
- .body
- CameraClientControlsView
- DirectorSessionViewModel
- DirectorSessionView
- EasyStreamUITests
- RemoteCameraSettings
- FacebookConfiguration
- SignalingChannel
- .current
- CameraPreviewView
- PackageDescription
- SwitchTransitionKind
- LiveProgramAirStore
- .write
- DiscoveryViewModel
- DirectorProgramOutputWindowView.swift
- CountdownAnimationModifier
- DirectorPreviewMonitorStore
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- BroadcastWidgetConfiguration
- AudioEncoderStats
- BroadcastTransmissionMenu
- WebRTCVideoView
- RemoteWhiteBalanceOption
- CameraSessionView
- Identifiable
- CameraCaptureService
- Color
- PreviewMultiviewGridSpec
- CodingKeys
- ClippingRTCVideoContainerView
- StreamConnectionState
- SwitchTransition
- .matches
- PeerConnectionDelegateBridge
- DiscoveredDevice
- String
- RTMPStreamError
- Testing
- Data
- CaseIterable
- BroadcastLogoAnimation
- .application
- SwiftUI
- WebRTCConfiguration
- EasyStreamCore
- DirectorSessionViewModel.swift
- Event
- .body
- ProgramWidgetLayer
- BroadcastPlaylistRepository
- Error
- StreamDestination
- WebRTCVideoFramePublisher
- PreviewMonitorLayoutMode
- DirectorProgramOutputStore
- .addIceCandidate
- CameraSourceTile
- BroadcastTheme.swift
- UIKit
- DirectorRemoteControlsView
- TransitionProgramView
- TeamIntercomService
- BroadcastDraggableWidgetOverlay
- BroadcastBarlessWindowConfigurator
- RemoteLensOption
- MessageType
- ProgramFeedWidgetLayer
- CameraPermissionStatus
- LocalNetworkPermissionTrigger
- StreamDestinationPanel
- NSObject
- .save
- DeferredBroadcastLibraryPanel
- .content
- ClockWidgetView
- IntercomPushToTalkPulseRing
- BroadcastResourceDisplayView
- DirectorSourceSidebarView
- String
- .applyExternalDisplayPreference
- .destinationSection
- Event
- BoundedWebRTCVideoView
- .captureOutput
- AVCaptureDevice
- CMSampleBuffer
- Decoder
- UInt16
- CMFormatDescription
- NWEndpoint
- ProgramOutputSyncBridge
- RTCMediaStreamTrack
- AVAudioConverter
- RTCVideoRenderer

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 101 edges
2. `BroadcastMediaViewModel` - 86 edges
3. `BroadcastResource` - 75 edges
4. `EasyStreamCore` - 69 edges
5. `BroadcastWidgetConfiguration` - 57 edges
6. `TeamIntercomService` - 55 edges
7. `DirectorSessionView` - 48 edges
8. `CameraSessionViewModel` - 46 edges
9. `CameraCaptureService` - 39 edges
10. `BroadcastWidgetStudioPanel` - 38 edges

## Surprising Connections (you probably didn't know these)
- `.cameraPermissionView` --calls--> `BroadcastGlowButtonStyle`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/BroadcastGlassStyles.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `CameraSessionView` --calls--> `TeamIntercomService`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamTransport/Sources/EasyStreamTransport/TeamIntercomService.swift

## Import Cycles
- None detected.

## Communities (135 total, 12 thin omitted)

### Community 0 - "H264VideoEncoder"
Cohesion: 0.05
Nodes (44): CMFormatDescription, OSStatus, CameraTransportDefaults, EncodedVideoSample, Bool, CMTime, Data, Int (+36 more)

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "ClippingRTCVideoContainer"
Cohesion: 0.23
Nodes (10): NSCoder, NSRect, NSSize, ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize (+2 more)

### Community 3 - "FacebookWebLoginSession"
Cohesion: 0.07
Nodes (29): AccessToken, CheckedContinuation, Notification, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession, Bool (+21 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.24
Nodes (14): AnimatedLogoWidgetView, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView, .body (+6 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "IntercomPushToTalkButton"
Cohesion: 0.15
Nodes (20): IntercomPushToTalkButton, .activeCornerRadius, .buttonShape, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor (+12 more)

### Community 8 - "BroadcastResource"
Cohesion: 0.13
Nodes (15): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, BroadcastResourceKind (+7 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.10
Nodes (23): .body, .connectionSummary, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool (+15 more)

### Community 10 - "LogoAnimationModifier"
Cohesion: 0.26
Nodes (9): .body, LogoAnimationCycle, LogoAnimationModifier, .anim, LogoMotionContainer, .body, Content, Double (+1 more)

### Community 11 - "RoundedRectangle"
Cohesion: 0.08
Nodes (28): .phoneSessionContent, .previewHeader, .tabletSessionContent, CameraSwitcherAssignment, .displayName, idle, .isActive, preview (+20 more)

### Community 12 - "DirectorSwitcherColumnView"
Cohesion: 0.11
Nodes (23): DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, .directorWorkspaceLayout, .previewGrid, .programOutput, DirectorMainSwitcherAreaView, .body (+15 more)

### Community 13 - "CameraSourceID"
Cohesion: 0.13
Nodes (15): EasyStreamSwitcher, CameraSourceID, .id, UUID, Set, SwitcherEngine, .state, SwitcherEvent (+7 more)

### Community 14 - "BroadcastGlowButtonStyle"
Cohesion: 0.07
Nodes (30): ButtonStyle, Configuration, FacebookSession, .body, BroadcastGlassBorderedButtonStyle, BroadcastGlassPanelModifier, BroadcastGlassProminentButtonStyle, BroadcastGlassStyles (+22 more)

### Community 15 - "CachedWidgetLogoView"
Cohesion: 0.14
Nodes (18): AnyView, NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox (+10 more)

### Community 16 - "PreviewMonitorCamera"
Cohesion: 0.35
Nodes (9): PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CameraSourceID, CGSize, Int (+1 more)

### Community 17 - "DiscoveryService"
Cohesion: 0.13
Nodes (19): NWEndpoint, EasyStreamLog, DiscoveryService, .discoveredDevices, AsyncStream, Bool, DeviceIdentity, DiscoveredDevice (+11 more)

### Community 18 - ".inspectorPanel"
Cohesion: 0.22
Nodes (9): .inspectorPanel, .inspectorSection, ConnectedCameraSource, CameraSourceID, Float, RTCAudioTrack, RTCVideoTrack, StreamConnectionState (+1 more)

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.20
Nodes (12): DirectorStreamReceiver, SessionContext, AsyncStream, CameraSourceID, NWConnection, RTCPeerConnection, RTCPeerConnectionState, SignalingChannel (+4 more)

### Community 20 - "PreviewMonitorSettings"
Cohesion: 0.31
Nodes (9): PreviewMonitorSettings, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body, PreviewMonitorSettingsSheet, Binding, Void (+1 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - "Task"
Cohesion: 0.17
Nodes (6): .destinationPanelStream, CameraSwitcherAssignment, DeviceIdentity, DiscoveryEvent, Task, SwitcherEvent

### Community 23 - "View"
Cohesion: 0.12
Nodes (20): .sourceSidebarSection, .camerasContent, Content, ConnectionStatusBadge, DirectorConnectionPanel, .body, DiscoveredDeviceRow, .body (+12 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "SignalingMessage"
Cohesion: 0.14
Nodes (12): Encoder, SignalingMessage, answer, control, hello, ice, offer, settingsState (+4 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "Equatable"
Cohesion: 0.26
Nodes (10): Codable, Equatable, PreviewMonitorAppearance, PreviewMonitorOverlayOptions, PreviewMonitorRGBColor, Bool, Double, SequencePhase (+2 more)

### Community 28 - "DirectorSidebarTab"
Cohesion: 0.11
Nodes (20): .sourceSidebar, .body, .body, DirectorSidebarTab, cameras, .id, library, .systemImage (+12 more)

### Community 29 - "CameraLensKind"
Cohesion: 0.11
Nodes (22): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+14 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.14
Nodes (12): .librarySidebarContent, .libraryContent, BroadcastMediaViewModel, .allResources, .directorLiveAirWidgetLayers, .isEditingExistingWidget, .librarySearchText, .liveAirWidgetLayers (+4 more)

### Community 31 - "EasyStreamUIComponents"
Cohesion: 0.25
Nodes (3): EasyStreamUIComponents, Observation, UniformTypeIdentifiers

### Community 32 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "DirectorStatusBar"
Cohesion: 0.57
Nodes (5): AudioEncoderStats, DirectorStatusBar, .body, Int, String

### Community 35 - "BroadcastTheme"
Cohesion: 0.11
Nodes (21): LinearGradient, .buttonBackground, .body, BroadcastCompactLiveBadge, .body, BroadcastTheme, .templatePicker, .lensPicker (+13 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (41): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+33 more)

### Community 38 - ".body"
Cohesion: 0.15
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 39 - "CameraClientControlsView"
Cohesion: 0.20
Nodes (15): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, AvailableCameraLens (+7 more)

### Community 40 - "DirectorSessionViewModel"
Cohesion: 0.13
Nodes (17): DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing, .outgoingProgramVideoTrack, .previewVideoTrack, .programDisplayTrack, .programVideoTrack (+9 more)

### Community 41 - "DirectorSessionView"
Cohesion: 0.09
Nodes (23): DirectorSessionView, .canTake, .compactLayout, .destinationPanel, .keyboardShortcuts, .mainSwitcherArea, .previewSelection, .programDisplayName (+15 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "RemoteCameraSettings"
Cohesion: 0.19
Nodes (15): RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens, setMuted, setSwitcherAssignment, setWhiteBalance (+7 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "SignalingChannel"
Cohesion: 0.25
Nodes (7): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, SignalingChannel, AsyncStream, Bool, NWConnection

### Community 46 - ".current"
Cohesion: 0.46
Nodes (3): AVCaptureVideoOrientation, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "CameraPreviewView"
Cohesion: 0.24
Nodes (6): AVCaptureVideoPreviewLayer, NSView, CameraPreviewView, PreviewContainerView, AVCaptureSession, UIViewRepresentable

### Community 49 - "SwitchTransitionKind"
Cohesion: 0.23
Nodes (19): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, BroadcastCleanProgramFeedView, .body (+11 more)

### Community 50 - "LiveProgramAirStore"
Cohesion: 0.11
Nodes (21): DirectorProgramAirGraphicsView, .body, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, .hasAirGraphics, DirectorProgramVideoBusView, .body (+13 more)

### Community 51 - ".write"
Cohesion: 0.30
Nodes (7): RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Int, UInt32, UInt8

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "DirectorProgramOutputWindowView.swift"
Cohesion: 0.22
Nodes (6): App, EasyStreamApp, .body, DirectorProgramOutputWindowView, EasyStreamFacebookLoginSetup, Scene

### Community 54 - "CountdownAnimationModifier"
Cohesion: 0.15
Nodes (14): Animation, .placeholderLogo, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .opacity, .scale (+6 more)

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.12
Nodes (13): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+5 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.07
Nodes (27): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+19 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.19
Nodes (10): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryError, invalidWidgetAsset, BroadcastResourceRepositoryProtocol, Data, FileManager, String (+2 more)

### Community 59 - "BroadcastWidgetConfiguration"
Cohesion: 0.07
Nodes (32): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+24 more)

### Community 60 - "AudioEncoderStats"
Cohesion: 0.18
Nodes (9): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32, AudioEncoderStats (+1 more)

### Community 61 - "BroadcastTransmissionMenu"
Cohesion: 0.12
Nodes (23): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, BroadcastTransmissionMenu (+15 more)

### Community 62 - "WebRTCVideoView"
Cohesion: 0.28
Nodes (6): Coordinator, Context, RTCVideoTrack, WebRTCVideoView, RTCMTLNSVideoView, RTCVideoViewDelegate

### Community 63 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 64 - "CameraSessionView"
Cohesion: 0.13
Nodes (15): CameraSessionView, .cameraPermissionView, .exposureBinding, .lensLabel, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, Binding (+7 more)

### Community 65 - "Identifiable"
Cohesion: 0.05
Nodes (46): CodingKey, Decodable, Identifiable, LocalizedError, FacebookGraphClient, GraphAPIErrorResponse, GraphError, Data (+38 more)

### Community 66 - "CameraCaptureService"
Cohesion: 0.11
Nodes (17): AVCaptureDevice, AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraImagingState, NSObjectProtocol, CameraCaptureService, AvailableCameraLens, AVCaptureSession (+9 more)

### Community 67 - "Color"
Cohesion: 0.24
Nodes (9): Color, PreviewMonitorCellView, .body, .borderColor, .bottomBar, .leadingLabels, .overlayLayer, .safeAreaGuides (+1 more)

### Community 68 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 69 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 70 - "ClippingRTCVideoContainerView"
Cohesion: 0.26
Nodes (9): boundedSize(), ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGSize, ProposedViewSize, RTCMTLVideoView (+1 more)

### Community 71 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 72 - "SwitchTransition"
Cohesion: 0.25
Nodes (5): .selectedTransition, TimeInterval, SwitcherSnapshot, SwitchTransition, TransitionPreferencesStore

### Community 73 - ".matches"
Cohesion: 0.31
Nodes (6): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String

### Community 74 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 75 - "DiscoveredDevice"
Cohesion: 0.13
Nodes (17): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, DiscoveryEvent (+9 more)

### Community 76 - "String"
Cohesion: 0.10
Nodes (36): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+28 more)

### Community 77 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 78 - "Testing"
Cohesion: 0.10
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "Data"
Cohesion: 0.44
Nodes (4): AMF0, Data, Double, String

### Community 80 - "CaseIterable"
Cohesion: 0.13
Nodes (14): CaseIterable, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded, serif (+6 more)

### Community 81 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): Decoder, BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate (+1 more)

### Community 82 - ".application"
Cohesion: 0.21
Nodes (9): Any, Bool, UIApplication, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+1 more)

### Community 83 - "SwiftUI"
Cohesion: 0.11
Nodes (6): AppKit, AVKit, ImageIO, PlatformSettings, SwiftUI, WebKit

### Community 84 - "WebRTCConfiguration"
Cohesion: 0.43
Nodes (3): WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 85 - "EasyStreamCore"
Cohesion: 0.13
Nodes (8): CoreMedia, CoreVideo, EasyStreamCore, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox, WebRTC

### Community 86 - "DirectorSessionViewModel.swift"
Cohesion: 0.18
Nodes (7): EasyStreamAudioPipeline, EasyStreamCameraCapture, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamTransport, EasyStreamVideoPipeline, OSLog

### Community 87 - "Event"
Cohesion: 0.18
Nodes (11): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+3 more)

### Community 88 - ".body"
Cohesion: 0.17
Nodes (4): .body, Data, Int, String

### Community 89 - "ProgramWidgetLayer"
Cohesion: 0.16
Nodes (8): BroadcastMacFilePicker, .committedLiveAirWidgetLayers, .previewOverlayWidgetLayers, ProgramWidgetLayer, Bool, URL, Void, UTType

### Community 90 - "BroadcastPlaylistRepository"
Cohesion: 0.29
Nodes (5): BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL, playlists

### Community 91 - "Error"
Cohesion: 0.11
Nodes (18): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+10 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "WebRTCVideoFramePublisher"
Cohesion: 0.24
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 94 - "PreviewMonitorLayoutMode"
Cohesion: 0.20
Nodes (10): PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5, .id (+2 more)

### Community 95 - "DirectorProgramOutputStore"
Cohesion: 0.42
Nodes (6): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL

### Community 96 - ".addIceCandidate"
Cohesion: 0.27
Nodes (5): RTCPeerConnection, Int32, RTCIceCandidate, RTCMediaConstraints, RTCSessionDescription

### Community 97 - "CameraSourceTile"
Cohesion: 0.36
Nodes (7): .previewGridSection, CameraSourceTile, .body, .borderColor, Bool, Void, TakeToProgramButton

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.15
Nodes (16): .camerasSidebarContent, .body, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body, BroadcastPanelModifier, BroadcastSectionHeader (+8 more)

### Community 99 - "UIKit"
Cohesion: 0.12
Nodes (12): AppTrackingTransparency, AVFoundation, CoreGraphics, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin, CameraStreamConfiguration (+4 more)

### Community 100 - "DirectorRemoteControlsView"
Cohesion: 0.22
Nodes (11): DirectorRemoteControlsView, .body, .connectionStateLabel, .exposureControl, .lensPicker, .reconnectButtonTitle, .whiteBalancePicker, .zoomControl (+3 more)

### Community 101 - "TransitionProgramView"
Cohesion: 0.33
Nodes (7): Double, RTCVideoTrack, TransitionProgramView, .body, .incomingOpacity, .outgoingOpacity, .body

### Community 102 - "TeamIntercomService"
Cohesion: 0.07
Nodes (35): AVAudioConverter, AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, .controlsSheet, ObjectIdentifier, IntercomConstants, Double (+27 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.14
Nodes (19): CGPoint, Gesture, BroadcastDraggableWidgetOverlay, .body, Binding, CGFloat, CGRect, CGSize (+11 more)

### Community 104 - "BroadcastBarlessWindowConfigurator"
Cohesion: 0.33
Nodes (5): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSView, NSWindow

### Community 105 - "RemoteLensOption"
Cohesion: 0.25
Nodes (8): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, .activeLens

### Community 106 - "MessageType"
Cohesion: 0.29
Nodes (7): MessageType, answer, control, hello, ice, offer, settingsState

### Community 107 - "ProgramFeedWidgetLayer"
Cohesion: 0.24
Nodes (15): .body, BroadcastWidgetPlacement, ProgramFeedView, .body, ProgramFeedWidgetLayer, Binding, Bool, Double (+7 more)

### Community 108 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.27
Nodes (9): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, StreamDestination, String, Void (+1 more)

### Community 111 - "NSObject"
Cohesion: 0.15
Nodes (11): AppDelegate, NSObject, CGSize, CMTime, CVPixelBuffer, Sendable, Void, WebRTCProgramFrameSink (+3 more)

### Community 112 - ".save"
Cohesion: 0.36
Nodes (4): CameraSettingsStore, CameraSourceID, UUID, Void

### Community 113 - "DeferredBroadcastLibraryPanel"
Cohesion: 0.33
Nodes (8): DeferredBroadcastLibraryPanel, .body, .loadToken, Binding, Set, String, UUID, Void

### Community 114 - ".content"
Cohesion: 0.14
Nodes (16): Font, NSColor, NSFont, .content, TickerScrollingContent, .body, .measuredSegmentWidth, .tickerLabel (+8 more)

### Community 115 - "ClockWidgetView"
Cohesion: 0.33
Nodes (7): ClockWidgetView, .body, Date, String, TickerWidgetView, .body, .displayText

### Community 116 - "IntercomPushToTalkPulseRing"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 117 - "BroadcastResourceDisplayView"
Cohesion: 0.24
Nodes (11): AVPlayer, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body, BroadcastVideoResourceView, .body, Binding (+3 more)

### Community 118 - "DirectorSourceSidebarView"
Cohesion: 0.46
Nodes (3): .playlistsSidebarContent, DirectorSourceSidebarView, .playlistsContent

### Community 119 - "String"
Cohesion: 0.38
Nodes (5): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, .body, String

### Community 120 - ".applyExternalDisplayPreference"
Cohesion: 0.53
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 122 - "Event"
Cohesion: 0.33
Nodes (6): Event, connected, disconnected, failed, message, String

### Community 123 - "BoundedWebRTCVideoView"
Cohesion: 0.40
Nodes (5): BoundedWebRTCVideoView, .body, RTCVideoTrack, .videoContent, .videoLayer

### Community 124 - ".captureOutput"
Cohesion: 0.50
Nodes (3): AVCaptureConnection, AVCaptureOutput, CMSampleBuffer

### Community 131 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

## Knowledge Gaps
- **405 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+400 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `H264VideoEncoder`, `Identifiable`, `ProgramAudioEncoderPipeline`, `ProgramOutputSyncBridge`, `SwitchTransition`, `DirectorSessionView`, `DirectorSwitcherColumnView`, `CameraSourceID`, `DiscoveryService`, `LiveProgramAirStore`, `.inspectorPanel`, `DirectorStreamReceiver`, `DirectorSourceSidebarView`, `DirectorSessionViewModel.swift`, `Task`, `.destinationSection`, `BroadcastStreamPublisher`, `StreamDestination`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `BroadcastTheme.swift`, `UIKit`, `BroadcastWidgetRenderer.swift`, `DirectorSwitcherColumnView`, `CameraSourceID`, `Testing`, `String`, `SwiftUI`, `DirectorProgramOutputWindowView.swift`, `DirectorSessionViewModel.swift`, `EasyStreamUIComponents`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Why does `Foundation` connect `EasyStreamCore` to `H264VideoEncoder`, `FacebookWebLoginSession`, `BroadcastResource`, `RoundedRectangle`, `DirectorSwitcherColumnView`, `CameraSourceID`, `AppRole`, `BonjourServiceType`, `Equatable`, `CameraLensKind`, `EasyStreamUIComponents`, `Sendable`, `FacebookConfiguration`, `.write`, `DirectorPreviewMonitorStore`, `BroadcastResourceRepository`, `BroadcastWidgetConfiguration`, `BroadcastTransmissionMenu`, `Identifiable`, `StreamConnectionState`, `SwitchTransition`, `.matches`, `DiscoveredDevice`, `String`, `Testing`, `CaseIterable`, `SwiftUI`, `DirectorSessionViewModel.swift`, `BroadcastPlaylistRepository`, `StreamDestination`, `UIKit`, `TeamIntercomService`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `BroadcastResource` (e.g. with `.airFullScreenGraphicResource` and `.applyLogoData()`) actually correct?**
  _`BroadcastResource` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _405 weakly-connected nodes found - possible documentation gaps or missing edges._