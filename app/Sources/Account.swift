import Foundation

enum BillingStatus: Equatable {
    case ok
    case paymentRequired
    case sessionExpired
    case forbidden
    case rateLimited

    var message: String {
        switch self {
        case .ok:              return ""
        case .paymentRequired: return "Payment required — update billing at claude.ai"
        case .sessionExpired:  return "Session expired — please refresh your cookie"
        case .forbidden:       return "Access denied — cookie may be invalid or account suspended"
        case .rateLimited:     return "Rate limited — too many requests, try again later"
        }
    }

    var icon: String {
        switch self {
        case .ok:              return ""
        case .paymentRequired: return "creditcard.trianglebadge.exclamationmark"
        case .sessionExpired:  return "key.slash"
        case .forbidden:       return "lock.slash"
        case .rateLimited:     return "clock.badge.exclamationmark"
        }
    }
}

struct Account: Codable, Identifiable {
    var id: String
    var label: String
    var cookie: String
    var showInMenuBar: Bool = true

    // Transient usage data — not persisted, fetched live
    var sessionUsage: Int = 0
    var sessionLimit: Int = 100
    var weeklyUsage: Int = 0
    var weeklyLimit: Int = 100
    var weeklySonnetUsage: Int = 0
    var weeklySonnetLimit: Int = 100
    var sessionPercentage: Double = 0.0
    var weeklyPercentage: Double = 0.0
    var weeklySonnetPercentage: Double = 0.0
    var sessionResetsAt: Date?
    var weeklyResetsAt: Date?
    var weeklySonnetResetsAt: Date?
    var hasWeeklySonnet: Bool = false
    var errorMessage: String?
    var billingStatus: BillingStatus = .ok
    var hasFetchedData: Bool = false
    var lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case id, label, cookie, showInMenuBar
    }

    init(label: String, cookie: String) {
        self.id = UUID().uuidString
        self.label = label.isEmpty ? "Account" : label
        self.cookie = cookie
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        label = try c.decode(String.self, forKey: .label)
        cookie = try c.decode(String.self, forKey: .cookie)
        showInMenuBar = try c.decodeIfPresent(Bool.self, forKey: .showInMenuBar) ?? true
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(label, forKey: .label)
        try c.encode(cookie, forKey: .cookie)
        try c.encode(showInMenuBar, forKey: .showInMenuBar)
    }

    mutating func updatePercentages() {
        sessionPercentage = Double(sessionUsage) / Double(max(sessionLimit, 1))
        weeklyPercentage = Double(weeklyUsage) / Double(max(weeklyLimit, 1))
        weeklySonnetPercentage = Double(weeklySonnetUsage) / Double(max(weeklySonnetLimit, 1))
    }
}
