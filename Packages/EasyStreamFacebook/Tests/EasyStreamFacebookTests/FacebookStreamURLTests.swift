import Testing
import EasyStreamCore
@testable import EasyStreamFacebook

@Test func facebookSecureStreamURLParsing() throws {
    let secureURL = "rtmps://rtmp-api.facebook.com:443/rtmp/10214937378883406?s_bl=1&s_sw=0"
    let destination = try #require(
        StreamDestinationFacebookParsing.destination(fromSecureStreamURL: secureURL)
    )

    #expect(destination.serverURL == "rtmps://rtmp-api.facebook.com:443/rtmp")
    #expect(destination.streamName == "10214937378883406?s_bl=1&s_sw=0")

    let parsed = try destination.parsed()
    #expect(parsed.host == "rtmp-api.facebook.com")
    #expect(parsed.useTLS)
    #expect(parsed.appName == "rtmp")
    #expect(parsed.streamName == "10214937378883406?s_bl=1&s_sw=0")
}
