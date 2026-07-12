import Foundation

enum Endpoints {
    static let domain = Bundle.main.object(forInfoDictionaryKey: "Domain") as? String ?? "alttabneo.local"
    static let apiDomain = Bundle.main.object(forInfoDictionaryKey: "ApiDomain") as? String ?? domain
    static let website = AltTabNeoBranding.website ?? "https://\(domain)"
    static let appcastUrl = "\(website)/appcast.xml"
    static let supportUrl = "\(website)/support"
    static let checkoutUrl = "\(website)/pricing"
    static let accountUrl = "\(website)/my-account"
    static let licenseApiBaseUrl = "https://\(apiDomain)/v1/license"
    static let feedbackUrl = "https://\(apiDomain)/v1/feedback"
}
