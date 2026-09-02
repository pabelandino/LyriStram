# Graph Report - EasyStream  (2026-09-01)

## Corpus Check
- 158 files · ~64,944 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2900 nodes · 6936 edges · 151 communities (144 shown, 7 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 579 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9ee4496e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamCore
- Data
- WebRTCVideoView
- BroadcastGlowButtonStyle
- FLVBuilder
- CountdownAnimationModifier
- PlayoutTapAudioDevice
- .apply
- SignalingChannel
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- BroadcastMediaThumbnailLoader
- RemoteWhiteBalanceOption
- DirectorProgramVideoBusView
- DirectorSessionView
- View
- DiscoveryService
- ConnectedCameraSource
- DirectorStreamReceiver
- BroadcastMetalProgramFeedPlatformView
- AppRole
- DirectorSessionViewModel
- DiscoveredDevice
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- BroadcastTransmissionMenu
- .startOffer
- ProgramVideoEncoderPipeline
- BroadcastMediaViewModel
- Void
- CameraSourceID
- ProgramAudioEncoderPipeline
- String
- Equatable
- DeviceIdentity
- BroadcastWidgetStudioPanel
- RTMPPublisher
- LiveProgramFeedView
- FacebookPlatformAuth.swift
- DirectorSessionViewModel.swift
- EasyStreamUITests
- WebRTC
- FacebookConfiguration
- View
- .current
- FacebookGraphClient
- PackageDescription
- RoundedRectangle
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastWidgetPlacement
- DirectorPreviewMonitorStore
- CameraStreamClient
- .decode
- BroadcastResource
- DirectorRemoteControlsView
- FacebookAuthError
- ProgramCrossfadeContainerUIView
- H264VideoEncoder
- WebRTCConfiguration
- CameraSessionView
- CaseIterable
- BroadcastFontPreset
- TeamIntercomService
- .playlistsSidebarContent
- BroadcastWidgetTemplate
- BroadcastMetalOverlayProvider
- BroadcastResourceKind
- ProgramTransitionFrame
- .matches
- .startCaptureEngine
- .recreateSession
- BroadcastMetalProgramFeedContainerNSView
- .setOpacity
- Testing
- LiveProgramAirStore
- .content
- BroadcastMetalCompositor
- RemoteCameraSettings
- ProgramFeedWidgetLayer
- DirectorSourcesPanel
- Foundation
- CameraClientControlsView
- BroadcastMetalSwiftUIOverlayProvider
- AACAudioEncoder
- .layerFrame
- UIKit
- Error
- StreamDestination
- WebRTCVideoFramePublisher
- DiscoveryEvent
- CameraTransportProfile
- StreamConnectionState
- IntercomPushToTalkPulseRing
- BroadcastTheme.swift
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- PreviewMonitorCamera
- WhiteBalanceModeOption
- BroadcastDraggableWidgetOverlay
- BroadcastMetalProgramFeedView
- CameraPreviewView
- BroadcastBarlessWindowConfigurator
- Sendable
- DirectorProgramOutputStore
- ProgramCrossfadeLetterboxSizeDelegate
- StreamDestinationPanel
- UIView
- BroadcastWidgetConfiguration
- NSObject
- TransitionCurve
- Identifiable
- IntercomPushToTalkButton
- .application
- WebRTCProgramFrameSink
- TeamIntercomPeer
- CodingKeys
- CameraPermissionStatus
- DirectorSidebarTab
- PreviewMultiviewGridSpec
- LayoutNeutralRTCMTLNSVideoView
- CameraCaptureService
- Coordinator
- CameraLensKind
- ProgramOutputSyncBridge
- ClippingRTCVideoContainerView
- .applyExternalDisplayPreference
- .tabletSessionContent
- .frame
- BroadcastMetalI420ConversionCache
- VideoEncoderConfiguration
- State
- RTMPStreamError
- BroadcastTheme
- .detachAndClear
- .extract
- FacebookLivePanel
- .init
- EncodedVideoSample
- ProgramCrossfadeContainerNSView
- Event
- LocalNetworkPermissionTrigger
- BroadcastMetalWidgetOverlayContent
- RoleCard
- TransitionPreferencesStore
- CameraCaptureError
- SignalStrengthView

## God Nodes (most connected - your core abstractions)
1. `DirectorSessionViewModel` - 104 edges
2. `BroadcastMediaViewModel` - 88 edges
3. `BroadcastResource` - 82 edges
4. `EasyStreamCore` - 81 edges
5. `CameraSourceID` - 75 edges
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

## Communities (151 total, 7 thin omitted)

### Community 0 - "EasyStreamCore"
Cohesion: 0.10
Nodes (10): AppKit, AVKit, DirectorProgramOutputWindowView, EasyStreamCameraCapture, EasyStreamCore, EasyStreamTransport, EasyStreamUIComponents, ImageIO (+2 more)

### Community 1 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 2 - "WebRTCVideoView"
Cohesion: 0.23
Nodes (6): NSViewRepresentable, Context, RTCVideoTrack, Void, WebRTCVideoView, RTCMTLNSVideoView

### Community 3 - "BroadcastGlowButtonStyle"
Cohesion: 0.19
Nodes (11): ButtonStyle, Configuration, BroadcastGlassBorderedButtonStyle, BroadcastGlowButtonStyle, BroadcastTakeButtonStyle, Bool, LinearGradient, .actionButtons (+3 more)

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "CountdownAnimationModifier"
Cohesion: 0.14
Nodes (17): Animation, .body, ClockWidgetView, .body, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY (+9 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - ".apply"
Cohesion: 0.23
Nodes (8): ProgramCrossfadeHost, ApplySignature, ProgramCrossfadeSession, Bool, Double, Int, ObjectIdentifier, RTCVideoTrack

### Community 8 - "SignalingChannel"
Cohesion: 0.16
Nodes (13): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, Event, connected, disconnected, failed, message (+5 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.11
Nodes (18): .body, .connectionSummary, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool (+10 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.10
Nodes (20): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+12 more)

### Community 12 - "BroadcastMediaThumbnailLoader"
Cohesion: 0.19
Nodes (14): NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox, .logoAspectRatio (+6 more)

### Community 13 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 14 - "DirectorProgramVideoBusView"
Cohesion: 0.16
Nodes (14): DirectorProgramAirGraphicsView, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, DirectorProgramVideoBusView, .body, Bool, Double (+6 more)

### Community 15 - "DirectorSessionView"
Cohesion: 0.05
Nodes (48): DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, DirectorSessionView, .canTake, .compactLayout, .destinationPanel, .directorWorkspaceLayout (+40 more)

### Community 16 - "View"
Cohesion: 0.16
Nodes (8): BroadcastGlassPanelModifier, BroadcastGlassStyles, BroadcastHiddenToolbarModifier, BroadcastStudioChromeModifier, CGFloat, Content, View, View

### Community 17 - "DiscoveryService"
Cohesion: 0.13
Nodes (16): EasyStreamLog, DiscoveryService, .discoveredDevices, AsyncStream, Bool, NWBrowser, NWConnection, NWEndpoint (+8 more)

### Community 18 - "ConnectedCameraSource"
Cohesion: 0.13
Nodes (12): .camerasSidebarContent, .inspectorSection, ConnectedCameraSource, .outgoingProgramVideoTrack, .previewVideoTrack, .programVideoTrack, Double, Float (+4 more)

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.09
Nodes (24): DirectorStreamReceiver, Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated (+16 more)

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.22
Nodes (11): BroadcastMetalProgramFeedPlatformView, Coordinator, CGSize, Context, Coordinator, Double, ProposedViewSize, RTCVideoTrack (+3 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - "DirectorSessionViewModel"
Cohesion: 0.10
Nodes (17): .destinationPanelFacebook, .destinationPanelStream, .destinationSection, DirectorSessionViewModel, .connectedSourceCount, .isFacebookConfigured, .isPublishing, .programDisplayTrack (+9 more)

### Community 23 - "DiscoveredDevice"
Cohesion: 0.11
Nodes (22): .sourceSidebarSection, Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved (+14 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "SignalingMessage"
Cohesion: 0.09
Nodes (19): Encoder, MessageType, answer, control, hello, ice, offer, settingsState (+11 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "BroadcastTransmissionMenu"
Cohesion: 0.07
Nodes (30): .settings, .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayOption, ProgramOutputPreferencesStore (+22 more)

### Community 28 - ".startOffer"
Cohesion: 0.21
Nodes (6): RTCPeerConnection, Int32, RTCIceCandidate, RTCMediaConstraints, RTCSessionDescription, String

### Community 29 - "ProgramVideoEncoderPipeline"
Cohesion: 0.20
Nodes (9): ProgramVideoEncoderPipeline, AsyncStream, Bool, CMTime, CVPixelBuffer, Never, RTCVideoTrack, Task (+1 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.08
Nodes (22): .body, .inspectorPanel, .librarySidebarContent, .libraryContent, BroadcastMediaViewModel, .allResources, .committedLiveAirWidgetLayers, .directorLiveAirWidgetLayers (+14 more)

### Community 31 - "Void"
Cohesion: 0.15
Nodes (15): .body, PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, .body, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel (+7 more)

### Community 32 - "CameraSourceID"
Cohesion: 0.13
Nodes (18): TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID, .id, UUID, Set, SwitcherEngine (+10 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "String"
Cohesion: 0.09
Nodes (41): BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title, video, widget (+33 more)

### Community 35 - "Equatable"
Cohesion: 0.15
Nodes (21): Codable, Equatable, PreviewMonitorAppearance, PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3 (+13 more)

### Community 36 - "DeviceIdentity"
Cohesion: 0.23
Nodes (9): DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac, unknown (+1 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (41): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .currentColor, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton (+33 more)

### Community 38 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.30
Nodes (14): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, StableProgramVideoView, StableWidgetOverlayView, .body, Bool (+6 more)

### Community 40 - "FacebookPlatformAuth.swift"
Cohesion: 0.13
Nodes (10): App, AppTrackingTransparency, EasyStreamApp, .body, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin (+2 more)

### Community 41 - "DirectorSessionViewModel.swift"
Cohesion: 0.14
Nodes (7): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamSwitcher, EasyStreamVideoPipeline, Observation, OSLog

### Community 42 - "EasyStreamUITests"
Cohesion: 0.15
Nodes (6): EasyStreamUITests, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, Bool, XCTest, XCTestCase

### Community 43 - "WebRTC"
Cohesion: 0.13
Nodes (5): CoreGraphics, CoreVideo, Metal, MetalKit, WebRTC

### Community 44 - "FacebookConfiguration"
Cohesion: 0.15
Nodes (12): FacebookConfiguration, .appID, .basicOAuthScopeList, .callbackURLScheme, .clientToken, .isConfigured, .oauthScopeList, .oauthScopes (+4 more)

### Community 45 - "View"
Cohesion: 0.14
Nodes (24): AnimatedLogoWidgetView, .body, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, BroadcastWidgetOverlayView, .body (+16 more)

### Community 46 - ".current"
Cohesion: 0.30
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "FacebookGraphClient"
Cohesion: 0.24
Nodes (11): Decodable, FacebookGraphClient, GraphAPIErrorResponse, GraphError, Data, String, URL, T (+3 more)

### Community 49 - "RoundedRectangle"
Cohesion: 0.15
Nodes (14): BroadcastGlassProminentButtonStyle, Content, View, .body, Color, PreviewMonitorCellView, .body, .borderColor (+6 more)

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
Cohesion: 0.15
Nodes (19): AVPlayer, .body, .body, BroadcastWidgetPlacement, BroadcastAsyncImageResourceView, .body, BroadcastResourceDisplayView, .body (+11 more)

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.13
Nodes (13): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+5 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.11
Nodes (16): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, AsyncStream (+8 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResource"
Cohesion: 0.14
Nodes (17): .airFullScreenGraphicResource, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, BroadcastResource, .listLabel, Date (+9 more)

### Community 59 - "DirectorRemoteControlsView"
Cohesion: 0.07
Nodes (43): .takeSection, RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide (+35 more)

### Community 60 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

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
Cohesion: 0.18
Nodes (12): CameraSessionView, .cameraPermissionView, .exposureBinding, .lensLabel, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, Binding (+4 more)

### Community 65 - "CaseIterable"
Cohesion: 0.12
Nodes (15): CaseIterable, BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate (+7 more)

### Community 66 - "BroadcastFontPreset"
Cohesion: 0.15
Nodes (16): Font, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded (+8 more)

### Community 67 - "TeamIntercomService"
Cohesion: 0.17
Nodes (13): Never, NWBrowser, NWConnection, NWListener, NWParameters, NWTXTRecord, ObjectIdentifier, Set (+5 more)

### Community 69 - "BroadcastWidgetTemplate"
Cohesion: 0.14
Nodes (15): BroadcastWidgetTemplate, animatedLogo, clock, countdown, logo, lowerThird, lowerThirdPro, .mentoTemplates (+7 more)

### Community 70 - "BroadcastMetalOverlayProvider"
Cohesion: 0.20
Nodes (9): BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture (+1 more)

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.12
Nodes (17): BroadcastMacFilePicker, Void, BroadcastResourceKind, image, .systemImage, .title, video, widget (+9 more)

### Community 72 - "ProgramTransitionFrame"
Cohesion: 0.13
Nodes (22): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, Double, LinearProgress, WipeTransitionEffect (+14 more)

### Community 73 - ".matches"
Cohesion: 0.31
Nodes (6): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String

### Community 74 - ".startCaptureEngine"
Cohesion: 0.19
Nodes (8): AVAudioEngine, AVAudioPCMBuffer, AVAudioPlayerNode, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool, Data

### Community 75 - ".recreateSession"
Cohesion: 0.21
Nodes (10): OSStatus, CMTime, CVPixelBuffer, Int32, VideoEncoderError, configurationFailed, encodeFailed, sampleExtractionFailed (+2 more)

### Community 76 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.08
Nodes (14): Bool, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer (+6 more)

### Community 77 - ".setOpacity"
Cohesion: 0.31
Nodes (5): AnyObject, ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 78 - "Testing"
Cohesion: 0.11
Nodes (6): EasyStreamTests, deviceIdentityPersistsID(), StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing(), Testing

### Community 79 - "LiveProgramAirStore"
Cohesion: 0.33
Nodes (5): LiveProgramAirStore, URL, UUID, Void, UInt64

### Community 80 - ".content"
Cohesion: 0.13
Nodes (17): AnyView, NSColor, .placeholderLogo, .opacity, .content, .body, WidgetCornerHandle, .body (+9 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.11
Nodes (20): MTKView, MTKViewDelegate, MTLCommandQueue, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer, .outgoingRenderer (+12 more)

### Community 82 - "RemoteCameraSettings"
Cohesion: 0.14
Nodes (17): CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens, setMuted, setSwitcherAssignment (+9 more)

### Community 83 - "ProgramFeedWidgetLayer"
Cohesion: 0.40
Nodes (9): ProgramFeedView, ProgramFeedWidgetLayer, Binding, Bool, Double, RTCVideoTrack, String, URL (+1 more)

### Community 84 - "DirectorSourcesPanel"
Cohesion: 0.33
Nodes (7): DirectorInspectorPanel, .body, DirectorInspectorSection, DirectorSourcesPanel, .body, Content, String

### Community 85 - "Foundation"
Cohesion: 0.12
Nodes (7): AVFoundation, CoreMedia, Foundation, Network, EasyStreamNetworkMessages, VideoToolbox, WebKit

### Community 86 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 89 - ".layerFrame"
Cohesion: 0.16
Nodes (12): CGImage, BroadcastMetalTextureUploader, BroadcastMetalVideoFrame, LayerFrame, CVMetalTextureCache, CVPixelBuffer, Float, MTLDevice (+4 more)

### Community 90 - "UIKit"
Cohesion: 0.15
Nodes (6): CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32, PlatformSettings, UIKit

### Community 91 - "Error"
Cohesion: 0.13
Nodes (15): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, BroadcastResourceRepositoryError, invalidWidgetAsset, FacebookPlatformAuthError (+7 more)

### Community 92 - "StreamDestination"
Cohesion: 0.13
Nodes (16): .streamDestination, ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp (+8 more)

### Community 93 - "WebRTCVideoFramePublisher"
Cohesion: 0.27
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 94 - "DiscoveryEvent"
Cohesion: 0.29
Nodes (7): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired

### Community 95 - "CameraTransportProfile"
Cohesion: 0.17
Nodes (11): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+3 more)

### Community 96 - "StreamConnectionState"
Cohesion: 0.24
Nodes (10): RemoteStreamSession, StreamConnectionState, connected, connecting, disconnected, failed, idle, signaling (+2 more)

### Community 97 - "IntercomPushToTalkPulseRing"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.15
Nodes (16): .body, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body, BroadcastPanelModifier, BroadcastSectionHeader, .body (+8 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.07
Nodes (27): AccessToken, CheckedContinuation, Notification, NSWindowDelegate, FacebookAuthService, FacebookTokenParser, FacebookWebLoginSession, Bool (+19 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "PreviewMonitorCamera"
Cohesion: 0.36
Nodes (8): PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CGSize, Int, RTCVideoTrack

### Community 102 - "WhiteBalanceModeOption"
Cohesion: 0.15
Nodes (12): Double, Float, WhiteBalanceModeOption, auto, cool, .displayName, .id, locked (+4 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.16
Nodes (17): CGPoint, BroadcastDraggableWidgetOverlay, .body, CGFloat, CGRect, CGSize, Gesture, WidgetOverlayContentSizing (+9 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 105 - "CameraPreviewView"
Cohesion: 0.29
Nodes (6): AVCaptureVideoPreviewLayer, .phoneSessionContent, CameraPreviewView, PreviewContainerView, AVCaptureSession, UIViewRepresentable

### Community 106 - "BroadcastBarlessWindowConfigurator"
Cohesion: 0.43
Nodes (3): BroadcastBarlessWindowConfigurator, Context, NSWindow

### Community 107 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 108 - "DirectorProgramOutputStore"
Cohesion: 0.56
Nodes (6): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL

### Community 109 - "ProgramCrossfadeLetterboxSizeDelegate"
Cohesion: 0.22
Nodes (9): MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect, CGSize, RTCVideoRenderer, Void (+1 more)

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.27
Nodes (8): StreamDestinationPanel, .body, .publisherStatus, Binding, Bool, Int, String, Void

### Community 111 - "UIView"
Cohesion: 0.15
Nodes (8): CALayer, ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView, QuartzCore

### Community 112 - "BroadcastWidgetConfiguration"
Cohesion: 0.10
Nodes (20): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+12 more)

### Community 113 - "NSObject"
Cohesion: 0.14
Nodes (11): AppDelegate, NSObject, RTCVideoFrame, BroadcastMetalVideoSink, Slot, incoming, outgoing, program (+3 more)

### Community 114 - "TransitionCurve"
Cohesion: 0.25
Nodes (6): Double, LinearProgress, TransitionCurve, easeInOutCubic, linear, smoothStep

### Community 115 - "Identifiable"
Cohesion: 0.09
Nodes (22): CodingKey, Identifiable, LocalizedError, FacebookLiveService, String, CodingKeys, accessToken, id (+14 more)

### Community 116 - "IntercomPushToTalkButton"
Cohesion: 0.15
Nodes (18): IntercomPushToTalkButton, .activeCornerRadius, .buttonShape, .iconName, .idleCornerRadius, .isLive, .micIcon, .ringColor (+10 more)

### Community 117 - ".application"
Cohesion: 0.21
Nodes (9): Any, Bool, UIApplication, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+1 more)

### Community 118 - "WebRTCProgramFrameSink"
Cohesion: 0.22
Nodes (8): CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void, WebRTCProgramFrameSink, RTCVideoRenderer

### Community 119 - "TeamIntercomPeer"
Cohesion: 0.24
Nodes (8): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer, .activeTargetName

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 122 - "DirectorSidebarTab"
Cohesion: 0.12
Nodes (16): .sourceSidebar, DirectorSourceSidebarView, .body, BroadcastPlaylistRepository, BroadcastPlaylistRepositoryProtocol, FileManager, URL, DirectorSidebarTab (+8 more)

### Community 123 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 124 - "LayoutNeutralRTCMTLNSVideoView"
Cohesion: 0.27
Nodes (7): ClippingRTCVideoContainer, .fittingSize, .intrinsicContentSize, LayoutNeutralRTCMTLNSVideoView, .fittingSize, .intrinsicContentSize, NSSize

### Community 125 - "CameraCaptureService"
Cohesion: 0.14
Nodes (10): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Int32 (+2 more)

### Community 126 - "Coordinator"
Cohesion: 0.22
Nodes (5): DispatchWorkItem, Coordinator, Coordinator, NSObjectProtocol, RTCVideoRenderer

### Community 127 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 128 - "ProgramOutputSyncBridge"
Cohesion: 0.50
Nodes (4): ProgramOutputSyncBridge, .body, .stableVideoToken, String

### Community 129 - "ClippingRTCVideoContainerView"
Cohesion: 0.33
Nodes (8): boundedSize(), ClippingRTCVideoContainerView, .intrinsicContentSize, LayoutNeutralRTCMTLVideoView, .intrinsicContentSize, CGSize, ProposedViewSize, RTCMTLVideoView

### Community 130 - ".applyExternalDisplayPreference"
Cohesion: 0.43
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 134 - "VideoEncoderConfiguration"
Cohesion: 0.39
Nodes (4): CameraTransportDefaults, Int, Int32, VideoEncoderConfiguration

### Community 135 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 136 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 137 - "BroadcastTheme"
Cohesion: 0.16
Nodes (14): .buttonBackground, .body, .body, BroadcastCompactLiveBadge, .body, BroadcastTheme, .templatePicker, .lensPicker (+6 more)

### Community 138 - ".detachAndClear"
Cohesion: 0.61
Nodes (3): ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack

### Community 139 - ".extract"
Cohesion: 0.28
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "FacebookLivePanel"
Cohesion: 0.39
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 141 - ".init"
Cohesion: 0.50
Nodes (3): CGRect, NSCoder, NSRect

### Community 142 - "EncodedVideoSample"
Cohesion: 0.60
Nodes (5): EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.10
Nodes (13): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+5 more)

### Community 144 - "Event"
Cohesion: 0.33
Nodes (6): Event, failed, sample, started, stopped, String

### Community 146 - "BroadcastMetalWidgetOverlayContent"
Cohesion: 0.52
Nodes (5): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void

### Community 147 - "RoleCard"
Cohesion: 0.40
Nodes (5): RoleCard, .body, .roleCards, Bool, Void

### Community 150 - "CameraCaptureError"
Cohesion: 0.40
Nodes (5): CameraCaptureError, adjustmentFailed, configurationFailed, deviceUnavailable, permissionDenied

### Community 151 - "SignalStrengthView"
Cohesion: 0.50
Nodes (4): .body, SignalStrengthView, .body, Int

## Knowledge Gaps
- **464 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+459 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `ProgramOutputSyncBridge`, `CameraSourceID`, `ProgramAudioEncoderPipeline`, `BroadcastStreamPublisher`, `DirectorSessionViewModel.swift`, `DirectorProgramVideoBusView`, `DirectorSessionView`, `DiscoveryService`, `ConnectedCameraSource`, `Identifiable`, `TransitionPreferencesStore`, `DirectorStreamReceiver`, `DiscoveredDevice`, `DirectorSidebarTab`, `StreamDestination`, `ProgramVideoEncoderPipeline`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Why does `BroadcastMetalCompositor` connect `BroadcastMetalCompositor` to `BroadcastMetalOverlayProvider`, `WebRTC`, `BroadcastMetalProgramFeedContainerNSView`, `Sendable`, `NSObject`, `.layerFrame`?**
  _High betweenness centrality (0.064) - this node is a cross-community bridge._
- **Why does `CameraSourceID` connect `CameraSourceID` to `Equatable`, `PreviewMonitorCamera`, `CameraSessionViewModel`, `Sendable`, `DirectorSessionView`, `RoundedRectangle`, `ConnectedCameraSource`, `RemoteCameraSettings`, `Identifiable`, `Foundation`, `DirectorSessionViewModel`, `DirectorPreviewMonitorStore`, `BonjourServiceType`, `DirectorStreamReceiver`, `IntercomPushToTalkButton`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `BroadcastResource` (e.g. with `.airFullScreenGraphicResource` and `.applyLogoData()`) actually correct?**
  _`BroadcastResource` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _464 weakly-connected nodes found - possible documentation gaps or missing edges._