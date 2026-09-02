# Graph Report - EasyStream  (2026-09-01)

## Corpus Check
- 160 files · ~65,785 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2939 nodes · 7047 edges · 143 communities (140 shown, 3 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 583 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2fc13132`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamCore
- Data
- Coordinator
- Color
- FLVBuilder
- CountdownWidgetView
- PlayoutTapAudioDevice
- .apply
- DirectorSessionView
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- BroadcastMediaThumbnailLoader
- RemoteWhiteBalanceOption
- LiveProgramAirStore
- .selectPreview
- View
- DiscoveryService
- CameraSourceID
- DirectorStreamReceiver
- BroadcastMetalProgramFeedContainerNSView
- AppRole
- DirectorSessionViewModel
- DiscoveredDevice
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- DirectorProgramOutputStore
- VideoRendererSinkCategory
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- View
- SwitcherEvent
- ProgramAudioEncoderPipeline
- String
- PreviewMonitorSettings
- DeviceIdentity
- BroadcastWidgetStudioPanel
- RTMPPublisher
- LiveProgramFeedView
- UIKit
- DirectorSessionViewModel.swift
- EasyStreamUITests
- WebRTC
- FacebookConfiguration
- BroadcastWidgetRenderer.swift
- .current
- FacebookLiveService
- PackageDescription
- BroadcastPanelModifier
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetPlacement
- DirectorPreviewMonitorStore
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- CameraSourceTile
- CountdownAnimationModifier
- ProgramCrossfadeContainerUIView
- H264VideoEncoder
- WebRTCConfiguration
- CameraSessionView
- CaseIterable
- BroadcastFontPreset
- TeamIntercomService
- DirectorRemoteControlsView
- Driver
- BroadcastMetalEmptyOverlayProvider
- BroadcastResourceKind
- Equatable
- .matches
- BroadcastResource
- .recreateSession
- BroadcastMetalProgramFeedContainerUIView
- CameraClientControlsView
- Testing
- .apply
- CachedWidgetLogoView
- BroadcastMetalCompositor
- RemoteCameraSettings
- ProgramFeedWidgetLayer
- DirectorSourceListRow
- Foundation
- StreamConnectionState
- BroadcastMetalSwiftUIOverlayProvider
- AACAudioEncoder
- .layerFrame
- BroadcastPlaylistRepository
- Error
- StreamDestination
- WebRTCVideoFramePublisher
- DiscoveryEvent
- CameraTransportProfile
- PreviewMonitorLayoutMode
- BroadcastAudioIntercomPanels.swift
- BroadcastTheme
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- PreviewMonitorCellView
- NSObject
- BroadcastDraggableWidgetOverlay
- BroadcastMetalProgramFeedView
- LayoutNeutralRTCMTLNSVideoView
- DirectorSwitcherColumnView
- Sendable
- WhiteBalanceModeOption
- .tapPCM
- StreamDestinationPanel
- UIView
- BroadcastWidgetConfiguration
- BroadcastMetalVideoSink
- DirectorProgramVideoBusView
- Codable
- IntercomPushToTalkButton
- .application
- WebRTCProgramFrameSink
- EncodedAudioSample
- CodingKeys
- CameraPermissionStatus
- DirectorSidebarTab
- PreviewMultiviewGridSpec
- NSView
- CameraCaptureService
- Event
- CameraLensKind
- ProgramOutputSyncBridge
- EncodedVideoSample
- .applyExternalDisplayPreference
- FacebookPlatformAuthError
- .letterboxRect
- VideoEncoderConfiguration
- RTMPStreamError
- .extract
- ProgramCrossfadeContainerNSView
- Event
- LocalNetworkPermissionTrigger
- BroadcastMetalWidgetOverlayContent
- RoundedRectangle
- TransitionPreferencesStore
- DiscoveredDeviceRow

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 106 edges
2. `BroadcastMediaViewModel` - 88 edges
3. `EasyStreamCore` - 84 edges
4. `BroadcastResource` - 82 edges
5. `CameraSourceID` - 78 edges
6. `BroadcastWidgetConfiguration` - 60 edges
7. `TeamIntercomService` - 55 edges
8. `SwitchTransitionKind` - 50 edges
9. `DirectorSessionView` - 48 edges
10. `CameraSessionViewModel` - 48 edges

## Surprising Connections (you probably didn't know these)
- `.cameraPermissionView` --calls--> `BroadcastGlowButtonStyle`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/BroadcastGlassStyles.swift
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `CameraSessionView` --calls--> `TeamIntercomService`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamTransport/Sources/EasyStreamTransport/TeamIntercomService.swift

## Import Cycles
- None detected.

## Communities (143 total, 3 thin omitted)

### Community 0 - "EasyStreamCore"
Cohesion: 0.11
Nodes (10): AppKit, AVKit, DirectorProgramOutputWindowView, EasyStreamCameraCapture, EasyStreamCore, EasyStreamTransport, EasyStreamUIComponents, ImageIO (+2 more)

### Community 1 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 2 - "Coordinator"
Cohesion: 0.09
Nodes (24): AVCaptureVideoPreviewLayer, CALayer, DispatchWorkItem, boundedSize(), CameraPreviewView, ClippingRTCVideoContainerView, .intrinsicContentSize, Coordinator (+16 more)

### Community 3 - "Color"
Cohesion: 0.15
Nodes (14): ButtonStyle, Configuration, BroadcastGlassBorderedButtonStyle, BroadcastGlassProminentButtonStyle, BroadcastGlowButtonStyle, BroadcastTakeButtonStyle, Bool, LinearGradient (+6 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "CountdownWidgetView"
Cohesion: 0.31
Nodes (7): ClockWidgetView, .body, CountdownWidgetView, .body, .formattedRemaining, Date, String

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.10
Nodes (20): PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels, .isInitialized, .isPlaying (+12 more)

### Community 7 - ".apply"
Cohesion: 0.18
Nodes (11): ProgramCrossfadeHost, ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack, ApplySignature, ProgramCrossfadeSession, Bool, Double (+3 more)

### Community 8 - "DirectorSessionView"
Cohesion: 0.09
Nodes (21): DirectorSessionView, .canTake, .compactLayout, .destinationPanel, .destinationPanelStream, .keyboardShortcuts, .mainSwitcherArea, .programDisplayName (+13 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.13
Nodes (15): .body, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool, Never (+7 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.18
Nodes (11): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+3 more)

### Community 12 - "BroadcastMediaThumbnailLoader"
Cohesion: 0.42
Nodes (6): .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox

### Community 13 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 14 - "LiveProgramAirStore"
Cohesion: 0.15
Nodes (14): DirectorProgramAirGraphicsView, .body, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, URL, UUID, Void (+6 more)

### Community 15 - ".selectPreview"
Cohesion: 0.10
Nodes (21): DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, .previewGrid, .previewGridSection, .previewSelection, .programOutput, Binding (+13 more)

### Community 16 - "View"
Cohesion: 0.16
Nodes (8): BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastHiddenToolbarModifier, BroadcastStudioChromeModifier, CGFloat, Content, View, View

### Community 17 - "DiscoveryService"
Cohesion: 0.14
Nodes (15): EasyStreamLog, DiscoveryService, .discoveredDevices, Bool, NWBrowser, NWConnection, NWEndpoint, NWListener (+7 more)

### Community 18 - "CameraSourceID"
Cohesion: 0.16
Nodes (12): .inspectorSection, ConnectedCameraSource, .outgoingProgramVideoTrack, .previewVideoTrack, .programVideoTrack, Float, RTCAudioTrack, RTCVideoTrack (+4 more)

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.05
Nodes (39): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, DirectorStreamReceiver, Event, failed, sourceAudioTrack, sourceConnected (+31 more)

### Community 20 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.12
Nodes (18): BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, BroadcastMetalProgramFeedPlatformView, Coordinator, CGRect, CGSize (+10 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - "DirectorSessionViewModel"
Cohesion: 0.12
Nodes (16): DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing, .programDisplayTrack, .selectedFacebookPageID, Bool, Double (+8 more)

### Community 23 - "DiscoveredDevice"
Cohesion: 0.11
Nodes (20): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, Bool (+12 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "SignalingMessage"
Cohesion: 0.11
Nodes (17): Encoder, MessageType, answer, control, hello, ice, offer, settingsState (+9 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "DirectorProgramOutputStore"
Cohesion: 0.06
Nodes (36): DirectorProgramOutputStore, .settings, Bool, Double, RTCVideoTrack, String, URL, .body (+28 more)

### Community 28 - "VideoRendererSinkCategory"
Cohesion: 0.12
Nodes (17): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+9 more)

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.08
Nodes (25): .body, .inspectorPanel, .librarySidebarContent, .libraryContent, BroadcastMacFilePicker, BroadcastMediaViewModel, .allResources, .committedLiveAirWidgetLayers (+17 more)

### Community 31 - "View"
Cohesion: 0.17
Nodes (15): Content, PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body (+7 more)

### Community 32 - "SwitcherEvent"
Cohesion: 0.10
Nodes (16): EasyStreamSwitcher, TimeInterval, SwitcherSnapshot, SwitchTransition, Set, SwitcherEngine, .state, SwitcherEvent (+8 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.19
Nodes (9): ProgramAudioEncoderPipeline, AsyncStream, Bool, Data, Double, Never, Task, UInt32 (+1 more)

### Community 34 - "String"
Cohesion: 0.09
Nodes (41): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+33 more)

### Community 35 - "PreviewMonitorSettings"
Cohesion: 0.28
Nodes (7): PreviewMonitorPreferencesStore, PreviewMonitorAppearance, PreviewMonitorOverlayOptions, PreviewMonitorRGBColor, PreviewMonitorSettings, Bool, Double

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (42): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton, .body (+34 more)

### Community 38 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.30
Nodes (14): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, StableProgramVideoView, StableWidgetOverlayView, .body, Bool (+6 more)

### Community 40 - "UIKit"
Cohesion: 0.08
Nodes (16): App, AppTrackingTransparency, EasyStreamApp, .body, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin (+8 more)

### Community 41 - "DirectorSessionViewModel.swift"
Cohesion: 0.17
Nodes (6): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamVideoPipeline, Observation, OSLog

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "WebRTC"
Cohesion: 0.14
Nodes (4): CoreGraphics, Metal, MetalKit, WebRTC

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.16
Nodes (21): AnimatedLogoWidgetView, .body, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView (+13 more)

### Community 46 - ".current"
Cohesion: 0.30
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "FacebookLiveService"
Cohesion: 0.16
Nodes (4): .destinationPanelFacebook, .destinationSection, FacebookLiveService, FacebookSessionStore

### Community 49 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 50 - "SwitchTransitionKind"
Cohesion: 0.16
Nodes (15): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, slide, wipe (+7 more)

### Community 51 - "ProgramCrossfadePlatformView"
Cohesion: 0.15
Nodes (12): ProgramCrossfadeLayout, CGSize, ProposedViewSize, Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context (+4 more)

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "ProgramCrossfadePlatformView"
Cohesion: 0.23
Nodes (9): Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context, Coordinator, Double, ProposedViewSize (+1 more)

### Community 54 - "BroadcastWidgetPlacement"
Cohesion: 0.21
Nodes (14): AVPlayer, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body, BroadcastVideoResourceView, .body (+6 more)

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.15
Nodes (12): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+4 more)

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
Cohesion: 0.16
Nodes (19): CameraSourceTile, .body, .borderColor, .placeholderMessage, .placeholderSymbolName, DirectorStatusBar, .body, Bool (+11 more)

### Community 60 - "CountdownAnimationModifier"
Cohesion: 0.14
Nodes (16): Animation, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .opacity, .scale, LogoAnimationCycle (+8 more)

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "H264VideoEncoder"
Cohesion: 0.22
Nodes (7): EncoderCallbackBridge, H264VideoEncoder, AsyncStream, Bool, CMSampleBuffer, Void, VTCompressionOutputCallback

### Community 63 - "WebRTCConfiguration"
Cohesion: 0.29
Nodes (4): RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 64 - "CameraSessionView"
Cohesion: 0.13
Nodes (15): CameraSessionView, .cameraPermissionView, .connectionSummary, .exposureBinding, .lensLabel, .streamBadgeLabel, .tabletSessionContent, .whiteBalanceBinding (+7 more)

### Community 65 - "CaseIterable"
Cohesion: 0.12
Nodes (15): CaseIterable, BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate (+7 more)

### Community 66 - "BroadcastFontPreset"
Cohesion: 0.08
Nodes (28): Font, NSColor, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced (+20 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.07
Nodes (34): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, .controlsSheet, IntercomConstants, Double, String, UInt16 (+26 more)

### Community 68 - "DirectorRemoteControlsView"
Cohesion: 0.14
Nodes (18): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, DirectorRemoteControlsView (+10 more)

### Community 69 - "Driver"
Cohesion: 0.27
Nodes (9): CADisplayLink, CFTimeInterval, CVDisplayLink, Driver, ProgramTransitionDisplayLink, Double, Int, TimeInterval (+1 more)

### Community 70 - "BroadcastMetalEmptyOverlayProvider"
Cohesion: 0.29
Nodes (6): BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, Bool, CGSize, MTLDevice, MTLTexture

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.15
Nodes (14): BroadcastResourceKind, image, .systemImage, .title, video, widget, DeferredBroadcastLibraryPanel, .body (+6 more)

### Community 72 - "Equatable"
Cohesion: 0.07
Nodes (34): Equatable, SequencePhase, offscreen, onscreen, CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect (+26 more)

### Community 73 - ".matches"
Cohesion: 0.31
Nodes (6): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String

### Community 74 - "BroadcastResource"
Cohesion: 0.17
Nodes (9): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, Date (+1 more)

### Community 75 - ".recreateSession"
Cohesion: 0.21
Nodes (10): OSStatus, CMTime, CVPixelBuffer, Int32, VideoEncoderError, configurationFailed, encodeFailed, sampleExtractionFailed (+2 more)

### Community 76 - "BroadcastMetalProgramFeedContainerUIView"
Cohesion: 0.12
Nodes (7): Bool, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer, .programRenderer, Bool, RTCVideoRenderer

### Community 77 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 78 - "Testing"
Cohesion: 0.11
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - ".apply"
Cohesion: 0.29
Nodes (4): Double, Float, RemoteCameraCommandExecutor, Bool

### Community 80 - "CachedWidgetLogoView"
Cohesion: 0.23
Nodes (12): AnyView, NSImage, .logoAspectRatio, BroadcastWidgetImageLoader, CachedWidgetLogoView, .body, CGFloat, Content (+4 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.10
Nodes (23): MTKView, MTKViewDelegate, MTLCommandQueue, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer, .outgoingRenderer (+15 more)

### Community 82 - "RemoteCameraSettings"
Cohesion: 0.14
Nodes (17): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens, setMuted, setSwitcherAssignment (+9 more)

### Community 83 - "ProgramFeedWidgetLayer"
Cohesion: 0.24
Nodes (13): .body, ProgramFeedView, ProgramFeedWidgetLayer, Binding, Bool, Double, RTCVideoTrack, String (+5 more)

### Community 84 - "DirectorSourceListRow"
Cohesion: 0.23
Nodes (11): DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorSourceListRow, .accentBarColor, .rowBorder, DirectorSourcesPanel, Bool (+3 more)

### Community 85 - "Foundation"
Cohesion: 0.11
Nodes (8): AVFoundation, CoreMedia, CoreVideo, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox, WebKit

### Community 86 - "StreamConnectionState"
Cohesion: 0.22
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 89 - ".layerFrame"
Cohesion: 0.14
Nodes (14): CGImage, BroadcastMetalI420ConversionCache, BroadcastMetalTextureUploader, BroadcastMetalVideoFrame, LayerFrame, CVMetalTextureCache, CVPixelBuffer, CVPixelBufferPool (+6 more)

### Community 90 - "BroadcastPlaylistRepository"
Cohesion: 0.25
Nodes (5): BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL, playlists

### Community 91 - "Error"
Cohesion: 0.14
Nodes (14): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+6 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "WebRTCVideoFramePublisher"
Cohesion: 0.26
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 94 - "DiscoveryEvent"
Cohesion: 0.24
Nodes (8): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired, AsyncStream

### Community 95 - "CameraTransportProfile"
Cohesion: 0.14
Nodes (11): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+3 more)

### Community 96 - "PreviewMonitorLayoutMode"
Cohesion: 0.20
Nodes (10): PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5, .id (+2 more)

### Community 97 - "BroadcastAudioIntercomPanels.swift"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 98 - "BroadcastTheme"
Cohesion: 0.11
Nodes (22): .buttonBackground, .body, BroadcastCompactLiveBadge, .body, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body (+14 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.07
Nodes (28): AccessToken, CheckedContinuation, Notification, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession, Bool (+20 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "PreviewMonitorCellView"
Cohesion: 0.23
Nodes (13): PreviewMonitorCamera, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges, PreviewMonitorMultiviewGrid, .body (+5 more)

### Community 102 - "NSObject"
Cohesion: 0.22
Nodes (9): AppDelegate, MainActor, NSObject, ProgramCrossfadeLetterboxSizeDelegate, CGSize, RTCVideoRenderer, Void, RTCVideoViewDelegate (+1 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.16
Nodes (17): CGPoint, BroadcastDraggableWidgetOverlay, .body, CGFloat, CGRect, CGSize, Gesture, WidgetOverlayContentSizing (+9 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 105 - "LayoutNeutralRTCMTLNSVideoView"
Cohesion: 0.21
Nodes (10): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, CGRect, NSCoder (+2 more)

### Community 106 - "DirectorSwitcherColumnView"
Cohesion: 0.28
Nodes (9): .directorWorkspaceLayout, DirectorMainSwitcherAreaView, .canTake, DirectorSwitcherColumnView, .body, .canTake, .programDisplayName, DirectorTakeBarView (+1 more)

### Community 107 - "Sendable"
Cohesion: 0.44
Nodes (8): AudioEncoderConfiguration, ProgramAudioTapRegistry, Storage, Data, Double, UInt32, Void, Sendable

### Community 108 - "WhiteBalanceModeOption"
Cohesion: 0.25
Nodes (8): WhiteBalanceModeOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 109 - ".tapPCM"
Cohesion: 0.29
Nodes (5): AudioBufferList, AVAudioSourceNode, Double, UInt32, UnsafeMutablePointer

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.31
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 111 - "UIView"
Cohesion: 0.16
Nodes (7): ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView, QuartzCore

### Community 112 - "BroadcastWidgetConfiguration"
Cohesion: 0.06
Nodes (33): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+25 more)

### Community 113 - "BroadcastMetalVideoSink"
Cohesion: 0.18
Nodes (8): RTCVideoFrame, BroadcastMetalVideoSink, Slot, incoming, outgoing, program, CGSize, RTCVideoFrame

### Community 114 - "DirectorProgramVideoBusView"
Cohesion: 0.33
Nodes (6): DirectorProgramVideoBusView, .body, Bool, Double, RTCVideoTrack, String

### Community 115 - "Codable"
Cohesion: 0.06
Nodes (52): Codable, CodingKey, Decodable, Identifiable, LocalizedError, FacebookGraphClient, GraphAPIErrorResponse, GraphError (+44 more)

### Community 116 - "IntercomPushToTalkButton"
Cohesion: 0.15
Nodes (19): IntercomPushToTalkButton, .activeCornerRadius, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor, .subtitle (+11 more)

### Community 117 - ".application"
Cohesion: 0.21
Nodes (9): Any, Bool, UIApplication, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+1 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "EncodedAudioSample"
Cohesion: 0.48
Nodes (4): AudioStreamPacketDescription, EncodedAudioSample, CMTime, Int

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 122 - "DirectorSidebarTab"
Cohesion: 0.15
Nodes (13): .playlistsSidebarContent, .sourceSidebar, DirectorSourceSidebarView, .body, .playlistsContent, DirectorSidebarTab, cameras, .id (+5 more)

### Community 123 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 124 - "NSView"
Cohesion: 0.19
Nodes (7): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow, NSView, CGFloat, Double

### Community 125 - "CameraCaptureService"
Cohesion: 0.14
Nodes (10): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Int32 (+2 more)

### Community 126 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 127 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 128 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 129 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 130 - ".applyExternalDisplayPreference"
Cohesion: 0.53
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 131 - "FacebookPlatformAuthError"
Cohesion: 0.33
Nodes (6): FacebookPlatformAuthError, cancelled, invalidConfiguration, limitedLoginOnly, missingAccessToken, missingPresenter

### Community 132 - ".letterboxRect"
Cohesion: 0.67
Nodes (3): ProgramCrossfadeLetterboxCalculator, CGFloat, CGRect

### Community 134 - "VideoEncoderConfiguration"
Cohesion: 0.39
Nodes (4): CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration

### Community 136 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 139 - ".extract"
Cohesion: 0.28
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.09
Nodes (15): AnyObject, ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder (+7 more)

### Community 144 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 146 - "BroadcastMetalWidgetOverlayContent"
Cohesion: 0.52
Nodes (5): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void

### Community 147 - "RoundedRectangle"
Cohesion: 0.11
Nodes (20): .phoneSessionContent, .buttonShape, CameraTallyGlowOverlay, .body, .glowColor, CameraTallyGlowPlacement, contentFrame, .cornerRadius (+12 more)

### Community 151 - "DiscoveredDeviceRow"
Cohesion: 0.22
Nodes (8): .camerasSidebarContent, .sourceSidebarSection, .camerasContent, DiscoveredDeviceRow, .body, SignalStrengthView, .body, Int

## Knowledge Gaps
- **471 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+466 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `BroadcastMetalCompositor` connect `BroadcastMetalCompositor` to `NSObject`, `WebRTC`, `BroadcastMetalProgramFeedContainerUIView`, `Sendable`, `BroadcastMetalVideoSink`, `BroadcastMetalProgramFeedContainerNSView`, `.layerFrame`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `ProgramOutputSyncBridge`, `DirectorSessionView`, `LiveProgramAirStore`, `.selectPreview`, `DiscoveryService`, `CameraSourceID`, `DirectorStreamReceiver`, `TransitionPreferencesStore`, `DiscoveredDevice`, `BroadcastStreamPublisher`, `VideoRendererSinkCategory`, `ProgramVideoEncoderPipeline`, `SwitcherEvent`, `ProgramAudioEncoderPipeline`, `DirectorSessionViewModel.swift`, `FacebookLiveService`, `StreamConnectionState`, `StreamDestination`, `DirectorSwitcherColumnView`, `DirectorProgramVideoBusView`, `Codable`, `DirectorSidebarTab`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Why does `CameraSourceID` connect `CameraSourceID` to `CameraSessionView`, `SwitcherEvent`, `PreviewMonitorCellView`, `DirectorSessionView`, `CameraSessionViewModel`, `Sendable`, `.selectPreview`, `RemoteCameraSettings`, `Codable`, `DirectorStreamReceiver`, `IntercomPushToTalkButton`, `DirectorSessionViewModel`, `DirectorPreviewMonitorStore`, `StreamConnectionState`, `BonjourServiceType`?**
  _High betweenness centrality (0.071) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _471 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `EasyStreamCore` be split into smaller, more focused modules?**
  _Cohesion score 0.10609756097560975 - nodes in this community are weakly interconnected._