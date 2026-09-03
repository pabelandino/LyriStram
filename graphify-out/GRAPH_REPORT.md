# Graph Report - EasyStream  (2026-09-03)

## Corpus Check
- 187 files · ~70,671 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3331 nodes · 7647 edges · 206 communities (181 shown, 25 thin omitted)
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 562 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e63b5b3d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamCore
- RTMPPublisher
- DirectorMonitorQualitySettings
- BroadcastGlowButtonStyle
- FLVBuilder
- FacebookPage
- PlayoutTapAudioDevice
- ProgramCrossfadeHost
- DirectorSwitcherColumnView
- CameraSessionViewModel
- TransitionUniforms
- Color
- CameraSourceID
- PreviewMonitorCellView
- .connectIfNeeded
- NSView
- WebRTCVideoView
- LocalNetworkPermissionTrigger
- RoundedRectangle
- WebRTC
- BroadcastMetalProgramFeedPlatformView
- AppRole
- Task
- DirectorConnectionPanel
- BonjourServiceType
- Equatable
- BroadcastStreamPublisher
- BroadcastTransmissionMenu
- .invalidateDisplay
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- AppKit
- SwitcherEngine
- ProgramAudioEncoderPipeline
- String
- Codable
- DeviceIdentity
- BroadcastWidgetStudioPanel
- BroadcastWidgetRenderer.swift
- LiveProgramFeedView
- DirectorSessionViewModel
- ProgramPreviewVisibilityPolicy
- EasyStreamUITests
- SignalingChannel
- FacebookConfiguration
- DiscoveryService
- AVCaptureVideoOrientation
- Data
- PackageDescription
- BroadcastMediaLibraryPanel.swift
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetConfiguration
- VideoEncoderError
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- CameraSourceTile
- .body
- ProgramCrossfadeContainerUIView
- View
- DirectorProgramVideoBusView
- CameraSessionView
- BroadcastFontPreset
- CountdownAnimationModifier
- TeamIntercomService
- BroadcastPlaylist
- Driver
- DirectorSettingsSheet
- BroadcastResourceKind
- ProgramTransitionEffect.swift
- .matches
- FacebookSignInRequest
- UIView
- BroadcastMetalProgramFeedContainerUIView
- ProgramFrameRingBuffer
- Testing
- RTMPStreamError
- CachedWidgetLogoView
- BroadcastMetalCompositor
- RemoteCameraCommand
- BroadcastResourceDisplayView
- DirectorSessionView
- Foundation
- Identifiable
- BroadcastMetalSwiftUIOverlayProvider
- WebRTCVideoFramePublisher
- .makeBGRATexture
- Sendable
- Error
- StreamDestination
- DirectorPreviewMonitorStore
- LayoutNeutralRTCMTLVideoView
- .applySlot
- UIKit
- AACAudioEncoder
- BroadcastTheme.swift
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- CameraTransportProfile
- ProgramCrossfadeLetterboxSizeDelegate
- BroadcastDraggableWidgetOverlay
- BroadcastMetalProgramFeedView
- ClippingRTCVideoContainer
- BroadcastStreamSpec
- View
- StreamOutputPreset
- ProgramFeedWidgetLayer
- View
- VideoEncoderStats
- SignalingMessage
- NSObject
- AppOrientationPolicy
- FacebookGraphClient
- IntercomPushToTalkPulseRing
- .application
- WebRTCProgramFrameSink
- BroadcastTheme
- CodingKeys
- TeamIntercomPeer
- WebRTCConfiguration
- DiscoveredDevice
- VideoRendererSinkCategory
- CameraCaptureService
- Image
- Event
- SwitchTransition
- ProgramFrameRingBuffer.cpp
- PreviewContainerView
- CameraClientControlsView
- PreviewMultiviewGridSpec
- TransitionCurve
- ProgramFrameNativeStatus
- BroadcastWidgetTemplate
- .playlistsSidebarContent
- FacebookAuthError
- BroadcastPanelModifier
- .extract
- .body
- IntercomPushToTalkButton
- .sizeThatFits
- ProgramCrossfadeContainerNSView
- H264VideoEncoder
- EasyStreamApp
- Coordinator
- BroadcastResource
- StreamConnectionState
- BroadcastLogoAnimation
- ProgramFrameBusSlot
- State
- BroadcastMetalProgramFeedContainerNSView
- EncodedVideoSample
- CameraSourceID
- String
- WebRTCVideoContentMode
- CameraPermissionStatus
- .handleOffer
- .apply
- StreamDestinationPanel
- BroadcastMediaPhotoImporter
- DirectorRemoteControlsView
- TickerScrollingContent
- .signIn
- DiscoveryEvent
- RemoteCameraSettings.swift
- GraphAPIErrorResponse
- .applyExternalDisplayPreference
- FacebookSession
- .recordFrame
- DirectorProgramOutputStore
- DirectorSessionViewModel.swift
- DirectorStatusBar
- RemoteWhiteBalanceOption
- FacebookLivePanel
- MessageType
- EncoderCallbackBridge
- .tabletSessionContent
- StreamingDeliveryMode
- FacebookGraphError
- .init
- ProgramFrameNativeCapabilities
- Any
- UIApplication
- View
- View
- View
- View
- CGFloat
- NWParameters
- RTCAudioTrack
- Decoder
- Encoder
- Data
- Image
- Gesture
- CVMetalTextureCache
- MTLDevice
- MTLTexture
- SIMD2
- View
- NSSize
- NSObjectProtocol

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 114 edges
2. `EasyStreamCore` - 94 edges
3. `BroadcastMediaViewModel` - 80 edges
4. `BroadcastResource` - 61 edges
5. `BroadcastWidgetConfiguration` - 58 edges
6. `SwitchTransitionKind` - 54 edges
7. `TeamIntercomService` - 53 edges
8. `BroadcastMetalCompositor` - 50 edges
9. `CameraSessionViewModel` - 47 edges
10. `BroadcastWidgetStudioPanel` - 40 edges

## Surprising Connections (you probably didn't know these)
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.phoneSessionContent` --calls--> `CameraTallyGlowOverlay`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView+IOS.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift
- `.controlsSheet` --calls--> `CameraClientControlsView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView+IOS.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraClientControlsView.swift

## Import Cycles
- None detected.

## Communities (206 total, 25 thin omitted)

### Community 0 - "EasyStreamCore"
Cohesion: 0.14
Nodes (7): EasyStreamCameraCapture, EasyStreamCore, EasyStreamTransport, EasyStreamUIComponents, Observation, SwiftUI, UniformTypeIdentifiers

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "DirectorMonitorQualitySettings"
Cohesion: 0.11
Nodes (16): Decoder, Encoder, CodingKeys, outputPreset, prefetchTakeTarget, previewPreset, progPreset, tier (+8 more)

### Community 3 - "BroadcastGlowButtonStyle"
Cohesion: 0.16
Nodes (13): ButtonStyle, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlowButtonStyle, BroadcastTakeButtonStyle, Bool, LinearGradient, .actionButtons (+5 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "FacebookPage"
Cohesion: 0.21
Nodes (10): CodingKey, CodingKeys, accessToken, id, name, secureStreamURL, FacebookLiveVideo, FacebookPage (+2 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "ProgramCrossfadeHost"
Cohesion: 0.13
Nodes (15): ProgramCrossfadeHost, Bool, ProgramTransitionFrame, ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack, VideoRendererSinkCategory, ProgramBusController (+7 more)

### Community 8 - "DirectorSwitcherColumnView"
Cohesion: 0.21
Nodes (14): DirectorMainSwitcherAreaView, .canTake, DirectorProgramOutputCorePanel, .programDisplayName, DirectorSwitcherColumnView, .body, .canTake, .programDisplayName (+6 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.10
Nodes (23): CameraPermissionStatus, .body, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool (+15 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "Color"
Cohesion: 0.10
Nodes (22): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+14 more)

### Community 12 - "CameraSourceID"
Cohesion: 0.20
Nodes (11): DirectorStreamReceiver, .remoteControlsSection, ConnectedCameraSource, CameraSourceID, Double, Float, RTCVideoTrack, StreamConnectionState (+3 more)

### Community 13 - "PreviewMonitorCellView"
Cohesion: 0.23
Nodes (13): PreviewMonitorCamera, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges, PreviewMonitorMultiviewGrid, .body (+5 more)

### Community 14 - ".connectIfNeeded"
Cohesion: 0.17
Nodes (9): ObjectIdentifier, NWBrowser, NWConnection, NWListener, NWParameters, NWTXTRecord, Set, String (+1 more)

### Community 15 - "NSView"
Cohesion: 0.19
Nodes (7): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow, NSView, CGFloat, Double

### Community 16 - "WebRTCVideoView"
Cohesion: 0.19
Nodes (11): AVCaptureVideoPreviewLayer, NSView, CameraPreviewView, Coordinator, AVCaptureSession, Context, Coordinator, RTCVideoTrack (+3 more)

### Community 18 - "RoundedRectangle"
Cohesion: 0.13
Nodes (14): .body, .body, SignalStrengthView, .body, Int, .body, .bottomBar, .leadingLabels (+6 more)

### Community 19 - "WebRTC"
Cohesion: 0.13
Nodes (4): CoreGraphics, Metal, MetalKit, WebRTC

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.22
Nodes (11): BroadcastMetalProgramFeedPlatformView, Coordinator, BroadcastResource, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack (+3 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - "Task"
Cohesion: 0.13
Nodes (7): .destinationSection, .facebookPanel, .streamPanel, Bool, DeviceIdentity, DiscoveryEvent, Task

### Community 23 - "DirectorConnectionPanel"
Cohesion: 0.22
Nodes (10): ConnectionStatusBadge, .body, DirectorConnectionPanel, .body, LocalNetworkPermissionView, .body, Bool, String (+2 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "Equatable"
Cohesion: 0.11
Nodes (21): Equatable, SequencePhase, offscreen, onscreen, Phase, empty, offAirWarm, onAir (+13 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "BroadcastTransmissionMenu"
Cohesion: 0.11
Nodes (22): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, BroadcastTransmissionMenu (+14 more)

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.11
Nodes (14): .body, .liveGraphicsSection, .widgetStudioSection, BroadcastMediaViewModel, .allResources, .directorLiveAirWidgetLayers, .isEditingExistingWidget, .librarySearchText (+6 more)

### Community 31 - "AppKit"
Cohesion: 0.11
Nodes (5): AppKit, AVKit, ImageIO, PlatformSettings, WebKit

### Community 32 - "SwitcherEngine"
Cohesion: 0.17
Nodes (16): EasyStreamSwitcher, CameraSourceID, Set, SwitcherEngine, .state, SwitcherEvent, fallbackChanged, previewChanged (+8 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "String"
Cohesion: 0.20
Nodes (20): BroadcastPlaylist, BroadcastPlaylistKind, BroadcastMediaLibraryPanel, .body, .filteredPlaylists, BroadcastPlaylistEditorSheet, .body, BroadcastPlaylistPanel (+12 more)

### Community 35 - "Codable"
Cohesion: 0.18
Nodes (17): Codable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4 (+9 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (43): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+35 more)

### Community 38 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.11
Nodes (28): AnimatedLogoWidgetView, .body, .placeholderLogo, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, BroadcastWidgetOverlayView (+20 more)

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.23
Nodes (18): .body, BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, PreviewWidgetOverlayView, StableProgramVideoView, StableWidgetOverlayView (+10 more)

### Community 40 - "DirectorSessionViewModel"
Cohesion: 0.08
Nodes (24): ProgramOutputSyncBridge, .body, .stableVideoToken, String, DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing (+16 more)

### Community 41 - "ProgramPreviewVisibilityPolicy"
Cohesion: 0.15
Nodes (13): ProgramPreviewVisibilityPolicy, allConnectedSources, previewSourceOnly, Bool, ProgramRenderBackend, legacyDualWebRTC, metalCompositor, ProgramRenderConfiguration (+5 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "SignalingChannel"
Cohesion: 0.16
Nodes (13): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, Event, connected, disconnected, failed, message (+5 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "DiscoveryService"
Cohesion: 0.14
Nodes (15): EasyStreamLog, DiscoveryService, .discoveredDevices, Bool, NWBrowser, NWConnection, NWEndpoint, NWListener (+7 more)

### Community 46 - "AVCaptureVideoOrientation"
Cohesion: 0.27
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 49 - "BroadcastMediaLibraryPanel.swift"
Cohesion: 0.11
Nodes (20): DirectorLibraryRailView, BroadcastMediaViewModel, .directorWorkspaceLayout, .librarySection, DirectorSourceSidebarView, .body, .camerasContent, BroadcastMediaViewModel (+12 more)

### Community 50 - "SwitchTransitionKind"
Cohesion: 0.10
Nodes (25): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, slide, wipe (+17 more)

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
Cohesion: 0.11
Nodes (21): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+13 more)

### Community 55 - "VideoEncoderError"
Cohesion: 0.29
Nodes (7): OSStatus, CMTime, CVPixelBuffer, VideoEncoderError, encodeFailed, sampleExtractionFailed, sessionCreationFailed

### Community 56 - "CameraStreamClient"
Cohesion: 0.08
Nodes (22): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+14 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.21
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "CameraSourceTile"
Cohesion: 0.17
Nodes (17): .previewGridSection, Gesture, CameraSourceTile, .body, .borderColor, .placeholderMessage, .placeholderSymbolName, Bool (+9 more)

### Community 60 - ".body"
Cohesion: 0.15
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "View"
Cohesion: 0.13
Nodes (26): Option, BroadcastPlatform, facebook, rtmp, .shortLabel, youtube, View, .accentColor (+18 more)

### Community 63 - "DirectorProgramVideoBusView"
Cohesion: 0.09
Nodes (22): DirectorProgramAirGraphicsView, .body, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, DirectorProgramVideoBusView, .body, Bool (+14 more)

### Community 64 - "CameraSessionView"
Cohesion: 0.10
Nodes (17): CameraLensKind, CameraSessionView, .exposureBinding, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, .platformSessionContent, .platformSessionContent (+9 more)

### Community 65 - "BroadcastFontPreset"
Cohesion: 0.10
Nodes (23): Font, NSColor, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced (+15 more)

### Community 66 - "CountdownAnimationModifier"
Cohesion: 0.17
Nodes (13): Animation, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .opacity, .scale, CountdownWidgetView (+5 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.17
Nodes (11): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool, Data (+3 more)

### Community 68 - "BroadcastPlaylist"
Cohesion: 0.10
Nodes (22): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+14 more)

### Community 69 - "Driver"
Cohesion: 0.24
Nodes (10): CADisplayLink, CFTimeInterval, CVDisplayLink, Void, Driver, ProgramTransitionDisplayLink, Double, Int (+2 more)

### Community 70 - "DirectorSettingsSheet"
Cohesion: 0.15
Nodes (10): DirectorPreviewMonitorStore, DirectorSettingsSheet, BroadcastMediaViewModel, BroadcastResource, String, Void, .committedLiveAirWidgetLayers, .previewOverlayWidgetLayers (+2 more)

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.15
Nodes (10): BroadcastMacFilePicker, URL, Void, BroadcastResourceKind, image, .systemImage, .title, video (+2 more)

### Community 72 - "ProgramTransitionEffect.swift"
Cohesion: 0.19
Nodes (12): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, Double, LinearProgress, WipeTransitionEffect (+4 more)

### Community 73 - ".matches"
Cohesion: 0.24
Nodes (7): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String, Bool

### Community 74 - "FacebookSignInRequest"
Cohesion: 0.38
Nodes (5): FacebookNativeAuthBridge, FacebookSignInRequest, Bool, String, SignInHandler

### Community 75 - "UIView"
Cohesion: 0.15
Nodes (8): CALayer, ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView, QuartzCore

### Community 76 - "BroadcastMetalProgramFeedContainerUIView"
Cohesion: 0.12
Nodes (10): Bool, ProgramTransitionFrame, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer, .programRenderer, Bool, ProgramTransitionFrame (+2 more)

### Community 77 - "ProgramFrameRingBuffer"
Cohesion: 0.22
Nodes (8): FrameDescriptor, size_t, ProgramFrameRingBuffer, count_, latest, push, slots_, writeIndex_

### Community 78 - "Testing"
Cohesion: 0.10
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 80 - "CachedWidgetLogoView"
Cohesion: 0.14
Nodes (18): AnyView, NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox (+10 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.10
Nodes (22): BroadcastMetalOverlayProvider, BroadcastMetalVideoFrame, CVMetalTextureCache, MTKView, MTKViewDelegate, MTLCommandQueue, MTLRenderPipelineState, MTLSamplerState (+14 more)

### Community 82 - "RemoteCameraCommand"
Cohesion: 0.18
Nodes (16): RemoteCameraCommand, applySavedSettings, reconnectStream, setDirectorMonitorQuality, setExposureBias, setLens, setMuted, setSwitcherAssignment (+8 more)

### Community 83 - "BroadcastResourceDisplayView"
Cohesion: 0.22
Nodes (12): AVPlayer, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body, BroadcastVideoResourceView, .body, Binding (+4 more)

### Community 84 - "DirectorSessionView"
Cohesion: 0.07
Nodes (28): CGFloat, DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, BroadcastMediaViewModel, DirectorSessionView, .canTake, .compactLayout (+20 more)

### Community 85 - "Foundation"
Cohesion: 0.11
Nodes (6): CoreMedia, CoreVideo, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox

### Community 86 - "Identifiable"
Cohesion: 0.11
Nodes (24): CaseIterable, Identifiable, AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front (+16 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.10
Nodes (22): AnyObject, BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice (+14 more)

### Community 88 - "WebRTCVideoFramePublisher"
Cohesion: 0.27
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 89 - ".makeBGRATexture"
Cohesion: 0.17
Nodes (11): CGImage, BroadcastMetalTextureUploader, BroadcastMetalVideoFrame, LayerFrame, CVMetalTextureCache, CVPixelBuffer, Float, MTLDevice (+3 more)

### Community 90 - "Sendable"
Cohesion: 0.23
Nodes (14): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+6 more)

### Community 91 - "Error"
Cohesion: 0.10
Nodes (20): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+12 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "DirectorPreviewMonitorStore"
Cohesion: 0.12
Nodes (13): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+5 more)

### Community 94 - "LayoutNeutralRTCMTLVideoView"
Cohesion: 0.22
Nodes (9): ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGRect, CGSize, NSCoder, ProposedViewSize (+1 more)

### Community 95 - ".applySlot"
Cohesion: 0.33
Nodes (4): ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 96 - "UIKit"
Cohesion: 0.11
Nodes (11): AppTrackingTransparency, AVFoundation, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin, CameraStreamConfiguration, AVCaptureSession (+3 more)

### Community 97 - "AACAudioEncoder"
Cohesion: 0.18
Nodes (9): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32, AudioEncoderStats (+1 more)

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.15
Nodes (16): .connectionSummary, .camerasSidebarContent, .body, BroadcastCompactLiveBadge, .body, BroadcastFormField, BroadcastInspectorEmptyState, .body (+8 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.14
Nodes (14): CheckedContinuation, Notification, NSWindowDelegate, FacebookWebLoginSession, Bool, Error, NSWindow, Void (+6 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "CameraTransportProfile"
Cohesion: 0.13
Nodes (13): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+5 more)

### Community 102 - "ProgramCrossfadeLetterboxSizeDelegate"
Cohesion: 0.22
Nodes (9): MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect, CGSize, RTCVideoRenderer, Void (+1 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.18
Nodes (15): CGPoint, BroadcastDraggableWidgetOverlay, .body, CGFloat, CGRect, CGSize, Gesture, WidgetPlacementChrome (+7 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.36
Nodes (9): BroadcastMetalProgramFeedView, .body, Bool, BroadcastResource, Double, RTCVideoTrack, URL, UUID (+1 more)

### Community 105 - "ClippingRTCVideoContainer"
Cohesion: 0.26
Nodes (9): NSSize, ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, NSCoder (+1 more)

### Community 106 - "BroadcastStreamSpec"
Cohesion: 0.11
Nodes (21): BroadcastStreamSpec, .displayLabel, PreviewTilePreset, economy, .id, standard, .streamSpec, .title (+13 more)

### Community 107 - "View"
Cohesion: 0.14
Nodes (9): Configuration, BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastHiddenToolbarModifier, BroadcastStudioChromeModifier, CGFloat, Content, View (+1 more)

### Community 108 - "StreamOutputPreset"
Cohesion: 0.12
Nodes (17): StreamOutputPreset, .detail, .encoderConfiguration, facebook1080p30, facebook720p30, .id, .platforms, stream540p30 (+9 more)

### Community 109 - "ProgramFeedWidgetLayer"
Cohesion: 0.19
Nodes (18): BroadcastWidgetConfiguration, BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void, ProgramFeedView, .body (+10 more)

### Community 110 - "View"
Cohesion: 0.20
Nodes (14): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body, PreviewMonitorSettingsSheet (+6 more)

### Community 111 - "VideoEncoderStats"
Cohesion: 0.26
Nodes (7): CameraTransportDefaults, Bool, Int, Int32, VideoEncoderConfiguration, VideoEncoderStats, .estimatedBitrateKbps

### Community 112 - "SignalingMessage"
Cohesion: 0.14
Nodes (12): SignalingMessage, answer, control, hello, ice, offer, settingsState, Decoder (+4 more)

### Community 113 - "NSObject"
Cohesion: 0.11
Nodes (13): AppDelegate, MTLDevice, MTLLibrary, NSObject, RTCVideoFrame, BroadcastMetalVideoSink, Slot, incoming (+5 more)

### Community 114 - "AppOrientationPolicy"
Cohesion: 0.24
Nodes (5): AppOrientationPolicy, UIInterfaceOrientationMask, CameraSessionTabletChrome, Content, .phoneSessionContent

### Community 115 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 116 - "IntercomPushToTalkPulseRing"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 117 - ".application"
Cohesion: 0.17
Nodes (11): Any, Bool, UIInterfaceOrientationMask, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+3 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "BroadcastTheme"
Cohesion: 0.23
Nodes (11): BroadcastTheme, .templatePicker, .lensPicker, DirectorSourceListRow, .accentBarColor, .body, .rowBackground, .rowBorder (+3 more)

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "TeamIntercomPeer"
Cohesion: 0.24
Nodes (7): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer

### Community 122 - "WebRTCConfiguration"
Cohesion: 0.29
Nodes (4): RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 123 - "DiscoveredDevice"
Cohesion: 0.17
Nodes (12): .sourceSidebarSection, Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved (+4 more)

### Community 124 - "VideoRendererSinkCategory"
Cohesion: 0.15
Nodes (12): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+4 more)

### Community 125 - "CameraCaptureService"
Cohesion: 0.14
Nodes (10): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Int32 (+2 more)

### Community 126 - "Image"
Cohesion: 0.13
Nodes (19): .sourceSidebar, Image, BroadcastAsyncThumbnailImage, .body, BroadcastResourceThumbnail, .body, .content, .body (+11 more)

### Community 127 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 128 - "SwitchTransition"
Cohesion: 0.20
Nodes (8): .takeBar, .transitionSection, .selectedTransition, TimeInterval, SwitchTransition, TransitionPreferencesStore, SwitchTransitionControls, .body

### Community 129 - "ProgramFrameRingBuffer.cpp"
Cohesion: 0.40
Nodes (5): FrameDescriptor, size_t, ProgramFrameRingBuffer::latest(), ProgramFrameRingBuffer::ProgramFrameRingBuffer(), ProgramFrameRingBuffer::push()

### Community 130 - "PreviewContainerView"
Cohesion: 0.29
Nodes (6): CameraPreviewView, PreviewContainerView, AVCaptureSession, Context, UIView, UIViewRepresentable

### Community 131 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 132 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 133 - "TransitionCurve"
Cohesion: 0.25
Nodes (6): Double, LinearProgress, TransitionCurve, easeInOutCubic, linear, smoothStep

### Community 134 - "ProgramFrameNativeStatus"
Cohesion: 0.40
Nodes (4): EasyStreamVideoBusNative, ProgramFrameNativeStatus, .moduleVersion, String

### Community 135 - "BroadcastWidgetTemplate"
Cohesion: 0.15
Nodes (13): BroadcastWidgetTemplate, animatedLogo, clock, countdown, logo, lowerThird, lowerThirdPro, .mentoTemplates (+5 more)

### Community 137 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 138 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 139 - ".extract"
Cohesion: 0.28
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - ".body"
Cohesion: 0.27
Nodes (4): .body, Data, Int, String

### Community 141 - "IntercomPushToTalkButton"
Cohesion: 0.13
Nodes (22): .controlsSheet, IntercomPushToTalkButton, .activeCornerRadius, .buttonBackground, .buttonShape, .iconName, .idleCornerRadius, .isLive (+14 more)

### Community 142 - ".sizeThatFits"
Cohesion: 0.25
Nodes (5): CGSize, ProposedViewSize, VideoPreviewLayout, CGSize, ProposedViewSize

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+2 more)

### Community 145 - "H264VideoEncoder"
Cohesion: 0.26
Nodes (6): H264VideoEncoder, AsyncStream, Int32, configurationFailed, VTCompressionOutputCallback, VTCompressionSession

### Community 147 - "EasyStreamApp"
Cohesion: 0.18
Nodes (7): App, EasyStreamApp, .body, DirectorProgramOutputWindowView, EasyStreamFacebookLoginSetup, ProgramInfrastructureBootstrap, Scene

### Community 148 - "Coordinator"
Cohesion: 0.23
Nodes (9): DispatchWorkItem, NSObjectProtocol, Coordinator, Coordinator, RTCVideoTrack, VideoRendererSinkCategory, Void, WebRTCVideoView (+1 more)

### Community 149 - "BroadcastResource"
Cohesion: 0.21
Nodes (9): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, Date (+1 more)

### Community 150 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 151 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 152 - "ProgramFrameBusSlot"
Cohesion: 0.12
Nodes (16): .programFrameBusSnapshot, ProgramFrameBusSlot, programIncoming, programOnAir, programOutgoing, ProgramFrameTelemetryNoOp, ProgramFrameTelemetryPort, ProgramFrameTelemetryRegistry (+8 more)

### Community 153 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 154 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.12
Nodes (5): Int, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer

### Community 155 - "EncodedVideoSample"
Cohesion: 0.24
Nodes (10): EncodedVideoSample, CMFormatDescription, CMTime, Data, Event, failed, sample, started (+2 more)

### Community 156 - "CameraSourceID"
Cohesion: 0.16
Nodes (11): CameraSourceID, .id, UUID, DirectorStreamReceiver, SessionContext, AsyncStream, NWConnection, RTCMediaStreamTrack (+3 more)

### Community 157 - "String"
Cohesion: 0.27
Nodes (4): FacebookAuthService, FacebookTokenParser, String, URL

### Community 158 - "WebRTCVideoContentMode"
Cohesion: 0.21
Nodes (10): BoundedWebRTCVideoView, .body, RTCVideoTrack, VideoRendererSinkCategory, .videoContent, .videoLayer, .uiMetalMode, WebRTCVideoContentMode (+2 more)

### Community 159 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 160 - ".handleOffer"
Cohesion: 0.27
Nodes (6): RTCPeerConnection, Int32, RTCIceCandidate, RTCMediaConstraints, RTCSessionDescription, UUID

### Community 161 - ".apply"
Cohesion: 0.35
Nodes (4): CameraCaptureService, Double, Float, RemoteCameraCommandExecutor

### Community 162 - "StreamDestinationPanel"
Cohesion: 0.31
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 163 - "BroadcastMediaPhotoImporter"
Cohesion: 0.20
Nodes (10): BroadcastResourceKind, Data, CameraSessionTabletChrome, Content, BroadcastMediaPhotoImporter, BroadcastWidgetLogoPhotoImporter, Bool, Content (+2 more)

### Community 164 - "DirectorRemoteControlsView"
Cohesion: 0.14
Nodes (18): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, DirectorRemoteControlsView (+10 more)

### Community 165 - "TickerScrollingContent"
Cohesion: 0.29
Nodes (9): .body, ClockWidgetView, .body, Date, String, TickerScrollingContent, TickerWidgetView, .body (+1 more)

### Community 166 - ".signIn"
Cohesion: 0.33
Nodes (5): AccessToken, FacebookPlatformAuth, Bool, String, UIViewController

### Community 167 - "DiscoveryEvent"
Cohesion: 0.24
Nodes (8): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired, AsyncStream

### Community 168 - "RemoteCameraSettings.swift"
Cohesion: 0.29
Nodes (4): CameraSettingsStore, CameraSourceID, UUID, SwitcherSnapshot

### Community 169 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 170 - ".applyExternalDisplayPreference"
Cohesion: 0.53
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 171 - "FacebookSession"
Cohesion: 0.19
Nodes (6): FacebookLiveService, String, FacebookSession, .isSignedIn, Bool, FacebookSessionStore

### Community 172 - ".recordFrame"
Cohesion: 0.33
Nodes (8): MutableTrackState, CGSize, Int, RTCVideoFrame, RTCVideoTrack, String, UInt64, TrackSnapshot

### Community 173 - "DirectorProgramOutputStore"
Cohesion: 0.56
Nodes (6): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL

### Community 174 - "DirectorSessionViewModel.swift"
Cohesion: 0.22
Nodes (5): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamVideoPipeline, OSLog

### Community 175 - "DirectorStatusBar"
Cohesion: 0.50
Nodes (6): AudioEncoderStats, DirectorStatusBar, .body, Int, String, VideoEncoderStats

### Community 176 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 177 - "FacebookLivePanel"
Cohesion: 0.39
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 178 - "MessageType"
Cohesion: 0.29
Nodes (7): MessageType, answer, control, hello, ice, offer, settingsState

### Community 179 - "EncoderCallbackBridge"
Cohesion: 0.43
Nodes (4): EncoderCallbackBridge, Bool, CMSampleBuffer, Void

### Community 180 - ".tabletSessionContent"
Cohesion: 0.40
Nodes (3): .tabletSessionContent, .body, UUID

### Community 181 - "StreamingDeliveryMode"
Cohesion: 0.33
Nodes (5): StreamingDeliveryMode, .displayName, hls, rtmps, webrtcLAN

### Community 182 - "FacebookGraphError"
Cohesion: 0.40
Nodes (5): LocalizedError, FacebookGraphError, apiError, .errorDescription, invalidResponse

### Community 183 - ".init"
Cohesion: 0.50
Nodes (3): CGRect, NSCoder, NSRect

### Community 184 - "ProgramFrameNativeCapabilities"
Cohesion: 0.50
Nodes (3): ProgramFrameNativeCapabilities, .busModuleVersion, String

## Knowledge Gaps
- **545 isolated node(s):** `.platformSessionContent`, `.platformSessionContent`, `.streamBadgeLabel`, `.directorCommittedAirLayers`, `.switcherLayout` (+540 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **25 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `EasyStreamCore` connect `EasyStreamCore` to `UIKit`, `SwitcherEngine`, `BroadcastTheme.swift`, `BroadcastWidgetRenderer.swift`, `LiveProgramFeedView`, `ProgramTransitionEffect.swift`, `PreviewMonitorCellView`, `Testing`, `DirectorSessionViewModel.swift`, `BroadcastMediaLibraryPanel.swift`, `WebRTC`, `EasyStreamApp`, `Foundation`, `Equatable`, `View`, `AppKit`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `SwitchTransition`, `DirectorMonitorQualitySettings`, `DirectorSwitcherColumnView`, `CameraSourceID`, `Task`, `ProgramFrameBusSlot`, `BroadcastStreamPublisher`, `ProgramVideoEncoderPipeline`, `SwitcherEngine`, `ProgramAudioEncoderPipeline`, `FacebookSession`, `DiscoveryService`, `DirectorSessionViewModel.swift`, `BroadcastMediaLibraryPanel.swift`, `DirectorProgramVideoBusView`, `DirectorSettingsSheet`, `DirectorSessionView`, `StreamDestination`, `VideoRendererSinkCategory`?**
  _High betweenness centrality (0.078) - this node is a cross-community bridge._
- **Why does `SwitchTransitionKind` connect `SwitchTransitionKind` to `SwitchTransition`, `Codable`, `ProgramCrossfadeHost`, `RemoteCameraSettings.swift`, `BroadcastMetalProgramFeedView`, `ProgramTransitionEffect.swift`, `LiveProgramFeedView`, `DirectorProgramOutputStore`, `ProgramFeedWidgetLayer`, `RemoteCameraCommand`, `ProgramCrossfadePlatformView`, `BroadcastMetalProgramFeedPlatformView`, `ProgramCrossfadePlatformView`, `Identifiable`, `Equatable`, `Sendable`, `CameraSourceTile`, `DirectorProgramVideoBusView`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Are the 12 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 12 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `.body` and `.widgetStudioSection`) actually correct?**
  _`BroadcastMediaViewModel` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.platformSessionContent`, `.platformSessionContent`, `.streamBadgeLabel` to the rest of the system?**
  _545 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `EasyStreamCore` be split into smaller, more focused modules?**
  _Cohesion score 0.13949579831932774 - nodes in this community are weakly interconnected._