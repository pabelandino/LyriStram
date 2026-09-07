# Graph Report - EasyStream  (2026-09-01)

## Corpus Check
- 174 files · ~68,023 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3070 nodes · 7326 edges · 173 communities (161 shown, 12 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 600 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2eeb5674`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- UIKit
- Data
- ClippingRTCVideoContainerView
- BroadcastGlowButtonStyle
- FLVBuilder
- CountdownAnimationModifier
- PlayoutTapAudioDevice
- ProgramCrossfadeHost
- DirectorSessionView
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- Task
- View
- DirectorProgramVideoBusView
- NSView
- Coordinator
- DiscoveryService
- Color
- DirectorStreamReceiver
- BroadcastMetalProgramFeedPlatformView
- AppRole
- DirectorSessionViewModel
- DirectorConnectionPanel
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- BroadcastTransmissionMenu
- VideoRendererSinkCategory
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- DirectorPreviewMonitorStore
- CameraSourceID
- ProgramAudioEncoderPipeline
- String
- Codable
- DeviceIdentity
- BroadcastWidgetStudioPanel
- RTMPPublisher
- LiveProgramFeedView
- EasyStreamCore
- ProgramPreviewVisibilityPolicy
- EasyStreamUITests
- AppKit
- FacebookConfiguration
- BroadcastWidgetRenderer.swift
- .current
- Identifiable
- PackageDescription
- .connectIfNeeded
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetConfiguration
- H264VideoEncoder
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- DirectorRemoteControlsView
- VideoEncoderError
- ProgramCrossfadeContainerUIView
- BroadcastWidgetPlacement
- WebRTC
- CameraSessionView
- BroadcastFontPreset
- .content
- TeamIntercomService
- .startOffer
- Driver
- BroadcastMetalOverlayProvider
- BroadcastResource
- ProgramTransitionFrame
- .matches
- ProgramFrameBusSlot
- IntercomPushToTalkPulseRing
- BroadcastMetalProgramFeedContainerNSView
- ProgramFrameRingBuffer
- Testing
- CameraPreviewView
- CachedWidgetLogoView
- BroadcastMetalCompositor
- RemoteCameraSettings
- ProgramFeedWidgetLayer
- DirectorSidebarTab
- Foundation
- .makeVideoTextures
- BroadcastMetalSwiftUIOverlayProvider
- WebRTCVideoFramePublisher
- .requestDraw
- Sendable
- Error
- StreamDestination
- StreamConnectionState
- DiscoveredDevice
- CameraTransportProfile
- FacebookAuthError
- .apply
- BroadcastTheme.swift
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- .invalidateDisplay
- ProgramCrossfadeLetterboxSizeDelegate
- BroadcastDraggableWidgetOverlay
- BroadcastMetalProgramFeedView
- LayoutNeutralRTCMTLNSVideoView
- .body
- SignalingChannel
- RoundedRectangle
- Event
- StreamDestinationPanel
- VideoEncoderConfiguration
- CaseIterable
- NSObject
- DirectorSourcesPanel
- FacebookGraphClient
- IntercomPushToTalkButton
- .application
- WebRTCProgramFrameSink
- CameraClientControlsView
- CodingKeys
- TeamIntercomPeer
- AACAudioEncoder
- PreviewMultiviewGridSpec
- .apply
- CameraCaptureService
- BroadcastTheme
- CameraLensKind
- RemoteLensOption
- ProgramFrameRingBuffer.cpp
- EncodedVideoSample
- DiscoveredDeviceRow
- FacebookPlatformAuth.swift
- LogoAnimationModifier
- ProgramFrameNativeStatus
- ProgramFrameNativeCapabilities
- RTMPStreamError
- .signIn
- Event
- .extract
- DirectorProgramOutputStore
- BroadcastPlaylistRepository
- .handleBrowseResults
- ProgramCrossfadeContainerNSView
- LocalNetworkPermissionTrigger
- ProgramOutputSyncBridge
- CameraPermissionStatus
- WhiteBalanceModeOption
- TransitionCurve
- .applyExternalDisplayPreference
- BroadcastPanelModifier
- State
- .finish
- RemoteWhiteBalanceOption
- .handleOffer
- FacebookSignInRequest
- FacebookLivePanel
- EncoderCallbackBridge
- FacebookAuthService
- .controlsSheet
- .frame
- ProgramRenderBackend
- DirectorStatusBar
- String
- TransitionPreferencesStore
- CameraStreamConfiguration.swift
- .init
- FacebookGraphClient.swift
- .addIceCandidate
- .decodeMessages
- NWError

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 110 edges
2. `EasyStreamCore` - 89 edges
3. `BroadcastMediaViewModel` - 88 edges
4. `BroadcastResource` - 82 edges
5. `CameraSourceID` - 81 edges
6. `BroadcastWidgetConfiguration` - 60 edges
7. `TeamIntercomService` - 55 edges
8. `SwitchTransitionKind` - 53 edges
9. `DirectorSessionView` - 48 edges
10. `CameraSessionViewModel` - 48 edges

## Surprising Connections (you probably didn't know these)
- `.previewDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.programDisplayName` --references--> `PreviewMonitorCamera`  [INFERRED]
  EasyStream/Features/Director/DirectorPreviewMonitorStore.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/PreviewMonitorViews.swift
- `.body` --calls--> `StableProgramVideoView`  [INFERRED]
  EasyStream/Features/Director/DirectorProgramMonitorView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/StableProgramVideoView.swift
- `CameraSessionView` --calls--> `TeamIntercomService`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamTransport/Sources/EasyStreamTransport/TeamIntercomService.swift
- `.body` --calls--> `ConnectionStatusBadge`  [INFERRED]
  EasyStream/Features/Camera/CameraSessionView.swift → Packages/EasyStreamUIComponents/Sources/EasyStreamUIComponents/DiscoveryViews.swift

## Import Cycles
- None detected.

## Communities (173 total, 12 thin omitted)

### Community 0 - "UIKit"
Cohesion: 0.19
Nodes (8): EasyStreamAudioPipeline, EasyStreamCameraCapture, EasyStreamStreaming, EasyStreamTransport, EasyStreamUIComponents, Observation, UIKit, UniformTypeIdentifiers

### Community 1 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 2 - "ClippingRTCVideoContainerView"
Cohesion: 0.23
Nodes (7): boundedSize(), ClippingRTCVideoContainerView, .intrinsicContentSize, .intrinsicContentSize, CGSize, ProposedViewSize, RTCVideoRenderer

### Community 3 - "BroadcastGlowButtonStyle"
Cohesion: 0.08
Nodes (21): ButtonStyle, Configuration, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastGlowButtonStyle, BroadcastHiddenToolbarModifier (+13 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "CountdownAnimationModifier"
Cohesion: 0.16
Nodes (14): Animation, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .scale (+6 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - "ProgramCrossfadeHost"
Cohesion: 0.14
Nodes (12): ProgramCrossfadeHost, Bool, ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack, ApplySignature, ProgramCrossfadeSession, Bool (+4 more)

### Community 8 - "DirectorSessionView"
Cohesion: 0.04
Nodes (53): DirectorProgramAirGraphicsView, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, URL (+45 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.13
Nodes (15): .body, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool, Never (+7 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.10
Nodes (21): .phoneSessionContent, .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram (+13 more)

### Community 12 - "Task"
Cohesion: 0.13
Nodes (8): .destinationPanelFacebook, .destinationPanelStream, .destinationSection, Task, AudioEncoderStats, Bool, VideoEncoderStats, .estimatedBitrateKbps

### Community 13 - "View"
Cohesion: 0.20
Nodes (14): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body, PreviewMonitorSettingsSheet (+6 more)

### Community 14 - "DirectorProgramVideoBusView"
Cohesion: 0.33
Nodes (6): DirectorProgramVideoBusView, .body, Bool, Double, RTCVideoTrack, String

### Community 15 - "NSView"
Cohesion: 0.19
Nodes (7): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow, NSView, CGFloat, Double

### Community 16 - "Coordinator"
Cohesion: 0.18
Nodes (9): DispatchWorkItem, Coordinator, Coordinator, NSObjectProtocol, RTCVideoTrack, Void, WebRTCVideoView, RTCMTLNSVideoView (+1 more)

### Community 17 - "DiscoveryService"
Cohesion: 0.13
Nodes (16): EasyStreamLog, DiscoveryService, .discoveredDevices, AsyncStream, Bool, NWBrowser, NWConnection, NWEndpoint (+8 more)

### Community 18 - "Color"
Cohesion: 0.19
Nodes (15): BroadcastGlassProminentButtonStyle, Color, PreviewMonitorCamera, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges (+7 more)

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.20
Nodes (8): DirectorStreamReceiver, SessionContext, AsyncStream, NWConnection, RTCMediaStreamTrack, RTCPeerConnection, String, UUID

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.23
Nodes (10): BroadcastMetalProgramFeedPlatformView, Coordinator, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack, URL (+2 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - "DirectorSessionViewModel"
Cohesion: 0.09
Nodes (24): .inspectorSection, .canTake, .canTake, ConnectedCameraSource, DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing (+16 more)

### Community 23 - "DirectorConnectionPanel"
Cohesion: 0.20
Nodes (10): ConnectionStatusBadge, .body, DirectorConnectionPanel, .body, LocalNetworkPermissionView, .body, Bool, String (+2 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "SignalingMessage"
Cohesion: 0.11
Nodes (17): Encoder, MessageType, answer, control, hello, ice, offer, settingsState (+9 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "BroadcastTransmissionMenu"
Cohesion: 0.11
Nodes (22): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, BroadcastTransmissionMenu (+14 more)

### Community 28 - "VideoRendererSinkCategory"
Cohesion: 0.13
Nodes (17): .videoRendererSinkSnapshot, Int, VideoRendererSinkCategory, encoder, externalOutput, other, previewMonitor, program (+9 more)

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.07
Nodes (25): .body, .inspectorPanel, .librarySidebarContent, .libraryContent, BroadcastMacFilePicker, BroadcastMediaViewModel, .allResources, .committedLiveAirWidgetLayers (+17 more)

### Community 31 - "DirectorPreviewMonitorStore"
Cohesion: 0.12
Nodes (15): .body, DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String (+7 more)

### Community 32 - "CameraSourceID"
Cohesion: 0.09
Nodes (23): DirectorPreviewGridView, .body, EasyStreamSwitcher, Equatable, TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID (+15 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "String"
Cohesion: 0.09
Nodes (42): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+34 more)

### Community 35 - "Codable"
Cohesion: 0.18
Nodes (17): Codable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4 (+9 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (43): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+35 more)

### Community 38 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.24
Nodes (16): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, PreviewWidgetOverlayView, .body, StableProgramVideoView, StableWidgetOverlayView, .body (+8 more)

### Community 41 - "ProgramPreviewVisibilityPolicy"
Cohesion: 0.19
Nodes (9): .previewGridSection, ProgramPreviewVisibilityPolicy, allConnectedSources, previewSourceOnly, Bool, DirectorPreviewTileTrackPolicy, Bool, RTCVideoTrack (+1 more)

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "AppKit"
Cohesion: 0.15
Nodes (5): AppKit, AVKit, ImageIO, PlatformSettings, WebKit

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "BroadcastWidgetRenderer.swift"
Cohesion: 0.16
Nodes (20): AnimatedLogoWidgetView, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView, .body (+12 more)

### Community 46 - ".current"
Cohesion: 0.30
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "Identifiable"
Cohesion: 0.09
Nodes (22): CodingKey, Identifiable, LocalizedError, FacebookLiveService, String, CodingKeys, accessToken, id (+14 more)

### Community 49 - ".connectIfNeeded"
Cohesion: 0.20
Nodes (7): NWConnection, NWListener, NWParameters, NWTXTRecord, ObjectIdentifier, String, Task

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
Nodes (33): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+25 more)

### Community 55 - "H264VideoEncoder"
Cohesion: 0.26
Nodes (6): H264VideoEncoder, AsyncStream, Int32, configurationFailed, VTCompressionOutputCallback, VTCompressionSession

### Community 56 - "CameraStreamClient"
Cohesion: 0.10
Nodes (18): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, AsyncStream (+10 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.22
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "DirectorRemoteControlsView"
Cohesion: 0.12
Nodes (25): CameraSourceTile, .body, .borderColor, .placeholderMessage, .placeholderSymbolName, DirectorRemoteControlsView, .body, .connectionStateLabel (+17 more)

### Community 60 - "VideoEncoderError"
Cohesion: 0.29
Nodes (7): OSStatus, CMTime, CVPixelBuffer, VideoEncoderError, encodeFailed, sampleExtractionFailed, sessionCreationFailed

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.08
Nodes (18): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+10 more)

### Community 62 - "BroadcastWidgetPlacement"
Cohesion: 0.18
Nodes (17): AVPlayer, .body, .body, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body (+9 more)

### Community 63 - "WebRTC"
Cohesion: 0.14
Nodes (5): CoreGraphics, CoreVideo, Metal, MetalKit, WebRTC

### Community 64 - "CameraSessionView"
Cohesion: 0.13
Nodes (14): CameraSessionView, .connectionSummary, .exposureBinding, .lensLabel, .streamBadgeLabel, .tabletSessionContent, .whiteBalanceBinding, .zoomBinding (+6 more)

### Community 65 - "BroadcastFontPreset"
Cohesion: 0.15
Nodes (16): Font, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded (+8 more)

### Community 66 - ".content"
Cohesion: 0.16
Nodes (13): NSColor, .placeholderLogo, .opacity, .content, .body, WidgetCornerHandle, .body, BroadcastWidgetColors (+5 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.16
Nodes (11): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool, Data (+3 more)

### Community 68 - ".startOffer"
Cohesion: 0.13
Nodes (9): RTCPeerConnection, Int32, RTCIceCandidate, RTCMediaConstraints, RTCSessionDescription, RTCMediaConstraints, WebRTCConfiguration, RTCConfiguration (+1 more)

### Community 69 - "Driver"
Cohesion: 0.27
Nodes (9): CADisplayLink, CFTimeInterval, CVDisplayLink, Driver, ProgramTransitionDisplayLink, Double, Int, TimeInterval (+1 more)

### Community 70 - "BroadcastMetalOverlayProvider"
Cohesion: 0.18
Nodes (10): AnyObject, BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice (+2 more)

### Community 71 - "BroadcastResource"
Cohesion: 0.10
Nodes (23): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, BroadcastResourceKind (+15 more)

### Community 72 - "ProgramTransitionFrame"
Cohesion: 0.12
Nodes (22): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, Double, LinearProgress, WipeTransitionEffect (+14 more)

### Community 73 - ".matches"
Cohesion: 0.31
Nodes (6): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String

### Community 74 - "ProgramFrameBusSlot"
Cohesion: 0.08
Nodes (25): .programFrameBusSnapshot, ProgramFrameBusSlot, programIncoming, programOnAir, programOutgoing, ProgramFrameTelemetryNoOp, ProgramFrameTelemetryPort, ProgramFrameTelemetryRegistry (+17 more)

### Community 75 - "IntercomPushToTalkPulseRing"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 76 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.08
Nodes (11): Bool, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer (+3 more)

### Community 77 - "ProgramFrameRingBuffer"
Cohesion: 0.22
Nodes (8): FrameDescriptor, size_t, ProgramFrameRingBuffer, count_, latest, push, slots_, writeIndex_

### Community 78 - "Testing"
Cohesion: 0.08
Nodes (8): EasyStreamDiscovery, EasyStreamTests, OSLog, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "CameraPreviewView"
Cohesion: 0.29
Nodes (6): AVCaptureVideoPreviewLayer, CameraPreviewView, PreviewContainerView, AVCaptureSession, Context, UIViewRepresentable

### Community 80 - "CachedWidgetLogoView"
Cohesion: 0.14
Nodes (18): AnyView, NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox (+10 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.12
Nodes (20): MTKView, MTKViewDelegate, MTLCommandQueue, MTLLibrary, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer (+12 more)

### Community 82 - "RemoteCameraSettings"
Cohesion: 0.14
Nodes (17): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens, setMuted, setSwitcherAssignment (+9 more)

### Community 83 - "ProgramFeedWidgetLayer"
Cohesion: 0.24
Nodes (14): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void, ProgramFeedView, ProgramFeedWidgetLayer, Binding (+6 more)

### Community 84 - "DirectorSidebarTab"
Cohesion: 0.20
Nodes (10): .sourceSidebar, DirectorSidebarTab, cameras, .id, library, playlists, .systemImage, .title (+2 more)

### Community 85 - "Foundation"
Cohesion: 0.12
Nodes (6): AVFoundation, CoreMedia, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox

### Community 86 - ".makeVideoTextures"
Cohesion: 0.24
Nodes (7): CGImage, BroadcastMetalTextureUploader, CVMetalTextureCache, CVPixelBuffer, MTLDevice, MTLTexture, RTCI420Buffer

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "WebRTCVideoFramePublisher"
Cohesion: 0.26
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 89 - ".requestDraw"
Cohesion: 0.16
Nodes (6): CGSize, BroadcastMetalVideoFrame, LayerFrame, Float, RTCVideoFrame, SIMD2

### Community 90 - "Sendable"
Cohesion: 0.23
Nodes (14): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+6 more)

### Community 91 - "Error"
Cohesion: 0.10
Nodes (20): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, CameraCaptureError, adjustmentFailed, configurationFailed (+12 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 94 - "DiscoveredDevice"
Cohesion: 0.13
Nodes (17): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, DiscoveryEvent (+9 more)

### Community 95 - "CameraTransportProfile"
Cohesion: 0.15
Nodes (11): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+3 more)

### Community 96 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 97 - ".apply"
Cohesion: 0.22
Nodes (5): CALayer, ProgramTransitionRevealMask, CGRect, Double, QuartzCore

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.17
Nodes (14): .body, BroadcastCompactLiveBadge, BroadcastFormField, BroadcastInspectorEmptyState, .body, BroadcastSectionHeader, .body, BroadcastTallyPill (+6 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.20
Nodes (11): CheckedContinuation, NSWindowDelegate, FacebookWebLoginSession, Bool, NSWindow, URL, Void, WKNavigationAction (+3 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 102 - "ProgramCrossfadeLetterboxSizeDelegate"
Cohesion: 0.22
Nodes (9): MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect, CGSize, RTCVideoRenderer, Void (+1 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.16
Nodes (17): CGPoint, BroadcastDraggableWidgetOverlay, .body, CGFloat, CGRect, CGSize, Gesture, WidgetOverlayContentSizing (+9 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 105 - "LayoutNeutralRTCMTLNSVideoView"
Cohesion: 0.23
Nodes (10): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, CGRect, NSCoder (+2 more)

### Community 106 - ".body"
Cohesion: 0.15
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 107 - "SignalingChannel"
Cohesion: 0.20
Nodes (10): Event, connected, disconnected, failed, message, SignalingChannel, AsyncStream, Bool (+2 more)

### Community 108 - "RoundedRectangle"
Cohesion: 0.17
Nodes (12): .buttonShape, .body, .body, .body, .bottomBar, .leadingLabels, RoleCard, .body (+4 more)

### Community 109 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.27
Nodes (8): StreamDestinationPanel, .body, .publisherStatus, Binding, Bool, Int, String, Void

### Community 111 - "VideoEncoderConfiguration"
Cohesion: 0.43
Nodes (4): CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration

### Community 112 - "CaseIterable"
Cohesion: 0.12
Nodes (15): CaseIterable, BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate (+7 more)

### Community 113 - "NSObject"
Cohesion: 0.15
Nodes (11): AppDelegate, NSObject, RTCVideoFrame, BroadcastMetalVideoSink, Slot, incoming, outgoing, program (+3 more)

### Community 114 - "DirectorSourcesPanel"
Cohesion: 0.29
Nodes (8): .body, DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorSourcesPanel, .body, Content, String

### Community 115 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 116 - "IntercomPushToTalkButton"
Cohesion: 0.15
Nodes (19): IntercomPushToTalkButton, .activeCornerRadius, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor, .subtitle (+11 more)

### Community 117 - ".application"
Cohesion: 0.21
Nodes (9): Any, Bool, UIApplication, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+1 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "TeamIntercomPeer"
Cohesion: 0.24
Nodes (7): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer

### Community 122 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 123 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 124 - ".apply"
Cohesion: 0.29
Nodes (4): Double, Float, RemoteCameraCommandExecutor, Bool

### Community 125 - "CameraCaptureService"
Cohesion: 0.14
Nodes (10): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Int32 (+2 more)

### Community 126 - "BroadcastTheme"
Cohesion: 0.21
Nodes (11): .buttonBackground, .body, BroadcastTheme, .templatePicker, .lensPicker, DirectorSourceListRow, .accentBarColor, .rowBackground (+3 more)

### Community 127 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 128 - "RemoteLensOption"
Cohesion: 0.25
Nodes (8): RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide, .activeLens

### Community 129 - "ProgramFrameRingBuffer.cpp"
Cohesion: 0.40
Nodes (5): FrameDescriptor, size_t, ProgramFrameRingBuffer::latest(), ProgramFrameRingBuffer::ProgramFrameRingBuffer(), ProgramFrameRingBuffer::push()

### Community 130 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 131 - "DiscoveredDeviceRow"
Cohesion: 0.22
Nodes (8): .camerasSidebarContent, .sourceSidebarSection, .camerasContent, DiscoveredDeviceRow, .body, SignalStrengthView, .body, Int

### Community 132 - "FacebookPlatformAuth.swift"
Cohesion: 0.12
Nodes (10): App, AppTrackingTransparency, EasyStreamApp, EasyStreamFacebook, EasyStreamFacebookLogin, EasyStreamVideoPipeline, FacebookCore, FacebookLogin (+2 more)

### Community 133 - "LogoAnimationModifier"
Cohesion: 0.26
Nodes (9): .body, LogoAnimationCycle, LogoAnimationModifier, .anim, LogoMotionContainer, .body, Content, Double (+1 more)

### Community 134 - "ProgramFrameNativeStatus"
Cohesion: 0.40
Nodes (4): EasyStreamVideoBusNative, ProgramFrameNativeStatus, .moduleVersion, String

### Community 135 - "ProgramFrameNativeCapabilities"
Cohesion: 0.50
Nodes (3): ProgramFrameNativeCapabilities, .busModuleVersion, String

### Community 136 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 137 - ".signIn"
Cohesion: 0.33
Nodes (5): AccessToken, FacebookPlatformAuth, Bool, String, UIViewController

### Community 138 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 139 - ".extract"
Cohesion: 0.29
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "DirectorProgramOutputStore"
Cohesion: 0.56
Nodes (6): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL

### Community 141 - "BroadcastPlaylistRepository"
Cohesion: 0.21
Nodes (6): .playlistsSidebarContent, .playlistsContent, BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.13
Nodes (10): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+2 more)

### Community 147 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 148 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 149 - "WhiteBalanceModeOption"
Cohesion: 0.25
Nodes (8): WhiteBalanceModeOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 150 - "TransitionCurve"
Cohesion: 0.25
Nodes (6): Double, LinearProgress, TransitionCurve, easeInOutCubic, linear, smoothStep

### Community 151 - ".applyExternalDisplayPreference"
Cohesion: 0.43
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 152 - "BroadcastPanelModifier"
Cohesion: 0.38
Nodes (4): BroadcastPanelModifier, Bool, Content, View

### Community 153 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 154 - ".finish"
Cohesion: 0.29
Nodes (4): Notification, Error, .body, Result

### Community 155 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 156 - ".handleOffer"
Cohesion: 0.36
Nodes (4): RTCPeerConnection, RTCMediaConstraints, RTCPeerConnectionState, RTCSessionDescription

### Community 157 - "FacebookSignInRequest"
Cohesion: 0.38
Nodes (5): FacebookNativeAuthBridge, FacebookSignInRequest, Bool, String, SignInHandler

### Community 158 - "FacebookLivePanel"
Cohesion: 0.39
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 159 - "EncoderCallbackBridge"
Cohesion: 0.43
Nodes (4): EncoderCallbackBridge, Bool, CMSampleBuffer, Void

### Community 163 - "ProgramRenderBackend"
Cohesion: 0.47
Nodes (4): ProgramRenderBackend, legacyDualWebRTC, metalCompositor, ProgramRenderConfiguration

### Community 164 - "DirectorStatusBar"
Cohesion: 0.67
Nodes (4): DirectorStatusBar, .body, Int, String

### Community 167 - "CameraStreamConfiguration.swift"
Cohesion: 0.40
Nodes (4): CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32

### Community 168 - ".init"
Cohesion: 0.50
Nodes (3): CGRect, NSCoder, NSRect

### Community 169 - "FacebookGraphClient.swift"
Cohesion: 0.67
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

### Community 172 - "NWError"
Cohesion: 0.67
Nodes (3): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool

## Knowledge Gaps
- **488 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+483 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `UIKit`, `CameraSourceID`, `ProgramAudioEncoderPipeline`, `TransitionPreferencesStore`, `DirectorSessionView`, `ProgramFrameBusSlot`, `Task`, `VideoRendererSinkCategory`, `DirectorProgramVideoBusView`, `Identifiable`, `DiscoveryService`, `ProgramOutputSyncBridge`, `DirectorStreamReceiver`, `BroadcastStreamPublisher`, `StreamDestination`, `ProgramVideoEncoderPipeline`, `DiscoveredDevice`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `EasyStreamCore` connect `EasyStreamCore` to `UIKit`, `CameraSourceID`, `String`, `BroadcastTheme.swift`, `FacebookPlatformAuth.swift`, `.frame`, `CameraStreamConfiguration.swift`, `ProgramTransitionFrame`, `FacebookGraphClient.swift`, `LiveProgramFeedView`, `AppKit`, `ProgramFrameBusSlot`, `BroadcastWidgetRenderer.swift`, `Testing`, `View`, `Foundation`, `WebRTC`?**
  _High betweenness centrality (0.074) - this node is a cross-community bridge._
- **Why does `Foundation` connect `Foundation` to `UIKit`, `Data`, `ProgramFrameNativeCapabilities`, `DirectorSessionView`, `CameraSwitcherAssignment`, `BroadcastPlaylistRepository`, `AppRole`, `TransitionCurve`, `BonjourServiceType`, `BroadcastTransmissionMenu`, `VideoRendererSinkCategory`, `FacebookSignInRequest`, `DirectorPreviewMonitorStore`, `CameraSourceID`, `String`, `Codable`, `ProgramRenderBackend`, `TransitionPreferencesStore`, `ProgramPreviewVisibilityPolicy`, `FacebookGraphClient.swift`, `AppKit`, `FacebookConfiguration`, `Identifiable`, `BroadcastWidgetConfiguration`, `BroadcastResourceRepository`, `ProgramCrossfadeContainerUIView`, `WebRTC`, `BroadcastResource`, `ProgramTransitionFrame`, `.matches`, `ProgramFrameBusSlot`, `Testing`, `Sendable`, `StreamDestination`, `StreamConnectionState`, `CameraTransportProfile`, `CaseIterable`, `TeamIntercomPeer`, `CameraLensKind`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _488 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `BroadcastGlowButtonStyle` be split into smaller, more focused modules?**
  _Cohesion score 0.08362369337979095 - nodes in this community are weakly interconnected._