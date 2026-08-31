import Testing
import EasyStreamCore

@Test func audioConfigurationDefaults() {
    let config = AudioEncoderConfiguration.broadcastAAC
    #expect(config.sampleRate == 48_000)
    #expect(config.channelCount == 2)
    #expect(config.bitrate == 128_000)
}
