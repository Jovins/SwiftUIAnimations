import UIKit
import SnapKit
import RxSwift
import FullStory

protocol TBManagePhotosViewControllerDelegate: NSObjectProtocol {
    func photosDidFinishDeleting(photos: [String])
    func movePhotosDidFinish()
}

final class TBManagePhotosViewController: UIViewController {

    var albumModel: TBAlbumModel?
    var profilesModel: [TBAlbumsProfileModel]?
    var photosModel: TBPhotosModel? {
        didSet {
            guard let model = photosModel else { return }
            week = model.week ?? 0
            month = model.month
            year = model.year
        }
    }
    private var photos: [TBPhotoModel] {
        guard let photos = photosModel?.photos else {
            return []
        }
        return photos
    }
    weak var delegate: TBManagePhotosViewControllerDelegate?
    private var week: Int = 0
    private var month: Int?
    private var year: Int?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .GlobalBackgroundPrimary
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 20, bottom: 36, right: 20)
        collectionView.register(TBManagePhotosCollectionViewCell.self)
        collectionView.register(TBManagePhotosAddCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    private let selectCTA: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 32)))
        button.setAttributedTitle("Select".attributedText(.mulishLink3, foregroundColor: .DarkGray400), for: .disabled)
        button.setAttributedTitle("Select".attributedText(.mulishLink3), for: .normal)
        button.setAttributedTitle("Cancel".attributedText(.mulishLink3), for: .selected)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        return button
    }()
    private let selectAllCTA: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 32)))
        button.setAttributedTitle("Select All".attributedText(.mulishLink3), for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        return button
    }()
    private lazy var toolbar: TBManagePhotosToolbar = {
        let bar = TBManagePhotosToolbar()
        bar.isEditing = false
        bar.delegate = self
        bar.isHidden = true
        return bar
    }()
    private var showShadow: Bool {
        let normalHeight = view.bounds.height - TBManagePhotosToolbar.toolbarHeight
        return collectionView.contentSize.height > normalHeight
    }
    private let loadingHUD: TBLoadingHUD = TBLoadingHUD()
    private var isEditState: Bool = false
    private var selectedIndexPaths: Set<IndexPath> = []
    private var collectionViewBottomConstraint: Constraint?
    private let networkHelper = TBMyPhotosNetworkHelper()
    private let disposed = DisposeBag()

    var cameraLibraryController: CameraLibraryMultiAlbumViewController?
    var photoEditor: TBAddPhotoViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.isEnabled = !photos.isEmpty
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolbar.showShadow = showShadow
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectCTA)
        selectAllCTA.addTarget(self, action: #selector(didTapSelectAllCTA), for: .touchUpInside)
        selectCTA.addTarget(self, action: #selector(didTapSelectCTA(sender:)), for: .touchUpInside)
        [collectionView, toolbar].forEach(view.addSubview)
        collectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            collectionViewBottomConstraint = $0.bottom.equalToSuperview().offset(0).constraint
        }
        toolbar.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    @objc private func didTapSelectCTA(sender: UIButton) {
        reset(isSelected: sender.isSelected)
    }

    @objc private func didTapSelectAllCTA() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.photos.enumerated().forEach { (index, _) in
                self.selectedIndexPaths.insert(IndexPath(item: index + 1, section: 0))
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.toolbar.isEnabled = !self.selectedIndexPaths.isEmpty
            }
        }
    }

    private func bindData() {
        TBMyPhotosRepository.shared.profilesModelSubject.observeOn(MainScheduler.instance).subscribe {[weak self] _ in
            guard let self = self else { return }
            switch self.albumModel?.albumType {
            case .pregnant:
                self.photosModel = self.albumModel?.pregnancyPhotos.first(where: {$0.week == self.photosModel?.week})
            case .child:
                self.photosModel = self.albumModel?.childPhotos.first(where: {$0.week == self.photosModel?.week})
            case .toddler:
                self.photosModel = self.albumModel?.toddlerPhotos.flatMap({ $0 }).first(where: {
                    guard let year = self.photosModel?.year else { return false }
                    return year > 2 ? $0.year == self.photosModel?.year : $0.year == self.photosModel?.year && $0.month == self.photosModel?.month
                })
            default:
                break
            }
        } onError: { _ in
        }.disposed(by: disposed)
    }

    private func reset(isSelected: Bool = true) {
        selectCTA.isSelected = !isSelected
        isEditState = selectCTA.isSelected
        navigationItem.leftBarButtonItem = isEditState ? UIBarButtonItem(customView: selectAllCTA) : nil
        tabBarController?.setTabBarVisible(!isEditState, animated: true)
        UIView.animate(withDuration: 0.5) {
            self.toolbar.isHidden = !self.isEditState
            self.collectionViewBottomConstraint?.update(offset: self.isEditState ? -TBManagePhotosToolbar.toolbarHeight : 0)
        }
        toolbar.isEnabled = false
        selectedIndexPaths.removeAll()
        navigationItem.rightBarButtonItem?.isEnabled = !photos.isEmpty
        collectionView.reloadData()
    }

    private func addPhoto() {
        cameraLibraryController = CameraLibraryMultiAlbumViewController()
        guard let vc = cameraLibraryController else { return }
        vc.delegate = self
        let libraryNav = UINavigationController(rootViewController: vc)
        libraryNav.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(libraryNav)
    }

    private func showPhoto(row: Int) {
        guard let albumModel = albumModel,
              let photosModel = photosModel,
              let profilesModel = profilesModel,
              let photoModel = photos[safe: row] else { return }
        let individualViewController = TBPhotoIndividualViewController(with: albumModel, photosModel: photosModel, profilesModel: profilesModel, index: row, currentPhotoModel: photoModel)
        individualViewController.delegate = self
        let navVC = UINavigationController(rootViewController: individualViewController)
        navVC.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(navVC)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBManagePhotosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 106)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TBManagePhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row != 0 else {
            let cell: TBManagePhotosAddCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.isEditState = isEditState
            return cell
        }
        let cell: TBManagePhotosCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if let photo = photos[safe: indexPath.row - 1] {
            cell.setupPhoto(photo: photo, isEditState: isEditState)
            cell.isSelecting = selectedIndexPaths.contains(indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditState else {
            if indexPath.row > 0,
               let cell = collectionView.cellForItem(at: indexPath) as? TBManagePhotosCollectionViewCell {

                cell.isSelecting = !selectedIndexPaths.contains(indexPath)
                if selectedIndexPaths.contains(indexPath) {
                    selectedIndexPaths.remove(indexPath)
                } else {
                    selectedIndexPaths.insert(indexPath)
                }
                toolbar.isEnabled = !selectedIndexPaths.isEmpty
            }
            return
        }
        (indexPath.row != 0) ? showPhoto(row: indexPath.row - 1) : addPhoto()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distance = scrollView.contentSize.height - scrollView.contentOffset.y + 20
        if distance <= scrollView.frame.size.height {
            toolbar.showShadow = false
        } else {
            toolbar.showShadow = showShadow
        }
    }
}

// MARK: - TBManagePhotosToolbarDelegate
extension TBManagePhotosViewController: TBManagePhotosToolbarDelegate {

    func didTapToolbarShareCTA(sender: Any) {
        var images = [UIImage]()
        selectedIndexPaths.forEach { [weak self] indexPath in
            guard let self = self, let cell = self.collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? TBManagePhotosCollectionViewCell,
            let image = cell.photoImageView.image else { return }
            images.append(image)
        }
        TBShareManager.shared.presentSocialService(type: .system, sender: sender, items: images) {
            let shareString = "Photo".pluralize(with: self.selectedIndexPaths.count) + (self.selectedIndexPaths.count > 1 ? " have " : " has ") + "been shared."
            self.reset()
            TBToastView().display(attributedText: shareString.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                                  on: self.view)
            TBAnalyticsManager.trackSharePhoto(userDecisionArea: "week photo page")
        }
    }

    func didTapToolbarManageCTA(sender: Any) {
        let photoString = "Photo".pluralize(with: selectedIndexPaths.count)
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let moveAction = UIAlertAction(title: "Move \(photoString)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.movePhotos()
        }
        let downloadAction = UIAlertAction(title: "Download \(photoString)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.checkPermissions(with: .downloadPhotos) { isAuthorized in
                guard isAuthorized else { return }
                self.loadingHUD.show()
                var urls: [String] = []
                self.selectedIndexPaths.forEach { indexPath in
                    if let photo = self.photos[safe: indexPath.row - 1],
                       let url = photo.variantURLs?.medium {
                        urls.append(url)
                    }
                }
                TBPhotoDownloadManager.shared.downloadPhotosToAlbum(urls: urls) { allSuccess, _ in
                    self.loadingHUD.dismiss()
                    if allSuccess {
                        let haveOrHas = urls.count > 1 ? "have" : "has"
                        let message = "\("Photo".pluralize(with: urls.count)) \(haveOrHas) been downloaded."
                        TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                                              on: self.view,
                                              bottomSpacing: self.toolbar.height())
                    } else {
                        let message = "An error occurred. Please try again or contact us if the problem persists."
                        TBErrorToastView.showErrorMessageToTopVC(message: message.attributedText(.mulishBody3))
                    }
                }
            }
        }
        let deleteAction = UIAlertAction(title: "Delete \(photoString)", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteAlbumPhotos()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(moveAction)
        alertVC.addAction(downloadAction)
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        if let popoverController = alertVC.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(alertVC)
    }

    private func deleteAlbumPhotos() {
        let photoString = "photo".pluralize(with: selectedIndexPaths.count)
        let thisString = selectedIndexPaths.count > 1 ? "these" : "this"
        let alertVC = UIAlertController(title: nil, message: "Are you sure you want to delete \(thisString) \(photoString)?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deletePhotos()
        }
        alertVC.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertVC.addAction(cancelAction)
        alertVC.preferredAction = cancelAction
        present(alertVC, animated: true)
        FS.unmask(views: alertVC.view)
    }

    private func deletePhotos() {
        guard let albumId = albumModel?.id else { return }
        let photoIds: [String] = selectedIndexPaths.sorted(by: { $1.section > $0.section || $1.row < $0.row }).compactMap { [weak self] indexPath -> String? in
            guard let self = self, let photo = self.photos[safe: indexPath.row - 1], let id = photo.id else { return nil }
            if let model = photosModel {
                model.photos.remove(at: indexPath.row - 1)
                self.photosModel = model
            }
            return String(id)
        }
        loadingHUD.show()
        networkHelper.removePhotos(albumId: albumId, photoIds: photoIds).observeOn(MainScheduler.instance).subscribe { [weak self] (response) in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            guard "\(response.statusCode)".hasPrefix("2") else { return }
            self.reset()
            self.collectionView.reloadData()
            self.delegate?.photosDidFinishDeleting(photos: photoIds)
            let message = (photoIds.count > 1) ? "Photos have been deleted." : "Photo has been deleted."
            TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                                  on: self.view)
            TBAnalyticsManager.trackDeletePhoto(userDecisionArea: "week photo page")
        } onError: { [weak self] _ in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            TBErrorToastView.showErrorMessageToTopVC(message: "An error occurred. Please try again or contact us if the problem persists.".attributedText(.mulishBody3))
        }.disposed(by: disposed)
    }

    private func movePhotos() {
        let photoIds: [String] = selectedIndexPaths.sorted(by: { $1.section > $0.section || $1.row < $0.row }).compactMap { [weak self] indexPath -> String? in
            guard let self = self, let photo = self.photos[safe: indexPath.row - 1], let id = photo.id else { return nil }
            return String(id)
        }
        let movePhotoVC = TBMovePhotosViewController()
        movePhotoVC.modalPresentationStyle = .fullScreen
        movePhotoVC.photoIds = photoIds
        movePhotoVC.profilesModel = profilesModel
        movePhotoVC.delegate = self
        AppRouter.shared.navigator.present(movePhotoVC)
    }
}

// MARK: CameraLibraryViewControllerDelegate
extension TBManagePhotosViewController: CameraLibraryViewControllerDelegate {
    func didFinishPickingMedia(viewController: UIViewController, imageTaken: UIImage, isFromSavedImage: Bool) {
        cameraLibraryController?.dismiss(animated: false, completion: { [self] in
            var weekDataSource = [Int]()
            var albumModels: [TBPhotosModel]?
            if let album = albumModel,
               let albumType = album.albumType {
                switch albumType {
                case .pregnant:
                    albumModels = album.pregnancyPhotos
                case .child:
                    albumModels = album.childPhotos
                case .toddler:
                    break
                }
            }
            albumModels?.forEach({ model in
                if let week = model.week {
                    weekDataSource.append(week)
                }
            })

            photoEditor = TBAddPhotoViewController()
            photoEditor?.delegate = self
            guard let vc = photoEditor,
                  let albumType = albumModel?.albumType else { return }
            switch albumType {
            case .pregnant, .child:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel?.id,
                              albumName: albumModel?.name,
                              albumType: albumModel?.albumType,
                            weeks: weekDataSource,
                            currentWeek: week)
            case .toddler:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel?.id,
                              albumName: albumModel?.name,
                              albumType: albumModel?.albumType,
                              currentMonth: month,
                              currentYear: year)
            }
            let libraryNav = UINavigationController(rootViewController: vc)
            libraryNav.modalPresentationStyle = .fullScreen
            AppRouter.shared.navigator.present(libraryNav)
        })
    }
}

// MARK: - PhotoEditorViewControllerV2Delegate
extension TBManagePhotosViewController: TBAddPhotoViewControllerDelegate {
    func uploadPhotoModel(viewController: UIViewController, model: TBPhotoModel?, albumId: String?) {
        guard let model = model else { return }
        if let photosModel = photosModel, shouldInsertPhoto(model: model) {
            photosModel.photos.insert(model, at: 0)
            self.photosModel = photosModel
            collectionView.reloadData()
        }
        TBToastView().display(attributedText: ("Photo has been uploaded.").attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                              on: self.view)
        TBMyPhotosRepository.shared.uploadPhotoModel(model: model, albumId: albumId)
    }

    private func shouldInsertPhoto(model: TBPhotoModel) -> Bool {
        if week == model.week {
            return true
        } else if let month = month {
            return month == model.month && year == model.year
        } else if let year = year {
            return year == model.year
        } else {
            return false
        }
    }

    private func shouldRemovePhoto(model: TBPhotosModel) -> Bool {
        if let selectWeek = model.week {
            return week != model.week
        } else if let month = month {
            return month != model.month || year != model.year
        } else if let year = year {
            return year != model.year
        } else {
            return false
        }
    }
}

// MARK: - TBMovePhotosViewControllerDelegate
extension TBManagePhotosViewController: TBMovePhotosViewControllerDelegate {

    func photosDidFinishMoving(photoIds: [String], selectAlbum: TBAlbumModel?, selectPhoto: TBPhotosModel?) {
        if selectAlbum?.id != albumModel?.id {
            updatePhotosData(photoIds: photoIds)
        } else if selectAlbum?.albumType != albumModel?.albumType {
            updatePhotosData(photoIds: photoIds)
        } else if let selectPhoto = selectPhoto, shouldRemovePhoto(model: selectPhoto) {
            updatePhotosData(photoIds: photoIds)
        }
        reset()
    }

    private func updatePhotosData(photoIds: [String]) {
        guard let model = photosModel else { return }
        photoIds.forEach { id in
            guard let index = model.photos.firstIndex(where: { $0.id == Int(id) }) else { return }
            model.photos.remove(at: index)
        }
        photosModel = model
        collectionView.reloadData()
        delegate?.movePhotosDidFinish()
        let message = (photoIds.count > 1) ? "Photos have been moved." : "Photo has been moved."
        TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                              on: self.view)
    }
}

extension TBManagePhotosViewController: TBPhotoIndividualViewControllerDelegate {
    func didDelete(photoIds: [String], showToast: Bool) {
        collectionView.reloadData()
        delegate?.photosDidFinishDeleting(photos: photoIds)
        if showToast {
            let message = (photoIds.count > 1) ? "Photos have been deleted." : "Photo has been deleted."
            TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                                  on: self.view)
        }
    }

    func didMove(photoIds: [String], showToast: Bool) {
        collectionView.reloadData()
        delegate?.movePhotosDidFinish()
        if showToast {
            let message = (photoIds.count > 1) ? "Photos have been moved." : "Photo has been moved."
            TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                                  on: self.view)
        }
    }
}
