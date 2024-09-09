import Foundation
import Moya

struct TBMyPhotosAPI {
    let baseURL: URL
    let authToken: String
    let endpoint: TBMyPhotosEndpoint
}

enum TBMyPhotosEndpoint {
    case getAlbums
    case removeAlbums(albumIds: [String])
    case moveAlbums(albumId: String, photoIds: [String], week: Int?, month: Int?, year: Int?)
    case uploadPhoto(caption: String?, week: Int?, month: Int?, year: Int?, albumId: String?, file: Data)
    case editPhoto(caption: String?, week: Int?, month: Int?, year: Int?, albumId: String?, photoId: Int)
    case removePhotos(albumId: String, photoIds: [String])
}

extension TBMyPhotosAPI: TargetType {
    var path: String {
        switch endpoint {
        case .getAlbums,
             .removeAlbums:
            return "/v1/albums"
        case let .moveAlbums(albumId, _, _, _, _),
             let .removePhotos(albumId, _):
            return "/v1/albums/\(albumId)/photos"
        case .uploadPhoto:
            return "/v1/member_photos"
        case let .editPhoto(_, _, _, _, _, photoId):
            return "/v1/member_photos/\(photoId)"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .getAlbums:
            return .get
        case .removeAlbums,
             .moveAlbums,
             .removePhotos,
             .editPhoto:
            return .put
        case .uploadPhoto:
            return .post
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch endpoint {
        case .getAlbums:
            return .requestPlain
        case let .removeAlbums(albumIds):
            var dic: [String: Any] = ["action": "remove"]
            dic["album_ids"] = albumIds
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case let .moveAlbums(_, photoIds, week, month, year):
            var dic: [String: Any] = ["action": "move"]
            dic["photo_ids"] = photoIds
            dic["week"] = week
            dic["month"] = month
            dic["year"] = year
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case let .uploadPhoto(caption, week, month, year, albumId, file):
            var uploadBodyArray = [MultipartFormData]()
            if let caption = caption {
                uploadBodyArray.append(MultipartFormData.build(stringValue: caption, key: "caption"))
            }
            if let week = week {
                uploadBodyArray.append(MultipartFormData.build(intValue: week, key: "week"))
            }
            if let month = month {
                uploadBodyArray.append(MultipartFormData.build(intValue: month, key: "month"))
            }
            if let year = year {
                uploadBodyArray.append(MultipartFormData.build(intValue: year, key: "year"))
            }
            if let albumId = albumId {
                uploadBodyArray.append(MultipartFormData.build(stringValue: albumId, key: "album_id"))
            }
            let fileData = MultipartFormData(provider: .data(file), name: "file", fileName: "bump-photo.jpeg", mimeType: "image/jpeg")
            uploadBodyArray.append(fileData)
            return .uploadMultipart(uploadBodyArray)
        case .removePhotos(_, let photoIds):
            var dic: [String: Any] = ["action": "remove"]
            dic["photo_ids"] = photoIds
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case let .editPhoto(caption, week, month, year, albumId, _):
            var uploadBodyArray = [MultipartFormData]()
            if let caption = caption {
                uploadBodyArray.append(MultipartFormData.build(stringValue: caption, key: "caption"))
            }
            if let week = week {
                uploadBodyArray.append(MultipartFormData.build(intValue: week, key: "week"))
            }
            if let month = month {
                uploadBodyArray.append(MultipartFormData.build(intValue: month, key: "month"))
            }
            if let year = year {
                uploadBodyArray.append(MultipartFormData.build(intValue: year, key: "year"))
            }
            if let albumId = albumId {
                uploadBodyArray.append(MultipartFormData.build(stringValue: albumId, key: "album_id"))
            }
            return .uploadMultipart(uploadBodyArray)
        }
    }

    var headers: [String: String]? {
        var dic: [String: String] = ["CLIENT_APP": "BumpiOS"]
        dic["auth_token"] = authToken
        return dic
    }
}
