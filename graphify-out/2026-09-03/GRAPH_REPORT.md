# Graph Report - EasyStream  (2026-09-03)

## Corpus Check
- 190 files · ~72,428 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3303 nodes · 7803 edges · 173 communities (170 shown, 3 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 592 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f38c0078`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- SwiftUI
- RTMPPublisher
- DirectorMonitorQualitySettings
- .body
- FLVBuilder
- DirectorSessionViewModel
- PlayoutTapAudioDevice
- ProgramCrossfadeHost
- Sendable
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- Task
- PreviewMonitorCamera
- .connectIfNeeded
- NSView
- Coordinator
- .start
- FacebookAuthError
- DirectorSessionViewModel.swift
- BroadcastMetalProgramFeedPlatformView
- AppRole
- .reportSettingsState
- DiscoveredDevice
- BonjourServiceType
- ProgramFeedWidgetLayer
- BroadcastStreamPublisher
- BroadcastTransmissionMenu
- FacebookPlatformAuth.swift
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- UIKit
- CameraSourceID
- ProgramAudioEncoderPipeline
- BroadcastMediaLibraryPanel.swift
- Equatable
- Coordinator
- BroadcastWidgetStudioPanel
- BroadcastWidgetRenderer.swift
- BroadcastGlowButtonStyle
- ProgramOutputSyncBridge
- ProgramPreviewVisibilityPolicy
- EasyStreamUITests
- SignalingChannel
- FacebookConfiguration
- DiscoveryService
- AVCaptureVideoOrientation
- WhiteBalanceModeOption
- PackageDescription
- .content
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetConfiguration
- .recreateSession
- CameraStreamClient
- .decode
- BroadcastResource
- DirectorProgramOutputStore
- DirectorSourceListRow
- ProgramCrossfadeContainerUIView
- DirectorVideoQualityPanel.swift
- DirectorProgramVideoBusView
- CameraSessionView
- CameraClientControlsView
- CameraLensKind
- TeamIntercomService
- Data
- Driver
- BroadcastMetalOverlayProvider
- BroadcastResourceKind
- ProgramTransitionFrame
- .matches
- CameraSessionLayoutKind
- UIView
- AACAudioEncoder
- ProgramFrameRingBuffer
- Testing
- BroadcastMediaThumbnailLoader
- CachedWidgetLogoView
- BroadcastMetalCompositor
- RemoteCameraCommand
- CameraTransportProfile
- LiveProgramAirStore
- EasyStreamCore
- TickerScrollingContent
- BroadcastMetalSwiftUIOverlayProvider
- WebRTCVideoFramePublisher
- .makeBGRATexture
- .apply
- Error
- StreamDestination
- DirectorPreviewMonitorStore
- LayoutNeutralRTCMTLVideoView
- ProgramTransitionSlot
- CameraTallyGlowOverlay
- .sizeThatFits
- BroadcastTheme
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- BroadcastMetalTextureUploader.swift
- ProgramCrossfadeLetterboxSizeDelegate
- BroadcastDraggableWidgetOverlay
- LiveProgramFeedView
- ClippingRTCVideoContainer
- BroadcastStreamSpec
- CameraCaptureLoadTier
- StreamOutputPreset
- DirectorSessionView
- View
- EncodedVideoSample
- SignalingMessage
- NSObject
- .layerFrame
- FacebookGraphClient
- BroadcastFontPreset
- .application
- WebRTCProgramFrameSink
- RoundedRectangle
- BroadcastPanelModifier
- TeamIntercomPeer
- Color
- DiscoveryEvent
- VideoRendererSinkCategory
- CameraCaptureService
- WebRTCConfiguration
- DirectorRemoteControlsView
- AppOrientationPolicy
- ProgramFrameRingBuffer.cpp
- PreviewContainerView
- PreviewMultiviewGridSpec
- .startListener
- TransitionPreferencesStore
- ProgramMonitorPreset
- CameraPermissionStatus
- BroadcastMetalProgramFeedView
- CodingKeys
- LiveVideoStreamSizeStore
- .extract
- DirectorStatusBar
- IntercomPushToTalkButton
- RTMPStreamError
- ProgramCrossfadeContainerNSView
- H264VideoEncoder
- ProgramFrameNativeStatus
- RemoteLensOption
- BroadcastPlaylist
- RemoteWhiteBalanceOption
- DeviceIdentity
- ProgramFrameBusSlot
- State
- BroadcastMetalProgramFeedContainerNSView
- Event
- DirectorStreamReceiver
- FacebookLivePanel
- WebRTCVideoContentMode
- .init
- FacebookGraphError
- .boundedSize
- StreamDestinationPanel
- ProgramFrameNativeCapabilities
- CameraSourceTile
- CountdownAnimationModifier
- VideoEncoderConfiguration
- FacebookSession
- GraphAPIErrorResponse
- BroadcastWidgetPlacement
- NWError
- Identifiable
- .cappedDrawableSize

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 119 edges
2. `EasyStreamCore` - 96 edges
3. `BroadcastMediaViewModel` - 88 edges
4. `CameraSourceID` - 83 edges
5. `BroadcastResource` - 82 edges
6. `BroadcastWidgetConfiguration` - 60 edges
7. `TeamIntercomService` - 56 edges
8. `SwitchTransitionKind` - 54 edges
9. `BroadcastMetalCompositor` - 53 edges
10. `CameraSessionViewModel` - 48 edges

## Surprising Connections (you probably didn't know these)
- `.cameraIntercomCard` --calls--> `TeamIntercomPanel`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionLandscapeLayout.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/BroadcastAudioIntercomPanels.swift
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `.landscapeSessionContent` --calls--> `CameraTallyGlowOverlay`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionLandscapeLayout.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift

## Import Cycles
- None detected.

## Communities (173 total, 3 thin omitted)

### Community 0 - "SwiftUI"
Cohesion: 0.10
Nodes (5): EasyStreamUIComponents, Observation, SwiftUI, UniformTypeIdentifiers, WebRTC

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "DirectorMonitorQualitySettings"
Cohesion: 0.17
Nodes (10): DirectorMonitorQualityPreferencesStore, DirectorMonitorQualitySettings, .outputEncoderConfiguration, LegacyTier, balanced, economy, high, Bool (+2 more)

### Community 3 - ".body"
Cohesion: 0.15
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "DirectorSessionViewModel"
Cohesion: 0.09
Nodes (25): .keyboardShortcuts, .remoteControlsSection, ConnectedCameraSource, DirectorSessionViewModel, .activeStreamingSourceCount, .connectedSourceCount, .isFacebookConfigured, .isPublishing (+17 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "ProgramCrossfadeHost"
Cohesion: 0.11
Nodes (18): ProgramCrossfadeHost, Bool, ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack, Phase, empty, offAirWarm (+10 more)

### Community 8 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.13
Nodes (15): .body, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool, Never (+7 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.20
Nodes (10): CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program, Bool (+2 more)

### Community 12 - "Task"
Cohesion: 0.11
Nodes (10): .destinationSection, .facebookPanel, .streamPanel, .effectiveMonitorQuality, .monitorQuality, Task, AudioEncoderStats, Bool (+2 more)

### Community 13 - "PreviewMonitorCamera"
Cohesion: 0.36
Nodes (8): PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CGSize, Int, RTCVideoTrack

### Community 14 - ".connectIfNeeded"
Cohesion: 0.29
Nodes (5): ObjectIdentifier, NWConnection, String, Task, UUID

### Community 15 - "NSView"
Cohesion: 0.19
Nodes (7): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow, NSView, CGFloat, Double

### Community 16 - "Coordinator"
Cohesion: 0.20
Nodes (9): AVCaptureVideoPreviewLayer, CameraPreviewView, Coordinator, AVCaptureSession, Context, Coordinator, RTCVideoTrack, WebRTCVideoView (+1 more)

### Community 18 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 19 - "DirectorSessionViewModel.swift"
Cohesion: 0.16
Nodes (6): EasyStreamAudioPipeline, EasyStreamCameraCapture, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamTransport, OSLog

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.22
Nodes (11): BroadcastMetalProgramFeedPlatformView, Coordinator, CGSize, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack (+3 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - ".reportSettingsState"
Cohesion: 0.18
Nodes (7): .exposureBinding, .whiteBalanceBinding, .zoomBinding, Binding, Double, Float, Bool

### Community 23 - "DiscoveredDevice"
Cohesion: 0.12
Nodes (20): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, Bool (+12 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "ProgramFeedWidgetLayer"
Cohesion: 0.24
Nodes (14): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void, ProgramFeedView, ProgramFeedWidgetLayer, Binding (+6 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "BroadcastTransmissionMenu"
Cohesion: 0.14
Nodes (20): ProgramOutputDisplayOption, ProgramOutputSettings, Bool, Int, String, BroadcastTransmissionMenu, .body, .externalDisplaySection (+12 more)

### Community 28 - "FacebookPlatformAuth.swift"
Cohesion: 0.09
Nodes (13): App, AppTrackingTransparency, EasyStreamApp, .body, DirectorProgramOutputWindowView, EasyStreamFacebook, EasyStreamFacebookLogin, EasyStreamVideoPipeline (+5 more)

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.07
Nodes (29): .body, DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, .body, DirectorSettingsSheet, .liveGraphicsSection, .widgetDraftPreviewCanvas (+21 more)

### Community 31 - "UIKit"
Cohesion: 0.11
Nodes (6): AppKit, AVKit, ImageIO, PlatformSettings, UIKit, WebKit

### Community 32 - "CameraSourceID"
Cohesion: 0.12
Nodes (23): EasyStreamSwitcher, TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID, .id, UUID, Set (+15 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "BroadcastMediaLibraryPanel.swift"
Cohesion: 0.08
Nodes (40): .sourceSidebar, .body, BroadcastAsyncThumbnailImage, BroadcastMediaLibraryPanel, .filteredPlaylists, BroadcastMediaPhotoImporter, BroadcastPlaylistEditorSheet, BroadcastPlaylistPanel (+32 more)

### Community 35 - "Equatable"
Cohesion: 0.18
Nodes (18): Codable, Equatable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3 (+10 more)

### Community 36 - "Coordinator"
Cohesion: 0.24
Nodes (7): DispatchWorkItem, Coordinator, Coordinator, NSObjectProtocol, RTCVideoTrack, Void, WebRTCVideoView

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (41): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+33 more)

### Community 38 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.19
Nodes (16): AnimatedLogoWidgetView, .body, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView, .body, LogoMotionContainer, .body (+8 more)

### Community 39 - "BroadcastGlowButtonStyle"
Cohesion: 0.08
Nodes (23): ButtonStyle, Configuration, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlassPanelModifier, BroadcastGlassProminentButtonStyle, BroadcastGlassStyles, BroadcastGlowButtonStyle (+15 more)

### Community 40 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 41 - "ProgramPreviewVisibilityPolicy"
Cohesion: 0.15
Nodes (12): ProgramPreviewVisibilityPolicy, allConnectedSources, previewSourceOnly, Bool, ProgramRenderBackend, legacyDualWebRTC, metalCompositor, ProgramRenderConfiguration (+4 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "SignalingChannel"
Cohesion: 0.16
Nodes (12): Event, connected, disconnected, failed, message, SignalingChannel, SignalingCodec, AsyncStream (+4 more)

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "DiscoveryService"
Cohesion: 0.15
Nodes (15): EasyStreamLog, DiscoveryService, .discoveredDevices, Bool, NWBrowser, NWConnection, NWEndpoint, NWListener (+7 more)

### Community 46 - "AVCaptureVideoOrientation"
Cohesion: 0.27
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "WhiteBalanceModeOption"
Cohesion: 0.25
Nodes (8): WhiteBalanceModeOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 49 - ".content"
Cohesion: 0.20
Nodes (10): NSColor, .content, .body, BroadcastWidgetColors, Binding, Bool, LinearGradient, String (+2 more)

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
Cohesion: 0.23
Nodes (9): Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context, Coordinator, Double, ProposedViewSize (+1 more)

### Community 54 - "BroadcastWidgetConfiguration"
Cohesion: 0.05
Nodes (51): CaseIterable, BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle (+43 more)

### Community 55 - ".recreateSession"
Cohesion: 0.21
Nodes (10): OSStatus, CMTime, CVPixelBuffer, Int32, VideoEncoderError, configurationFailed, encodeFailed, sampleExtractionFailed (+2 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.07
Nodes (24): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+16 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResource"
Cohesion: 0.13
Nodes (18): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, Date (+10 more)

### Community 59 - "DirectorProgramOutputStore"
Cohesion: 0.30
Nodes (8): DirectorProgramOutputStore, .settings, Bool, Double, RTCVideoTrack, String, URL, ProgramOutputPreferencesStore

### Community 60 - "DirectorSourceListRow"
Cohesion: 0.16
Nodes (15): .body, DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorLibraryRailPanel, .body, DirectorSourceListRow, .accentBarColor (+7 more)

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "DirectorVideoQualityPanel.swift"
Cohesion: 0.14
Nodes (20): Option, BroadcastPlatformTagRow, .body, BroadcastQualityDropdown, .body, BroadcastSettingsInfoCallout, .body, BroadcastSettingsToggleRow (+12 more)

### Community 63 - "DirectorProgramVideoBusView"
Cohesion: 0.18
Nodes (11): DirectorProgramAirGraphicsView, .body, DirectorProgramVideoBusView, .body, Bool, Double, RTCVideoTrack, String (+3 more)

### Community 64 - "CameraSessionView"
Cohesion: 0.17
Nodes (11): .cameraIntercomCard, .cameraLayoutKind, CameraSessionView, .streamBadgeLabel, .platformSessionContent, View, .platformSessionContent, View (+3 more)

### Community 65 - "CameraClientControlsView"
Cohesion: 0.18
Nodes (14): ClosedRange, CameraClientControlsView, .body, .exposureControl, .lensPicker, .muteControl, .whiteBalancePicker, .zoomControl (+6 more)

### Community 66 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.16
Nodes (11): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool, Data (+3 more)

### Community 68 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 69 - "Driver"
Cohesion: 0.27
Nodes (9): CADisplayLink, CVDisplayLink, Driver, ProgramTransitionDisplayLink, CFTimeInterval, Double, Int, TimeInterval (+1 more)

### Community 70 - "BroadcastMetalOverlayProvider"
Cohesion: 0.20
Nodes (9): BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture (+1 more)

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.12
Nodes (16): BroadcastMacFilePicker, Void, BroadcastResourceKind, image, .systemImage, .title, video, widget (+8 more)

### Community 72 - "ProgramTransitionFrame"
Cohesion: 0.09
Nodes (27): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, Double, LinearProgress, WipeTransitionEffect (+19 more)

### Community 73 - ".matches"
Cohesion: 0.24
Nodes (7): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String, Bool

### Community 74 - "CameraSessionLayoutKind"
Cohesion: 0.23
Nodes (9): CameraSessionLayoutKind, mac, phone, tablet, CameraSessionLayoutMetrics, .landscapeSessionContent, CGFloat, CGSize (+1 more)

### Community 75 - "UIView"
Cohesion: 0.17
Nodes (7): CALayer, ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView

### Community 76 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 77 - "ProgramFrameRingBuffer"
Cohesion: 0.22
Nodes (8): FrameDescriptor, size_t, ProgramFrameRingBuffer, count_, latest, push, slots_, writeIndex_

### Community 78 - "Testing"
Cohesion: 0.10
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "BroadcastMediaThumbnailLoader"
Cohesion: 0.42
Nodes (6): .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox

### Community 80 - "CachedWidgetLogoView"
Cohesion: 0.21
Nodes (12): AnyView, NSImage, .logoAspectRatio, BroadcastWidgetImageLoader, CachedWidgetLogoView, .body, CGFloat, Content (+4 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.10
Nodes (22): MTKView, MTKViewDelegate, MTLCommandQueue, MTLLibrary, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer (+14 more)

### Community 82 - "RemoteCameraCommand"
Cohesion: 0.13
Nodes (18): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setDirectorMonitorQuality, setExposureBias, setLens, setMuted (+10 more)

### Community 83 - "CameraTransportProfile"
Cohesion: 0.17
Nodes (11): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+3 more)

### Community 84 - "LiveProgramAirStore"
Cohesion: 0.11
Nodes (22): DirectorProgramLiveMonitorView, .body, .programVideoContent, DirectorMainSwitcherAreaView, .body, .canTake, DirectorProgramOutputCorePanel, .body (+14 more)

### Community 85 - "EasyStreamCore"
Cohesion: 0.12
Nodes (8): AVFoundation, CoreMedia, CoreVideo, EasyStreamCore, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox

### Community 86 - "TickerScrollingContent"
Cohesion: 0.24
Nodes (10): ClockWidgetView, .body, Date, String, TickerScrollingContent, .measuredSegmentWidth, .tickerLabel, TickerWidgetView (+2 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "WebRTCVideoFramePublisher"
Cohesion: 0.27
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 89 - ".makeBGRATexture"
Cohesion: 0.21
Nodes (9): CGImage, BroadcastMetalI420ConversionCache, BroadcastMetalTextureUploader, CVMetalTextureCache, CVPixelBuffer, CVPixelBufferPool, MTLDevice, MTLTexture (+1 more)

### Community 90 - ".apply"
Cohesion: 0.38
Nodes (3): Double, Float, RemoteCameraCommandExecutor

### Community 91 - "Error"
Cohesion: 0.10
Nodes (20): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+12 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "DirectorPreviewMonitorStore"
Cohesion: 0.10
Nodes (16): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+8 more)

### Community 94 - "LayoutNeutralRTCMTLVideoView"
Cohesion: 0.18
Nodes (10): ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGRect, CGSize, NSCoder, ProposedViewSize (+2 more)

### Community 95 - "ProgramTransitionSlot"
Cohesion: 0.22
Nodes (8): AnyObject, ProgramTransitionSlot, .usesSpatialPresentation, Double, ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 96 - "CameraTallyGlowOverlay"
Cohesion: 0.24
Nodes (9): CameraTallyGlowOverlay, .body, .glowColor, CameraTallyGlowPlacement, contentFrame, .cornerRadius, .edgeInset, screenEdge (+1 more)

### Community 97 - ".sizeThatFits"
Cohesion: 0.20
Nodes (6): CGSize, ProposedViewSize, VideoPreviewLayout, CGSize, ProposedViewSize, RTCVideoRenderer

### Community 98 - "BroadcastTheme"
Cohesion: 0.11
Nodes (22): .cameraControlsCard, .cameraDirectorCard, .buttonBackground, .body, .body, BroadcastCompactLiveBadge, .body, BroadcastFormField (+14 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.07
Nodes (29): AccessToken, CheckedContinuation, Notification, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession, Bool (+21 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "BroadcastMetalTextureUploader.swift"
Cohesion: 0.13
Nodes (8): CoreGraphics, Metal, MetalKit, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32, QuartzCore

### Community 102 - "ProgramCrossfadeLetterboxSizeDelegate"
Cohesion: 0.22
Nodes (9): MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect, CGSize, RTCVideoRenderer, Void (+1 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.14
Nodes (20): CGPoint, BroadcastDraggableWidgetOverlay, .body, .body, Binding, CGFloat, CGRect, CGSize (+12 more)

### Community 104 - "LiveProgramFeedView"
Cohesion: 0.33
Nodes (13): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, StableProgramVideoView, StableWidgetOverlayView, Bool, Double (+5 more)

### Community 105 - "ClippingRTCVideoContainer"
Cohesion: 0.26
Nodes (9): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, NSCoder, NSRect (+1 more)

### Community 106 - "BroadcastStreamSpec"
Cohesion: 0.16
Nodes (14): BroadcastStreamSpec, .displayLabel, PreviewTilePreset, economy, .id, minimal, standard, .streamSpec (+6 more)

### Community 107 - "CameraCaptureLoadTier"
Cohesion: 0.29
Nodes (6): CameraCaptureLoadTier, idle, preview, program, .sessionPreset, AVCaptureSession

### Community 108 - "StreamOutputPreset"
Cohesion: 0.11
Nodes (18): BroadcastPlatform, facebook, rtmp, .shortLabel, youtube, StreamOutputPreset, .detail, facebook1080p30 (+10 more)

### Community 109 - "DirectorSessionView"
Cohesion: 0.07
Nodes (32): DirectorLibraryRailView, DirectorSessionView, .camerasSidebarContent, .canTake, .compactLayout, .directorWorkspaceLayout, .librarySection, .mainSwitcherArea (+24 more)

### Community 110 - "View"
Cohesion: 0.16
Nodes (15): Content, PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body (+7 more)

### Community 111 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 112 - "SignalingMessage"
Cohesion: 0.06
Nodes (39): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+31 more)

### Community 113 - "NSObject"
Cohesion: 0.12
Nodes (12): AppDelegate, NSObject, Bool, RTCVideoFrame, BroadcastMetalVideoSink, Slot, incoming, outgoing (+4 more)

### Community 114 - ".layerFrame"
Cohesion: 0.22
Nodes (5): BroadcastMetalVideoFrame, LayerFrame, Float, RTCVideoFrame, SIMD2

### Community 115 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 116 - "BroadcastFontPreset"
Cohesion: 0.18
Nodes (13): Font, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded (+5 more)

### Community 117 - ".application"
Cohesion: 0.17
Nodes (11): Any, Bool, UIApplication, UIInterfaceOrientationMask, URL, FacebookSDKBootstrap, Any, Bool (+3 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "RoundedRectangle"
Cohesion: 0.11
Nodes (20): .buttonShape, .body, .body, SignalStrengthView, .body, Int, PreviewMonitorCellView, .body (+12 more)

### Community 120 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 121 - "TeamIntercomPeer"
Cohesion: 0.24
Nodes (7): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer

### Community 122 - "Color"
Cohesion: 0.29
Nodes (7): BroadcastLiveStreamSizeBadge, LiveLabel, ProgramBusLiveResolutionBadge, .body, String, Color, .body

### Community 123 - "DiscoveryEvent"
Cohesion: 0.22
Nodes (8): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired, AsyncStream

### Community 124 - "VideoRendererSinkCategory"
Cohesion: 0.15
Nodes (12): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+4 more)

### Community 125 - "CameraCaptureService"
Cohesion: 0.14
Nodes (10): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Int32 (+2 more)

### Community 126 - "WebRTCConfiguration"
Cohesion: 0.43
Nodes (3): WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

### Community 127 - "DirectorRemoteControlsView"
Cohesion: 0.27
Nodes (10): DirectorRemoteControlsView, .body, .connectionStateLabel, .exposureControl, .lensPicker, .reconnectButtonTitle, .whiteBalancePicker, .zoomControl (+2 more)

### Community 128 - "AppOrientationPolicy"
Cohesion: 0.28
Nodes (4): AppOrientationPolicy, UIInterfaceOrientationMask, CameraSessionLandscapeChrome, Content

### Community 129 - "ProgramFrameRingBuffer.cpp"
Cohesion: 0.40
Nodes (5): FrameDescriptor, size_t, ProgramFrameRingBuffer::latest(), ProgramFrameRingBuffer::ProgramFrameRingBuffer(), ProgramFrameRingBuffer::push()

### Community 130 - "PreviewContainerView"
Cohesion: 0.39
Nodes (5): CameraPreviewView, PreviewContainerView, AVCaptureSession, Context, UIViewRepresentable

### Community 131 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 132 - ".startListener"
Cohesion: 0.21
Nodes (5): NWBrowser, NWListener, NWParameters, NWTXTRecord, Set

### Community 134 - "ProgramMonitorPreset"
Cohesion: 0.22
Nodes (9): ProgramMonitorPreset, balanced720, .detail, economy540, full1080, .id, light360, .streamSpec (+1 more)

### Community 135 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 136 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 137 - "CodingKeys"
Cohesion: 0.25
Nodes (8): CodingKeys, energySaverMode, outputPreset, pauseIdleCameraStreams, prefetchTakeTarget, previewPreset, progPreset, tier

### Community 138 - "LiveVideoStreamSizeStore"
Cohesion: 0.57
Nodes (3): LiveVideoStreamSizeStore, CGSize, String

### Community 139 - ".extract"
Cohesion: 0.29
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "DirectorStatusBar"
Cohesion: 0.47
Nodes (5): DirectorStatusBar, .body, .cameraCountLabel, Int, String

### Community 141 - "IntercomPushToTalkButton"
Cohesion: 0.11
Nodes (27): IntercomActivationRing, .body, IntercomPushToTalkButton, .activeCornerRadius, .body, .iconName, .idleCornerRadius, .isLive (+19 more)

### Community 142 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+2 more)

### Community 145 - "H264VideoEncoder"
Cohesion: 0.22
Nodes (7): EncoderCallbackBridge, H264VideoEncoder, AsyncStream, Bool, CMSampleBuffer, Void, VTCompressionOutputCallback

### Community 147 - "ProgramFrameNativeStatus"
Cohesion: 0.40
Nodes (4): EasyStreamVideoBusNative, ProgramFrameNativeStatus, .moduleVersion, String

### Community 148 - "RemoteLensOption"
Cohesion: 0.25
Nodes (8): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, .activeLens

### Community 149 - "BroadcastPlaylist"
Cohesion: 0.12
Nodes (17): .playlistsSidebarContent, .playlistsContent, BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title (+9 more)

### Community 150 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 151 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 152 - "ProgramFrameBusSlot"
Cohesion: 0.09
Nodes (24): .programFrameBusSnapshot, ProgramFrameBusSlot, programIncoming, programOnAir, programOutgoing, ProgramFrameTelemetryNoOp, ProgramFrameTelemetryPort, ProgramFrameTelemetryRegistry (+16 more)

### Community 153 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 154 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.07
Nodes (11): Int, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer (+3 more)

### Community 155 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 156 - "DirectorStreamReceiver"
Cohesion: 0.09
Nodes (24): DirectorStreamReceiver, Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated (+16 more)

### Community 157 - "FacebookLivePanel"
Cohesion: 0.39
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 158 - "WebRTCVideoContentMode"
Cohesion: 0.22
Nodes (9): BoundedWebRTCVideoView, .body, RTCVideoTrack, .videoContent, .videoLayer, .uiMetalMode, WebRTCVideoContentMode, aspectFill (+1 more)

### Community 159 - ".init"
Cohesion: 0.50
Nodes (3): CGRect, NSCoder, NSRect

### Community 160 - "FacebookGraphError"
Cohesion: 0.40
Nodes (5): LocalizedError, FacebookGraphError, apiError, .errorDescription, invalidResponse

### Community 161 - ".boundedSize"
Cohesion: 0.40
Nodes (3): ProgramCrossfadeLayout, CGSize, ProposedViewSize

### Community 162 - "StreamDestinationPanel"
Cohesion: 0.27
Nodes (8): StreamDestinationPanel, .body, .publisherStatus, Binding, Bool, Int, String, Void

### Community 163 - "ProgramFrameNativeCapabilities"
Cohesion: 0.50
Nodes (3): ProgramFrameNativeCapabilities, .busModuleVersion, String

### Community 164 - "CameraSourceTile"
Cohesion: 0.20
Nodes (14): CameraSourceTile, .body, .borderColor, .placeholderMessage, .placeholderSymbolName, Bool, Double, Gesture (+6 more)

### Community 165 - "CountdownAnimationModifier"
Cohesion: 0.11
Nodes (20): Animation, .placeholderLogo, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .opacity, .scale (+12 more)

### Community 166 - "VideoEncoderConfiguration"
Cohesion: 0.24
Nodes (8): .encoderConfiguration, CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration, .bitrateMbpsLabel, .displayLabel, .resolutionLabel

### Community 167 - "FacebookSession"
Cohesion: 0.19
Nodes (6): FacebookLiveService, String, FacebookSession, .isSignedIn, Bool, FacebookSessionStore

### Community 168 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 169 - "BroadcastWidgetPlacement"
Cohesion: 0.15
Nodes (21): AVPlayer, .body, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body, BroadcastVideoResourceView (+13 more)

### Community 170 - "NWError"
Cohesion: 0.67
Nodes (3): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool

### Community 171 - "Identifiable"
Cohesion: 0.21
Nodes (11): CodingKey, Identifiable, CodingKeys, accessToken, id, name, secureStreamURL, FacebookLiveVideo (+3 more)

### Community 174 - ".cappedDrawableSize"
Cohesion: 0.32
Nodes (3): BroadcastMetalDrawableLimits, CGFloat, CGSize

## Knowledge Gaps
- **556 isolated node(s):** `roleSelection`, `session`, `phone`, `tablet`, `mac` (+551 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `BroadcastMetalCompositor` connect `BroadcastMetalCompositor` to `BroadcastMetalTextureUploader.swift`, `BroadcastMetalOverlayProvider`, `Sendable`, `.cappedDrawableSize`, `NSObject`, `.layerFrame`, `BroadcastMetalProgramFeedContainerNSView`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `DirectorMonitorQualitySettings`, `TransitionPreferencesStore`, `Task`, `DirectorSessionViewModel.swift`, `DiscoveredDevice`, `ProgramFrameBusSlot`, `BroadcastStreamPublisher`, `DirectorStreamReceiver`, `ProgramVideoEncoderPipeline`, `BroadcastMediaViewModel`, `CameraSourceID`, `ProgramAudioEncoderPipeline`, `FacebookSession`, `ProgramOutputSyncBridge`, `Identifiable`, `DiscoveryService`, `DirectorProgramVideoBusView`, `LiveProgramAirStore`, `StreamDestination`, `DirectorSessionView`, `VideoRendererSinkCategory`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `SwiftUI`, `CameraSourceID`, `BroadcastMediaLibraryPanel.swift`, `BroadcastTheme`, `BroadcastMetalTextureUploader.swift`, `BroadcastWidgetRenderer.swift`, `ProgramTransitionFrame`, `LiveProgramFeedView`, `IntercomPushToTalkButton`, `Testing`, `DirectorSourceListRow`, `View`, `DirectorSessionViewModel.swift`, `FacebookPlatformAuth.swift`, `DirectorVideoQualityPanel.swift`, `UIKit`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `.body` and `DirectorSessionView`) actually correct?**
  _`BroadcastMediaViewModel` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `phone` to the rest of the system?**
  _556 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `SwiftUI` be split into smaller, more focused modules?**
  _Cohesion score 0.10227272727272728 - nodes in this community are weakly interconnected._