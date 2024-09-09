import Foundation

struct TBFoodSafetyModel: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var iconUrl: String?
    var sourceUrl: String?
    var sourceName: String?
    var disclaimer: String?
    var imageUrl: String?
    var restrictions: [TBFoodSafetyRestriction]?
    var categories: [TBFoodSafetyCategory]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case iconUrl = "icon_url"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case disclaimer
        case imageUrl = "image_url"
        case restrictions
        case categories
    }

    func sortedRestrictions() -> [TBFoodSafetyRestriction] {
        if let restrictionSet = self.restrictions {
            let restrictionsArray = Array(restrictionSet)
            return restrictionsArray.sorted(by: { (firstRestriction, secondRestriction) -> Bool in
                if let firstName = firstRestriction.name, let secondName = secondRestriction.name {
                    return firstName > secondName
                }
                return false
            })
        }
        return [TBFoodSafetyRestriction]()
    }

    var isSafe: Bool {
        if let restrictions = restrictions {
            for restriction in restrictions {
                if let isSafe = restriction.isSafe, !isSafe {
                    return false
                }
            }
        }
        return true
    }
}

struct TBFoodSafetyRestriction: Codable, Equatable {

    var id: Int?
    var name: String?
    var isSafe: Bool?
    var description: String?
    var iconUrl: String?
    var imageUrl: String?
    var sourceUrl: String?
    var sourceName: String?
    var disclaimer: String?
    var severity: TBFoodSafetySeverity?

    var placeholderImage: UIImage? {
        guard let iconName = self.name else {
            return nil
        }
        if iconName.localizedCaseInsensitiveContains("approve") {
            return TBIconList.check.image()
        } else if iconName.localizedCaseInsensitiveContains("avoid") {
            return TBIconList.abandon.image()
        } else if iconName.localizedCaseInsensitiveContains("cook") {
            return UIImage(named: "cookIcon")
        } else if iconName.localizedCaseInsensitiveContains("limit") {
            return UIImage(named: "limitIcon")
        } else if iconName.localizedCaseInsensitiveContains("pasteurize") {
            return UIImage(named: "pasteurizeIcon")
        } else if iconName.localizedCaseInsensitiveContains("super") {
            return UIImage(named: "superIcon")
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isSafe = "is_safe"
        case description
        case iconUrl = "icon_url"
        case imageUrl = "image_url"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case disclaimer
        case severity
    }

    static func == (lhs: TBFoodSafetyRestriction, rhs: TBFoodSafetyRestriction) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TBFoodSafetySeverity: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var iconUrl: String?
    var hex: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case iconUrl = "icon_url"
        case hex
    }
}

struct TBFoodSafetyCategory: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var imageUrl: String?
    var disclaimer: String?
    var sourceUrl: String?
    var sourceName: String?
    var sources: [TBFoodSafetySource]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case disclaimer
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case sources
    }
}

struct TBFoodSafetySource: Codable {
    var sourceName: String?
    var sourceUrl: String?

    enum CodingKeys: String, CodingKey {
        case sourceName = "source_name"
        case sourceUrl = "source_url"
    }
}
