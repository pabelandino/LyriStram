# Graph Report - EasyStream  (2026-08-31)

## Corpus Check
- 128 files · ~54,680 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2407 nodes · 5874 edges · 118 communities (115 shown, 3 thin omitted)
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
- SignalingChannel
- CameraSessionViewModel
- LogoAnimationModifier
- CameraSwitcherAssignment
- DirectorSessionViewModel
- SwitcherEvent
- BroadcastGlowButtonStyle
- .content
- View
- DiscoveryService
- CameraSourceID
- DirectorStreamReceiver
- Void
- AppRole
- .body
- DiscoveredDevice
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- PreviewMonitorSettings
- DirectorSidebarTab
- CameraLensKind
- BroadcastMediaViewModel
- WebRTC
- Sendable
- ProgramAudioEncoderPipeline
- DirectorRemoteControlsView
- DirectorSourceListRow
- DeviceIdentity
- BroadcastWidgetStudioPanel
- .body
- CameraClientControlsView
- RoundedRectangle
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
- BroadcastWidgetRenderer.swift
- DirectorPreviewMonitorStore
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- BroadcastWidgetConfiguration
- AACAudioEncoder
- ProgramOutputDisplayOption
- FacebookGraphClient
- CaseIterable
- CameraSessionView
- Equatable
- CameraCaptureService
- PreviewMonitorCellView
- PreviewMultiviewGridSpec
- CodingKeys
- .prepareLiveBroadcast
- BroadcastMediaThumbnailLoader
- BroadcastTransmissionMenu
- .matches
- PeerConnectionDelegateBridge
- DiscoveryEvent
- String
- RTMPStreamError
- Testing
- RootView
- BroadcastFontPreset
- BroadcastLogoAnimation
- .handleOpenURL
- SwiftUI
- WebRTCConfiguration
- EasyStreamCore
- Event
- FacebookLivePanel
- BroadcastPlaylistRepository
- .beginImport
- .applyExternalDisplayPreference
- Error
- StreamDestination
- WebRTCVideoFramePublisher
- Bool
- SwitchTransitionKind
- BroadcastPanelModifier
- CodingKeys
- BroadcastTheme.swift
- CameraStreamConfiguration.swift
- AudioEncoderStats
- FacebookPlatformAuthError
- TeamIntercomService
- BroadcastDraggableWidgetOverlay
- FacebookGraphError
- SignalStrengthView
- SequencePhase
- ProgramFeedWidgetLayer
- GraphAPIErrorResponse
- StreamDestinationPanel
- WebRTCProgramFrameSink
- BroadcastResourceKind
- Color
- .tapPCM
- BroadcastAudioIntercomPanels.swift
- BroadcastResourceDisplayView
- ProgramOutputSyncBridge
- NSObject

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
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `CameraSessionView` --calls--> `TeamIntercomService`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamTransport/Sources/EasyStreamTransport/TeamIntercomService.swift
- `.body` --calls--> `ConnectionStatusBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift
- `.body` --calls--> `LocalNetworkPermissionView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift

## Import Cycles
- None detected.

## Communities (118 total, 3 thin omitted)

### Community 0 - "H264VideoEncoder"
Cohesion: 0.05
Nodes (43): OSStatus, CameraTransportDefaults, EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data, Int (+35 more)

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "WebRTCVideoView"
Cohesion: 0.06
Nodes (38): AVCaptureVideoPreviewLayer, .phoneSessionContent, NSCoder, NSColor, NSSize, NSView, NSViewRepresentable, BroadcastBarlessWindowConfigurator (+30 more)

### Community 3 - "FacebookWebLoginSession"
Cohesion: 0.06
Nodes (32): AccessToken, CheckedContinuation, Notification, NSRect, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession (+24 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "BroadcastWidgetCanvas"
Cohesion: 0.17
Nodes (18): AnimatedLogoWidgetView, .placeholderLogo, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView (+10 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.10
Nodes (19): PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels, .isInitialized, .isPlaying (+11 more)

### Community 7 - "IntercomPushToTalkButton"
Cohesion: 0.15
Nodes (19): IntercomPushToTalkButton, .activeCornerRadius, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor, .subtitle (+11 more)

### Community 8 - "SignalingChannel"
Cohesion: 0.16
Nodes (13): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, Event, connected, disconnected, failed, message (+5 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.13
Nodes (15): .body, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool, Never (+7 more)

### Community 10 - "LogoAnimationModifier"
Cohesion: 0.26
Nodes (9): .body, LogoAnimationCycle, LogoAnimationModifier, .anim, LogoMotionContainer, .body, Content, Double (+1 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.10
Nodes (22): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+14 more)

### Community 12 - "DirectorSessionViewModel"
Cohesion: 0.07
Nodes (37): DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, .directorWorkspaceLayout, .previewGrid, .programOutput, DirectorMainSwitcherAreaView, .body (+29 more)

### Community 13 - "SwitcherEvent"
Cohesion: 0.11
Nodes (16): .selectedTransition, TimeInterval, SwitcherSnapshot, SwitchTransition, TransitionPreferencesStore, Set, SwitcherEngine, .state (+8 more)

### Community 14 - "BroadcastGlowButtonStyle"
Cohesion: 0.09
Nodes (20): ButtonStyle, Configuration, BroadcastGlassBorderedButtonStyle, BroadcastGlassPanelModifier, BroadcastGlassProminentButtonStyle, BroadcastGlassStyles, BroadcastGlowButtonStyle, BroadcastHiddenToolbarModifier (+12 more)

### Community 15 - ".content"
Cohesion: 0.23
Nodes (12): AnyView, NSImage, .logoAspectRatio, .content, BroadcastWidgetImageLoader, CachedWidgetLogoView, .body, Content (+4 more)

### Community 16 - "View"
Cohesion: 0.19
Nodes (14): .previewDisplayName, .programDisplayName, Content, PreviewMonitorCamera, PreviewMonitorHeaderBar, .body, PreviewMonitorMultiviewGrid, .body (+6 more)

### Community 17 - "DiscoveryService"
Cohesion: 0.14
Nodes (15): EasyStreamLog, DiscoveryService, .discoveredDevices, Bool, NWBrowser, NWConnection, NWEndpoint, NWListener (+7 more)

### Community 18 - "CameraSourceID"
Cohesion: 0.17
Nodes (10): .inspectorPanel, .inspectorSection, ConnectedCameraSource, Float, RTCAudioTrack, RTCVideoTrack, String, CameraSourceID (+2 more)

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.14
Nodes (14): DirectorStreamReceiver, RTCPeerConnection, SessionContext, AsyncStream, Int32, NWConnection, RTCIceCandidate, RTCMediaConstraints (+6 more)

### Community 20 - "Void"
Cohesion: 0.23
Nodes (11): PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body, PreviewMonitorSettingsSheet, .body, Binding (+3 more)

### Community 21 - "AppRole"
Cohesion: 0.08
Nodes (23): AppCoordinator, .selectedRole, AppRole, .advertisedServiceType, .browsedServiceTypes, camera, director, .displayName (+15 more)

### Community 22 - ".body"
Cohesion: 0.18
Nodes (5): .body, .destinationPanelFacebook, .destinationPanelStream, .destinationSection, Task

### Community 23 - "DiscoveredDevice"
Cohesion: 0.12
Nodes (20): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, Bool (+12 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.15
Nodes (12): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+4 more)

### Community 25 - "SignalingMessage"
Cohesion: 0.07
Nodes (29): Encoder, MessageType, answer, control, hello, ice, offer, settingsState (+21 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "PreviewMonitorSettings"
Cohesion: 0.17
Nodes (16): PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5 (+8 more)

### Community 28 - "DirectorSidebarTab"
Cohesion: 0.16
Nodes (12): .playlistsSidebarContent, .sourceSidebar, DirectorSourceSidebarView, .playlistsContent, DirectorSidebarTab, cameras, .id, library (+4 more)

### Community 29 - "CameraLensKind"
Cohesion: 0.11
Nodes (22): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+14 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.09
Nodes (26): .librarySidebarContent, .libraryContent, BroadcastMediaViewModel, .airFullScreenGraphicResource, .allResources, .committedLiveAirWidgetLayers, .directorLiveAirWidgetLayers, .draftWidgetResource (+18 more)

### Community 31 - "WebRTC"
Cohesion: 0.14
Nodes (7): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamVideoPipeline, Observation, OSLog, WebRTC

### Community 32 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "DirectorRemoteControlsView"
Cohesion: 0.06
Nodes (42): .previewGridSection, RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide (+34 more)

### Community 35 - "DirectorSourceListRow"
Cohesion: 0.18
Nodes (14): .body, DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorSourceListRow, .accentBarColor, .rowBackground, .rowBorder (+6 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (40): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton, .body (+32 more)

### Community 38 - ".body"
Cohesion: 0.16
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 39 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 40 - "RoundedRectangle"
Cohesion: 0.19
Nodes (13): LinearGradient, .buttonBackground, .buttonShape, .body, BroadcastTheme, .templatePicker, .lensPicker, .body (+5 more)

### Community 41 - "DirectorSessionView"
Cohesion: 0.07
Nodes (26): DirectorSessionView, .camerasSidebarContent, .canTake, .compactLayout, .destinationPanel, .keyboardShortcuts, .mainSwitcherArea, .previewSelection (+18 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "RemoteCameraSettings"
Cohesion: 0.09
Nodes (25): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens, setMuted, setSwitcherAssignment (+17 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "BroadcastWidgetTemplate"
Cohesion: 0.15
Nodes (13): BroadcastWidgetTemplate, animatedLogo, clock, countdown, logo, lowerThird, lowerThirdPro, .mentoTemplates (+5 more)

### Community 46 - ".current"
Cohesion: 0.27
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 49 - "LiveProgramFeedView"
Cohesion: 0.25
Nodes (16): .body, BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, PreviewWidgetOverlayView, StableProgramVideoView, StableWidgetOverlayView (+8 more)

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
Cohesion: 0.14
Nodes (8): AppTrackingTransparency, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin, StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing()

### Community 54 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.11
Nodes (23): Animation, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .opacity (+15 more)

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.15
Nodes (11): DirectorPreviewMonitorStore, .settings, Int, Never, String, Task, Void, DirectorPreviewMonitorWindowView (+3 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.08
Nodes (23): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+15 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.20
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "BroadcastWidgetConfiguration"
Cohesion: 0.15
Nodes (14): BroadcastGradientStyle, BroadcastWidgetConfiguration, .resolvedSubtitleColorHex, .resolvedTemplate, .resolvedTickerBackgroundHex, .resolvedTickerTextColorHex, .resolvedTitleColorHex, .resolvedUseLowerThirdGradient (+6 more)

### Community 60 - "AACAudioEncoder"
Cohesion: 0.26
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 61 - "ProgramOutputDisplayOption"
Cohesion: 0.17
Nodes (12): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, ProgramOutputDestinationPanel (+4 more)

### Community 62 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 63 - "CaseIterable"
Cohesion: 0.15
Nodes (12): CaseIterable, BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, StreamingDeliveryMode (+4 more)

### Community 64 - "CameraSessionView"
Cohesion: 0.11
Nodes (16): CameraSessionView, .cameraPermissionView, .connectionSummary, .exposureBinding, .lensLabel, .streamBadgeLabel, .tabletSessionContent, .whiteBalanceBinding (+8 more)

### Community 65 - "Equatable"
Cohesion: 0.23
Nodes (10): Codable, Equatable, Identifiable, FacebookLiveVideo, FacebookPage, FacebookSession, .isSignedIn, FacebookUserProfile (+2 more)

### Community 66 - "CameraCaptureService"
Cohesion: 0.10
Nodes (17): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, NSObjectProtocol, CameraCaptureService, CameraPermissionStatus, authorized, denied, notDetermined (+9 more)

### Community 67 - "PreviewMonitorCellView"
Cohesion: 0.43
Nodes (5): PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges

### Community 68 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 69 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 70 - ".prepareLiveBroadcast"
Cohesion: 0.21
Nodes (3): FacebookLiveService, String, FacebookSessionStore

### Community 71 - "BroadcastMediaThumbnailLoader"
Cohesion: 0.42
Nodes (6): .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox

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
Cohesion: 0.15
Nodes (10): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired, AsyncStream (+2 more)

### Community 76 - "String"
Cohesion: 0.10
Nodes (38): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+30 more)

### Community 77 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 78 - "Testing"
Cohesion: 0.13
Nodes (4): EasyStreamSwitcher, EasyStreamTests, deviceIdentityPersistsID(), Testing

### Community 79 - "RootView"
Cohesion: 0.22
Nodes (9): App, RootView, .body, EasyStreamApp, .body, DirectorProgramOutputWindowView, RoleSelectionScreen, .body (+1 more)

### Community 80 - "BroadcastFontPreset"
Cohesion: 0.14
Nodes (15): Font, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded (+7 more)

### Community 81 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 82 - ".handleOpenURL"
Cohesion: 0.36
Nodes (5): FacebookSDKBootstrap, Any, Bool, UIApplication, URL

### Community 83 - "SwiftUI"
Cohesion: 0.13
Nodes (10): AppKit, AVKit, EasyStreamCameraCapture, EasyStreamTransport, EasyStreamUIComponents, ImageIO, PlatformSettings, SwiftUI (+2 more)

### Community 84 - "WebRTCConfiguration"
Cohesion: 0.25
Nodes (4): RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 85 - "EasyStreamCore"
Cohesion: 0.13
Nodes (8): AVFoundation, CoreMedia, CoreVideo, EasyStreamCore, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox

### Community 86 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 87 - "FacebookLivePanel"
Cohesion: 0.33
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 88 - "BroadcastPlaylistRepository"
Cohesion: 0.25
Nodes (5): BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL, playlists

### Community 89 - ".beginImport"
Cohesion: 0.29
Nodes (3): BroadcastMacFilePicker, Void, UTType

### Community 90 - ".applyExternalDisplayPreference"
Cohesion: 0.43
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 91 - "Error"
Cohesion: 0.14
Nodes (14): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+6 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "WebRTCVideoFramePublisher"
Cohesion: 0.24
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 95 - "SwitchTransitionKind"
Cohesion: 0.27
Nodes (12): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL, SwitchTransitionKind, cut (+4 more)

### Community 96 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 97 - "CodingKeys"
Cohesion: 0.33
Nodes (6): CodingKey, CodingKeys, accessToken, id, name, secureStreamURL

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.16
Nodes (15): .body, BroadcastCompactLiveBadge, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body, BroadcastSectionHeader, .body (+7 more)

### Community 99 - "CameraStreamConfiguration.swift"
Cohesion: 0.33
Nodes (5): CoreGraphics, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32

### Community 101 - "FacebookPlatformAuthError"
Cohesion: 0.33
Nodes (6): FacebookPlatformAuthError, cancelled, invalidConfiguration, limitedLoginOnly, missingAccessToken, missingPresenter

### Community 102 - "TeamIntercomService"
Cohesion: 0.07
Nodes (34): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, .controlsSheet, ObjectIdentifier, IntercomConstants, Double, String (+26 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.16
Nodes (17): CGPoint, Gesture, BroadcastDraggableWidgetOverlay, .body, CGFloat, CGRect, CGSize, WidgetOverlayContentSizing (+9 more)

### Community 104 - "FacebookGraphError"
Cohesion: 0.40
Nodes (5): LocalizedError, FacebookGraphError, apiError, .errorDescription, invalidResponse

### Community 105 - "SignalStrengthView"
Cohesion: 0.50
Nodes (4): .body, SignalStrengthView, .body, Int

### Community 106 - "SequencePhase"
Cohesion: 0.67
Nodes (3): SequencePhase, offscreen, onscreen

### Community 107 - "ProgramFeedWidgetLayer"
Cohesion: 0.40
Nodes (9): ProgramFeedView, ProgramFeedWidgetLayer, Binding, Bool, Double, RTCVideoTrack, String, URL (+1 more)

### Community 108 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.27
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 111 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, Sendable, Void, WebRTCProgramFrameSink, RTCVideoFrame, RTCVideoRenderer

### Community 113 - "BroadcastResourceKind"
Cohesion: 0.12
Nodes (17): Data, BroadcastResourceKind, image, .systemImage, .title, video, widget, Date (+9 more)

### Community 114 - "Color"
Cohesion: 0.24
Nodes (8): .currentColor, BroadcastWidgetColors, Color, Binding, Bool, Double, String, UnitPoint

### Community 115 - ".tapPCM"
Cohesion: 0.29
Nodes (5): AudioBufferList, AVAudioSourceNode, Double, UInt32, UnsafeMutablePointer

### Community 116 - "BroadcastAudioIntercomPanels.swift"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 117 - "BroadcastResourceDisplayView"
Cohesion: 0.24
Nodes (11): AVPlayer, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body, BroadcastVideoResourceView, .body, Binding (+3 more)

### Community 131 - "ProgramOutputSyncBridge"
Cohesion: 0.40
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 133 - "NSObject"
Cohesion: 0.25
Nodes (7): AppDelegate, Any, Bool, UIApplication, URL, NSObject, UIApplicationDelegate

## Knowledge Gaps
- **404 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+399 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `H264VideoEncoder`, `Equatable`, `ProgramAudioEncoderPipeline`, `ProgramOutputSyncBridge`, `AudioEncoderStats`, `.prepareLiveBroadcast`, `DirectorSessionView`, `SwitcherEvent`, `StreamDestination`, `DiscoveryService`, `LiveProgramAirStore`, `CameraSourceID`, `DirectorStreamReceiver`, `.body`, `DiscoveredDevice`, `BroadcastStreamPublisher`, `DirectorSidebarTab`, `WebRTC`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `Foundation` connect `EasyStreamCore` to `H264VideoEncoder`, `FacebookWebLoginSession`, `CameraSwitcherAssignment`, `DirectorSessionViewModel`, `SwitcherEvent`, `AppRole`, `BonjourServiceType`, `SignalingMessage`, `PreviewMonitorSettings`, `CameraLensKind`, `WebRTC`, `Sendable`, `FacebookConfiguration`, `Data`, `FacebookPlatformAuth.swift`, `DirectorPreviewMonitorStore`, `BroadcastResourceRepository`, `BroadcastWidgetConfiguration`, `ProgramOutputDisplayOption`, `CaseIterable`, `Equatable`, `.prepareLiveBroadcast`, `.matches`, `String`, `Testing`, `SwiftUI`, `BroadcastPlaylistRepository`, `StreamDestination`, `TeamIntercomService`, `BroadcastResourceKind`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `BroadcastTheme.swift`, `CameraStreamConfiguration.swift`, `ProgramOutputSyncBridge`, `BroadcastWidgetStudioPanel`, `DirectorSourceListRow`, `CameraSwitcherAssignment`, `String`, `Testing`, `StreamDestinationPanel`, `LiveProgramFeedView`, `SwiftUI`, `BroadcastAudioIntercomPanels.swift`, `FacebookPlatformAuth.swift`, `BroadcastWidgetRenderer.swift`, `Void`, `AppRole`, `WebRTC`?**
  _High betweenness centrality (0.065) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `BroadcastResource` (e.g. with `.airFullScreenGraphicResource` and `.applyLogoData()`) actually correct?**
  _`BroadcastResource` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _404 weakly-connected nodes found - possible documentation gaps or missing edges._