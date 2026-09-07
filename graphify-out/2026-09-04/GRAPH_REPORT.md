# Graph Report - EasyStream  (2026-09-03)

## Corpus Check
- 192 files · ~72,848 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3319 nodes · 7838 edges · 179 communities (177 shown, 2 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 595 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f38c0078`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamCore
- RTMPPublisher
- DirectorMonitorQualitySettings
- .body
- FLVBuilder
- DirectorSessionViewModel
- PlayoutTapAudioDevice
- ProgramCrossfadeHost
- Equatable
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- .body
- PreviewMonitorCellView
- .connectIfNeeded
- BroadcastBarlessWindowConfigurator
- Coordinator
- LocalNetworkPermissionTrigger
- FacebookAuthError
- BroadcastGlowButtonStyle
- BroadcastMetalProgramFeedPlatformView
- AppRole
- Binding
- DirectorConnectionPanel
- BonjourServiceType
- ProgramFeedWidgetLayer
- BroadcastStreamPublisher
- BroadcastTransmissionMenu
- FacebookPlatformAuth.swift
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- SwiftUI
- SwitcherEngine
- ProgramAudioEncoderPipeline
- String
- Sendable
- Coordinator
- BroadcastWidgetStudioPanel
- View
- View
- ProgramOutputSyncBridge
- ProgramPreviewVisibilityPolicy
- EasyStreamUITests
- SignalingChannel
- FacebookConfiguration
- DiscoveryService
- AVCaptureVideoOrientation
- TeamIntercomPanel
- PackageDescription
- DirectorSidebarTab
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetConfiguration
- .recreateSession
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- DirectorProgramOutputStore
- .content
- ProgramCrossfadeContainerUIView
- DirectorVideoQualityPanel.swift
- DirectorProgramVideoBusView
- CameraSessionView
- BroadcastResource
- CameraLensKind
- TeamIntercomService
- Data
- Driver
- BroadcastMetalEmptyOverlayProvider
- BroadcastResourceKind
- ProgramTransitionEffect.swift
- .matches
- CameraSessionLayoutKind
- NSView
- StreamConnectionState
- ProgramFrameRingBuffer
- Testing
- BroadcastMediaThumbnailLoader
- CodingKeys
- BroadcastMetalCompositor
- RemoteCameraCommand
- CameraTransportProfile
- LiveProgramAirStore
- Foundation
- String
- BroadcastMetalSwiftUIOverlayProvider
- WebRTCVideoFramePublisher
- .makeVideoTextures
- WhiteBalanceModeOption
- Error
- StreamDestination
- DirectorPreviewMonitorStore
- LayoutNeutralRTCMTLVideoView
- .setOpacity
- CameraTallyGlowOverlay
- .sizeThatFits
- BroadcastTheme.swift
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- BroadcastMetalTextureUploader.swift
- ProgramCrossfadeLetterboxSizeDelegate
- .resized
- LiveProgramFeedView
- ClippingRTCVideoContainer
- BroadcastStreamSpec
- .signIn
- StreamOutputPreset
- DirectorSessionView
- Void
- EncodedVideoSample
- SignalingMessage
- NSObject
- .layerFrame
- FacebookGraphClient
- BroadcastFontPreset
- .application
- WebRTCProgramFrameSink
- RoleSelectionView
- BroadcastPanelModifier
- TeamIntercomPeer
- Color
- DiscoveredDevice
- VideoRendererSinkCategory
- CameraCaptureService
- WebRTCConfiguration
- DirectorRemoteControlsView
- AppOrientationPolicy
- ProgramFrameRingBuffer.cpp
- PreviewContainerView
- PreviewMultiviewGridSpec
- .handleBrowseResults
- BroadcastLogoAnimation
- ProgramMonitorPreset
- Event
- BroadcastMetalProgramFeedView
- CodingKeys
- LiveVideoStreamSizeStore
- .extract
- DirectorStatusBar
- RoundedRectangle
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
- .save
- BoundedWebRTCVideoView
- .init
- TransitionCurve
- .applyExternalDisplayPreference
- StreamDestinationPanel
- ProgramFrameNativeCapabilities
- CameraSourceTile
- CountdownAnimationModifier
- VideoEncoderConfiguration
- FacebookSession
- GraphAPIErrorResponse
- BroadcastWidgetPlacement
- MessageType
- Identifiable
- FacebookSignInRequest
- UIView
- .cappedDrawableSize
- StreamingDeliveryMode
- SignalStrengthView
- Phase
- BroadcastSettingsInfoCallout

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 121 edges
2. `EasyStreamCore` - 97 edges
3. `BroadcastMediaViewModel` - 88 edges
4. `CameraSourceID` - 83 edges
5. `BroadcastResource` - 82 edges
6. `BroadcastWidgetConfiguration` - 60 edges
7. `TeamIntercomService` - 56 edges
8. `SwitchTransitionKind` - 54 edges
9. `BroadcastMetalCompositor` - 53 edges
10. `CameraSessionViewModel` - 48 edges

## Surprising Connections (you probably didn't know these)
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `.landscapeSessionContent` --calls--> `CameraTallyGlowOverlay`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionLandscapeLayout.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraTallyGlowOverlay.swift
- `.cameraControlsCard` --calls--> `CameraClientControlsView`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionLandscapeLayout.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/CameraClientControlsView.swift

## Import Cycles
- None detected.

## Communities (179 total, 2 thin omitted)

### Community 0 - "EasyStreamCore"
Cohesion: 0.15
Nodes (3): EasyStreamCore, MetalKit, WebRTC

### Community 1 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 2 - "DirectorMonitorQualitySettings"
Cohesion: 0.15
Nodes (12): DirectorVideoQualitySettingsView, Void, DirectorMonitorQualityPreferencesStore, DirectorMonitorQualitySettings, .outputEncoderConfiguration, LegacyTier, balanced, economy (+4 more)

### Community 3 - ".body"
Cohesion: 0.15
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "DirectorSessionViewModel"
Cohesion: 0.09
Nodes (28): .keyboardShortcuts, .remoteControlsSection, ConnectedCameraSource, DirectorSessionViewModel, .activeStreamingSourceCount, .connectedSourceCount, .effectiveMonitorQuality, .isFacebookConfigured (+20 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "ProgramCrossfadeHost"
Cohesion: 0.12
Nodes (15): ProgramCrossfadeHost, Bool, ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack, ProgramBusController, Snapshot, Bool (+7 more)

### Community 8 - "Equatable"
Cohesion: 0.18
Nodes (14): Equatable, SequencePhase, offscreen, onscreen, ProgramTransitionFrame, .usesVisualTransform, ProgramTransitionLifecycle, ProgramTransitionPresentationMode (+6 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.14
Nodes (15): .body, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool, Never (+7 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.16
Nodes (10): CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program, Bool (+2 more)

### Community 12 - ".body"
Cohesion: 0.11
Nodes (12): .body, DirectorSettingsSheet, .streamPanel, Void, DirectorWorkspaceSession, .monitorQuality, Bool, Task (+4 more)

### Community 13 - "PreviewMonitorCellView"
Cohesion: 0.23
Nodes (13): PreviewMonitorCamera, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges, PreviewMonitorMultiviewGrid, .body (+5 more)

### Community 14 - ".connectIfNeeded"
Cohesion: 0.23
Nodes (6): ObjectIdentifier, NWConnection, NWListener, NWParameters, String, Task

### Community 15 - "BroadcastBarlessWindowConfigurator"
Cohesion: 0.36
Nodes (4): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow

### Community 16 - "Coordinator"
Cohesion: 0.20
Nodes (9): AVCaptureVideoPreviewLayer, CameraPreviewView, Coordinator, AVCaptureSession, Context, Coordinator, RTCVideoTrack, WebRTCVideoView (+1 more)

### Community 18 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 19 - "BroadcastGlowButtonStyle"
Cohesion: 0.16
Nodes (13): ButtonStyle, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlowButtonStyle, BroadcastTakeButtonStyle, Bool, LinearGradient, .actionButtons (+5 more)

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.22
Nodes (11): BroadcastMetalProgramFeedPlatformView, Coordinator, CGSize, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack (+3 more)

### Community 21 - "AppRole"
Cohesion: 0.12
Nodes (17): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+9 more)

### Community 22 - "Binding"
Cohesion: 0.22
Nodes (6): .exposureBinding, .whiteBalanceBinding, .zoomBinding, Binding, Double, Float

### Community 23 - "DirectorConnectionPanel"
Cohesion: 0.22
Nodes (10): ConnectionStatusBadge, .body, DirectorConnectionPanel, .body, LocalNetworkPermissionView, .body, Bool, String (+2 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "ProgramFeedWidgetLayer"
Cohesion: 0.21
Nodes (14): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void, ProgramFeedView, ProgramFeedWidgetLayer, Binding (+6 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "BroadcastTransmissionMenu"
Cohesion: 0.12
Nodes (22): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, BroadcastTransmissionMenu (+14 more)

### Community 28 - "FacebookPlatformAuth.swift"
Cohesion: 0.08
Nodes (17): App, AppTrackingTransparency, EasyStreamApp, .body, DirectorProgramOutputWindowView, DirectorVideoQualityWindowView, .body, EasyStreamFacebook (+9 more)

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.08
Nodes (21): .body, .liveGraphicsSection, .widgetStudioSection, BroadcastMediaViewModel, .allResources, .committedLiveAirWidgetLayers, .directorLiveAirWidgetLayers, .isEditingExistingWidget (+13 more)

### Community 31 - "SwiftUI"
Cohesion: 0.12
Nodes (10): AppKit, AVKit, EasyStreamCameraCapture, EasyStreamTransport, EasyStreamUIComponents, ImageIO, PlatformSettings, SwiftUI (+2 more)

### Community 32 - "SwitcherEngine"
Cohesion: 0.09
Nodes (22): .selectedTransition, EasyStreamSwitcher, TimeInterval, SwitcherSnapshot, SwitchTransition, TransitionPreferencesStore, Set, SwitcherEngine (+14 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.07
Nodes (33): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32, Event (+25 more)

### Community 34 - "String"
Cohesion: 0.12
Nodes (31): BroadcastAsyncThumbnailImage, BroadcastMediaLibraryPanel, .body, .filteredPlaylists, BroadcastMediaPhotoImporter, BroadcastPlaylistEditorSheet, .body, BroadcastPlaylistPanel (+23 more)

### Community 35 - "Sendable"
Cohesion: 0.18
Nodes (18): Codable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4 (+10 more)

### Community 36 - "Coordinator"
Cohesion: 0.16
Nodes (12): DispatchWorkItem, Coordinator, Coordinator, NSObjectProtocol, RTCVideoTrack, Void, .uiMetalMode, WebRTCVideoView (+4 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (40): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton, .body (+32 more)

### Community 38 - "View"
Cohesion: 0.12
Nodes (28): AnimatedLogoWidgetView, BroadcastDraggableWidgetOverlay, .body, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView, .body, .opacity (+20 more)

### Community 39 - "View"
Cohesion: 0.13
Nodes (9): Configuration, BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastHiddenToolbarModifier, BroadcastStudioChromeModifier, CGFloat, Content, View (+1 more)

### Community 40 - "ProgramOutputSyncBridge"
Cohesion: 0.40
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 41 - "ProgramPreviewVisibilityPolicy"
Cohesion: 0.15
Nodes (12): ProgramPreviewVisibilityPolicy, allConnectedSources, previewSourceOnly, Bool, ProgramRenderBackend, legacyDualWebRTC, metalCompositor, ProgramRenderConfiguration (+4 more)

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
Cohesion: 0.25
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "TeamIntercomPanel"
Cohesion: 0.25
Nodes (11): .cameraIntercomCard, ProgramAudioSourcePanel, .body, SourceOption, Bool, String, UUID, Void (+3 more)

### Community 49 - "DirectorSidebarTab"
Cohesion: 0.16
Nodes (12): .sourceSidebar, .body, DirectorLeftSidebarTabPicker, .body, DirectorSidebarTab, cameras, .id, library (+4 more)

### Community 50 - "SwitchTransitionKind"
Cohesion: 0.09
Nodes (26): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, slide, wipe (+18 more)

### Community 51 - "ProgramCrossfadePlatformView"
Cohesion: 0.15
Nodes (12): ProgramCrossfadeLayout, CGSize, ProposedViewSize, Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context (+4 more)

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "ProgramCrossfadePlatformView"
Cohesion: 0.23
Nodes (9): Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context, Coordinator, Double, ProposedViewSize (+1 more)

### Community 54 - "BroadcastWidgetConfiguration"
Cohesion: 0.06
Nodes (35): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+27 more)

### Community 55 - ".recreateSession"
Cohesion: 0.21
Nodes (10): OSStatus, CMTime, CVPixelBuffer, Int32, VideoEncoderError, configurationFailed, encodeFailed, sampleExtractionFailed (+2 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.07
Nodes (24): Bool, CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady (+16 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.22
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "DirectorProgramOutputStore"
Cohesion: 0.42
Nodes (6): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL

### Community 60 - ".content"
Cohesion: 0.12
Nodes (22): AnyView, .body, .content, CachedWidgetLogoView, Content, DirectorInspectorPanel, .body, DirectorInspectorSection (+14 more)

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.12
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "DirectorVideoQualityPanel.swift"
Cohesion: 0.14
Nodes (20): Option, BroadcastPlatformTagRow, .body, BroadcastQualityDropdown, .body, BroadcastSettingsInfoCallout, .body, BroadcastSettingsToggleRow (+12 more)

### Community 63 - "DirectorProgramVideoBusView"
Cohesion: 0.33
Nodes (6): DirectorProgramVideoBusView, .body, Bool, Double, RTCVideoTrack, String

### Community 64 - "CameraSessionView"
Cohesion: 0.16
Nodes (14): CameraSessionLayoutMetrics, .cameraLayoutKind, .landscapeSessionContent, CGFloat, View, CameraSessionView, .streamBadgeLabel, .platformSessionContent (+6 more)

### Community 65 - "BroadcastResource"
Cohesion: 0.20
Nodes (10): String, .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel (+2 more)

### Community 66 - "CameraLensKind"
Cohesion: 0.09
Nodes (28): ClosedRange, AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id (+20 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.14
Nodes (13): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, .body, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool (+5 more)

### Community 68 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 69 - "Driver"
Cohesion: 0.27
Nodes (9): CADisplayLink, CVDisplayLink, Driver, ProgramTransitionDisplayLink, CFTimeInterval, Double, Int, TimeInterval (+1 more)

### Community 70 - "BroadcastMetalEmptyOverlayProvider"
Cohesion: 0.29
Nodes (6): BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, Bool, CGSize, MTLDevice, MTLTexture

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.12
Nodes (17): BroadcastMacFilePicker, Void, BroadcastResourceKind, image, .systemImage, .title, video, widget (+9 more)

### Community 72 - "ProgramTransitionEffect.swift"
Cohesion: 0.19
Nodes (12): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, Double, LinearProgress, WipeTransitionEffect (+4 more)

### Community 73 - ".matches"
Cohesion: 0.24
Nodes (7): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String, Bool

### Community 74 - "CameraSessionLayoutKind"
Cohesion: 0.33
Nodes (5): CameraSessionLayoutKind, mac, phone, tablet, CGSize

### Community 75 - "NSView"
Cohesion: 0.15
Nodes (8): CALayer, ProgramTransitionRevealMask, CGRect, Double, NSView, CGFloat, Double, QuartzCore

### Community 76 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 77 - "ProgramFrameRingBuffer"
Cohesion: 0.22
Nodes (8): FrameDescriptor, size_t, ProgramFrameRingBuffer, count_, latest, push, slots_, writeIndex_

### Community 78 - "Testing"
Cohesion: 0.14
Nodes (3): EasyStreamTests, deviceIdentityPersistsID(), Testing

### Community 79 - "BroadcastMediaThumbnailLoader"
Cohesion: 0.17
Nodes (15): NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox, .body (+7 more)

### Community 80 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.09
Nodes (25): MTKView, MTKViewDelegate, MTLCommandQueue, MTLLibrary, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer (+17 more)

### Community 82 - "RemoteCameraCommand"
Cohesion: 0.19
Nodes (15): RemoteCameraCommand, applySavedSettings, reconnectStream, setDirectorMonitorQuality, setExposureBias, setLens, setMuted, setSwitcherAssignment (+7 more)

### Community 83 - "CameraTransportProfile"
Cohesion: 0.15
Nodes (12): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+4 more)

### Community 84 - "LiveProgramAirStore"
Cohesion: 0.11
Nodes (22): DirectorProgramLiveMonitorView, .body, .programVideoContent, DirectorMainSwitcherAreaView, .body, .canTake, DirectorProgramOutputCorePanel, .body (+14 more)

### Community 85 - "Foundation"
Cohesion: 0.08
Nodes (11): AVFoundation, CoreMedia, EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, Foundation, Network, Observation (+3 more)

### Community 86 - "String"
Cohesion: 0.29
Nodes (4): FacebookAuthService, FacebookTokenParser, String, WebKit

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "WebRTCVideoFramePublisher"
Cohesion: 0.26
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 89 - ".makeVideoTextures"
Cohesion: 0.20
Nodes (9): CGImage, BroadcastMetalI420ConversionCache, BroadcastMetalTextureUploader, CVMetalTextureCache, CVPixelBuffer, CVPixelBufferPool, MTLDevice, MTLTexture (+1 more)

### Community 90 - "WhiteBalanceModeOption"
Cohesion: 0.18
Nodes (11): Double, Float, WhiteBalanceModeOption, auto, cool, .displayName, .id, locked (+3 more)

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
Cohesion: 0.24
Nodes (8): ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGRect, CGSize, NSCoder, ProposedViewSize

### Community 95 - ".setOpacity"
Cohesion: 0.32
Nodes (5): AnyObject, ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 96 - "CameraTallyGlowOverlay"
Cohesion: 0.24
Nodes (9): CameraTallyGlowOverlay, .body, .glowColor, CameraTallyGlowPlacement, contentFrame, .cornerRadius, .edgeInset, screenEdge (+1 more)

### Community 97 - ".sizeThatFits"
Cohesion: 0.20
Nodes (6): CGSize, ProposedViewSize, VideoPreviewLayout, CGSize, ProposedViewSize, RTCVideoRenderer

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.13
Nodes (17): .cameraControlsCard, .cameraDirectorCard, BroadcastCompactLiveBadge, .body, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body (+9 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.12
Nodes (16): CheckedContinuation, Notification, NSWindowDelegate, FacebookWebLoginSession, Bool, Error, NSWindow, URL (+8 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.18
Nodes (12): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, RTCDataChannel, RTCIceConnectionState, RTCIceGatheringState (+4 more)

### Community 101 - "BroadcastMetalTextureUploader.swift"
Cohesion: 0.15
Nodes (7): CoreGraphics, CoreVideo, Metal, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32

### Community 102 - "ProgramCrossfadeLetterboxSizeDelegate"
Cohesion: 0.22
Nodes (9): MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect, CGSize, RTCVideoRenderer, Void (+1 more)

### Community 103 - ".resized"
Cohesion: 0.15
Nodes (16): CGPoint, CGFloat, CGRect, CGSize, Gesture, WidgetOverlayContentSizing, fillFrame, uniformSquare (+8 more)

### Community 104 - "LiveProgramFeedView"
Cohesion: 0.23
Nodes (17): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, PreviewWidgetOverlayView, .body, StableProgramVideoView, StableWidgetOverlayView (+9 more)

### Community 105 - "ClippingRTCVideoContainer"
Cohesion: 0.26
Nodes (9): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, NSCoder, NSRect (+1 more)

### Community 106 - "BroadcastStreamSpec"
Cohesion: 0.18
Nodes (13): BroadcastStreamSpec, .displayLabel, PreviewTilePreset, economy, .id, minimal, standard, .streamSpec (+5 more)

### Community 107 - ".signIn"
Cohesion: 0.33
Nodes (5): AccessToken, FacebookPlatformAuth, Bool, String, UIViewController

### Community 108 - "StreamOutputPreset"
Cohesion: 0.11
Nodes (19): BroadcastPlatform, facebook, rtmp, .shortLabel, youtube, StreamOutputPreset, .detail, .encoderConfiguration (+11 more)

### Community 109 - "DirectorSessionView"
Cohesion: 0.07
Nodes (32): DirectorLibraryRailView, DirectorSessionView, .camerasSidebarContent, .canTake, .compactLayout, .directorWorkspaceLayout, .librarySection, .mainSwitcherArea (+24 more)

### Community 110 - "Void"
Cohesion: 0.19
Nodes (12): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body, PreviewMonitorSettingsSheet (+4 more)

### Community 111 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 112 - "SignalingMessage"
Cohesion: 0.14
Nodes (12): SignalingMessage, answer, control, hello, ice, offer, settingsState, Decoder (+4 more)

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
Cohesion: 0.09
Nodes (26): Font, NSColor, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced (+18 more)

### Community 117 - ".application"
Cohesion: 0.17
Nodes (11): Any, Bool, UIApplication, UIInterfaceOrientationMask, URL, FacebookSDKBootstrap, Any, Bool (+3 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "RoleSelectionView"
Cohesion: 0.18
Nodes (11): RoleCard, .body, RoleSelectionView, .body, .footer, .header, .roleCards, Binding (+3 more)

### Community 120 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 121 - "TeamIntercomPeer"
Cohesion: 0.28
Nodes (7): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer

### Community 122 - "Color"
Cohesion: 0.18
Nodes (10): BroadcastGlassProminentButtonStyle, BroadcastLiveStreamSizeBadge, .body, LiveLabel, ProgramBusLiveResolutionBadge, .body, String, Color (+2 more)

### Community 123 - "DiscoveredDevice"
Cohesion: 0.12
Nodes (18): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, DiscoveryEvent (+10 more)

### Community 124 - "VideoRendererSinkCategory"
Cohesion: 0.15
Nodes (12): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+4 more)

### Community 125 - "CameraCaptureService"
Cohesion: 0.08
Nodes (21): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureLoadTier, idle, preview, program, .sessionPreset, AVCaptureSession (+13 more)

### Community 126 - "WebRTCConfiguration"
Cohesion: 0.25
Nodes (5): RTCMediaConstraints, Void, WebRTCConfiguration, RTCConfiguration, RTCPeerConnectionFactory

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

### Community 132 - ".handleBrowseResults"
Cohesion: 0.31
Nodes (3): NWBrowser, NWTXTRecord, Set

### Community 133 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 134 - "ProgramMonitorPreset"
Cohesion: 0.22
Nodes (9): ProgramMonitorPreset, balanced720, .detail, economy540, full1080, .id, light360, .streamSpec (+1 more)

### Community 135 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 136 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 137 - "CodingKeys"
Cohesion: 0.25
Nodes (8): CodingKeys, energySaverMode, outputPreset, pauseIdleCameraStreams, prefetchTakeTarget, previewPreset, progPreset, tier

### Community 138 - "LiveVideoStreamSizeStore"
Cohesion: 0.39
Nodes (4): LiveVideoStreamSizeStore, CGSize, String, RTCVideoRenderer

### Community 139 - ".extract"
Cohesion: 0.29
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "DirectorStatusBar"
Cohesion: 0.47
Nodes (5): DirectorStatusBar, .body, .cameraCountLabel, Int, String

### Community 141 - "RoundedRectangle"
Cohesion: 0.10
Nodes (30): DirectorProgramStudioHintsOverlay, .body, .widgetDraftPreviewCanvas, IntercomActivationRing, .body, IntercomPushToTalkButton, .activeCornerRadius, .body (+22 more)

### Community 142 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.12
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
Cohesion: 0.21
Nodes (10): CaseIterable, DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac (+2 more)

### Community 152 - "ProgramFrameBusSlot"
Cohesion: 0.08
Nodes (25): .programFrameBusSnapshot, ProgramFrameBusSlot, programIncoming, programOnAir, programOutgoing, ProgramFrameTelemetryNoOp, ProgramFrameTelemetryPort, ProgramFrameTelemetryRegistry (+17 more)

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
Cohesion: 0.14
Nodes (14): DirectorStreamReceiver, RTCPeerConnection, SessionContext, AsyncStream, Int32, NWConnection, RTCIceCandidate, RTCMediaConstraints (+6 more)

### Community 157 - ".save"
Cohesion: 0.36
Nodes (3): CameraSettingsStore, UUID, Void

### Community 158 - "BoundedWebRTCVideoView"
Cohesion: 0.40
Nodes (5): BoundedWebRTCVideoView, .body, RTCVideoTrack, .videoContent, .videoLayer

### Community 159 - ".init"
Cohesion: 0.50
Nodes (3): CGRect, NSCoder, NSRect

### Community 160 - "TransitionCurve"
Cohesion: 0.25
Nodes (6): Double, LinearProgress, TransitionCurve, easeInOutCubic, linear, smoothStep

### Community 161 - ".applyExternalDisplayPreference"
Cohesion: 0.43
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 162 - "StreamDestinationPanel"
Cohesion: 0.27
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 163 - "ProgramFrameNativeCapabilities"
Cohesion: 0.50
Nodes (3): ProgramFrameNativeCapabilities, .busModuleVersion, String

### Community 164 - "CameraSourceTile"
Cohesion: 0.22
Nodes (13): CameraSourceTile, .borderColor, .placeholderMessage, .placeholderSymbolName, Bool, Double, Gesture, RTCVideoTrack (+5 more)

### Community 165 - "CountdownAnimationModifier"
Cohesion: 0.16
Nodes (14): Animation, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .scale (+6 more)

### Community 166 - "VideoEncoderConfiguration"
Cohesion: 0.25
Nodes (7): CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration, .bitrateMbpsLabel, .displayLabel, .resolutionLabel

### Community 167 - "FacebookSession"
Cohesion: 0.12
Nodes (16): .destinationSection, .facebookPanel, FacebookLiveService, String, FacebookPage, FacebookSession, .isSignedIn, Bool (+8 more)

### Community 168 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 169 - "BroadcastWidgetPlacement"
Cohesion: 0.13
Nodes (23): AVPlayer, DirectorProgramAirGraphicsView, .body, DirectorProgramPreviewOverlayView, .body, URL, UUID, Void (+15 more)

### Community 170 - "MessageType"
Cohesion: 0.29
Nodes (7): MessageType, answer, control, hello, ice, offer, settingsState

### Community 171 - "Identifiable"
Cohesion: 0.14
Nodes (15): CodingKey, Identifiable, LocalizedError, CodingKeys, accessToken, id, name, secureStreamURL (+7 more)

### Community 172 - "FacebookSignInRequest"
Cohesion: 0.38
Nodes (5): FacebookNativeAuthBridge, FacebookSignInRequest, Bool, String, SignInHandler

### Community 173 - "UIView"
Cohesion: 0.43
Nodes (3): CGFloat, Double, UIView

### Community 174 - ".cappedDrawableSize"
Cohesion: 0.32
Nodes (3): BroadcastMetalDrawableLimits, CGFloat, CGSize

### Community 175 - "StreamingDeliveryMode"
Cohesion: 0.33
Nodes (5): StreamingDeliveryMode, .displayName, hls, rtmps, webrtcLAN

### Community 176 - "SignalStrengthView"
Cohesion: 0.50
Nodes (4): .body, SignalStrengthView, .body, Int

### Community 177 - "Phase"
Cohesion: 0.40
Nodes (5): Phase, empty, offAirWarm, onAir, transitioning

### Community 178 - "BroadcastSettingsInfoCallout"
Cohesion: 0.50
Nodes (4): BroadcastSettingsInfoCallout, .body, .body, String

## Knowledge Gaps
- **557 isolated node(s):** `roleSelection`, `session`, `phone`, `tablet`, `mac` (+552 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `BroadcastMetalCompositor` connect `BroadcastMetalCompositor` to `EasyStreamCore`, `Sendable`, `.cappedDrawableSize`, `NSObject`, `.layerFrame`, `.makeVideoTextures`, `BroadcastMetalProgramFeedContainerNSView`?**
  _High betweenness centrality (0.080) - this node is a cross-community bridge._
- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `SwitcherEngine`, `ProgramAudioEncoderPipeline`, `DirectorMonitorQualitySettings`, `FacebookSession`, `ProgramOutputSyncBridge`, `.body`, `DirectorSessionView`, `DiscoveryService`, `VideoRendererSinkCategory`, `DirectorStreamReceiver`, `LiveProgramAirStore`, `Foundation`, `ProgramFrameBusSlot`, `BroadcastStreamPublisher`, `DiscoveredDevice`, `StreamDestination`, `ProgramVideoEncoderPipeline`, `DirectorProgramVideoBusView`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `ProgramCrossfadeHost`, `CameraSwitcherAssignment`, `RoundedRectangle`, `PreviewMonitorCellView`, `ProgramFrameBusSlot`, `ProgramFeedWidgetLayer`, `FacebookPlatformAuth.swift`, `SwiftUI`, `SwitcherEngine`, `String`, `StreamDestinationPanel`, `View`, `ProgramOutputSyncBridge`, `.content`, `DirectorVideoQualityPanel.swift`, `ProgramTransitionEffect.swift`, `Testing`, `Foundation`, `BroadcastTheme.swift`, `BroadcastMetalTextureUploader.swift`, `LiveProgramFeedView`, `RoleSelectionView`, `Color`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `.body` and `DirectorSessionView`) actually correct?**
  _`BroadcastMediaViewModel` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `phone` to the rest of the system?**
  _557 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `EasyStreamCore` be split into smaller, more focused modules?**
  _Cohesion score 0.1476923076923077 - nodes in this community are weakly interconnected._