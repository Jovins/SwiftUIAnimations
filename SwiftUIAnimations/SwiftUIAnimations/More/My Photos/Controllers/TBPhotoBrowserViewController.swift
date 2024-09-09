import UIKit

protocol TBPhotoBrowserViewControllerDelegate: class {
    func uploadPhotoModel(viewController: UIViewController, model: TBPhotoModel?, albumId: String?)
}

class TBPhotoBrowserViewController: UIViewController {
    weak var delegate: TBPhotoBrowserViewControllerDelegate?
    private var albumModel: TBAlbumModel
    private var photoAlbum: [TBPhotosModel]
    private var index: Int
    private var indexPath: IndexPath

    private lazy var photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(TBPhotoBrowserPhotoCell.self)
        collectionView.register(TBPhotoAddPhotoCell.self)
        return collectionView
    }()

    init(albumModel: TBAlbumModel, photoAlbum: [TBPhotosModel], indexPath: IndexPath, index: Int) {
        self.albumModel = albumModel
        self.photoAlbum = photoAlbum
        self.indexPath = indexPath
        self.index = index
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        scrollToCurrentIndexPath()
    }

    private func setup() {
        self.view.addSubview(photosCollectionView)
        photosCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func scrollToCurrentIndexPath() {
        photosCollectionView.layoutIfNeeded()
        photosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}

extension TBPhotoBrowserViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoAlbum.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photosModel = photoAlbum[safe: section] else { return 0 }
        return photosModel.photos.isEmpty ? 1 : photosModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photosModel = photoAlbum[safe: indexPath.section] else { return UICollectionViewCell() }
        if photosModel.photos.isEmpty {
            let cell: TBPhotoAddPhotoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            return cell
        } else {
            guard let photoModel = photosModel.photos[safe: indexPath.item],
                  let mediumUrl = photoModel.variantURLs?.medium else { return UICollectionViewCell() }
            let cell: TBPhotoBrowserPhotoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setupCell(urlString: mediumUrl)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TBPhotoBrowserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == photosCollectionView else { return }
        let offsetX = scrollView.contentOffset.x
        let calculateIndex = Int(abs(offsetX / UIDevice.width))

        guard index != calculateIndex else { return }
        index = calculateIndex
        indexPath = fetchIndexPath(fromIndex: calculateIndex)
    }

    private func fetchIndexPath(fromIndex index: Int) -> IndexPath {
        var indexPath = IndexPath(item: 0, section: 0)
        var total: Int = index + 1
        for (section, photosModel) in photoAlbum.enumerated() {
            indexPath.section = section
            if total <= 0 { return indexPath }
            if photosModel.photos.isEmpty {
                indexPath.item = 0
                total -= 1
                if total <= 0 { return indexPath }
            }
            for (item, photoModel) in photosModel.photos.enumerated() {
                indexPath.item = item
                total -= 1
                if total <= 0 { return indexPath }
            }
        }
        return indexPath
    }
}

// MARK: - TBPhotoAddPhotoCellDelegate
extension TBPhotoBrowserViewController: TBPhotoAddPhotoCellDelegate {
    func addPhotoCellDidClickAddPhotoButton() {
        let vc = CameraLibraryMultiAlbumViewController()
        vc.delegate = self
        let libraryNav = UINavigationController(rootViewController: vc)
        libraryNav.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(libraryNav)
    }
}

// MARK: - CameraLibraryViewControllerDelegate
extension TBPhotoBrowserViewController: CameraLibraryViewControllerDelegate {
    func didFinishPickingMedia(viewController: UIViewController, imageTaken: UIImage, isFromSavedImage: Bool) {
        viewController.dismiss(animated: false, completion: { [self] in
            let weekDataSource = photoAlbum.compactMap { $0.week }
            let vc = TBAddPhotoViewController()
            vc.delegate = self
            guard let albumType = albumModel.albumType else { return }
            switch albumType {
            case .pregnant:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel.id,
                              albumName: albumModel.name,
                              albumType: albumModel.albumType,
                              weeks: weekDataSource,
                              currentWeek: photoAlbum[safe: indexPath.section]?.week)
            case .child:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel.id,
                              albumName: albumModel.name,
                              albumType: albumModel.albumType,
                              weeks: weekDataSource,
                              currentWeek: photoAlbum[safe: indexPath.section]?.week)
            case .toddler:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel.id,
                              albumName: albumModel.name,
                              albumType: albumModel.albumType,
                              currentMonth: photoAlbum[safe: indexPath.section]?.month,
                              currentYear: photoAlbum[safe: indexPath.section]?.year)
            }
            let libraryNav = UINavigationController(rootViewController: vc)
            libraryNav.modalPresentationStyle = .fullScreen
            AppRouter.shared.navigator.present(libraryNav)
        })
    }
}

// MARK: - PhotoEditorViewControllerDelegate
extension TBPhotoBrowserViewController: TBAddPhotoViewControllerDelegate {
    func uploadPhotoModel(viewController: UIViewController, model: TBPhotoModel?, albumId: String?) {
        guard let model = model else { return }
        self.dismiss(animated: true) {
            self.delegate?.uploadPhotoModel(viewController: viewController, model: model, albumId: albumId)
        }
    }
}

extension TBPhotoBrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIDevice.width, height: self.view.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
