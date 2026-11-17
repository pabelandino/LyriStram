import Testing
import LvoqStreamCore

@Test func streamDestinationParsing() throws {
    let destination = StreamDestination(
        serverURL: "rtmps://live.example.com:443/live",
        streamName: "lvoqstream-test"
    )
    let parsed = try destination.parsed()
    #expect(parsed.host == "live.example.com")
    #expect(parsed.port == 443)
    #expect(parsed.useTLS)
    #expect(parsed.appName == "live")
    #expect(parsed.streamName == "lvoqstream-test")
}
