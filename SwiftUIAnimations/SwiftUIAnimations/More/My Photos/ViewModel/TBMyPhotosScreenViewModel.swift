import Foundation
import RxSwift

final class TBMyPhotosScreenViewModel: NSObject {
    private let disposed = DisposeBag()
    private(set) var profilesModel: [TBAlbumsProfileModel] = []
    private(set) var profilesModelSubject = PublishSubject<Event<(type: TBMyPhotosRepository.ActionType, models: [TBAlbumsProfileModel])>>()
    private var myPhotosRepo: TBMyPhotosRepository?

    func bindData(repository: TBMyPhotosRepository) {
        self.myPhotosRepo = repository
        repository.profilesModelSubject.subscribe {[weak self] event in
            guard let self = self else { return }
            switch event {
            case let .next(tuple):
                self.profilesModel = tuple.models
                self.profilesModelSubject.onNext(.next(tuple))
            case let .error(error):
                self.profilesModelSubject.onNext(.error(error))
            default:
                break
            }
        } onError: { _ in
        }.disposed(by: disposed)
    }

    func fetchAlbums() {
        myPhotosRepo?.fetchAlbums()
    }

    func deleteAlbums(albumIds: [String]) {
        myPhotosRepo?.deleteAlbums(albumIds: albumIds)
    }

    func deletePhotos(photosIds: [String]) {
        myPhotosRepo?.deletePhotos(photosIds: photosIds)
    }

    func uploadPhotoModel(model: TBPhotoModel?, albumId: String?) {
        myPhotosRepo?.uploadPhotoModel(model: model, albumId: albumId)
    }
}
