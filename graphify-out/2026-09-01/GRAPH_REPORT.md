# Graph Report - EasyStream  (2026-09-01)

## Corpus Check
- 158 files · ~64,781 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2885 nodes · 6908 edges · 153 communities (149 shown, 4 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 579 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9ee4496e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamCore
- Data
- Coordinator
- .body
- FLVBuilder
- CountdownAnimationModifier
- PlayoutTapAudioDevice
- .apply
- SignalingChannel
- CameraSessionViewModel
- TransitionUniforms
- CameraSwitcherAssignment
- CachedWidgetLogoView
- RemoteWhiteBalanceOption
- DirectorProgramVideoBusView
- DirectorSessionView
- BroadcastGlowButtonStyle
- DiscoveryService
- ConnectedCameraSource
- DirectorStreamReceiver
- BroadcastMetalProgramFeedPlatformView
- AppRole
- Task
- DiscoveredDevice
- BonjourServiceType
- SignalingMessage
- BroadcastStreamPublisher
- BroadcastTransmissionMenu
- BroadcastResource
- H264VideoEncoder
- BroadcastMediaViewModel
- Void
- CameraSourceID
- ProgramAudioEncoderPipeline
- BroadcastMediaLibraryPanel.swift
- PreviewMonitorSettings
- String
- BroadcastWidgetStudioPanel
- RTMPPublisher
- LiveProgramFeedView
- FacebookPlatformAuth.swift
- TickerScrollingContent
- EasyStreamUITests
- WebRTC
- FacebookConfiguration
- View
- .current
- FacebookGraphClient
- PackageDescription
- Color
- SwitchTransitionKind
- ProgramCrossfadePlatformView
- DiscoveryViewModel
- ProgramCrossfadePlatformView
- BroadcastAsyncImageResourceView
- DirectorPreviewMonitorStore
- CameraStreamClient
- .decode
- BroadcastResourceRepository
- DirectorRemoteControlsView
- FacebookAuthError
- ProgramCrossfadeContainerUIView
- DirectorMainSwitcherAreaView
- WebRTCConfiguration
- CameraSessionView
- BroadcastLogoAnimation
- BroadcastFontPreset
- .connectIfNeeded
- BroadcastPlaylist
- BroadcastWidgetTemplate
- BroadcastMetalOverlayProvider
- BroadcastResourceKind
- ProgramTransitionFrame
- .matches
- TeamIntercomService
- .accept
- BroadcastMetalProgramFeedContainerNSView
- .applySlot
- Testing
- LiveProgramAirStore
- .content
- BroadcastMetalCompositor
- RemoteCameraSettings
- ProgramFeedWidgetLayer
- DirectorSourceListRow
- Foundation
- CameraClientControlsView
- BroadcastMetalSwiftUIOverlayProvider
- AACAudioEncoder
- .makeVideoTextures
- UIKit
- Error
- StreamDestination
- WebRTCVideoFramePublisher
- DiscoveryEvent
- CameraTransportProfile
- Codable
- IntercomPushToTalkPulseRing
- BroadcastTheme.swift
- FacebookWebLoginSession
- PeerConnectionDelegateBridge
- PreviewMonitorCamera
- WhiteBalanceModeOption
- BroadcastDraggableWidgetOverlay
- BroadcastMetalProgramFeedView
- EasyStreamApp
- NSView
- Sendable
- DirectorProgramOutputStore
- BroadcastMetalProgramFeedContainerUIView
- StreamDestinationPanel
- UIView
- BroadcastWidgetConfiguration
- BroadcastMetalVideoSink
- TransitionCurve
- .prepareLiveBroadcast
- IntercomPushToTalkButton
- .application
- NSObject
- TeamIntercomPeer
- CodingKeys
- CameraPermissionStatus
- DirectorSidebarTab
- PreviewMultiviewGridSpec
- .signIn
- CameraCaptureService
- PreviewMonitorLayoutMode
- CameraLensKind
- DirectorSessionViewModel
- String
- .applyExternalDisplayPreference
- Event
- .frame
- .layerFrame
- .finish
- State
- RTMPStreamError
- RoundedRectangle
- .clearFrame
- .extract
- FacebookLivePanel
- ProgramTransitionEffect.swift
- CoreMedia
- ProgramCrossfadeContainerNSView
- Equatable
- FacebookSignInRequest
- BroadcastMetalWidgetOverlayContent
- CodingKeys
- TransitionPreferencesStore
- FacebookGraphError
- CameraCaptureError
- SignalStrengthView
- GraphAPIErrorResponse

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

## Communities (153 total, 4 thin omitted)

### Community 0 - "EasyStreamCore"
Cohesion: 0.12
Nodes (8): AppKit, AVKit, EasyStreamCore, EasyStreamUIComponents, ImageIO, PlatformSettings, SwiftUI, UniformTypeIdentifiers

### Community 1 - "Data"
Cohesion: 0.21
Nodes (11): AMF0, RTMPChunk, RTMPChunkReader, RTMPChunkWriter, RTMPMessageType, Data, Double, Int (+3 more)

### Community 2 - "Coordinator"
Cohesion: 0.05
Nodes (43): AVCaptureVideoPreviewLayer, DispatchWorkItem, .phoneSessionContent, MainActor, ProgramCrossfadeLetterboxCalculator, ProgramCrossfadeLetterboxSizeDelegate, CGFloat, CGRect (+35 more)

### Community 3 - ".body"
Cohesion: 0.16
Nodes (8): .body, ProgramOutputWindowPlacement, Int, NSWindow, NSScreen, ProgramOutputDisplayDiscovery, .hasExternalDisplay, Int

### Community 4 - "FLVBuilder"
Cohesion: 0.23
Nodes (7): FLVBuilder, CMFormatDescription, CMTime, Data, Int, UInt32, UInt8

### Community 5 - "CountdownAnimationModifier"
Cohesion: 0.21
Nodes (10): Animation, CountdownAnimationModifier, .animation, .flipDegrees, .offsetY, .scale, CountdownWidgetView, .body (+2 more)

### Community 6 - "PlayoutTapAudioDevice"
Cohesion: 0.08
Nodes (25): AudioBufferList, AVAudioSourceNode, PlayoutTapAudioDevice, .deviceInputSampleRate, .deviceOutputSampleRate, .inputIOBufferDuration, .inputLatency, .inputNumberOfChannels (+17 more)

### Community 7 - ".apply"
Cohesion: 0.27
Nodes (8): ProgramCrossfadeHost, ApplySignature, ProgramCrossfadeSession, Bool, Double, Int, ObjectIdentifier, RTCVideoTrack

### Community 8 - "SignalingChannel"
Cohesion: 0.13
Nodes (15): NWError, .isEasyStreamLocalNetworkPermissionIssue, Bool, Event, connected, disconnected, failed, message (+7 more)

### Community 9 - "CameraSessionViewModel"
Cohesion: 0.12
Nodes (17): .body, .connectionSummary, CameraSessionViewModel, .availableDirectors, .canReconnect, .isMuted, AVCaptureSession, Bool (+9 more)

### Community 10 - "TransitionUniforms"
Cohesion: 0.10
Nodes (37): constant, float2, float3, float4, fragment, aspectFitUV(), broadcastCompositorFragment(), broadcastCompositorVertex() (+29 more)

### Community 11 - "CameraSwitcherAssignment"
Cohesion: 0.10
Nodes (20): .previewHeader, CameraSwitcherAssignment, .displayName, idle, .isActive, preview, previewAndProgram, program (+12 more)

### Community 12 - "CachedWidgetLogoView"
Cohesion: 0.15
Nodes (17): AnyView, NSImage, .body, BroadcastMediaThumbnailLoader, CGFloat, Image, URL, ThumbnailBox (+9 more)

### Community 13 - "RemoteWhiteBalanceOption"
Cohesion: 0.25
Nodes (8): RemoteWhiteBalanceOption, auto, cool, .displayName, .id, locked, neutral, warm

### Community 14 - "DirectorProgramVideoBusView"
Cohesion: 0.15
Nodes (15): DirectorProgramAirGraphicsView, .body, DirectorProgramLiveMonitorView, .body, .directorCommittedAirLayers, DirectorProgramVideoBusView, .body, Bool (+7 more)

### Community 15 - "DirectorSessionView"
Cohesion: 0.07
Nodes (29): DirectorSessionView, .camerasSidebarContent, .canTake, .compactLayout, .destinationPanel, .keyboardShortcuts, .previewGrid, .previewGridSection (+21 more)

### Community 16 - "BroadcastGlowButtonStyle"
Cohesion: 0.09
Nodes (21): ButtonStyle, Configuration, .cameraPermissionView, BroadcastGlassBorderedButtonStyle, BroadcastGlassPanelModifier, BroadcastGlassProminentButtonStyle, BroadcastGlassStyles, BroadcastGlowButtonStyle (+13 more)

### Community 17 - "DiscoveryService"
Cohesion: 0.11
Nodes (18): EasyStreamLog, DiscoveryService, .discoveredDevices, AsyncStream, Bool, NWBrowser, NWConnection, NWEndpoint (+10 more)

### Community 18 - "ConnectedCameraSource"
Cohesion: 0.16
Nodes (5): .inspectorSection, ConnectedCameraSource, RTCAudioTrack, RTCVideoTrack, String

### Community 19 - "DirectorStreamReceiver"
Cohesion: 0.14
Nodes (14): DirectorStreamReceiver, RTCPeerConnection, SessionContext, AsyncStream, Int32, NWConnection, RTCIceCandidate, RTCMediaConstraints (+6 more)

### Community 20 - "BroadcastMetalProgramFeedPlatformView"
Cohesion: 0.27
Nodes (9): BroadcastMetalProgramFeedPlatformView, Coordinator, Context, Coordinator, Double, RTCVideoTrack, URL, UUID (+1 more)

### Community 21 - "AppRole"
Cohesion: 0.09
Nodes (23): AppCoordinator, .selectedRole, RootView, .body, RoleSelectionScreen, .body, AppRole, .advertisedServiceType (+15 more)

### Community 22 - "Task"
Cohesion: 0.12
Nodes (9): .destinationPanelFacebook, .destinationPanelStream, .destinationSection, .streamDestination, Task, AudioEncoderStats, Bool, VideoEncoderStats (+1 more)

### Community 23 - "DiscoveredDevice"
Cohesion: 0.12
Nodes (20): Hasher, DiscoveredDevice, .isProtocolCompatible, DiscoveryConnectionState, discovered, removed, resolved, Bool (+12 more)

### Community 24 - "BonjourServiceType"
Cohesion: 0.13
Nodes (14): AppRoute, roleSelection, session, Hashable, BonjourServiceType, camera, director, intercom (+6 more)

### Community 25 - "SignalingMessage"
Cohesion: 0.08
Nodes (27): Encoder, MessageType, answer, control, hello, ice, offer, settingsState (+19 more)

### Community 26 - "BroadcastStreamPublisher"
Cohesion: 0.12
Nodes (16): StreamPublisherState, connecting, failed, idle, publishing, stopped, StreamPublisherStats, Int (+8 more)

### Community 27 - "BroadcastTransmissionMenu"
Cohesion: 0.11
Nodes (22): .settings, ProgramOutputDisplayOption, ProgramOutputPreferencesStore, ProgramOutputSettings, Bool, Int, String, BroadcastTransmissionMenu (+14 more)

### Community 28 - "BroadcastResource"
Cohesion: 0.14
Nodes (13): .airFullScreenGraphicResource, .committedLiveAirWidgetLayers, .draftWidgetResource, .fullScreenGraphicResource, .playlistQueueLabel, .previewFullScreenGraphicResource, .previewOverlayWidgetLayers, ProgramWidgetLayer (+5 more)

### Community 29 - "H264VideoEncoder"
Cohesion: 0.05
Nodes (41): OSStatus, CameraTransportDefaults, EncodedVideoSample, Bool, CMFormatDescription, CMTime, Data, Int (+33 more)

### Community 30 - "BroadcastMediaViewModel"
Cohesion: 0.10
Nodes (17): .body, .inspectorPanel, .librarySidebarContent, .libraryContent, BroadcastMediaViewModel, .allResources, .directorLiveAirWidgetLayers, .isEditingExistingWidget (+9 more)

### Community 31 - "Void"
Cohesion: 0.18
Nodes (13): PreviewMonitorHeaderBar, .body, PreviewMonitorInspectorSummary, .body, PreviewMonitorSettingsForm, .body, PreviewMonitorSettingsPanel, .body (+5 more)

### Community 32 - "CameraSourceID"
Cohesion: 0.13
Nodes (18): TimeInterval, SwitcherSnapshot, SwitchTransition, CameraSourceID, .id, UUID, Set, SwitcherEngine (+10 more)

### Community 33 - "ProgramAudioEncoderPipeline"
Cohesion: 0.13
Nodes (15): Event, failed, sample, started, stopped, ProgramAudioEncoderPipeline, AsyncStream, Bool (+7 more)

### Community 34 - "BroadcastMediaLibraryPanel.swift"
Cohesion: 0.14
Nodes (24): BroadcastMediaLibraryPanel, .body, .filteredPlaylists, BroadcastMediaPhotoImporter, BroadcastPlaylistEditorSheet, BroadcastPlaylistPanel, .body, BroadcastPlaylistRow (+16 more)

### Community 35 - "PreviewMonitorSettings"
Cohesion: 0.44
Nodes (6): PreviewMonitorAppearance, PreviewMonitorOverlayOptions, PreviewMonitorRGBColor, PreviewMonitorSettings, Bool, Double

### Community 36 - "String"
Cohesion: 0.15
Nodes (16): CaseIterable, DeviceIdentity, .suggestedRole, DevicePlatform, .displayName, iPad, iPhone, mac (+8 more)

### Community 37 - "BroadcastWidgetStudioPanel"
Cohesion: 0.07
Nodes (40): NSColorPanel, NSPanel, BroadcastHexColorWell, .body, .iosColorPicker, MacColorPanelController, NativeMacColorPanelButton, .body (+32 more)

### Community 38 - "RTMPPublisher"
Cohesion: 0.20
Nodes (8): RTMPPublisher, Bool, Data, Double, Int, String, UInt32, UInt8

### Community 39 - "LiveProgramFeedView"
Cohesion: 0.30
Nodes (14): BroadcastCleanProgramFeedView, .body, LiveProgramFeedView, .body, StableProgramVideoView, StableWidgetOverlayView, .body, Bool (+6 more)

### Community 40 - "FacebookPlatformAuth.swift"
Cohesion: 0.13
Nodes (8): AppTrackingTransparency, EasyStreamFacebook, EasyStreamFacebookLogin, FacebookCore, FacebookLogin, StreamDestinationFacebookParsing, String, facebookSecureStreamURLParsing()

### Community 41 - "TickerScrollingContent"
Cohesion: 0.24
Nodes (10): ClockWidgetView, .body, Date, String, TickerScrollingContent, .measuredSegmentWidth, .tickerLabel, TickerWidgetView (+2 more)

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
Nodes (25): AnimatedLogoWidgetView, .body, BroadcastWidgetCanvas, .body, .contentSizing, BroadcastWidgetContentView, .body, BroadcastWidgetOverlayView (+17 more)

### Community 46 - ".current"
Cohesion: 0.30
Nodes (5): AVCaptureOutput, AVCaptureVideoOrientation, CMSampleBuffer, AVCaptureConnection, CaptureVideoOrientation

### Community 47 - "FacebookGraphClient"
Cohesion: 0.31
Nodes (8): FacebookGraphClient, Data, String, URL, T, URLQueryItem, URLRequest, URLSession

### Community 49 - "Color"
Cohesion: 0.36
Nodes (6): Color, PreviewMonitorCellView, .borderColor, .overlayLayer, .safeAreaGuides, .tallyBadges

### Community 50 - "SwitchTransitionKind"
Cohesion: 0.16
Nodes (15): SwitchTransitionKind, cut, .displayName, dissolve, fade, .id, slide, wipe (+7 more)

### Community 51 - "ProgramCrossfadePlatformView"
Cohesion: 0.23
Nodes (9): Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context, Coordinator, Double, ProposedViewSize (+1 more)

### Community 52 - "DiscoveryViewModel"
Cohesion: 0.33
Nodes (5): DiscoveryViewModel, Never, String, Task, Void

### Community 53 - "ProgramCrossfadePlatformView"
Cohesion: 0.15
Nodes (12): ProgramCrossfadeLayout, CGSize, ProposedViewSize, Coordinator, ProgramCrossfadePlatformView, Bool, CGSize, Context (+4 more)

### Community 54 - "BroadcastAsyncImageResourceView"
Cohesion: 0.32
Nodes (8): AVPlayer, BroadcastAsyncImageResourceView, .body, .body, BroadcastVideoResourceView, .body, Image, URL

### Community 55 - "DirectorPreviewMonitorStore"
Cohesion: 0.13
Nodes (13): DirectorPreviewMonitorStore, .previewDisplayName, .programDisplayName, .settings, Int, Never, String, Task (+5 more)

### Community 56 - "CameraStreamClient"
Cohesion: 0.08
Nodes (23): CameraStreamClient, .isAudioMuted, .localVideoTrack, Event, connectionState, failed, localVideoTrackReady, RTCPeerConnection (+15 more)

### Community 57 - ".decode"
Cohesion: 0.27
Nodes (7): BonjourEndpointParser, BonjourTXTCodec, Bool, NWEndpoint, NWTXTRecord, String, UUID

### Community 58 - "BroadcastResourceRepository"
Cohesion: 0.21
Nodes (8): BroadcastResourceIndexEntry, BroadcastResourceRepository, BroadcastResourceRepositoryProtocol, Data, FileManager, String, URL, UUID

### Community 59 - "DirectorRemoteControlsView"
Cohesion: 0.07
Nodes (43): .takeSection, RemoteLensOption, .displayName, front, .id, telephoto, ultraWide, wide (+35 more)

### Community 60 - "FacebookAuthError"
Cohesion: 0.15
Nodes (13): FacebookAuthError, appIDNotConfigured, cancelled, clientTokenNotConfigured, denied, .errorDescription, invalidCallback, limitedLoginRequiresTracking (+5 more)

### Community 61 - "ProgramCrossfadeContainerUIView"
Cohesion: 0.14
Nodes (10): ProgramCrossfadeContainerUIView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, CGRect, CGSize (+2 more)

### Community 62 - "DirectorMainSwitcherAreaView"
Cohesion: 0.14
Nodes (15): DirectorProgramPreviewOverlayView, DirectorProgramStudioHintsOverlay, .body, .mainSwitcherArea, .programOutput, .takeBar, .transitionSection, DirectorMainSwitcherAreaView (+7 more)

### Community 63 - "WebRTCConfiguration"
Cohesion: 0.33
Nodes (3): RTCMediaConstraints, WebRTCConfiguration, RTCPeerConnectionFactory

### Community 64 - "CameraSessionView"
Cohesion: 0.14
Nodes (13): CameraSessionView, .exposureBinding, .lensLabel, .streamBadgeLabel, .whiteBalanceBinding, .zoomBinding, Binding, Double (+5 more)

### Community 65 - "BroadcastLogoAnimation"
Cohesion: 0.20
Nodes (9): BroadcastLogoAnimation, .displayName, flip, float, none, pulse, rotate, sphere3D (+1 more)

### Community 66 - "BroadcastFontPreset"
Cohesion: 0.17
Nodes (14): Font, NSFont, BroadcastFontPreset, boldDisplay, condensed, .displayName, monospaced, rounded (+6 more)

### Community 67 - ".connectIfNeeded"
Cohesion: 0.21
Nodes (6): NWBrowser, NWListener, NWParameters, NWTXTRecord, Set, String

### Community 68 - "BroadcastPlaylist"
Cohesion: 0.11
Nodes (17): .playlistsSidebarContent, .playlistsContent, BroadcastPlaylist, BroadcastPlaylistKind, image, mixed, .systemImage, .title (+9 more)

### Community 69 - "BroadcastWidgetTemplate"
Cohesion: 0.14
Nodes (15): BroadcastWidgetTemplate, animatedLogo, clock, countdown, logo, lowerThird, lowerThirdPro, .mentoTemplates (+7 more)

### Community 70 - "BroadcastMetalOverlayProvider"
Cohesion: 0.20
Nodes (9): BroadcastMetalEmptyOverlayProvider, .needsContinuousRefresh, BroadcastMetalOverlayProvider, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture (+1 more)

### Community 71 - "BroadcastResourceKind"
Cohesion: 0.12
Nodes (17): BroadcastMacFilePicker, URL, Void, BroadcastResourceKind, image, .systemImage, .title, video (+9 more)

### Community 72 - "ProgramTransitionFrame"
Cohesion: 0.18
Nodes (12): Double, LinearProgress, ProgramTransitionFrame, .usesVisualTransform, ProgramTransitionLifecycle, ProgramTransitionLifecycleRules, ProgramTransitionSlot, .usesSpatialPresentation (+4 more)

### Community 73 - ".matches"
Cohesion: 0.24
Nodes (7): BroadcastDisplayNameSanitizer, BroadcastMediaSearch, Character, .isHexDigit, Bool, String, Bool

### Community 74 - "TeamIntercomService"
Cohesion: 0.19
Nodes (10): AVAudioEngine, AVAudioPlayerNode, AVAudioFormat, .isValidIntercomFormat, AVAudioConverter, Bool, Never, Task (+2 more)

### Community 75 - ".accept"
Cohesion: 0.22
Nodes (5): AVAudioPCMBuffer, Data, NWConnection, ObjectIdentifier, UUID

### Community 76 - "BroadcastMetalProgramFeedContainerNSView"
Cohesion: 0.18
Nodes (7): Bool, BroadcastMetalProgramFeedContainerNSView, .incomingRenderer, .outgoingRenderer, .programRenderer, Bool, RTCVideoRenderer

### Community 77 - ".applySlot"
Cohesion: 0.31
Nodes (5): AnyObject, ProgramTransitionSlotPresenter, ProgramTransitionSlotView, CGFloat, Double

### Community 78 - "Testing"
Cohesion: 0.12
Nodes (4): EasyStreamSwitcher, EasyStreamTests, deviceIdentityPersistsID(), Testing

### Community 79 - "LiveProgramAirStore"
Cohesion: 0.28
Nodes (5): LiveProgramAirStore, URL, UUID, Void, UInt64

### Community 80 - ".content"
Cohesion: 0.18
Nodes (12): NSColor, .currentColor, .placeholderLogo, .opacity, .content, .body, BroadcastWidgetColors, Binding (+4 more)

### Community 81 - "BroadcastMetalCompositor"
Cohesion: 0.12
Nodes (18): MTKView, MTKViewDelegate, MTLCommandQueue, MTLRenderPipelineState, MTLSamplerState, BroadcastMetalCompositor, .incomingRenderer, .outgoingRenderer (+10 more)

### Community 82 - "RemoteCameraSettings"
Cohesion: 0.12
Nodes (19): Float, Void, CameraSettingsStore, RemoteCameraCommand, applySavedSettings, reconnectStream, setExposureBias, setLens (+11 more)

### Community 83 - "ProgramFeedWidgetLayer"
Cohesion: 0.24
Nodes (13): .body, ProgramFeedView, ProgramFeedWidgetLayer, Binding, Bool, Double, RTCVideoTrack, String (+5 more)

### Community 84 - "DirectorSourceListRow"
Cohesion: 0.18
Nodes (14): DirectorInspectorPanel, .body, DirectorInspectorSection, .body, DirectorSourceListRow, .accentBarColor, .rowBackground, .rowBorder (+6 more)

### Community 85 - "Foundation"
Cohesion: 0.09
Nodes (11): EasyStreamAudioPipeline, EasyStreamDiscovery, EasyStreamStreaming, EasyStreamTransport, EasyStreamVideoPipeline, Foundation, Network, Observation (+3 more)

### Community 86 - "CameraClientControlsView"
Cohesion: 0.23
Nodes (12): ClosedRange, CameraClientControlsView, .body, .exposureControl, .muteControl, .whiteBalancePicker, .zoomControl, Binding (+4 more)

### Community 87 - "BroadcastMetalSwiftUIOverlayProvider"
Cohesion: 0.19
Nodes (12): BroadcastMetalSwiftUIOverlayProvider, .needsContinuousRefresh, .overlayRefreshInterval, Bool, CGSize, MTLDevice, MTLTexture, String (+4 more)

### Community 88 - "AACAudioEncoder"
Cohesion: 0.23
Nodes (7): AACAudioEncoder, AsyncStream, AVAudioConverter, Data, Double, Int64, UInt32

### Community 89 - ".makeVideoTextures"
Cohesion: 0.24
Nodes (8): CGImage, MTLTexture, TextureSet, BroadcastMetalTextureUploader, CVMetalTextureCache, CVPixelBuffer, MTLDevice, MTLTexture

### Community 90 - "UIKit"
Cohesion: 0.14
Nodes (7): AVFoundation, EasyStreamCameraCapture, CameraStreamConfiguration, AVCaptureSession, CGFloat, Int32, UIKit

### Community 91 - "Error"
Cohesion: 0.13
Nodes (15): Error, AudioEncoderError, conversionFailed, converterCreationFailed, invalidInput, BroadcastResourceRepositoryError, invalidWidgetAsset, FacebookPlatformAuthError (+7 more)

### Community 92 - "StreamDestination"
Cohesion: 0.15
Nodes (14): ParsedStreamDestination, StreamDestination, .isConfigured, StreamDestinationError, .errorDescription, invalidURL, missingApp, missingHost (+6 more)

### Community 93 - "WebRTCVideoFramePublisher"
Cohesion: 0.27
Nodes (6): CVPixelBuffer, Int32, Int64, RTCVideoRotation, RTCVideoSource, WebRTCVideoFramePublisher

### Community 94 - "DiscoveryEvent"
Cohesion: 0.29
Nodes (7): DiscoveryEvent, advertisingFailed, browsingFailed, deviceAppeared, deviceRemoved, deviceUpdated, localNetworkPermissionRequired

### Community 95 - "CameraTransportProfile"
Cohesion: 0.17
Nodes (11): CameraTransportProfile, .frameRate, .height, .maxBitrateBps, .minBitrateBps, preview, program, standby (+3 more)

### Community 96 - "Codable"
Cohesion: 0.30
Nodes (9): Codable, Identifiable, FacebookLiveVideo, FacebookPage, FacebookSession, .isSignedIn, FacebookUserProfile, Bool (+1 more)

### Community 97 - "IntercomPushToTalkPulseRing"
Cohesion: 0.29
Nodes (9): IntercomActivationRing, .body, .body, IntercomPushToTalkPulseRing, .body, IntercomPushToTalkPulseRings, .body, CGFloat (+1 more)

### Community 98 - "BroadcastTheme.swift"
Cohesion: 0.11
Nodes (20): .body, BroadcastCompactLiveBadge, .body, BroadcastFormField, .body, BroadcastInspectorEmptyState, .body, BroadcastPanelModifier (+12 more)

### Community 99 - "FacebookWebLoginSession"
Cohesion: 0.20
Nodes (11): CheckedContinuation, NSWindowDelegate, FacebookWebLoginSession, Bool, NSWindow, URL, Void, WKNavigationAction (+3 more)

### Community 100 - "PeerConnectionDelegateBridge"
Cohesion: 0.16
Nodes (13): PeerConnectionDelegateBridge, RTCIceCandidate, RTCMediaStreamTrack, RTCPeerConnection, RTCPeerConnectionState, Void, RTCDataChannel, RTCIceConnectionState (+5 more)

### Community 101 - "PreviewMonitorCamera"
Cohesion: 0.36
Nodes (8): PreviewMonitorCamera, PreviewMonitorMultiviewGrid, .body, .pageCount, Bool, CGSize, Int, RTCVideoTrack

### Community 102 - "WhiteBalanceModeOption"
Cohesion: 0.18
Nodes (11): Double, Float, WhiteBalanceModeOption, auto, cool, .displayName, .id, locked (+3 more)

### Community 103 - "BroadcastDraggableWidgetOverlay"
Cohesion: 0.14
Nodes (19): CGPoint, BroadcastDraggableWidgetOverlay, .body, Binding, CGFloat, CGRect, CGSize, Gesture (+11 more)

### Community 104 - "BroadcastMetalProgramFeedView"
Cohesion: 0.39
Nodes (8): BroadcastMetalProgramFeedView, .body, Bool, Double, RTCVideoTrack, URL, UUID, Void

### Community 105 - "EasyStreamApp"
Cohesion: 0.25
Nodes (6): App, EasyStreamApp, .body, DirectorProgramOutputWindowView, EasyStreamFacebookLoginSetup, Scene

### Community 106 - "NSView"
Cohesion: 0.19
Nodes (7): NSViewRepresentable, BroadcastBarlessWindowConfigurator, Context, NSWindow, NSView, CGFloat, Double

### Community 107 - "Sendable"
Cohesion: 0.27
Nodes (12): AudioEncoderConfiguration, AudioStreamPacketDescription, EncodedAudioSample, ProgramAudioTapRegistry, Storage, CMTime, Data, Double (+4 more)

### Community 108 - "DirectorProgramOutputStore"
Cohesion: 0.56
Nodes (6): DirectorProgramOutputStore, Bool, Double, RTCVideoTrack, String, URL

### Community 109 - "BroadcastMetalProgramFeedContainerUIView"
Cohesion: 0.14
Nodes (9): BroadcastMetalProgramFeedContainerUIView, .incomingRenderer, .outgoingRenderer, .programRenderer, CGRect, CGSize, NSCoder, NSRect (+1 more)

### Community 110 - "StreamDestinationPanel"
Cohesion: 0.31
Nodes (7): StreamDestinationPanel, .publisherStatus, Binding, Bool, Int, String, Void

### Community 111 - "UIView"
Cohesion: 0.15
Nodes (8): CALayer, ProgramTransitionRevealMask, CGRect, Double, CGFloat, Double, UIView, QuartzCore

### Community 112 - "BroadcastWidgetConfiguration"
Cohesion: 0.09
Nodes (26): BroadcastCountdownAnimation, bounce, .displayName, fadeScale, flipClock, slideUp, BroadcastGradientStyle, BroadcastWidgetConfiguration (+18 more)

### Community 113 - "BroadcastMetalVideoSink"
Cohesion: 0.14
Nodes (9): RTCVideoFrame, BroadcastMetalVideoSink, Slot, incoming, outgoing, program, CGSize, RTCVideoFrame (+1 more)

### Community 114 - "TransitionCurve"
Cohesion: 0.25
Nodes (6): Double, LinearProgress, TransitionCurve, easeInOutCubic, linear, smoothStep

### Community 115 - ".prepareLiveBroadcast"
Cohesion: 0.19
Nodes (3): FacebookLiveService, String, FacebookSessionStore

### Community 116 - "IntercomPushToTalkButton"
Cohesion: 0.12
Nodes (22): .controlsSheet, .tabletSessionContent, IntercomPushToTalkButton, .activeCornerRadius, .buttonShape, .iconName, .idleCornerRadius, .isLive (+14 more)

### Community 117 - ".application"
Cohesion: 0.21
Nodes (9): Any, Bool, UIApplication, URL, FacebookSDKBootstrap, Any, Bool, UIApplication (+1 more)

### Community 118 - "NSObject"
Cohesion: 0.18
Nodes (10): AppDelegate, NSObject, CGSize, CMTime, CVPixelBuffer, RTCVideoFrame, Sendable, Void (+2 more)

### Community 119 - "TeamIntercomPeer"
Cohesion: 0.28
Nodes (7): IntercomConstants, Double, String, UInt16, UUID, TeamIntercomPeer, .activeTargetPeer

### Community 120 - "CodingKeys"
Cohesion: 0.17
Nodes (12): CodingKeys, candidate, command, deviceID, displayName, role, sdp, sdpMid (+4 more)

### Community 121 - "CameraPermissionStatus"
Cohesion: 0.33
Nodes (5): CameraPermissionStatus, authorized, denied, notDetermined, restricted

### Community 122 - "DirectorSidebarTab"
Cohesion: 0.20
Nodes (11): .sourceSidebar, DirectorSourceSidebarView, .body, DirectorSidebarTab, cameras, .id, library, .systemImage (+3 more)

### Community 123 - "PreviewMultiviewGridSpec"
Cohesion: 0.54
Nodes (4): .totalPages, PreviewMultiviewGridSpec, PreviewMultiviewLayoutEngine, Int

### Community 124 - ".signIn"
Cohesion: 0.33
Nodes (5): AccessToken, FacebookPlatformAuth, Bool, String, UIViewController

### Community 125 - "CameraCaptureService"
Cohesion: 0.14
Nodes (10): AVCaptureDeviceInput, AVCaptureVideoDataOutputSampleBufferDelegate, CameraCaptureService, AVCaptureDevice, AVCaptureSession, CMTime, CVPixelBuffer, Int32 (+2 more)

### Community 126 - "PreviewMonitorLayoutMode"
Cohesion: 0.20
Nodes (10): PreviewMonitorLayoutMode, auto, .displayName, grid2x2, grid3x3, grid4x4, grid5x5, .id (+2 more)

### Community 127 - "CameraLensKind"
Cohesion: 0.18
Nodes (14): AvailableCameraLens, CameraImagingState, CameraLensKind, .deviceType, .displayName, front, .id, .position (+6 more)

### Community 128 - "DirectorSessionViewModel"
Cohesion: 0.09
Nodes (26): .directorWorkspaceLayout, DirectorProgramOutputCorePanel, .body, .programDisplayName, DirectorSwitcherColumnView, .canTake, .programDisplayName, String (+18 more)

### Community 129 - "String"
Cohesion: 0.31
Nodes (3): FacebookAuthService, FacebookTokenParser, String

### Community 130 - ".applyExternalDisplayPreference"
Cohesion: 0.43
Nodes (3): PreviewMonitorWindowPlacement, Bool, NSWindow

### Community 131 - "Event"
Cohesion: 0.20
Nodes (10): Event, failed, sourceAudioTrack, sourceConnected, sourceConnectionState, sourceDisconnected, sourceSettingsUpdated, sourceVideoTrack (+2 more)

### Community 133 - ".layerFrame"
Cohesion: 0.24
Nodes (8): BroadcastMetalI420ConversionCache, BroadcastMetalVideoFrame, LayerFrame, CVPixelBufferPool, Float, RTCI420Buffer, RTCVideoFrame, SIMD2

### Community 134 - ".finish"
Cohesion: 0.22
Nodes (6): Notification, Error, .body, .body, .body, Result

### Community 135 - "State"
Cohesion: 0.40
Nodes (5): State, failed, ready, starting, stopped

### Community 136 - "RTMPStreamError"
Cohesion: 0.29
Nodes (7): RTMPStreamError, commandFailed, connectionFailed, .errorDescription, handshakeFailed, notConnected, sendFailed

### Community 137 - "RoundedRectangle"
Cohesion: 0.15
Nodes (19): .buttonBackground, BroadcastAsyncThumbnailImage, .body, .body, BroadcastResourceThumbnail, .body, Image, BroadcastTheme (+11 more)

### Community 138 - ".clearFrame"
Cohesion: 0.56
Nodes (3): ProgramCrossfadeRenderer, RTCVideoRenderer, RTCVideoTrack

### Community 139 - ".extract"
Cohesion: 0.28
Nodes (6): I420ToNV12Converter, CVPixelBuffer, CVPixelBufferPool, RTCI420Buffer, RTCVideoFrame, WebRTCVideoFramePixelBuffer

### Community 140 - "FacebookLivePanel"
Cohesion: 0.39
Nodes (7): FacebookLivePanel, .body, .pageSelection, Binding, Bool, String, Void

### Community 141 - "ProgramTransitionEffect.swift"
Cohesion: 0.46
Nodes (7): CutTransitionEffect, DissolveTransitionEffect, FadeTransitionEffect, ProgramTransitionEffect, SlideTransitionEffect, WipeTransitionEffect, ZoomTransitionEffect

### Community 143 - "ProgramCrossfadeContainerNSView"
Cohesion: 0.15
Nodes (10): ProgramCrossfadeContainerNSView, .incomingRenderer, .intrinsicContentSize, .outgoingRenderer, .programRenderer, Bool, NSCoder, NSRect (+2 more)

### Community 144 - "Equatable"
Cohesion: 0.29
Nodes (7): Equatable, SequencePhase, offscreen, onscreen, ProgramTransitionPresentationMode, opacityOnly, spatial

### Community 145 - "FacebookSignInRequest"
Cohesion: 0.38
Nodes (5): FacebookNativeAuthBridge, FacebookSignInRequest, Bool, String, SignInHandler

### Community 146 - "BroadcastMetalWidgetOverlayContent"
Cohesion: 0.52
Nodes (5): BroadcastMetalWidgetOverlayContent, Bool, URL, UUID, Void

### Community 147 - "CodingKeys"
Cohesion: 0.33
Nodes (6): CodingKey, CodingKeys, accessToken, id, name, secureStreamURL

### Community 149 - "FacebookGraphError"
Cohesion: 0.40
Nodes (5): LocalizedError, FacebookGraphError, apiError, .errorDescription, invalidResponse

### Community 150 - "CameraCaptureError"
Cohesion: 0.40
Nodes (5): CameraCaptureError, adjustmentFailed, configurationFailed, deviceUnavailable, permissionDenied

### Community 151 - "SignalStrengthView"
Cohesion: 0.67
Nodes (3): SignalStrengthView, .body, Int

### Community 152 - "GraphAPIErrorResponse"
Cohesion: 1.00
Nodes (3): Decodable, GraphAPIErrorResponse, GraphError

## Knowledge Gaps
- **464 isolated node(s):** `roleSelection`, `session`, `.streamBadgeLabel`, `.lensLabel`, `.directorCommittedAirLayers` (+459 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DirectorSessionViewModel` connect `DirectorSessionViewModel` to `DirectorProgramVideoBusView`, `DirectorSessionView`, `DiscoveryService`, `ConnectedCameraSource`, `DirectorStreamReceiver`, `TransitionPreferencesStore`, `Task`, `DiscoveredDevice`, `BroadcastStreamPublisher`, `H264VideoEncoder`, `CameraSourceID`, `ProgramAudioEncoderPipeline`, `DirectorMainSwitcherAreaView`, `RemoteCameraSettings`, `Foundation`, `StreamDestination`, `Codable`, `.prepareLiveBroadcast`, `DirectorSidebarTab`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `CameraSourceID` connect `CameraSourceID` to `CameraSessionView`, `DirectorSessionViewModel`, `Codable`, `Event`, `PreviewMonitorCamera`, `CameraSessionViewModel`, `Sendable`, `DirectorSessionView`, `Color`, `ConnectedCameraSource`, `RemoteCameraSettings`, `DirectorStreamReceiver`, `Foundation`, `IntercomPushToTalkButton`, `DirectorPreviewMonitorStore`, `BonjourServiceType`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._
- **Why does `BroadcastMetalCompositor` connect `BroadcastMetalCompositor` to `.layerFrame`, `BroadcastMetalOverlayProvider`, `WebRTC`, `BroadcastMetalProgramFeedContainerNSView`, `Sendable`, `BroadcastMetalProgramFeedContainerUIView`, `BroadcastMetalVideoSink`, `NSObject`, `.makeVideoTextures`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `DirectorSessionViewModel` (e.g. with `DirectorSessionView` and `.programDisplayName`) actually correct?**
  _`DirectorSessionViewModel` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 6 inferred relationships involving `BroadcastMediaViewModel` (e.g. with `DirectorSessionView` and `.inspectorPanel`) actually correct?**
  _`BroadcastMediaViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `BroadcastResource` (e.g. with `.airFullScreenGraphicResource` and `.applyLogoData()`) actually correct?**
  _`BroadcastResource` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `roleSelection`, `session`, `.streamBadgeLabel` to the rest of the system?**
  _464 weakly-connected nodes found - possible documentation gaps or missing edges._