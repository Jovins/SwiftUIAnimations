import Foundation

extension URL {
    var openableURL: URL? {
        var urlString = self.absoluteString
        if !urlString.hasPrefix("http") { urlString = "https://\(urlString)" }
        return URL(string: urlString)
    }

    var parameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
        let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }

    static func buildImageURL(mediaId: String, size: Int = 720) -> URL? {
        let string = TBNewAPIConstants.kImageAPIBaseUrl + "images/" + mediaId + "~rs_\(size).h"
        return URL(string: string)
    }
}

extension NSURL {
    @objc var isFromAssociatedDomain: Bool {
        let associatedDomains = ["thebump.app.link",
                                 "sfw6.app.link",
                                 "sfw6.test-app.link",
                                 "sfw6-alternate.app.link",
                                 "sfw6-alternate.test-app.link",
                                 "qa-www.thebump.com",
                                 "cloud.news.thebump.com",
                                 "click.news.thebump.com",
                                 "view.news.thebump.com",
                                 "image.news.thebump.com",
                                 "email.theknot.com",
                                 "www.thebump.com",
                                 "pregnant.thebump.com",
                                 "staging-www.thebump.com",
                                 "tbw-alpha-www.k8s.thebump.com",]

        guard let domain = self.host else { return false }

        return associatedDomains.contains(domain)
    }
}

extension URL {
    var isFromAssociatedDomain: Bool {
        let associatedDomains = ["thebump.app.link",
                                 "sfw6.app.link",
                                 "sfw6.test-app.link",
                                 "sfw6-alternate.app.link",
                                 "sfw6-alternate.test-app.link",
                                 "qa-www.thebump.com",
                                 "cloud.news.thebump.com",
                                 "click.news.thebump.com",
                                 "view.news.thebump.com",
                                 "image.news.thebump.com",
                                 "email.theknot.com",
                                 "www.thebump.com",
                                 "pregnant.thebump.com",
                                 "staging-www.thebump.com",
                                 "tbw-alpha-www.k8s.thebump.com"]

        guard let domain = self.host else { return false }

        return associatedDomains.contains(domain)
    }
}
