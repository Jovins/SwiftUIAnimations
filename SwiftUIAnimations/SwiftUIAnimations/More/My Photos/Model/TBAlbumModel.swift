import Foundation

final class TBAlbumsModel: NSObject, Codable {
    var profiles: [TBAlbumsProfileModel]?
}

final class TBAlbumsProfileModel: NSObject, Codable {
    var id: Int?
    var name: String?
    var albums: [TBAlbumModel]?
    var profileType: TBMyPhotosRepository.AlbumType?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case albums
    }
}

final class TBAlbumModel: NSObject, Codable {
    var id: String?
    var name: String?
    var type: String?
    var photos: [TBPhotoModel]?
    var pregnancyPhotos: [TBPhotosModel] = []
    var childPhotos: [TBPhotosModel] = []
    var toddlerPhotos: [[TBPhotosModel]] = []

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case photos
    }
}

extension TBAlbumModel {
    var albumType: TBMyPhotosRepository.AlbumType? {
        guard let type = self.type,
              let albumType = TBMyPhotosRepository.AlbumType(rawValue: type) else { return nil }
        return albumType
    }
}

final class TBPhotosModel: NSObject {
    var week: Int?
    var month: Int?
    var year: Int?
    var photos: [TBPhotoModel] = []
}
