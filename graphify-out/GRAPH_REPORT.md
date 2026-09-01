# Graph Report - EasyStream  (2026-08-31)

## Corpus Check
- 128 files · ~54,779 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2410 nodes · 5877 edges · 118 communities (116 shown, 2 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 540 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `243529b9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- H264VideoEncoder
- RTMPPublisher
- WebRTCVideoView
- FacebookWebLoginSession
- FLVBuilder
- BroadcastWidgetCanvas
- PlayoutTapAudioDevice
- IntercomPushToTalkButton
- BroadcastResource
- CameraSessionViewModel
- View
- CameraSwitcherAssignment
- .addIceCandidate
- CameraSourceID
- View
- CachedWidgetLogoView
- PreviewMonitorCamera
- DiscoveryService
- ConnectedCameraSource
- DirectorStreamReceiver
- Void
- AppRole
- DirectorSessionViewModel
- DiscoveredDevice
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- Equatable
- DirectorSidebarTab
- CameraLensKind
- BroadcastMediaViewModel
- EasyStreamCore
- Sendable
- ProgramAudioEncoderPipeline
- DirectorStatusBar
- DirectorSourceListRow
- DeviceIdentity
- BroadcastWidgetStudioPanel
- .body
- CameraClientControlsView
- Color
- DirectorSessionView
- EasyStreamUITests
- RemoteCameraSettings
- FacebookConfiguration
- BroadcastWidgetTemplate
- .current
- FacebookAuthError
- PackageDescription
- LiveProgramFeedView
- LiveProgramAirStore
- Data
- DiscoveryViewModel
- FacebookPlatformAuth.swift
- CountdownAnimationModifier
- DirectorPreviewMonitorStore
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- BroadcastWidgetConfiguration
- AudioEncoderStats
- ProgramOutputDisplayOption
- FacebookGraphClient
- CaseIterable
- CameraSessionView
- Identifiable
- CameraCaptureService
- RoundedRectangle
- PreviewMultiviewGridSpec
- CodingKeys
- .performDirectorConnection
- StreamConnectionState
- BroadcastTransmissionMenu
- .matches
- PeerConnectionDelegateBridge
- DiscoveryEvent
- String
- RTMPStreamError
- Testing
- FacebookSignInRequest
- BroadcastFontPreset
- BroadcastLogoAnimation
- .application
- BroadcastMediaLibraryPanel.swift
- WebRTCConfiguration
- Foundation
- DirectorSessionViewModel.swift
- .signIn
- .reload
- BroadcastResourceKind
- .apply
- Error
- StreamDestination
- WebRTCVideoFramePublisher
- PreviewMonitorLayoutMode
- SwitchTransitionKind
- BroadcastPanelModifier
- String
- BroadcastTheme.swift
- UIKit
- DirectorRemoteControlsView
- TransitionProgramView
- TeamIntercomService
- BroadcastDraggableWidgetOverlay
- WhiteBalanceModeOption
- RemoteLensOption
- MessageType
- ProgramFeedWidgetLayer
- CameraPermissionStatus
- LocalNetworkPermissionTrigger
- StreamDestinationPanel
- WebRTCProgramFrameSink
- DeferredBroadcastLibraryPanel
- .content
- .tapPCM
- BroadcastTheme
- BroadcastWidgetPlacement
- ProgramOutputSyncBridge

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 103 edges
2. `BroadcastMediaViewModel` - 86 edges
3. `BroadcastResource` - 75 edges
4. `CameraSourceID` - 72 edges
5. `EasyStreamCore` - 69 edges
6. `BroadcastWidgetConfiguration` - 57 edges
7. `TeamIntercomService` - 55 edges
8. `DirectorSessionView` - 48 edges
9. `CameraSessionViewModel` - 47 edges
10. `CameraCaptureService` - 39 edges

## Surprising Connections (you probably didn't know these)
- `.cameraPermissionView` --calls--> `BroadcastGlowButtonStyle`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/BroadcastGlassStyles.swift
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `.airFullScreenGraphicResource` --references--> `BroadcastResource`  [INFERRED]
  EasyStream/ViewModels/BroadcastMediaViewModel.swift → Packages/EasyStreamCore/Sources/EasyStreamCore/BroadcastResource.swift

## Import Cycles
- None detected.

## Communities (118 total, 2 thin omitted)

### Community 0 - "H264VideoEncoder"
Cohesion: 0.05
Nodes (41): OSStatus, CameraTransportDefaults, EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data, Int (+33 more)

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "WebRTCVideoView"
Cohesion: 0.05
Nodes (42): AVCaptureVideoPreviewLayer, .phoneSessionContent, NSCoder, NSSize, NSView, NSViewRepresentable, BoundedWebRTCVideoView, .body (+34 more)

### Community 3 - "FacebookWebLoginSession"
Cohesion: 0.14
Nodes (14): CheckedContinuation, Notification, NSWindowDelegate, FacebookWebLoginSession, Bool, Error, NSWindow, Void (+6 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "BroadcastWidgetCanvas"
Cohesion: 0.26
Nodes (13): AnimatedLogoWidgetView, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView, .body (+5 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.10
Nodes (20): PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels, .isInitialized, .isPlaying (+12 more)

### Community 7 - "IntercomPushToTalkButton"
Cohesion: 0.13
Nodes (21): IntercomPushToTalkButton, .activeCornerRadius, .buttonShape, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor (+13 more)

### Community 8 - "BroadcastResource"
Cohesion: 0.18
Nodes (8): .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, Date, UUID

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.15
Nodes (15): .body, .connectionSummary, .tabletSessionContent, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession (+7 more)

### Community 10 - "View"
Cohesion: 0.13
Nodes (19): DirectorProgramPreviewOverlayView, Content, .body, LogoAnimationCycle, LogoAnimationModifier, .anim, LogoMotionContainer, .body (+11 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.10
Nodes (22): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+14 more)

### Community 12 - ".addIceCandidate"
Cohesion: 0.23
Nodes (6): RTCPeerConnection, Int32, RTCIceCandidate, RTCMediaConstraints, RTCSessionDescription, String

### Community 13 - "CameraSourceID"
Cohesion: 0.11
Nodes (19): .selectedTransition, TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID, .id, UUID, TransitionPreferencesStore (+11 more)

### Community 14 - "View"
Cohesion: 0.16
Nodes (9): BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastHiddenToolbarModifier, BroadcastStudioChromeModifier, CGFloat, Content, View, View (+1 more)

### Community 15 - "CachedWidgetLogoView"
Cohesion: 0.16
Nodes (17): AnyView, NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox (+9 more)

### Community 16 - "PreviewMonitorCamera"
Cohesion: 0.36
Nodes (8): PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CGSize, Int, RTCVideoTrack

### Community 17 - "DiscoveryService"
Cohesion: 0.13
Nodes (16): EasyStreamLog, DiscoveryService, .discoveredDevices, AsyncStream, Bool, NWBrowser, NWConnection, NWEndpoint (+8 more)

### Community 18 - "ConnectedCameraSource"
Cohesion: 0.14
Nodes (11): .inspectorSection, ConnectedCameraSource, .outgoingProgramVideoTrack, .previewVideoTrack, .programVideoTrack, Double, Float, RTCAudioTrack (+3 more)

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.06
Nodes (37): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, DirectorStreamReceiver, Event, failed, sourceAudioTrack, sourceConnected (+29 more)

### Community 20 - "Void"
Cohesion: 0.17
Nodes (14): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, .body, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body (+6 more)

### Community 21 - "AppRole"
Cohesion: 0.08
Nodes (28): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+20 more)

### Community 22 - "DirectorSessionViewModel"
Cohesion: 0.11
Nodes (16): .body, .destinationPanelFacebook, .destinationPanelStream, .destinationSection, DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing (+8 more)

### Community 23 - "DiscoveredDevice"
Cohesion: 0.11
Nodes (20): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, Bool (+12 more)

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
Cohesion: 0.29
Nodes (11): Codable, Equatable, PreviewMonitorAppearance, PreviewMonitorOverlayOptions, PreviewMonitorRGBColor, PreviewMonitorSettings, Bool, Double (+3 more)

### Community 28 - "DirectorSidebarTab"
Cohesion: 0.20
Nodes (11): .sourceSidebar, DirectorSourceSidebarView, .body, DirectorSidebarTab, cameras, .id, library, .systemImage (+3 more)

### Community 29 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.12
Nodes (18): .inspectorPanel, .librarySidebarContent, .libraryContent, BroadcastMediaViewModel, .airFullScreenGraphicResource, .allResources, .committedLiveAirWidgetLayers, .directorLiveAirWidgetLayers (+10 more)

### Community 31 - "EasyStreamCore"
Cohesion: 0.14
Nodes (6): EasyStreamCore, EasyStreamUIComponents, Observation, SwiftUI, UniformTypeIdentifiers, WebRTC

### Community 32 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "DirectorStatusBar"
Cohesion: 0.31
Nodes (8): DirectorStatusBar, .body, Bool, Float, Int, String, Void, TakeToProgramButton

### Community 35 - "DirectorSourceListRow"
Cohesion: 0.11
Nodes (21): .camerasSidebarContent, .sourceSidebarSection, .camerasContent, DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorSourceListRow, .accentBarColor (+13 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (39): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+31 more)

### Community 38 - ".body"
Cohesion: 0.15
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 39 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 40 - "Color"
Cohesion: 0.14
Nodes (14): ButtonStyle, Configuration, LinearGradient, .buttonBackground, BroadcastGlassBorderedButtonStyle, BroadcastGlassProminentButtonStyle, BroadcastGlowButtonStyle, Bool (+6 more)

### Community 41 - "DirectorSessionView"
Cohesion: 0.05
Nodes (48): DirectorProgramStudioHintsOverlay, .body, DirectorSessionView, .canTake, .compactLayout, .destinationPanel, .directorWorkspaceLayout, .keyboardShortcuts (+40 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "RemoteCameraSettings"
Cohesion: 0.14
Nodes (17): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens, setMuted, setSwitcherAssignment (+9 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "BroadcastWidgetTemplate"
Cohesion: 0.14
Nodes (15): BroadcastWidgetTemplate, animatedLogo, clock, countdown, logo, lowerThird, lowerThirdPro, .mentoTemplates (+7 more)

### Community 46 - ".current"
Cohesion: 0.29
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 49 - "LiveProgramFeedView"
Cohesion: 0.23
Nodes (17): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, PreviewWidgetOverlayView, .body, StableProgramVideoView, StableWidgetOverlayView (+9 more)

### Community 50 - "LiveProgramAirStore"
Cohesion: 0.11
Nodes (21): DirectorProgramAirGraphicsView, .body, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, .hasAirGraphics, DirectorProgramVideoBusView, .body (+13 more)

### Community 51 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "FacebookPlatformAuth.swift"
Cohesion: 0.12
Nodes (11): App, AppTrackingTransparency, EasyStreamApp, .body, DirectorProgramOutputWindowView, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore (+3 more)

### Community 54 - "CountdownAnimationModifier"
Cohesion: 0.16
Nodes (14): Animation, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .scale (+6 more)

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.10
Nodes (16): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+8 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.10
Nodes (17): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, AsyncStream (+9 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.22
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "BroadcastWidgetConfiguration"
Cohesion: 0.14
Nodes (13): BroadcastGradientStyle, BroadcastWidgetConfiguration, .resolvedSubtitleColorHex, .resolvedTemplate, .resolvedTickerBackgroundHex, .resolvedTickerTextColorHex, .resolvedTitleColorHex, .resolvedUseLowerThirdGradient (+5 more)

### Community 60 - "AudioEncoderStats"
Cohesion: 0.18
Nodes (9): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32, AudioEncoderStats (+1 more)

### Community 61 - "ProgramOutputDisplayOption"
Cohesion: 0.19
Nodes (12): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, ProgramOutputDestinationPanel (+4 more)

### Community 62 - "FacebookGraphClient"
Cohesion: 0.24
Nodes (11): Decodable, FacebookGraphClient, GraphAPIErrorResponse, GraphError, Data, String, URL, T (+3 more)

### Community 63 - "CaseIterable"
Cohesion: 0.10
Nodes (20): CaseIterable, BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, RemoteWhiteBalanceOption (+12 more)

### Community 64 - "CameraSessionView"
Cohesion: 0.13
Nodes (14): CameraSessionView, .cameraPermissionView, .exposureBinding, .lensLabel, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, Binding (+6 more)

### Community 65 - "Identifiable"
Cohesion: 0.08
Nodes (29): CodingKey, Identifiable, LocalizedError, FacebookLiveService, String, CodingKeys, accessToken, id (+21 more)

### Community 66 - "CameraCaptureService"
Cohesion: 0.17
Nodes (9): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, NSObjectProtocol, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer (+1 more)

### Community 67 - "RoundedRectangle"
Cohesion: 0.27
Nodes (9): PreviewMonitorCellView, .body, .borderColor, .bottomBar, .leadingLabels, .overlayLayer, .safeAreaGuides, .tallyBadges (+1 more)

### Community 68 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 69 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 70 - ".performDirectorConnection"
Cohesion: 0.26
Nodes (3): NWParameters, Bool, Bool

### Community 71 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 72 - "BroadcastTransmissionMenu"
Cohesion: 0.24
Nodes (10): BroadcastTransmissionMenu, .body, .externalDisplaySection, .facebookSection, .isAnyOutputLive, .networkSection, Binding, Bool (+2 more)

### Community 73 - ".matches"
Cohesion: 0.31
Nodes (6): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String

### Community 74 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 75 - "DiscoveryEvent"
Cohesion: 0.29
Nodes (7): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired

### Community 76 - "String"
Cohesion: 0.08
Nodes (39): .playlistsSidebarContent, .playlistsContent, BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title (+31 more)

### Community 77 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 78 - "Testing"
Cohesion: 0.11
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "FacebookSignInRequest"
Cohesion: 0.24
Nodes (6): FacebookAuthService, FacebookNativeAuthBridge, FacebookSignInRequest, Bool, String, SignInHandler

### Community 80 - "BroadcastFontPreset"
Cohesion: 0.13
Nodes (15): Font, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded (+7 more)

### Community 81 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 82 - ".application"
Cohesion: 0.21
Nodes (9): Any, Bool, UIApplication, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+1 more)

### Community 83 - "BroadcastMediaLibraryPanel.swift"
Cohesion: 0.11
Nodes (7): AppKit, AVKit, ImageIO, View, PlatformSettings, PhotosUI, WebKit

### Community 84 - "WebRTCConfiguration"
Cohesion: 0.43
Nodes (3): WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 85 - "Foundation"
Cohesion: 0.14
Nodes (6): CoreMedia, CoreVideo, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox

### Community 86 - "DirectorSessionViewModel.swift"
Cohesion: 0.18
Nodes (6): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamSwitcher, EasyStreamVideoPipeline, OSLog

### Community 87 - ".signIn"
Cohesion: 0.33
Nodes (5): AccessToken, FacebookPlatformAuth, Bool, String, UIViewController

### Community 88 - ".reload"
Cohesion: 0.12
Nodes (8): Data, Int, String, BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL, playlists

### Community 89 - "BroadcastResourceKind"
Cohesion: 0.14
Nodes (10): BroadcastMacFilePicker, URL, Void, BroadcastResourceKind, image, .systemImage, .title, video (+2 more)

### Community 90 - ".apply"
Cohesion: 0.38
Nodes (3): Double, Float, RemoteCameraCommandExecutor

### Community 91 - "Error"
Cohesion: 0.10
Nodes (20): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+12 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "WebRTCVideoFramePublisher"
Cohesion: 0.24
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 94 - "PreviewMonitorLayoutMode"
Cohesion: 0.20
Nodes (10): PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5, .id (+2 more)

### Community 95 - "SwitchTransitionKind"
Cohesion: 0.27
Nodes (12): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL, SwitchTransitionKind, cut (+4 more)

### Community 96 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 97 - "String"
Cohesion: 0.33
Nodes (4): NSRect, FacebookTokenParser, String, URL

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.15
Nodes (15): BroadcastCompactLiveBadge, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body, BroadcastSectionHeader, .body, BroadcastTallyPill (+7 more)

### Community 99 - "UIKit"
Cohesion: 0.15
Nodes (9): AVFoundation, CoreGraphics, EasyStreamCameraCapture, EasyStreamTransport, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32 (+1 more)

### Community 100 - "DirectorRemoteControlsView"
Cohesion: 0.31
Nodes (9): DirectorRemoteControlsView, .body, .connectionStateLabel, .exposureControl, .lensPicker, .reconnectButtonTitle, .whiteBalancePicker, .zoomControl (+1 more)

### Community 101 - "TransitionProgramView"
Cohesion: 0.33
Nodes (7): Double, RTCVideoTrack, TransitionProgramView, .body, .incomingOpacity, .outgoingOpacity, .body

### Community 102 - "TeamIntercomService"
Cohesion: 0.07
Nodes (34): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, .controlsSheet, ObjectIdentifier, IntercomConstants, Double, String (+26 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.15
Nodes (18): CGPoint, Gesture, BroadcastDraggableWidgetOverlay, .body, Binding, CGFloat, CGRect, CGSize (+10 more)

### Community 104 - "WhiteBalanceModeOption"
Cohesion: 0.25
Nodes (8): WhiteBalanceModeOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 105 - "RemoteLensOption"
Cohesion: 0.25
Nodes (8): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, .activeLens

### Community 106 - "MessageType"
Cohesion: 0.29
Nodes (7): MessageType, answer, control, hello, ice, offer, settingsState

### Community 107 - "ProgramFeedWidgetLayer"
Cohesion: 0.40
Nodes (9): ProgramFeedView, ProgramFeedWidgetLayer, Binding, Bool, Double, RTCVideoTrack, String, URL (+1 more)

### Community 108 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.31
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 111 - "WebRTCProgramFrameSink"
Cohesion: 0.17
Nodes (11): AppDelegate, NSObject, CGSize, CMTime, CVPixelBuffer, Sendable, Void, WebRTCProgramFrameSink (+3 more)

### Community 113 - "DeferredBroadcastLibraryPanel"
Cohesion: 0.39
Nodes (7): DeferredBroadcastLibraryPanel, .loadToken, Binding, Set, String, UUID, Void

### Community 114 - ".content"
Cohesion: 0.21
Nodes (11): NSColor, .placeholderLogo, .opacity, .content, .body, BroadcastWidgetColors, Binding, Bool (+3 more)

### Community 115 - ".tapPCM"
Cohesion: 0.29
Nodes (5): AudioBufferList, AVAudioSourceNode, Double, UInt32, UnsafeMutablePointer

### Community 116 - "BroadcastTheme"
Cohesion: 0.18
Nodes (14): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+6 more)

### Community 117 - "BroadcastWidgetPlacement"
Cohesion: 0.21
Nodes (14): AVPlayer, .body, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body, BroadcastVideoResourceView (+6 more)

### Community 131 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

## Knowledge Gaps
- **405 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+400 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `H264VideoEncoder`, `Identifiable`, `ProgramAudioEncoderPipeline`, `ProgramOutputSyncBridge`, `DirectorSessionView`, `CameraSourceID`, `AudioEncoderStats`, `StreamDestination`, `DiscoveryService`, `LiveProgramAirStore`, `ConnectedCameraSource`, `DirectorStreamReceiver`, `DirectorSessionViewModel.swift`, `DiscoveredDevice`, `BroadcastStreamPublisher`, `DirectorSidebarTab`?**
  _High betweenness centrality (0.104) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `H264VideoEncoder`, `CameraSwitcherAssignment`, `CameraSourceID`, `AppRole`, `BonjourServiceType`, `Equatable`, `CameraLensKind`, `EasyStreamCore`, `Sendable`, `DirectorSessionView`, `RemoteCameraSettings`, `FacebookConfiguration`, `Data`, `DirectorPreviewMonitorStore`, `BroadcastResourceRepository`, `ProgramOutputDisplayOption`, `CaseIterable`, `Identifiable`, `StreamConnectionState`, `.matches`, `String`, `Testing`, `FacebookSignInRequest`, `BroadcastFontPreset`, `BroadcastMediaLibraryPanel.swift`, `DirectorSessionViewModel.swift`, `.reload`, `BroadcastResourceKind`, `StreamDestination`, `UIKit`, `TeamIntercomService`?**
  _High betweenness centrality (0.084) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `BroadcastTheme.swift`, `UIKit`, `DirectorSourceListRow`, `View`, `CameraSourceID`, `Testing`, `LiveProgramFeedView`, `BroadcastMediaLibraryPanel.swift`, `Foundation`, `FacebookPlatformAuth.swift`, `DirectorSessionViewModel.swift`?**
  _High betweenness centrality (0.071) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `BroadcastResource` (e.g. with `.airFullScreenGraphicResource` and `.applyLogoData()`) actually correct?**
  _`BroadcastResource` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _405 weakly-connected nodes found - possible documentation gaps or missing edges._