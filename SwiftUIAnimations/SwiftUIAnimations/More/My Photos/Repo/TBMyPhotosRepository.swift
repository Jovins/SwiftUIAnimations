import Foundation
import RxSwift

class TBMyPhotosRepository: NSObject {
    static let shared = TBMyPhotosRepository()
    private let orderAlbumArray = [AlbumType.pregnant.rawValue,
                                   AlbumType.child.rawValue,
                                   AlbumType.toddler.rawValue]
    private let disposed = DisposeBag()
    var albumsModel: TBAlbumsModel? {
        didSet {
            sortAlbums()
        }
    }
    private let myPhotosNetworkHelper = TBMyPhotosNetworkHelper()
    private(set) var profilesModel: [TBAlbumsProfileModel] = []
    private(set) var profilesModelSubject: PublishSubject<Event<(type: ActionType, models: [TBAlbumsProfileModel])>> = PublishSubject<Event<(type: ActionType, models: [TBAlbumsProfileModel])>>()

    override init() {}

    func fetchAlbums() {
        myPhotosNetworkHelper.getAlbums().subscribe {[weak self] model in
            guard let self = self else { return }
            self.albumsModel = model
            self.profilesModelSubject.onNext(.next((.initData, self.profilesModel)))
        } onError: {[weak self] error in
            guard let self = self else { return }
            self.profilesModelSubject.onNext(.error(error))
        }.disposed(by: disposed)
    }

    private func sortAlbums() {
        guard var profiles = albumsModel?.profiles else { return }
        profiles.map({ profile -> TBAlbumsProfileModel in
            guard let albums = profile.albums else { return profile }
            profile.albums = albums.sorted(by: { album1, album2 in
                guard let index1 = orderAlbumArray.firstIndex(of: album1.type ?? ""),
                      let index2 = orderAlbumArray.firstIndex(of: album2.type ?? "") else { return false }
                return index1 < index2
            })
            return profile
        })

        profiles = profiles.map({ profile in
            if let id = profile.id {
                profile.name = getProfileName(id: id)
                profile.profileType = getProfileType(id: id)
            }
            guard let albums = profile.albums else { return profile }
            albums.map({ album -> TBAlbumModel in
                guard let type = album.type,
                      let albumType = AlbumType(rawValue: type) else { return album }
                album.name = profile.name
                switch albumType {
                case .pregnant:
                    album.pregnancyPhotos = sortPregnantPhotosInAlbums(photos: album.photos)
                case .child:
                    album.childPhotos = sortChildPhotosInAlbums(photos: album.photos)
                case .toddler:
                    album.toddlerPhotos = sortToddlerPhotosInAlbums(photos: album.photos)
                }
                return album
            })
            profile.albums = albums
            return profile
        })

        var orderProfileIds: [Int] = []
        if let id = TBMemberDataManager.shared.memberData?.pregnancy?.id {
            orderProfileIds.append(id)
        }
        if let childIds = TBMemberDataManager.shared.memberData?.getSortedArrayOfChildren(fromOldestChild: false).map({$0.childId.intValue}) {
            orderProfileIds.append(contentsOf: childIds)
        }
        profiles = profiles.sorted(by: { profile1, profile2 in
            guard let index1 = orderProfileIds.firstIndex(of: profile1.id ?? -1),
                  let index2 = orderProfileIds.firstIndex(of: profile2.id ?? -1) else { return false }
            return index1 < index2
        })
        self.profilesModel = profiles
    }

    private func getProfileType(id: Int) -> AlbumType? {
        if id == TBMemberDataManager.shared.memberData?.pregnancy?.id {
            return .pregnant
        } else if let child = TBMemberDataManager.shared.memberData?.bornChildren?.first(where: {$0.id == id}) {
            if let children = child.convertToMemberChild(), children.isToddler {
                return .toddler
            } else {
                return .child
            }
        }
        return nil
    }

    private func getProfileName(id: Int) -> String {
        if id == TBMemberDataManager.shared.memberData?.pregnancy?.id {
            if let codeName = TBMemberDataManager.shared.memberData?.pregnancy?.codeName,
               !codeName.isEmpty {
                return codeName
            } else if let pregnancyDueDate = TBMemberDataManager.shared.memberData?.pregnancyDueDate {
                return "Expecting \(pregnancyDueDate.convertToMMDDYYYY())"
            } else {
                return "Pregnant"
            }
        }

        if let child = TBMemberDataManager.shared.memberData?.bornChildren?.first(where: {$0.id == id}) {
            if let firstName = child.firstName,
               !firstName.isEmpty {
                return firstName
            } else if let date = NSDate(fromJSONDateString: child.birthDate) as? Date {
                return "Baby \(date.convertToMMDDYYYY())"
            } else {
                return "Baby"
            }
        }

        return "UnknowProfile"
    }

    private func sortPregnantPhotosInAlbums(photos: [TBPhotoModel]?) -> [TBPhotosModel] {
        var pregnancyPhotosDic: [Int: TBPhotosModel] = [:]
        for i in 4...42 {
            let model = TBPhotosModel()
            model.week = i
            pregnancyPhotosDic[i] = model
        }
        if let photos = photos {
            for photo in photos {
                guard let week = photo.week,
                      let weekPhotos = pregnancyPhotosDic[week]?.photos else { continue }
                pregnancyPhotosDic[week]?.photos = weekPhotos + [photo]
            }
        }
        pregnancyPhotosDic.keys.forEach({ weekKey in
            guard let photos = pregnancyPhotosDic[weekKey]?.photos else { return }
            pregnancyPhotosDic[weekKey]?.photos = photos.sorted(by: {
                $0.createdAt >? $1.createdAt
            })
        })
        let pregnancyPhotos = pregnancyPhotosDic.sorted(by: {
            $0.key < $1.key
        }).map({$0.value})
        return pregnancyPhotos
    }

    private func sortChildPhotosInAlbums(photos: [TBPhotoModel]?) -> [TBPhotosModel] {
        var childPhotosDic: [Int: TBPhotosModel] = [:]
        for i in 0...52 {
            let model = TBPhotosModel()
            model.week = i
            childPhotosDic[i] = model
        }
        if let photos = photos {
            for photo in photos {
                guard let week = photo.week,
                      let weekPhotos = childPhotosDic[week]?.photos else { continue }
                childPhotosDic[week]?.photos = weekPhotos + [photo]
            }
        }
        childPhotosDic.keys.forEach({ weekKey in
            guard let photos = childPhotosDic[weekKey]?.photos else { return }
            childPhotosDic[weekKey]?.photos = photos.sorted(by: {
                $0.createdAt >? $1.createdAt
            })
        })
        let childPhotos = childPhotosDic.sorted(by: {
            $0.key < $1.key
        }).map({$0.value})
        return childPhotos
    }

    private func sortToddlerPhotosInAlbums(photos: [TBPhotoModel]?) -> [[TBPhotosModel]] {
        var toddlerPhotosDic: [Int: [Int: TBPhotosModel]] = [:]
        for year in 1...5 {
            toddlerPhotosDic[year] = [:]
            switch year {
            case 1:
                for month in 13...24 {
                    let model = TBPhotosModel()
                    model.year = year
                    model.month = month
                    toddlerPhotosDic[year]?[month] = model
                }
            case 2:
                for month in 25...36 {
                    let model = TBPhotosModel()
                    model.year = year
                    model.month = month
                    toddlerPhotosDic[year]?[month] = model
                }
            case 3:
                let model = TBPhotosModel()
                model.year = year
                toddlerPhotosDic[year]?[0] = model
            case 4:
                let model = TBPhotosModel()
                model.year = year
                toddlerPhotosDic[year]?[0] = model
            case 5:
                let model = TBPhotosModel()
                model.year = year
                toddlerPhotosDic[year]?[0] = model
            default:
                break
            }
        }
        if let photos = photos {
            for photo in photos {
                guard let year = photo.year else { continue }
                switch year {
                case 1, 2:
                    if let month = photo.month,
                       let monthPhotos = toddlerPhotosDic[year]?[month]?.photos {
                        toddlerPhotosDic[year]?[month]?.photos = monthPhotos + [photo]
                    }
                case 3, 4, 5:
                    if let yearPhotos = toddlerPhotosDic[year]?[0]?.photos {
                        toddlerPhotosDic[year]?[0]?.photos = yearPhotos + [photo]
                    }
                default:
                    break
                }
            }
        }
        toddlerPhotosDic.keys.forEach({ yearKey in
            toddlerPhotosDic[yearKey]?.keys.forEach({ monthKey in
                guard let photos = toddlerPhotosDic[yearKey]?[monthKey]?.photos else { return }
                toddlerPhotosDic[yearKey]?[monthKey]?.photos = photos.sorted(by: {
                    $0.createdAt >? $1.createdAt
                })
            })
        })
        let array = toddlerPhotosDic.sorted(by: {
            $0.key < $1.key
        }).map({$0.value})
        let toddlerPhotos = array.map({
            $0.sorted(by: {
                $0.key < $1.key
            }).map({$0.value})
        })
        return toddlerPhotos
    }

    func deleteAlbums(albumIds: [String]) {
        DispatchQueue.global().async {
            guard let albumsModel = self.albumsModel,
                  let profiles = albumsModel.profiles else { return }
            albumIds.forEach({ id in
                for profile in profiles {
                    for album in profile.albums ?? [] where album.id == id {
                        album.photos = []
                        return
                    }
                }
            })
            self.albumsModel = albumsModel
            self.profilesModelSubject.onNext(.next((.refreshData, self.profilesModel)))
        }
    }

    func deletePhotos(photosIds: [String]) {
        DispatchQueue.global().async {
            var photosIds = photosIds
            guard let albumsModel = self.albumsModel,
                  let profiles = albumsModel.profiles else { return }
            profiles.forEach({ profile in
                guard let albums = profile.albums else { return }
                albums.forEach({ album in
                    for id in photosIds {
                        guard let index = album.photos?.firstIndex(where: { $0.id == Int(id) }) else { return }
                        album.photos?.remove(at: index)
                    }
                })
            })
            self.albumsModel = albumsModel
            self.profilesModelSubject.onNext(.next((.refreshData, self.profilesModel)))
        }
    }

    func uploadPhotoModel(model: TBPhotoModel?, albumId: String?) {
        DispatchQueue.global().async {
            guard let albumsModel = self.albumsModel,
                  let profiles = albumsModel.profiles,
                  let albumId = albumId,
                  let model = model else { return }
            profiles.forEach({ profile in
                guard let albums = profile.albums else { return }
                for album in albums where album.id == albumId {
                    album.photos?.append(model)
                }
            })
            self.albumsModel = albumsModel
            self.profilesModelSubject.onNext(.next((.refreshData, self.profilesModel)))
        }
    }

    func resetRepository() {
        albumsModel = nil
        profilesModel = []
    }
}

extension TBMyPhotosRepository {
    enum AlbumType: String {
        case pregnant
        case child
        case toddler
    }

    enum ActionType {
        case initData
        case refreshData
    }
}
