import Foundation
import Moya
import RxSwift

final class TBMyPhotosNetworkHelper {
    // swiftlint:disable force_unwrapping
    static let myPhotosBaseURL = URL(string: thebumpContentBaseURL)!
    private let baseURL: URL
    private let moyaProvider: MoyaProvider<TBMyPhotosAPI>
    private var authToken: String {
        return TBMemberDataManager.shared.authenticationToken ?? ""
    }

    init(baseURL: URL = myPhotosBaseURL,
         moyaProvider: MoyaProvider<TBMyPhotosAPI> = MoyaProvider<TBMyPhotosAPI>()) {
        self.baseURL = baseURL
        self.moyaProvider = moyaProvider
    }

    func getAlbums() -> Observable<TBAlbumsModel> {
        let api = TBMyPhotosAPI(baseURL: baseURL, authToken: authToken, endpoint: .getAlbums)
        return Observable<TBAlbumsModel>.ofRequest(api: api, provider: moyaProvider)
    }

    func removeAlbums(albumIds: [String]) -> Observable<Response> {
        let api = TBMyPhotosAPI(baseURL: baseURL, authToken: authToken, endpoint: .removeAlbums(albumIds: albumIds))
        return Observable<Response>.ofRequest(api: api, provider: moyaProvider)
    }

    func moveAlbums(albumId: String, photoIds: [String], week: Int?, month: Int?, year: Int?) -> Observable<Response> {
        let api = TBMyPhotosAPI(baseURL: baseURL, authToken: authToken, endpoint: .moveAlbums(albumId: albumId, photoIds: photoIds, week: week, month: month, year: year))
        return Observable<Response>.ofRequest(api: api, provider: moyaProvider)
    }

    func uploadPhoto(caption: String?, week: Int?, month: Int?, year: Int?, albumId: String?, file: Data) -> Observable<TBPhotoModel?> {
        let api = TBMyPhotosAPI(baseURL: baseURL, authToken: authToken, endpoint: .uploadPhoto(caption: caption, week: week, month: month, year: year, albumId: albumId, file: file))
        return Observable<[String: TBPhotoModel]>.ofRequest(api: api, provider: moyaProvider).map({
            $0["photo"]
        })
    }

    func removePhotos(albumId: String, photoIds: [String]) -> Observable<Response> {
        let api = TBMyPhotosAPI(baseURL: baseURL, authToken: authToken, endpoint: .removePhotos(albumId: albumId, photoIds: photoIds))
        return Observable<Response>.ofRequest(api: api, provider: moyaProvider)
    }

    func editPhoto(caption: String?, week: Int?, month: Int?, year: Int?, albumId: String?, photoId: Int) -> Observable<TBPhotoModel?> {
        let api = TBMyPhotosAPI(baseURL: baseURL, authToken: authToken, endpoint: .editPhoto(caption: caption, week: week, month: month, year: year, albumId: albumId, photoId: photoId))
        return Observable<[String: TBPhotoModel]>.ofRequest(api: api, provider: moyaProvider).map({
            $0["photo"]
        })
    }
}
