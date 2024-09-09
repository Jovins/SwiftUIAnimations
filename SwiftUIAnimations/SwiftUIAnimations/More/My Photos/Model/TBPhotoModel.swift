import Foundation

final class TBPhotoModel: NSObject, Codable {
    var id: Int?
    var caption: String?
    var week: Int?
    var month: Int?
    var year: Int?
    var category: Int?
    var createdAt: Int?
    var variantURLs: TBPhotoVariantURLs?

    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case week
        case month
        case year
        case category
        case createdAt = "created_at"
        case variantURLs = "variant_urls"
    }
}

extension TBPhotoModel {
    final class TBPhotoVariantURLs: NSObject, Codable {
        var original: String?
        var medium: String
    }

    func update(by model: TBPhotoModel) {
        self.id = model.id
        self.caption = model.caption
        self.week = model.week
        self.month = model.month
        self.year = model.year
        self.category = model.category
        self.createdAt = model.createdAt
        self.variantURLs = model.variantURLs
    }
}
