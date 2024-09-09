import Foundation

struct TBToolListModel: Codable {
    let stage: String
    let color: String
    var tools: [TBToolsModel]
    var more: [TBToolsModel]

    var sortedTools: TBSortedToolsModel?

    enum CodingKeys: String, CodingKey {
        case stage
        case color
        case tools
        case more
    }
}

struct TBToolsModel: Codable {
    let title: String
    let type: String
    let icon: String
    enum CodingKeys: String, CodingKey {
        case title
        case type
        case icon
    }
}

final class TBToolsUsageCondition: Codable {
    var sortTypesDic: [String: TBToolSortType] = [:]
    var clickRecordDic: [String: TBToolClickRecord] = [:]
}

final class TBToolClickRecord: Codable {
    var count: Int = 0
    var updateAt: Date?
}

final class TBSortedToolsModel: Codable {
    var tools: [TBToolsModel] = []
    var more: [TBToolsModel] = []
}

enum TBToolSortType: String, Codable {
    case mostPopular
    case alphabeticalAtoZ
    case alphabeticalZtoA
    case mostFrequentlyUsed

    var title: String {
        switch self {
        case .mostPopular:
            return "Most Popular"
        case .alphabeticalAtoZ:
            return "Alphabetical A-Z"
        case .alphabeticalZtoA:
            return "Alphabetical Z-A"
        case .mostFrequentlyUsed:
            return "Most Frequently Used"
        }
    }
}
