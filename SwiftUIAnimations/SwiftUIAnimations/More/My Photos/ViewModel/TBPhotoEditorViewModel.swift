import Foundation
import RxSwift

final class TBPhotoEditorViewModel: NSObject {
    private let myPhotosNetworkHelper = TBMyPhotosNetworkHelper()
    private let disposed = DisposeBag()

    var albumID: String?
    var image: UIImage?
    var albumName: String?
    var albumType: TBMyPhotosRepository.AlbumType = .pregnant
    var pickerDataSource: [TBPickerModel]?
    var pickerIndex: Int = 0
    var week: Int?
    var month: Int?
    var year: Int?
    var photoDescription: String?
    var placeholderText: String {
        switch albumType {
        case .pregnant:
            return "How are you feeling?"
        case .child:
            return "What is baby discovering today?"
        case .toddler:
            return "What memories are we making today?"
        }
    }

    private(set) var uploadPhotoSubject: PublishSubject<Event<(TBPhotoModel?, String?)>> = PublishSubject<Event<(TBPhotoModel?, String?)>>()

    func addPhoto() {
        guard let data = image?.fixOrientation()?.jpegData(compressionQuality: 0.7),
              let pickerModel = pickerDataSource?[safe: pickerIndex] else { return }
        myPhotosNetworkHelper.uploadPhoto(caption: photoDescription,
                                          week: pickerModel.week,
                                          month: pickerModel.month,
                                          year: pickerModel.year,
                                          albumId: albumID,
                                          file: data)
        .subscribe { [weak self] model in
            guard let self = self else { return }
            self.uploadPhotoSubject.onNext(.next((model, self.albumID)))
            TBAnalyticsManager.trackPhotoUploaded(albumName: self.albumName ?? "null",
                                                  week: pickerModel.week,
                                                  month: pickerModel.month,
                                                  year: pickerModel.year,
                                                  albumType: self.albumType)
        } onError: { [weak self] error in
            guard let self = self else { return }
            self.uploadPhotoSubject.onNext(.error(error))
        }
        .disposed(by: disposed)
    }

    func albumTypeName() -> String {
        switch albumType {
        case .pregnant:
            return "Pregnancy Photos"
        case .child:
            return "Baby Photos"
        case .toddler:
            return "Toddler Photos"
        default:
            return ""
        }
    }
}

extension TBPhotoEditorViewModel {
    class TBPickerModel {
        var title: String?
        var week: Int?
        var month: Int?
        var year: Int?
    }
}
