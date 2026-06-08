import Foundation
@testable import PairShot
import Testing

struct PaywallURLsTests {
    private let base = "https://example.test"

    @Test
    func `privacy URL combines injected base with privacy path over https`() {
        let url = PaywallURLs.url(path: "/privacy", base: base, isEnglish: false)
        #expect(url.isFileURL == false)
        #expect(url.scheme == "https")
        #expect(url.host == "example.test")
        #expect(url.path == "/privacy")
    }

    @Test
    func `terms URL combines injected base with terms path over https`() {
        let url = PaywallURLs.url(path: "/terms", base: base, isEnglish: false)
        #expect(url.isFileURL == false)
        #expect(url.scheme == "https")
        #expect(url.host == "example.test")
        #expect(url.path == "/terms")
    }

    @Test
    func `english locale appends en suffix to path`() {
        let privacy = PaywallURLs.url(path: "/privacy", base: base, isEnglish: true)
        let terms = PaywallURLs.url(path: "/terms", base: base, isEnglish: true)
        #expect(privacy.path == "/privacy/en")
        #expect(terms.path == "/terms/en")
    }

    @Test
    func `privacy and terms URLs are distinct for same base`() {
        let privacy = PaywallURLs.url(path: "/privacy", base: base, isEnglish: false)
        let terms = PaywallURLs.url(path: "/terms", base: base, isEnglish: false)
        #expect(privacy != terms)
    }

    @Test
    func `resolveBase reads WebBaseUrl key from bundle and trims whitespace`() {
        let bundle = StubBundle(info: ["WebBaseUrl": "  https://stub.example  "])
        #expect(PaywallURLs.resolveBase(bundle: bundle) == "https://stub.example")
    }

    @Test
    func `resolveBase returns empty string when WebBaseUrl key is missing`() {
        let bundle = StubBundle(info: [:])
        #expect(PaywallURLs.resolveBase(bundle: bundle).isEmpty)
    }
}

private final class StubBundle: Bundle, @unchecked Sendable {
    private let info: [String: Any]

    init(info: [String: Any]) {
        self.info = info
        super.init()
    }

    override func object(forInfoDictionaryKey key: String) -> Any? {
        info[key]
    }
}
