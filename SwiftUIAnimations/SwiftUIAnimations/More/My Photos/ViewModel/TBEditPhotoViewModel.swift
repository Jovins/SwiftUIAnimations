import Foundation
import RxSwift

final class TBEditPhotoViewModel: NSObject {
    private let myPhotosNetworkHelper = TBMyPhotosNetworkHelper()
    private let disposed = DisposeBag()

    var image: UIImage?
    var profilesModel: [TBAlbumsProfileModel]?
    var selectedProfile: TBAlbumsProfileModel? {
        didSet {
            selectedAlbum = selectedProfile?.albums?.first
        }
    }
    var selectedAlbum: TBAlbumModel? {
        didSet {
            guard let type = selectedAlbum?.albumType else { return }
            switch type {
            case .pregnant:
                selectedPhotosModel = selectedAlbum?.pregnancyPhotos.first
            case .child:
                selectedPhotosModel = selectedAlbum?.childPhotos.first
            case .toddler:
                selectedPhotosModel = selectedAlbum?.toddlerPhotos.flatMap({$0}).first
            }
        }
    }
    var selectedPhotosModel: TBPhotosModel?
    var selectedPhotoModel: TBPhotoModel?
    private var originalProfile: TBAlbumsProfileModel?
    private var originalAlbum: TBAlbumModel?
    private var originalPhotosModel: TBPhotosModel?
    private var originalCaption: String?
    var photoDescription: String?
    var albumTypeTitle: String {
        switch selectedAlbum?.albumType {
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
    var timeTitle: String {
        switch selectedAlbum?.albumType {
        case .pregnant, .child:
           return "Week"
        case .toddler:
            return "Month/Year"
        default:
            return ""
        }
    }
    var selectedPhotoTime: String {
        switch selectedAlbum?.albumType {
        case .pregnant:
            guard let week = selectedPhotosModel?.week else { return "" }
            return "Week \(week) "
        case .child:
            guard let week = selectedPhotosModel?.week else { return "" }
            if week == 0 {
                return "Newborn"
            } else {
                return "Week \(week) "
            }
        case .toddler:
            guard let year = selectedPhotosModel?.year else { return "" }
            if year < 3,
               let month = selectedPhotosModel?.month {
                return "\(month) Months"
            } else {
                return "\(year) Years Old"
            }
        default:
            return ""
        }
    }
    var saveEnable: Bool {
        guard self.selectedProfile == self.originalProfile,
              self.selectedAlbum == self.originalAlbum,
              self.selectedPhotosModel == self.originalPhotosModel,
              (self.photoDescription ?? "") == (self.originalCaption ?? "") else {
            return true
        }
        return false
    }
    var placeholderText: String? {
        guard let type = selectedAlbum?.albumType else { return nil }
        switch type {
        case .pregnant:
            return "How are you feeling?"
        case .child:
            return "What is baby discovering today?"
        case .toddler:
            return "What memories are we making today?"
        }
    }
    private(set) var editPhotoSubject: PublishSubject<Event<(TBPhotoModel?, String?)>> = PublishSubject<Event<(TBPhotoModel?, String?)>>()

    func setupModel(image: UIImage?,
                    profilesModel: [TBAlbumsProfileModel]?,
                    profileModel: TBAlbumsProfileModel?,
                    albumModel: TBAlbumModel?,
                    photosModel: TBPhotosModel?,
                    photoModel: TBPhotoModel) {
        self.image = image
        self.profilesModel = profilesModel
        self.selectedProfile = profileModel
        self.selectedAlbum = albumModel
        self.selectedPhotosModel = photosModel
        self.selectedPhotoModel = photoModel
        self.photoDescription = photoModel.caption

        self.originalProfile = profileModel
        self.originalAlbum = albumModel
        self.originalPhotosModel = photosModel
        self.originalCaption = photoModel.caption
    }

    func editPhoto() {
        guard let selectedPhotoModel = selectedPhotoModel,
              let photoId = selectedPhotoModel.id else { return }
        myPhotosNetworkHelper.editPhoto(caption: photoDescription,
                                        week: selectedPhotosModel?.week,
                                        month: selectedPhotosModel?.month,
                                        year: selectedPhotosModel?.year,
                                        albumId: selectedAlbum?.id,
                                        photoId: photoId)
        .subscribe { [weak self] model in
            guard let self = self else { return }
            if let model = model {
                self.selectedPhotoModel?.update(by: model)
            }
            self.editPhotoSubject.onNext(.next((model, self.selectedAlbum?.id)))
        } onError: { [weak self] error in
            guard let self = self else { return }
            self.editPhotoSubject.onNext(.error(error))
        }
        .disposed(by: disposed)
    }
}
