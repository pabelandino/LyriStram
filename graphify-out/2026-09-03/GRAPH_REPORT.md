# Graph Report - EasyStream  (2026-09-03)

## Corpus Check
- 187 files · ~70,671 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3247 nodes · 7677 edges · 166 communities (161 shown, 5 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 590 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2eeb5674`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- SwiftUI
- RTMPPublisher
- DirectorMonitorQualitySettings
- BroadcastGlowButtonStyle
- FLVBuilder
- Identifiable
- PlayoutTapAudioDevice
- ProgramCrossfadeHost
- DirectorSwitcherColumnView
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- CameraSourceID
- Color
- TeamIntercomService
- NSView
- WebRTCVideoView
- LocalNetworkPermissionTrigger
- SignalStrengthView
- EasyStreamCore
- BroadcastMetalProgramFeedPlatformView
- AppRole
- DirectorSessionViewModel
- DiscoveredDevice
- EasyStreamLog
- Equatable
- BroadcastStreamPublisher
- DirectorProgramOutputStore
- .invalidateDisplay
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- UIKit
- SwitcherEngine
- ProgramAudioEncoderPipeline
- String
- Codable
- DeviceIdentity
- BroadcastWidgetStudioPanel
- BroadcastWidgetRenderer.swift
- LiveProgramFeedView
- LogoAnimationModifier
- Sendable
- EasyStreamUITests
- SignalingChannel
- FacebookConfiguration
- DiscoveryService
- AVCaptureVideoOrientation
- Data
- PackageDescription
- CaseIterable
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryEvent
- ProgramCrossfadePlatformView
- BroadcastWidgetConfiguration
- .recreateSession
- CameraStreamClient
- .decode
- BroadcastResource
- DirectorRemoteControlsView
- .requestDraw
- ProgramCrossfadeContainerUIView
- BroadcastSpecChipModel
- LiveProgramAirStore
- CameraSessionView
- BroadcastFontPreset
- CountdownAnimationModifier
- .startCaptureEngine
- BroadcastPlaylistRepository
- Driver
- BroadcastMetalOverlayProvider
- BroadcastResourceKind
- ProgramTransitionEffect.swift
- .matches
- FacebookSignInRequest
- UIView
- BroadcastMetalProgramFeedContainerNSView
- ProgramFrameRingBuffer
- Testing
- RTMPStreamError
- .content
- BroadcastMetalCompositor
- RemoteCameraCommand
- View
- DirectorSessionView
- Foundation
- CameraLensKind
- BroadcastMetalSwiftUIOverlayProvider
- WebRTCVideoFramePublisher
- .makeVideoTextures
- EncodedAudioSample
- Error
- StreamDestination
- DirectorPreviewMonitorStore
- LayoutNeutralRTCMTLVideoView
- .applySlot
- DirectorSessionViewModel.swift
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
- Void
- VideoEncoderConfiguration
- SignalingMessage
- NSObject
- AppOrientationPolicy
- FacebookGraphClient
- IntercomPushToTalkButton
- .application
- WebRTCProgramFrameSink
- RoundedRectangle
- CodingKeys
- TeamIntercomPeer
- WebRTCConfiguration
- BroadcastMediaThumbnailLoader
- VideoRendererSinkCategory
- CameraCaptureService
- DirectorInspectorSection
- Event
- BroadcastPlatform
- ProgramFrameRingBuffer.cpp
- PreviewContainerView
- .liveTileTrack
- PreviewMultiviewGridSpec
- TransitionCurve
- ProgramFrameNativeStatus
- CameraStreamConfiguration.swift
- .playlistsSidebarContent
- FacebookAuthError
- BroadcastPanelModifier
- .extract
- BroadcastSpecChip
- TeamIntercomPanel
- .sizeThatFits
- ProgramCrossfadeContainerNSView
- H264VideoEncoder
- EasyStreamApp
- Coordinator
- Phase
- CodingKeys
- BroadcastLogoAnimation
- ProgramFrameBusSlot
- State
- .lockProgramContentSizeFromProgramFrame
- Event
- DirectorStreamReceiver
- EncodedVideoSample
- WebRTCVideoContentMode
- CameraPermissionStatus
- StreamDestinationPanel
- CameraSessionTabletChrome
- RemoteLensOption
- GraphAPIErrorResponse
- .applyExternalDisplayPreference
- FacebookSession

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
- `.phoneSessionContent` --calls--> `CameraTallyGlowOverlay`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView+IOS.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift
- `.previewHeader` --calls--> `CameraAssignmentBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView+IOS.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift

## Import Cycles
- None detected.

## Communities (166 total, 5 thin omitted)

### Community 0 - "SwiftUI"
Cohesion: 0.14
Nodes (5): EasyStreamCameraCapture, EasyStreamTransport, EasyStreamUIComponents, SwiftUI, UniformTypeIdentifiers

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "DirectorMonitorQualitySettings"
Cohesion: 0.17
Nodes (10): DirectorMonitorQualityPreferencesStore, DirectorMonitorQualitySettings, .outputEncoderConfiguration, LegacyTier, balanced, economy, high, Bool (+2 more)

### Community 3 - "BroadcastGlowButtonStyle"
Cohesion: 0.15
Nodes (13): ButtonStyle, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlassProminentButtonStyle, BroadcastGlowButtonStyle, BroadcastTakeButtonStyle, Bool, LinearGradient (+5 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "Identifiable"
Cohesion: 0.14
Nodes (15): CodingKey, Identifiable, LocalizedError, CodingKeys, accessToken, id, name, secureStreamURL (+7 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "ProgramCrossfadeHost"
Cohesion: 0.12
Nodes (15): ProgramCrossfadeHost, Bool, ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack, ProgramBusController, Snapshot, Bool (+7 more)

### Community 8 - "DirectorSwitcherColumnView"
Cohesion: 0.31
Nodes (8): DirectorMainSwitcherAreaView, .canTake, DirectorSwitcherColumnView, .body, .canTake, .programDisplayName, DirectorTakeBarView, Bool

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.10
Nodes (18): .body, .tabletSessionContent, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool (+10 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.11
Nodes (20): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+12 more)

### Community 12 - "CameraSourceID"
Cohesion: 0.11
Nodes (17): .keyboardShortcuts, .remoteControlsSection, ConnectedCameraSource, .outgoingProgramVideoTrack, .previewVideoTrack, .programBusIncomingTrack, .programVideoTrack, Double (+9 more)

### Community 13 - "Color"
Cohesion: 0.21
Nodes (14): Color, PreviewMonitorCamera, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges, PreviewMonitorMultiviewGrid (+6 more)

### Community 14 - "TeamIntercomService"
Cohesion: 0.17
Nodes (13): ObjectIdentifier, Never, NWBrowser, NWConnection, NWListener, NWParameters, NWTXTRecord, Set (+5 more)

### Community 15 - "NSView"
Cohesion: 0.19
Nodes (7): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow, NSView, CGFloat, Double

### Community 16 - "WebRTCVideoView"
Cohesion: 0.20
Nodes (9): AVCaptureVideoPreviewLayer, CameraPreviewView, Coordinator, AVCaptureSession, Context, Coordinator, RTCVideoTrack, WebRTCVideoView (+1 more)

### Community 18 - "SignalStrengthView"
Cohesion: 0.50
Nodes (4): .body, SignalStrengthView, .body, Int

### Community 19 - "EasyStreamCore"
Cohesion: 0.14
Nodes (4): EasyStreamCore, Metal, MetalKit, WebRTC

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.23
Nodes (10): BroadcastMetalProgramFeedPlatformView, Coordinator, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack, URL (+2 more)

### Community 21 - "AppRole"
Cohesion: 0.08
Nodes (28): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+20 more)

### Community 22 - "DirectorSessionViewModel"
Cohesion: 0.08
Nodes (26): .body, .destinationSection, DirectorSettingsSheet, .facebookPanel, .streamPanel, Void, ProgramOutputSyncBridge, .body (+18 more)

### Community 23 - "DiscoveredDevice"
Cohesion: 0.10
Nodes (23): .sourceSidebarSection, NWParameters, Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed (+15 more)

### Community 24 - "EasyStreamLog"
Cohesion: 0.15
Nodes (14): BonjourServiceType, camera, director, intercom, .isSignalingService, .networkType, .plistEntry, NetworkConstants (+6 more)

### Community 25 - "Equatable"
Cohesion: 0.18
Nodes (14): Equatable, SequencePhase, offscreen, onscreen, ProgramTransitionFrame, .usesVisualTransform, ProgramTransitionLifecycle, ProgramTransitionPresentationMode (+6 more)

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
Cohesion: 0.07
Nodes (22): .body, .liveGraphicsSection, .widgetStudioSection, String, BroadcastMediaViewModel, .allResources, .committedLiveAirWidgetLayers, .directorLiveAirWidgetLayers (+14 more)

### Community 31 - "UIKit"
Cohesion: 0.11
Nodes (7): AppKit, AVKit, ImageIO, PlatformSettings, PhotosUI, UIKit, WebKit

### Community 32 - "SwitcherEngine"
Cohesion: 0.10
Nodes (20): .selectedTransition, EasyStreamSwitcher, TimeInterval, SwitcherSnapshot, SwitchTransition, TransitionPreferencesStore, Set, SwitcherEngine (+12 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "String"
Cohesion: 0.08
Nodes (43): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+35 more)

### Community 35 - "Codable"
Cohesion: 0.18
Nodes (17): Codable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4 (+9 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (41): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+33 more)

### Community 38 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.18
Nodes (18): AnimatedLogoWidgetView, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView, .body (+10 more)

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.33
Nodes (13): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, StableProgramVideoView, StableWidgetOverlayView, Bool, Double (+5 more)

### Community 40 - "LogoAnimationModifier"
Cohesion: 0.26
Nodes (9): .body, LogoAnimationCycle, LogoAnimationModifier, .anim, LogoMotionContainer, .body, Content, Double (+1 more)

### Community 41 - "Sendable"
Cohesion: 0.17
Nodes (12): ProgramPreviewVisibilityPolicy, allConnectedSources, previewSourceOnly, ProgramRenderBackend, legacyDualWebRTC, metalCompositor, ProgramRenderConfiguration, ProgramFrameNativeCapabilities (+4 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "SignalingChannel"
Cohesion: 0.15
Nodes (13): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, Event, connected, disconnected, failed, message (+5 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "DiscoveryService"
Cohesion: 0.16
Nodes (12): DiscoveryService, .discoveredDevices, AsyncStream, Bool, NWConnection, NWEndpoint, NWListener, Sendable (+4 more)

### Community 46 - "AVCaptureVideoOrientation"
Cohesion: 0.27
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 49 - "CaseIterable"
Cohesion: 0.12
Nodes (15): CaseIterable, StreamingDeliveryMode, .displayName, hls, rtmps, webrtcLAN, DirectorSidebarTab, cameras (+7 more)

### Community 50 - "SwitchTransitionKind"
Cohesion: 0.09
Nodes (26): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, slide, wipe (+18 more)

### Community 51 - "ProgramCrossfadePlatformView"
Cohesion: 0.15
Nodes (12): ProgramCrossfadeLayout, CGSize, ProposedViewSize, Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context (+4 more)

### Community 52 - "DiscoveryEvent"
Cohesion: 0.16
Nodes (12): DiscoveryViewModel, Never, String, Task, Void, DiscoveryEvent, advertisingFailed, browsingFailed (+4 more)

### Community 53 - "ProgramCrossfadePlatformView"
Cohesion: 0.21
Nodes (10): Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context, Coordinator, Double, ProposedViewSize (+2 more)

### Community 54 - "BroadcastWidgetConfiguration"
Cohesion: 0.06
Nodes (35): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+27 more)

### Community 55 - ".recreateSession"
Cohesion: 0.21
Nodes (10): OSStatus, CMTime, CVPixelBuffer, Int32, VideoEncoderError, configurationFailed, encodeFailed, sampleExtractionFailed (+2 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.09
Nodes (21): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+13 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResource"
Cohesion: 0.13
Nodes (17): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, Date (+9 more)

### Community 59 - "DirectorRemoteControlsView"
Cohesion: 0.12
Nodes (27): CameraSourceTile, .borderColor, .placeholderMessage, .placeholderSymbolName, DirectorRemoteControlsView, .body, .connectionStateLabel, .exposureControl (+19 more)

### Community 60 - ".requestDraw"
Cohesion: 0.19
Nodes (6): RTCVideoFrame, BroadcastMetalVideoFrame, LayerFrame, Float, RTCVideoFrame, SIMD2

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "BroadcastSpecChipModel"
Cohesion: 0.19
Nodes (13): Option, BroadcastQualityDropdown, BroadcastSettingsInfoCallout, .body, BroadcastSettingsToggleRow, .body, BroadcastSpecChipModel, DirectorVideoQualityPanel (+5 more)

### Community 63 - "LiveProgramAirStore"
Cohesion: 0.11
Nodes (19): DirectorProgramAirGraphicsView, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, DirectorProgramVideoBusView, .body, Bool, Double (+11 more)

### Community 64 - "CameraSessionView"
Cohesion: 0.15
Nodes (14): CameraSessionView, .exposureBinding, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, .platformSessionContent, View, .platformSessionContent (+6 more)

### Community 65 - "BroadcastFontPreset"
Cohesion: 0.10
Nodes (24): Font, NSColor, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced (+16 more)

### Community 66 - "CountdownAnimationModifier"
Cohesion: 0.13
Nodes (18): Animation, .placeholderLogo, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY (+10 more)

### Community 67 - ".startCaptureEngine"
Cohesion: 0.15
Nodes (8): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool, Data

### Community 68 - "BroadcastPlaylistRepository"
Cohesion: 0.33
Nodes (4): BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL

### Community 69 - "Driver"
Cohesion: 0.27
Nodes (9): CADisplayLink, CFTimeInterval, CVDisplayLink, Driver, ProgramTransitionDisplayLink, Double, Int, TimeInterval (+1 more)

### Community 70 - "BroadcastMetalOverlayProvider"
Cohesion: 0.18
Nodes (10): AnyObject, BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice (+2 more)

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.12
Nodes (17): BroadcastMacFilePicker, Void, BroadcastResourceKind, image, .systemImage, .title, video, widget (+9 more)

### Community 72 - "ProgramTransitionEffect.swift"
Cohesion: 0.19
Nodes (12): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, Double, LinearProgress, WipeTransitionEffect (+4 more)

### Community 73 - ".matches"
Cohesion: 0.31
Nodes (6): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String

### Community 74 - "FacebookSignInRequest"
Cohesion: 0.22
Nodes (6): FacebookAuthService, FacebookNativeAuthBridge, FacebookSignInRequest, Bool, String, SignInHandler

### Community 75 - "UIView"
Cohesion: 0.15
Nodes (8): CALayer, ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView, QuartzCore

### Community 76 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.07
Nodes (14): Bool, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer (+6 more)

### Community 77 - "ProgramFrameRingBuffer"
Cohesion: 0.22
Nodes (8): FrameDescriptor, size_t, ProgramFrameRingBuffer, count_, latest, push, slots_, writeIndex_

### Community 78 - "Testing"
Cohesion: 0.10
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 80 - ".content"
Cohesion: 0.20
Nodes (13): AnyView, NSImage, .logoAspectRatio, .content, BroadcastWidgetImageLoader, CachedWidgetLogoView, .body, CGFloat (+5 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.10
Nodes (21): MTKView, MTKViewDelegate, MTLCommandQueue, MTLLibrary, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer (+13 more)

### Community 82 - "RemoteCameraCommand"
Cohesion: 0.09
Nodes (26): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setDirectorMonitorQuality, setExposureBias, setLens, setMuted (+18 more)

### Community 83 - "View"
Cohesion: 0.17
Nodes (19): AVPlayer, .body, .body, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body (+11 more)

### Community 84 - "DirectorSessionView"
Cohesion: 0.06
Nodes (40): DirectorLibraryRailView, DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, DirectorSessionView, .camerasSidebarContent, .canTake, .compactLayout (+32 more)

### Community 85 - "Foundation"
Cohesion: 0.08
Nodes (10): AVFoundation, CoreMedia, CoreVideo, EasyStreamDiscovery, Foundation, Network, Observation, OSLog (+2 more)

### Community 86 - "CameraLensKind"
Cohesion: 0.08
Nodes (36): ClosedRange, .controlsSheet, AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front (+28 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "WebRTCVideoFramePublisher"
Cohesion: 0.27
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 89 - ".makeVideoTextures"
Cohesion: 0.20
Nodes (9): CGImage, BroadcastMetalI420ConversionCache, BroadcastMetalTextureUploader, CVMetalTextureCache, CVPixelBuffer, CVPixelBufferPool, MTLDevice, MTLTexture (+1 more)

### Community 90 - "EncodedAudioSample"
Cohesion: 0.26
Nodes (11): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+3 more)

### Community 91 - "Error"
Cohesion: 0.10
Nodes (20): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+12 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "DirectorPreviewMonitorStore"
Cohesion: 0.13
Nodes (13): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+5 more)

### Community 94 - "LayoutNeutralRTCMTLVideoView"
Cohesion: 0.22
Nodes (9): ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGRect, CGSize, NSCoder, ProposedViewSize (+1 more)

### Community 95 - ".applySlot"
Cohesion: 0.33
Nodes (4): ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 96 - "DirectorSessionViewModel.swift"
Cohesion: 0.16
Nodes (8): AppTrackingTransparency, EasyStreamAudioPipeline, EasyStreamFacebook, EasyStreamFacebookLogin, EasyStreamStreaming, EasyStreamVideoPipeline, FacebookCore, FacebookLogin

### Community 97 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.16
Nodes (11): .connectionSummary, BroadcastCompactLiveBadge, BroadcastFormField, .body, BroadcastSectionHeader, .body, Binding, String (+3 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.12
Nodes (18): CheckedContinuation, Notification, NSWindowDelegate, FacebookTokenParser, FacebookWebLoginSession, Bool, Error, NSWindow (+10 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "CameraTransportProfile"
Cohesion: 0.14
Nodes (12): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+4 more)

### Community 102 - "ProgramCrossfadeLetterboxSizeDelegate"
Cohesion: 0.22
Nodes (9): MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect, CGSize, RTCVideoRenderer, Void (+1 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.14
Nodes (19): CGPoint, BroadcastDraggableWidgetOverlay, .body, Binding, CGFloat, CGRect, CGSize, Gesture (+11 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 105 - "ClippingRTCVideoContainer"
Cohesion: 0.26
Nodes (9): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, NSCoder, NSRect (+1 more)

### Community 106 - "BroadcastStreamSpec"
Cohesion: 0.11
Nodes (21): BroadcastStreamSpec, .displayLabel, PreviewTilePreset, economy, .id, standard, .streamSpec, .title (+13 more)

### Community 107 - "View"
Cohesion: 0.13
Nodes (9): Configuration, BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastHiddenToolbarModifier, BroadcastStudioChromeModifier, CGFloat, Content, View (+1 more)

### Community 108 - "StreamOutputPreset"
Cohesion: 0.17
Nodes (12): StreamOutputPreset, .detail, facebook1080p30, facebook720p30, .id, .platforms, stream540p30, .title (+4 more)

### Community 109 - "ProgramFeedWidgetLayer"
Cohesion: 0.24
Nodes (14): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void, ProgramFeedView, ProgramFeedWidgetLayer, Binding (+6 more)

### Community 110 - "Void"
Cohesion: 0.18
Nodes (13): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, .body, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body (+5 more)

### Community 111 - "VideoEncoderConfiguration"
Cohesion: 0.24
Nodes (8): .encoderConfiguration, CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration, .bitrateMbpsLabel, .displayLabel, .resolutionLabel

### Community 112 - "SignalingMessage"
Cohesion: 0.07
Nodes (29): MessageType, answer, control, hello, ice, offer, settingsState, RemoteStreamSession (+21 more)

### Community 113 - "NSObject"
Cohesion: 0.17
Nodes (10): AppDelegate, NSObject, BroadcastMetalVideoSink, Slot, incoming, outgoing, program, CGSize (+2 more)

### Community 114 - "AppOrientationPolicy"
Cohesion: 0.21
Nodes (6): AppOrientationPolicy, UIInterfaceOrientationMask, CameraSessionTabletChrome, Content, View, .phoneSessionContent

### Community 115 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 116 - "IntercomPushToTalkButton"
Cohesion: 0.13
Nodes (20): IntercomActivationRing, .body, IntercomPushToTalkButton, .activeCornerRadius, .body, .buttonBackground, .buttonShape, .iconName (+12 more)

### Community 117 - ".application"
Cohesion: 0.17
Nodes (11): Any, Bool, UIApplication, UIInterfaceOrientationMask, URL, FacebookSDKBootstrap, Any, Bool (+3 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "RoundedRectangle"
Cohesion: 0.14
Nodes (19): .body, .body, .body, BroadcastTallyPill, .body, BroadcastTheme, .templatePicker, .body (+11 more)

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "TeamIntercomPeer"
Cohesion: 0.24
Nodes (8): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer, .activeTargetName

### Community 122 - "WebRTCConfiguration"
Cohesion: 0.29
Nodes (4): RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 123 - "BroadcastMediaThumbnailLoader"
Cohesion: 0.42
Nodes (6): .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox

### Community 124 - "VideoRendererSinkCategory"
Cohesion: 0.15
Nodes (12): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+4 more)

### Community 125 - "CameraCaptureService"
Cohesion: 0.11
Nodes (14): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Double (+6 more)

### Community 126 - "DirectorInspectorSection"
Cohesion: 0.18
Nodes (13): .sourceSidebar, .body, DirectorLeftSidebarTabPicker, .body, DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorLibraryRailPanel (+5 more)

### Community 127 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 128 - "BroadcastPlatform"
Cohesion: 0.20
Nodes (10): AppRoute, roleSelection, session, Hashable, BroadcastPlatform, facebook, rtmp, .shortLabel (+2 more)

### Community 129 - "ProgramFrameRingBuffer.cpp"
Cohesion: 0.40
Nodes (5): FrameDescriptor, size_t, ProgramFrameRingBuffer::latest(), ProgramFrameRingBuffer::ProgramFrameRingBuffer(), ProgramFrameRingBuffer::push()

### Community 130 - "PreviewContainerView"
Cohesion: 0.46
Nodes (4): CameraPreviewView, PreviewContainerView, AVCaptureSession, Context

### Community 131 - ".liveTileTrack"
Cohesion: 0.31
Nodes (4): Bool, DirectorPreviewTileTrackPolicy, Bool, RTCVideoTrack

### Community 132 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 133 - "TransitionCurve"
Cohesion: 0.25
Nodes (6): Double, LinearProgress, TransitionCurve, easeInOutCubic, linear, smoothStep

### Community 134 - "ProgramFrameNativeStatus"
Cohesion: 0.40
Nodes (4): EasyStreamVideoBusNative, ProgramFrameNativeStatus, .moduleVersion, String

### Community 135 - "CameraStreamConfiguration.swift"
Cohesion: 0.29
Nodes (5): CoreGraphics, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32

### Community 137 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 138 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 139 - ".extract"
Cohesion: 0.29
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "BroadcastSpecChip"
Cohesion: 0.29
Nodes (7): BroadcastPlatformTagRow, .body, .body, BroadcastSpecChip, .body, BroadcastSpecChipRow, .body

### Community 141 - "TeamIntercomPanel"
Cohesion: 0.26
Nodes (9): .body, ProgramAudioSourcePanel, SourceOption, Bool, String, UUID, Void, TeamIntercomPanel (+1 more)

### Community 142 - ".sizeThatFits"
Cohesion: 0.25
Nodes (5): CGSize, ProposedViewSize, VideoPreviewLayout, CGSize, ProposedViewSize

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+2 more)

### Community 145 - "H264VideoEncoder"
Cohesion: 0.22
Nodes (7): EncoderCallbackBridge, H264VideoEncoder, AsyncStream, Bool, CMSampleBuffer, Void, VTCompressionOutputCallback

### Community 147 - "EasyStreamApp"
Cohesion: 0.40
Nodes (5): App, EasyStreamApp, .body, DirectorProgramOutputWindowView, Scene

### Community 148 - "Coordinator"
Cohesion: 0.20
Nodes (8): DispatchWorkItem, Coordinator, Coordinator, NSObjectProtocol, RTCVideoRenderer, RTCVideoTrack, Void, WebRTCVideoView

### Community 149 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, empty, offAirWarm, onAir, transitioning

### Community 150 - "CodingKeys"
Cohesion: 0.33
Nodes (6): CodingKeys, outputPreset, prefetchTakeTarget, previewPreset, progPreset, tier

### Community 151 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 152 - "ProgramFrameBusSlot"
Cohesion: 0.06
Nodes (31): AccessToken, .programFrameBusSnapshot, ProgramFrameBusSlot, programIncoming, programOnAir, programOutgoing, ProgramFrameTelemetryNoOp, ProgramFrameTelemetryPort (+23 more)

### Community 153 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 155 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 156 - "DirectorStreamReceiver"
Cohesion: 0.14
Nodes (14): DirectorStreamReceiver, RTCPeerConnection, SessionContext, AsyncStream, Int32, NWConnection, RTCIceCandidate, RTCMediaConstraints (+6 more)

### Community 157 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 158 - "WebRTCVideoContentMode"
Cohesion: 0.22
Nodes (9): BoundedWebRTCVideoView, .body, RTCVideoTrack, .videoContent, .videoLayer, .uiMetalMode, WebRTCVideoContentMode, aspectFill (+1 more)

### Community 159 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 162 - "StreamDestinationPanel"
Cohesion: 0.31
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 163 - "CameraSessionTabletChrome"
Cohesion: 0.40
Nodes (3): CameraSessionTabletChrome, Content, View

### Community 164 - "RemoteLensOption"
Cohesion: 0.25
Nodes (8): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, .activeLens

### Community 169 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 170 - ".applyExternalDisplayPreference"
Cohesion: 0.43
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 171 - "FacebookSession"
Cohesion: 0.13
Nodes (14): FacebookLiveService, String, FacebookPage, FacebookSession, .isSignedIn, Bool, FacebookSessionStore, FacebookLivePanel (+6 more)

## Knowledge Gaps
- **545 isolated node(s):** `roleSelection`, `session`, `.platformSessionContent`, `.platformSessionContent`, `.streamBadgeLabel` (+540 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `DirectorSessionViewModel.swift`, `SwitcherEngine`, `ProgramAudioEncoderPipeline`, `DirectorMonitorQualitySettings`, `DirectorSwitcherColumnView`, `FacebookSession`, `CameraSourceID`, `DiscoveryService`, `VideoRendererSinkCategory`, `DirectorStreamReceiver`, `DirectorSessionView`, `DiscoveredDevice`, `ProgramFrameBusSlot`, `BroadcastStreamPublisher`, `StreamDestination`, `ProgramVideoEncoderPipeline`, `LiveProgramAirStore`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `SwiftUI`, `DirectorSessionViewModel.swift`, `SwitcherEngine`, `BroadcastTheme.swift`, `BroadcastWidgetRenderer.swift`, `CameraStreamConfiguration.swift`, `ProgramTransitionEffect.swift`, `ProgramCrossfadeHost`, `LiveProgramFeedView`, `Testing`, `IntercomPushToTalkButton`, `Foundation`, `ProgramFrameBusSlot`, `DirectorRemoteControlsView`, `DirectorInspectorSection`, `UIKit`?**
  _High betweenness centrality (0.071) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `SwiftUI`, `DirectorMonitorQualitySettings`, `Identifiable`, `TransitionCurve`, `CameraSwitcherAssignment`, `CameraSourceID`, `EasyStreamCore`, `AppRole`, `EasyStreamLog`, `ProgramFrameBusSlot`, `Equatable`, `DirectorProgramOutputStore`, `WebRTCVideoContentMode`, `UIKit`, `SwitcherEngine`, `String`, `Codable`, `Sendable`, `FacebookSession`, `FacebookConfiguration`, `Data`, `CaseIterable`, `BroadcastWidgetConfiguration`, `BroadcastResource`, `BroadcastPlaylistRepository`, `BroadcastResourceKind`, `.matches`, `FacebookSignInRequest`, `Testing`, `RemoteCameraCommand`, `DirectorSessionView`, `CameraLensKind`, `EncodedAudioSample`, `StreamDestination`, `DirectorPreviewMonitorStore`, `.applySlot`, `DirectorSessionViewModel.swift`, `CameraTransportProfile`, `BroadcastStreamSpec`, `SignalingMessage`, `TeamIntercomPeer`, `VideoRendererSinkCategory`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `.body` and `DirectorSessionView`) actually correct?**
  _`BroadcastMediaViewModel` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.platformSessionContent` to the rest of the system?**
  _545 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `SwiftUI` be split into smaller, more focused modules?**
  _Cohesion score 0.13666666666666666 - nodes in this community are weakly interconnected._