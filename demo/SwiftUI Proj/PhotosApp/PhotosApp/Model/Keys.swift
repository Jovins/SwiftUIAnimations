import SwiftUI

struct ViewFrame: Equatable {
    var frame: CGRect = .zero
    var bounds: CGRect = .zero
}

struct HeroKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

struct FrameKey: PreferenceKey {
    static var defaultValue: ViewFrame = .init()
    static func reduce(value: inout ViewFrame, nextValue: () -> ViewFrame) {
        value = nextValue()
    }
}
