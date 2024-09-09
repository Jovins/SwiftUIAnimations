import Foundation

struct TBDurationModel {
    var type: DurationType
    var data: [Int]
}

extension TBDurationModel {
    enum DurationType {
        case minute
        case second

        var unitTitle: String {
            switch self {
            case .minute:
                return "min"
            case .second:
                return "sec"
            }
        }
    }
}
