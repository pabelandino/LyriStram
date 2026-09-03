# Graph Report - EasyStream  (2026-09-03)

## Corpus Check
- 187 files · ~70,168 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3226 nodes · 7615 edges · 175 communities (171 shown, 4 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 587 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2eeb5674`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamUIComponents
- RTMPPublisher
- DirectorMonitorQualitySettings
- BroadcastTakeButtonStyle
- FLVBuilder
- Identifiable
- PlayoutTapAudioDevice
- ProgramCrossfadeHost
- DirectorSwitcherColumnView
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- DirectorSessionViewModel
- PreviewMonitorCamera
- .connectIfNeeded
- BroadcastBarlessWindowConfigurator
- WebRTCVideoView
- LocalNetworkPermissionTrigger
- RoundedRectangle
- EasyStreamCore
- BroadcastMetalProgramFeedPlatformView
- AppRole
- .body
- DirectorConnectionPanel
- BonjourServiceType
- MessageType
- BroadcastStreamPublisher
- DirectorProgramOutputStore
- .invalidateDisplay
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- UIKit
- CameraSourceID
- ProgramAudioEncoderPipeline
- String
- Codable
- DeviceIdentity
- BroadcastWidgetStudioPanel
- BroadcastWidgetCanvas
- LiveProgramFeedView
- BroadcastWidgetRenderer.swift
- ProgramPreviewVisibilityPolicy
- EasyStreamUITests
- SignalingChannel
- FacebookConfiguration
- DiscoveryService
- AVCaptureVideoOrientation
- Data
- PackageDescription
- DirectorSidebarTab
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetConfiguration
- H264VideoEncoder
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- CameraSourceTile
- StreamConnectionState
- ProgramCrossfadeContainerUIView
- BroadcastPlatform
- LiveProgramAirStore
- CameraSessionView
- .content
- CountdownAnimationModifier
- TeamIntercomService
- BroadcastPlaylist
- Driver
- BroadcastMetalOverlayProvider
- BroadcastResource
- Equatable
- .matches
- .recordFrame
- UIView
- BroadcastMetalProgramFeedContainerNSView
- ProgramFrameRingBuffer
- Testing
- RTMPStreamError
- CachedWidgetLogoView
- BroadcastMetalCompositor
- RemoteCameraCommand
- BroadcastWidgetPlacement
- DirectorSessionView
- Foundation
- CameraLensKind
- BroadcastMetalSwiftUIOverlayProvider
- WebRTCVideoFramePublisher
- .makeVideoTextures
- Sendable
- Error
- StreamDestination
- DirectorPreviewMonitorStore
- LayoutNeutralRTCMTLVideoView
- NSView
- FacebookPlatformAuth.swift
- AACAudioEncoder
- BroadcastTheme.swift
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- CameraTransportProfile
- BroadcastMetalTextureUploader.swift
- BroadcastDraggableWidgetOverlay
- BroadcastMetalProgramFeedView
- ClippingRTCVideoContainer
- BroadcastStreamSpec
- BroadcastGlowButtonStyle
- StreamOutputPreset
- ProgramFeedWidgetLayer
- View
- VideoEncoderConfiguration
- SignalingMessage
- NSObject
- .detachAndClear
- FacebookGraphClient
- IntercomPushToTalkPulseRing
- .application
- WebRTCProgramFrameSink
- BroadcastTheme
- CodingKeys
- TeamIntercomPeer
- WebRTCConfiguration
- Color
- VideoRendererSinkCategory
- CameraCaptureService
- DirectorInspectorSection
- Event
- TransitionPreferencesStore
- ProgramFrameRingBuffer.cpp
- PreviewContainerView
- RemoteWhiteBalanceOption
- PreviewMultiviewGridSpec
- ProgramMonitorPreset
- ProgramFrameNativeStatus
- FacebookLivePanel
- .handleBrowseResults
- FacebookAuthError
- BroadcastPanelModifier
- .extract
- DiscoveredDevice
- IntercomPushToTalkButton
- .boundedSize
- ProgramCrossfadeContainerNSView
- EncoderCallbackBridge
- ProgramOutputSyncBridge
- Coordinator
- CodingKeys
- CodingKeys
- BroadcastLogoAnimation
- ProgramFrameBusSlot
- State
- DirectorStatusBar
- Event
- DirectorStreamReceiver
- EncodedVideoSample
- WebRTCVideoContentMode
- CameraPermissionStatus
- BroadcastFontPreset
- .update
- StreamDestinationPanel
- CameraSessionTabletChrome
- DirectorRemoteControlsView
- .init
- CaseIterable
- .handleOffer
- BroadcastMetalWidgetOverlayContent
- GraphAPIErrorResponse
- .applyExternalDisplayPreference
- .prepareLiveBroadcast
- FacebookGraphError
- ProgramFrameNativeCapabilities
- NWError

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 116 edges
2. `EasyStreamCore` - 94 edges
3. `BroadcastMediaViewModel` - 89 edges
4. `BroadcastResource` - 82 edges
5. `CameraSourceID` - 82 edges
6. `BroadcastWidgetConfiguration` - 60 edges
7. `TeamIntercomService` - 56 edges
8. `SwitchTransitionKind` - 54 edges
9. `BroadcastMetalCompositor` - 50 edges
10. `CameraSessionViewModel` - 48 edges

## Surprising Connections (you probably didn't know these)
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `.previewHeader` --calls--> `CameraAssignmentBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView+IOS.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift
- `.controlsSheet` --calls--> `CameraClientControlsView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView+IOS.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraClientControlsView.swift

## Import Cycles
- None detected.

## Communities (175 total, 4 thin omitted)

### Community 0 - "EasyStreamUIComponents"
Cohesion: 0.13
Nodes (7): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamUIComponents, EasyStreamVideoPipeline, Observation, OSLog

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "DirectorMonitorQualitySettings"
Cohesion: 0.17
Nodes (10): DirectorMonitorQualityPreferencesStore, DirectorMonitorQualitySettings, .outputEncoderConfiguration, LegacyTier, balanced, economy, high, Bool (+2 more)

### Community 3 - "BroadcastTakeButtonStyle"
Cohesion: 0.39
Nodes (4): BroadcastTakeButtonStyle, Bool, LinearGradient, .body

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "Identifiable"
Cohesion: 0.27
Nodes (8): Identifiable, FacebookLiveVideo, FacebookPage, FacebookSession, .isSignedIn, FacebookUserProfile, Bool, String

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "ProgramCrossfadeHost"
Cohesion: 0.18
Nodes (10): ProgramCrossfadeHost, Bool, ProgramBusController, Snapshot, Bool, Double, Int, RTCVideoRenderer (+2 more)

### Community 8 - "DirectorSwitcherColumnView"
Cohesion: 0.11
Nodes (21): DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, .programOutput, DirectorMainSwitcherAreaView, .body, .canTake, DirectorPreviewGridView (+13 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.10
Nodes (18): .body, .tabletSessionContent, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool (+10 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.07
Nodes (26): AppOrientationPolicy, UIInterfaceOrientationMask, CameraSessionTabletChrome, Content, View, .phoneSessionContent, .previewHeader, CameraSwitcherAssignment (+18 more)

### Community 12 - "DirectorSessionViewModel"
Cohesion: 0.09
Nodes (24): .remoteControlsSection, ConnectedCameraSource, DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing, .monitorQuality, .outgoingProgramVideoTrack (+16 more)

### Community 13 - "PreviewMonitorCamera"
Cohesion: 0.36
Nodes (8): PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CGSize, Int, RTCVideoTrack

### Community 14 - ".connectIfNeeded"
Cohesion: 0.23
Nodes (6): ObjectIdentifier, NWConnection, NWListener, NWParameters, String, Task

### Community 15 - "BroadcastBarlessWindowConfigurator"
Cohesion: 0.36
Nodes (4): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow

### Community 16 - "WebRTCVideoView"
Cohesion: 0.19
Nodes (9): AVCaptureVideoPreviewLayer, CameraPreviewView, Coordinator, CGSize, Context, Coordinator, ProposedViewSize, RTCVideoTrack (+1 more)

### Community 18 - "RoundedRectangle"
Cohesion: 0.15
Nodes (13): .buttonShape, SignalStrengthView, .body, Int, .body, .bottomBar, .leadingLabels, RoleCard (+5 more)

### Community 19 - "EasyStreamCore"
Cohesion: 0.12
Nodes (5): EasyStreamCameraCapture, EasyStreamCore, EasyStreamTransport, SwiftUI, WebRTC

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.23
Nodes (10): BroadcastMetalProgramFeedPlatformView, Coordinator, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack, URL (+2 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - ".body"
Cohesion: 0.12
Nodes (11): .body, .destinationSection, DirectorSettingsSheet, .facebookPanel, .streamPanel, Void, Task, AudioEncoderStats (+3 more)

### Community 23 - "DirectorConnectionPanel"
Cohesion: 0.22
Nodes (10): ConnectionStatusBadge, .body, DirectorConnectionPanel, .body, LocalNetworkPermissionView, .body, Bool, String (+2 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "MessageType"
Cohesion: 0.29
Nodes (7): MessageType, answer, control, hello, ice, offer, settingsState

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "DirectorProgramOutputStore"
Cohesion: 0.06
Nodes (36): DirectorProgramOutputStore, .settings, Bool, Double, RTCVideoTrack, String, URL, .body (+28 more)

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.08
Nodes (21): .body, .liveGraphicsSection, .widgetStudioSection, BroadcastMediaViewModel, .allResources, .committedLiveAirWidgetLayers, .directorLiveAirWidgetLayers, .isEditingExistingWidget (+13 more)

### Community 31 - "UIKit"
Cohesion: 0.10
Nodes (8): AppKit, AVKit, EasyStreamFacebookLogin, ImageIO, PlatformSettings, UIKit, UniformTypeIdentifiers, WebKit

### Community 32 - "CameraSourceID"
Cohesion: 0.12
Nodes (22): EasyStreamSwitcher, TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID, .id, UUID, Set (+14 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "String"
Cohesion: 0.12
Nodes (31): BroadcastAsyncThumbnailImage, BroadcastMediaLibraryPanel, .body, .filteredPlaylists, BroadcastMediaPhotoImporter, BroadcastPlaylistEditorSheet, .body, BroadcastPlaylistPanel (+23 more)

### Community 35 - "Codable"
Cohesion: 0.18
Nodes (17): Codable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4 (+9 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (41): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+33 more)

### Community 38 - "BroadcastWidgetCanvas"
Cohesion: 0.22
Nodes (13): BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, BroadcastWidgetOverlayView, .body, LowerThirdProWidgetView, .body (+5 more)

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.33
Nodes (13): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, StableProgramVideoView, StableWidgetOverlayView, Bool, Double (+5 more)

### Community 40 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.20
Nodes (12): AnimatedLogoWidgetView, .body, .placeholderLogo, LogoAnimationCycle, LogoAnimationModifier, .anim, LogoMotionContainer, .body (+4 more)

### Community 41 - "ProgramPreviewVisibilityPolicy"
Cohesion: 0.15
Nodes (12): ProgramPreviewVisibilityPolicy, allConnectedSources, previewSourceOnly, Bool, ProgramRenderBackend, legacyDualWebRTC, metalCompositor, ProgramRenderConfiguration (+4 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "SignalingChannel"
Cohesion: 0.20
Nodes (10): Event, connected, disconnected, failed, message, SignalingChannel, AsyncStream, Bool (+2 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "DiscoveryService"
Cohesion: 0.13
Nodes (16): EasyStreamLog, DiscoveryService, .discoveredDevices, AsyncStream, Bool, NWBrowser, NWConnection, NWEndpoint (+8 more)

### Community 46 - "AVCaptureVideoOrientation"
Cohesion: 0.27
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 49 - "DirectorSidebarTab"
Cohesion: 0.18
Nodes (11): .sourceSidebar, DirectorLeftSidebarTabPicker, .body, DirectorSidebarTab, cameras, .id, library, .systemImage (+3 more)

### Community 50 - "SwitchTransitionKind"
Cohesion: 0.09
Nodes (26): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, slide, wipe (+18 more)

### Community 51 - "ProgramCrossfadePlatformView"
Cohesion: 0.23
Nodes (9): Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context, Coordinator, Double, ProposedViewSize (+1 more)

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "ProgramCrossfadePlatformView"
Cohesion: 0.15
Nodes (12): ProgramCrossfadeLayout, CGSize, ProposedViewSize, Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context (+4 more)

### Community 54 - "BroadcastWidgetConfiguration"
Cohesion: 0.06
Nodes (35): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+27 more)

### Community 55 - "H264VideoEncoder"
Cohesion: 0.15
Nodes (13): OSStatus, H264VideoEncoder, AsyncStream, CMTime, CVPixelBuffer, Int32, VideoEncoderError, configurationFailed (+5 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.08
Nodes (23): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+15 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.22
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "CameraSourceTile"
Cohesion: 0.20
Nodes (14): CameraSourceTile, .body, .borderColor, .placeholderMessage, .placeholderSymbolName, Bool, Double, Gesture (+6 more)

### Community 60 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "BroadcastPlatform"
Cohesion: 0.17
Nodes (14): Option, BroadcastPlatform, facebook, rtmp, .shortLabel, youtube, BroadcastPlatformTagRow, .body (+6 more)

### Community 63 - "LiveProgramAirStore"
Cohesion: 0.11
Nodes (19): DirectorProgramAirGraphicsView, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, DirectorProgramVideoBusView, .body, Bool, Double (+11 more)

### Community 64 - "CameraSessionView"
Cohesion: 0.18
Nodes (13): CameraSessionView, .exposureBinding, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, .platformSessionContent, View, .platformSessionContent (+5 more)

### Community 65 - ".content"
Cohesion: 0.12
Nodes (18): Font, NSColor, NSFont, .content, TickerScrollingContent, .body, .measuredSegmentWidth, .tickerLabel (+10 more)

### Community 66 - "CountdownAnimationModifier"
Cohesion: 0.12
Nodes (21): Animation, .body, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY (+13 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.14
Nodes (13): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, .body, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool (+5 more)

### Community 68 - "BroadcastPlaylist"
Cohesion: 0.12
Nodes (17): .playlistsSidebarContent, .playlistsContent, BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title (+9 more)

### Community 69 - "Driver"
Cohesion: 0.27
Nodes (9): CADisplayLink, CFTimeInterval, CVDisplayLink, Driver, ProgramTransitionDisplayLink, Double, Int, TimeInterval (+1 more)

### Community 70 - "BroadcastMetalOverlayProvider"
Cohesion: 0.18
Nodes (10): AnyObject, BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice (+2 more)

### Community 71 - "BroadcastResource"
Cohesion: 0.08
Nodes (27): String, BroadcastMacFilePicker, .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, Void (+19 more)

### Community 72 - "Equatable"
Cohesion: 0.06
Nodes (39): Equatable, SequencePhase, offscreen, onscreen, Phase, empty, offAirWarm, onAir (+31 more)

### Community 73 - ".matches"
Cohesion: 0.24
Nodes (7): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String, Bool

### Community 74 - ".recordFrame"
Cohesion: 0.33
Nodes (8): MutableTrackState, CGSize, Int, RTCVideoFrame, RTCVideoTrack, String, UInt64, TrackSnapshot

### Community 75 - "UIView"
Cohesion: 0.15
Nodes (8): CALayer, ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView, QuartzCore

### Community 76 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.07
Nodes (12): Bool, Int, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer (+4 more)

### Community 77 - "ProgramFrameRingBuffer"
Cohesion: 0.22
Nodes (8): FrameDescriptor, size_t, ProgramFrameRingBuffer, count_, latest, push, slots_, writeIndex_

### Community 78 - "Testing"
Cohesion: 0.14
Nodes (3): EasyStreamTests, deviceIdentityPersistsID(), Testing

### Community 79 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 80 - "CachedWidgetLogoView"
Cohesion: 0.14
Nodes (18): AnyView, NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox (+10 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.09
Nodes (25): MTKView, MTKViewDelegate, MTLCommandQueue, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer, .outgoingRenderer (+17 more)

### Community 82 - "RemoteCameraCommand"
Cohesion: 0.19
Nodes (15): RemoteCameraCommand, applySavedSettings, reconnectStream, setDirectorMonitorQuality, setExposureBias, setLens, setMuted, setSwitcherAssignment (+7 more)

### Community 83 - "BroadcastWidgetPlacement"
Cohesion: 0.15
Nodes (19): AVPlayer, .body, .body, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body (+11 more)

### Community 84 - "DirectorSessionView"
Cohesion: 0.07
Nodes (30): DirectorLibraryRailView, DirectorSessionView, .camerasSidebarContent, .canTake, .compactLayout, .directorWorkspaceLayout, .keyboardShortcuts, .librarySection (+22 more)

### Community 85 - "Foundation"
Cohesion: 0.10
Nodes (7): AVFoundation, CoreMedia, CoreVideo, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox

### Community 86 - "CameraLensKind"
Cohesion: 0.08
Nodes (34): ClosedRange, AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id (+26 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "WebRTCVideoFramePublisher"
Cohesion: 0.26
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 89 - ".makeVideoTextures"
Cohesion: 0.20
Nodes (9): CGImage, BroadcastMetalI420ConversionCache, BroadcastMetalTextureUploader, CVMetalTextureCache, CVPixelBuffer, CVPixelBufferPool, MTLDevice, MTLTexture (+1 more)

### Community 90 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 91 - "Error"
Cohesion: 0.10
Nodes (20): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+12 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "DirectorPreviewMonitorStore"
Cohesion: 0.11
Nodes (15): .body, DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String (+7 more)

### Community 94 - "LayoutNeutralRTCMTLVideoView"
Cohesion: 0.26
Nodes (8): ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGRect, CGSize, NSCoder, ProposedViewSize

### Community 95 - "NSView"
Cohesion: 0.18
Nodes (7): NSView, CGFloat, Double, ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 96 - "FacebookPlatformAuth.swift"
Cohesion: 0.17
Nodes (7): AppTrackingTransparency, EasyStreamFacebook, FacebookCore, FacebookLogin, StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing()

### Community 97 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.14
Nodes (16): .connectionSummary, BroadcastCompactLiveBadge, .body, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body, BroadcastSectionHeader (+8 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.06
Nodes (32): AccessToken, App, CheckedContinuation, EasyStreamApp, Notification, NSWindowDelegate, FacebookAuthService, FacebookTokenParser (+24 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "CameraTransportProfile"
Cohesion: 0.14
Nodes (12): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+4 more)

### Community 102 - "BroadcastMetalTextureUploader.swift"
Cohesion: 0.10
Nodes (16): CoreGraphics, MainActor, Metal, MetalKit, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32 (+8 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.16
Nodes (17): CGPoint, BroadcastDraggableWidgetOverlay, .body, CGFloat, CGRect, CGSize, Gesture, WidgetOverlayContentSizing (+9 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 105 - "ClippingRTCVideoContainer"
Cohesion: 0.20
Nodes (11): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, AVCaptureSession, NSCoder (+3 more)

### Community 106 - "BroadcastStreamSpec"
Cohesion: 0.21
Nodes (11): BroadcastStreamSpec, .displayLabel, PreviewTilePreset, economy, .id, standard, .streamSpec, .title (+3 more)

### Community 107 - "BroadcastGlowButtonStyle"
Cohesion: 0.10
Nodes (18): ButtonStyle, Configuration, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastGlowButtonStyle, BroadcastHiddenToolbarModifier (+10 more)

### Community 108 - "StreamOutputPreset"
Cohesion: 0.17
Nodes (12): StreamOutputPreset, .detail, facebook1080p30, facebook720p30, .id, .platforms, stream540p30, .title (+4 more)

### Community 109 - "ProgramFeedWidgetLayer"
Cohesion: 0.40
Nodes (9): ProgramFeedView, ProgramFeedWidgetLayer, Binding, Bool, Double, RTCVideoTrack, String, URL (+1 more)

### Community 110 - "View"
Cohesion: 0.20
Nodes (14): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body, PreviewMonitorSettingsSheet (+6 more)

### Community 111 - "VideoEncoderConfiguration"
Cohesion: 0.33
Nodes (5): .encoderConfiguration, CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration

### Community 112 - "SignalingMessage"
Cohesion: 0.14
Nodes (12): SignalingMessage, answer, control, hello, ice, offer, settingsState, Decoder (+4 more)

### Community 113 - "NSObject"
Cohesion: 0.12
Nodes (12): AppDelegate, MTLLibrary, NSObject, MTLDevice, BroadcastMetalVideoSink, Slot, incoming, outgoing (+4 more)

### Community 114 - ".detachAndClear"
Cohesion: 0.36
Nodes (3): ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack

### Community 115 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 116 - "IntercomPushToTalkPulseRing"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 117 - ".application"
Cohesion: 0.17
Nodes (11): Any, Bool, UIApplication, UIInterfaceOrientationMask, URL, FacebookSDKBootstrap, Any, Bool (+3 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "BroadcastTheme"
Cohesion: 0.24
Nodes (10): .buttonBackground, BroadcastTheme, .templatePicker, .lensPicker, DirectorSourceListRow, .accentBarColor, .rowBackground, .rowBorder (+2 more)

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "TeamIntercomPeer"
Cohesion: 0.28
Nodes (7): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer

### Community 122 - "WebRTCConfiguration"
Cohesion: 0.29
Nodes (4): RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 123 - "Color"
Cohesion: 0.29
Nodes (7): BroadcastGlassProminentButtonStyle, Color, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges

### Community 124 - "VideoRendererSinkCategory"
Cohesion: 0.19
Nodes (12): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+4 more)

### Community 125 - "CameraCaptureService"
Cohesion: 0.11
Nodes (14): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Double (+6 more)

### Community 126 - "DirectorInspectorSection"
Cohesion: 0.22
Nodes (10): .body, DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorLibraryRailPanel, .body, DirectorSourcesPanel, .body (+2 more)

### Community 127 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 129 - "ProgramFrameRingBuffer.cpp"
Cohesion: 0.40
Nodes (5): FrameDescriptor, size_t, ProgramFrameRingBuffer::latest(), ProgramFrameRingBuffer::ProgramFrameRingBuffer(), ProgramFrameRingBuffer::push()

### Community 130 - "PreviewContainerView"
Cohesion: 0.33
Nodes (5): CameraPreviewView, PreviewContainerView, AVCaptureSession, Context, UIViewRepresentable

### Community 131 - "RemoteWhiteBalanceOption"
Cohesion: 0.22
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 132 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 133 - "ProgramMonitorPreset"
Cohesion: 0.25
Nodes (8): ProgramMonitorPreset, balanced720, .detail, economy540, full1080, .id, light360, .title

### Community 134 - "ProgramFrameNativeStatus"
Cohesion: 0.40
Nodes (4): EasyStreamVideoBusNative, ProgramFrameNativeStatus, .moduleVersion, String

### Community 135 - "FacebookLivePanel"
Cohesion: 0.39
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 136 - ".handleBrowseResults"
Cohesion: 0.31
Nodes (3): NWBrowser, NWTXTRecord, Set

### Community 137 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 138 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 139 - ".extract"
Cohesion: 0.29
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "DiscoveredDevice"
Cohesion: 0.13
Nodes (17): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, DiscoveryEvent (+9 more)

### Community 141 - "IntercomPushToTalkButton"
Cohesion: 0.13
Nodes (21): .controlsSheet, IntercomPushToTalkButton, .activeCornerRadius, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor (+13 more)

### Community 142 - ".boundedSize"
Cohesion: 0.40
Nodes (3): CGSize, ProposedViewSize, VideoPreviewLayout

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+2 more)

### Community 145 - "EncoderCallbackBridge"
Cohesion: 0.43
Nodes (4): EncoderCallbackBridge, Bool, CMSampleBuffer, Void

### Community 147 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 148 - "Coordinator"
Cohesion: 0.18
Nodes (9): DispatchWorkItem, Coordinator, Coordinator, NSObjectProtocol, RTCVideoRenderer, RTCVideoTrack, Void, WebRTCVideoView (+1 more)

### Community 149 - "CodingKeys"
Cohesion: 0.33
Nodes (6): CodingKey, CodingKeys, accessToken, id, name, secureStreamURL

### Community 150 - "CodingKeys"
Cohesion: 0.33
Nodes (6): CodingKeys, outputPreset, prefetchTakeTarget, previewPreset, progPreset, tier

### Community 151 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 152 - "ProgramFrameBusSlot"
Cohesion: 0.10
Nodes (17): .programFrameBusSnapshot, ProgramFrameBusSlot, programIncoming, programOnAir, programOutgoing, ProgramFrameTelemetryNoOp, ProgramFrameTelemetryPort, ProgramFrameTelemetryRegistry (+9 more)

### Community 153 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 154 - "DirectorStatusBar"
Cohesion: 0.67
Nodes (4): DirectorStatusBar, .body, Int, String

### Community 155 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 156 - "DirectorStreamReceiver"
Cohesion: 0.16
Nodes (11): DirectorStreamReceiver, SessionContext, AsyncStream, Int32, NWConnection, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection (+3 more)

### Community 157 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 158 - "WebRTCVideoContentMode"
Cohesion: 0.22
Nodes (9): BoundedWebRTCVideoView, .body, RTCVideoTrack, .videoContent, .videoLayer, .uiMetalMode, WebRTCVideoContentMode, aspectFill (+1 more)

### Community 159 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 160 - "BroadcastFontPreset"
Cohesion: 0.25
Nodes (8): BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded, serif, system

### Community 161 - ".update"
Cohesion: 0.36
Nodes (3): CameraSettingsStore, UUID, Void

### Community 162 - "StreamDestinationPanel"
Cohesion: 0.31
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 163 - "CameraSessionTabletChrome"
Cohesion: 0.40
Nodes (3): CameraSessionTabletChrome, Content, View

### Community 164 - "DirectorRemoteControlsView"
Cohesion: 0.14
Nodes (18): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, DirectorRemoteControlsView (+10 more)

### Community 165 - ".init"
Cohesion: 0.50
Nodes (3): CGRect, NSCoder, NSRect

### Community 166 - "CaseIterable"
Cohesion: 0.29
Nodes (6): CaseIterable, StreamingDeliveryMode, .displayName, hls, rtmps, webrtcLAN

### Community 167 - ".handleOffer"
Cohesion: 0.52
Nodes (3): RTCPeerConnection, RTCMediaConstraints, RTCSessionDescription

### Community 168 - "BroadcastMetalWidgetOverlayContent"
Cohesion: 0.52
Nodes (5): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void

### Community 169 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 170 - ".applyExternalDisplayPreference"
Cohesion: 0.53
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 171 - ".prepareLiveBroadcast"
Cohesion: 0.21
Nodes (3): FacebookLiveService, String, FacebookSessionStore

### Community 172 - "FacebookGraphError"
Cohesion: 0.40
Nodes (5): LocalizedError, FacebookGraphError, apiError, .errorDescription, invalidResponse

### Community 173 - "ProgramFrameNativeCapabilities"
Cohesion: 0.50
Nodes (3): ProgramFrameNativeCapabilities, .busModuleVersion, String

### Community 174 - "NWError"
Cohesion: 0.67
Nodes (3): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool

## Knowledge Gaps
- **537 isolated node(s):** `roleSelection`, `session`, `.platformSessionContent`, `.platformSessionContent`, `.streamBadgeLabel` (+532 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `BroadcastMetalCompositor` connect `BroadcastMetalCompositor` to `BroadcastMetalTextureUploader.swift`, `BroadcastMetalOverlayProvider`, `BroadcastMetalProgramFeedContainerNSView`, `NSObject`, `.makeVideoTextures`, `Sendable`, `.invalidateDisplay`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `EasyStreamUIComponents`, `TransitionPreferencesStore`, `DirectorMonitorQualitySettings`, `Identifiable`, `DirectorSwitcherColumnView`, `DiscoveredDevice`, `ProgramOutputSyncBridge`, `.body`, `ProgramFrameBusSlot`, `BroadcastStreamPublisher`, `DirectorStreamReceiver`, `ProgramVideoEncoderPipeline`, `CameraSourceID`, `ProgramAudioEncoderPipeline`, `.prepareLiveBroadcast`, `DiscoveryService`, `LiveProgramAirStore`, `DirectorSessionView`, `StreamDestination`, `VideoRendererSinkCategory`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `EasyStreamUIComponents`, `TransitionPreferencesStore`, `DirectorMonitorQualitySettings`, `RemoteWhiteBalanceOption`, `Identifiable`, `DirectorSwitcherColumnView`, `CameraSwitcherAssignment`, `EasyStreamCore`, `AppRole`, `BonjourServiceType`, `ProgramFrameBusSlot`, `DirectorProgramOutputStore`, `WebRTCVideoContentMode`, `UIKit`, `CameraSourceID`, `Codable`, `CaseIterable`, `ProgramPreviewVisibilityPolicy`, `.prepareLiveBroadcast`, `FacebookConfiguration`, `ProgramFrameNativeCapabilities`, `Data`, `BroadcastWidgetConfiguration`, `BroadcastResourceRepository`, `StreamConnectionState`, `BroadcastPlaylist`, `BroadcastResource`, `Equatable`, `.matches`, `CameraLensKind`, `Sendable`, `StreamDestination`, `DirectorPreviewMonitorStore`, `NSView`, `FacebookPlatformAuth.swift`, `FacebookWebLoginSession`, `CameraTransportProfile`, `BroadcastStreamSpec`, `VideoEncoderConfiguration`, `TeamIntercomPeer`, `VideoRendererSinkCategory`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `.body` and `DirectorSessionView`) actually correct?**
  _`BroadcastMediaViewModel` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.platformSessionContent` to the rest of the system?**
  _537 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `EasyStreamUIComponents` be split into smaller, more focused modules?**
  _Cohesion score 0.12631578947368421 - nodes in this community are weakly interconnected._