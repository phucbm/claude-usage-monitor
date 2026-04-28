import SwiftUI
import AppKit

enum T {
    // MARK: - Colors (adaptive)
    static let ink     = Color(nsColor: .brutalInk)
    static let paper   = Color(nsColor: .brutalPaper)
    static let primary = Color(red: 0xEA/255, green: 0x60/255, blue: 0x49/255)
    static let muted   = Color(nsColor: .brutalMuted)

    // MARK: - Typography
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("JetBrains Mono", size: size).weight(weight)
    }

    // MARK: - Shape
    static let border: CGFloat = 1.5
    static let ringLineCap     = CGLineCap.butt
}

extension NSColor {
    static let brutalInk = NSColor(name: nil) { a in
        a.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0xF2/255, green: 0xF0/255, blue: 0xEB/255, alpha: 1)
            : NSColor(red: 0x0A/255, green: 0x0A/255, blue: 0x0A/255, alpha: 1)
    }
    static let brutalPaper = NSColor(name: nil) { a in
        a.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0x14/255, green: 0x14/255, blue: 0x12/255, alpha: 1)
            : NSColor(red: 0xF2/255, green: 0xF0/255, blue: 0xEB/255, alpha: 1)
    }
    static let brutalMuted = NSColor(name: nil) { a in
        a.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0x8A/255, green: 0x8A/255, blue: 0x88/255, alpha: 1)
            : NSColor(red: 0x6B/255, green: 0x6B/255, blue: 0x6B/255, alpha: 1)
    }
}
