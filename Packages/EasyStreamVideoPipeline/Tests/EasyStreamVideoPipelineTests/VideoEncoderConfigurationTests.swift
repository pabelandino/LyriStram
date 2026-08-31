import Testing
import EasyStreamCore

@Test func broadcastConfigurationDefaults() {
    let config = VideoEncoderConfiguration.broadcast1080p30
    #expect(config.width == 1920)
    #expect(config.height == 1080)
    #expect(config.frameRate == 30)
    #expect(config.averageBitrate == 6_000_000)
}
