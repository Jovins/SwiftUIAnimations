import UIKit
import SnapKit
import RxSwift
import FullStory

protocol TBPhotoIndividualViewControllerDelegate: class {
    func didDelete(photoIds: [String], showToast: Bool)
    func didMove(photoIds: [String], showToast: Bool)
}

final class TBPhotoIndividualViewController: UIViewController {
    weak var delegate: TBPhotoIndividualViewControllerDelegate?
    private enum PhotoIndividualCellType: Int {
        case name = 0
        case type
        case time
        case description
    }
    private lazy var currentPhotoAlbum: [TBPhotosModel] = {
        switch albumModel.albumType {
        case .pregnant:
            return albumModel.pregnancyPhotos
        case .child:
            return albumModel.childPhotos
        case .toddler:
            return albumModel.toddlerPhotos.flatMap({ $0 })
        default:
            return []
        }
    }()
    private var albumModel: TBAlbumModel
    private var photosModel: TBPhotosModel
    private var profilesModel: [TBAlbumsProfileModel]
    private var currentPhotoModel: TBPhotoModel?
    private var index: Int = -1
    private var indexPath: IndexPath = IndexPath(item: 0, section: 0) {
        didSet {
            scrollToCurrentIndexPath()
            reloadIndividualMessage()
        }
    }

    var photoEditor: TBEditPhotoViewController?
    private let networkHelper = TBMyPhotosNetworkHelper()
    private let disposed = DisposeBag()

    private lazy var toolbar: TBManagePhotosToolbar = {
        let bar = TBManagePhotosToolbar()
        bar.isEditing = true
        bar.isEnabled = true
        bar.delegate = self
        return bar
    }()

    private let individualTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TBPhotoEditorInfomationCell.self)
        tableView.register(TBPhotoEditorInputDescriptionCell.self)
        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tableView
    }()

    private let photosHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray300
        return view
    }()

    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: UIDevice.width), collectionViewLayout: layout)
        collectionView.register(TBPhotoIndividualPhotoCell.self)
        collectionView.register(TBPhotoAddPhotoCell.self)
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    private let loadingHUD: TBLoadingHUD = TBLoadingHUD()
    private var showShadow: Bool {
        let contentHeight: CGFloat = UIDevice.width + 2 * TBPhotoEditorInfomationCell.twoLinesCellHeight +
                                     TBPhotoEditorInfomationCell.oneLineCellHeight +
                                     TBPhotoEditorInputDescriptionCell.cellHeight(with: currentPhotoModel?.caption)
        let normalHeight = view.bounds.height - TBManagePhotosToolbar.toolbarHeight - 20
        return contentHeight > normalHeight
    }

    init(with albumModel: TBAlbumModel, photosModel: TBPhotosModel, profilesModel: [TBAlbumsProfileModel], index: Int, currentPhotoModel: TBPhotoModel) {
        self.albumModel = albumModel
        self.photosModel = photosModel
        self.profilesModel = profilesModel
        self.currentPhotoModel = currentPhotoModel

        super.init(nibName: nil, bundle: nil)
        guard let section = fetchSection(photoModel: currentPhotoModel) else { return }
        self.indexPath = IndexPath(item: index, section: section)
    }

    private func fetchSection(photoModel: TBPhotoModel) -> Int? {
        switch albumModel.albumType {
        case .pregnant:
            return currentPhotoAlbum.firstIndex(where: { $0.week == photoModel.week })
        case .child:
            return currentPhotoAlbum.firstIndex(where: { $0.week == photoModel.week })
        case .toddler:
            return currentPhotoAlbum.firstIndex(where: {
                guard let year = photoModel.year else { return false }
                return year > 2 ? $0.year == photoModel.year : $0.year == photoModel.year && $0.month == photoModel.month
            })
        default:
            return nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: false)

        setupPhotosHeader()
        reloadIndividualMessage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolbar.showShadow = showShadow
    }

    private func setup() {
        setupCloseButton()
        [individualTableView, toolbar].forEach(view.addSubview)
        setupTableView()
        setupBottomBar()
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(TBIconList.close.image(), for: .normal)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    private func setupTableView() {
        individualTableView.delegate = self
        individualTableView.dataSource = self
        individualTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(TBManagePhotosToolbar.toolbarHeight)
        }
    }

    private func setupBottomBar() {
        toolbar.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(TBManagePhotosToolbar.toolbarHeight)
        }
    }

    private func setupPhotosHeader() {
        individualTableView.tableHeaderView = photosHeader
        photosHeader.frame = CGRect(x: 0, y: 0, width: UIDevice.width, height: UIDevice.width + 16)

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosHeader.addSubview(photosCollectionView)
        photosCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
        scrollToCurrentIndexPath()
    }

    private func scrollToCurrentIndexPath() {
        photosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

    private func albumTypeName() -> String {
        switch albumModel.albumType {
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

    private func reloadIndividualMessage() {
        if let photosModel = currentPhotoAlbum[safe: indexPath.section] {
            currentPhotoModel = photosModel.photos[safe: indexPath.item]
            reloadTitle()
        }
        updateTableHeaderViewBackgroundColor()
        reloadToolBar()
        individualTableView.reloadData()
        photosCollectionView.reloadData()
    }

    private func reloadTitle() {
        guard let photosModel = currentPhotoAlbum[safe: indexPath.section] else { return }
        var titleString = ""
        if let year = photosModel.year, year > 2 {
            titleString = "\(year) Years"
        } else if let month = photosModel.month {
            titleString = "Month \(month)"
        } else if let week = photosModel.week {
            let prefix = (week==0) ? "NewBorn" : "Week \(week)"
            titleString = "\(prefix)"
        }
        let index = indexPath.item + 1
        let total = photosModel.photos.count
        let detail = "\(index) of \(total)"
        if !photosModel.photos.isEmpty {
            titleString.isEmpty ? titleString.append(detail) : titleString.append(", \(detail)")
        }
        title = titleString
    }

    private func updateTableHeaderViewBackgroundColor() {
        photosHeader.backgroundColor = currentPhotoModel == nil ? .OffWhite : .DarkGray300
    }

    private func reloadToolBar() {
        toolbar.isEnabled = currentPhotoModel != nil
    }

    private func updatePhotos(photoIds: [String]? = nil,
                              photoModel: TBPhotoModel? = nil,
                              toSection: Int? = nil,
                              toPhotosModel: TBPhotosModel? = nil,
                              toAlbumId: String? = nil,
                              action: PhotoUpdateAction) {
        // handle data
        switch action {
        case .edit:
            break
        case .move:
            removeCurrentPhotoModel()
            if let toSection = toSection, let photoModel = currentPhotoModel {
                insertPhoto(photoModel: photoModel, toSection: toSection)
            } else if let toPhotosModel = toPhotosModel, let photoModel = currentPhotoModel {
                insertPhoto(photoModel: photoModel, toPhotosModel: toPhotosModel)
            }
            guard let photoIds = photoIds else { return }
            delegate?.didMove(photoIds: photoIds, showToast: false)
        case .delete:
            removeCurrentPhotoModel()
            guard let photoIds = photoIds else { return }
            delegate?.didDelete(photoIds: photoIds, showToast: false)
        case .upload:
            if let photoModel = photoModel, let toSection = toSection {
                insertPhoto(photoModel: photoModel, toSection: toSection)
                indexPath = IndexPath(item: 0, section: toSection)
            }
            TBMyPhotosRepository.shared.uploadPhotoModel(model: photoModel, albumId: toAlbumId)
        }
        // reload
        reloadIndividualMessage()
        // toast
        let tips = action.tips
        TBToastView().display(attributedText: tips.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                              on: self.view,
                              bottomSpacing: self.toolbar.height())
    }

    private func removeCurrentPhotoModel() {
        guard let photosModel = currentPhotoAlbum[safe: indexPath.section] else { return }
        photosModel.photos.remove(at: indexPath.item)
        if indexPath.item >= photosModel.photos.count && !photosModel.photos.isEmpty {
            indexPath.item = photosModel.photos.count - 1
        }
    }

    private func insertPhoto(photoModel: TBPhotoModel, toSection: Int) {
        guard let photosModel = currentPhotoAlbum[safe: toSection] else { return }
        insertPhoto(photoModel: photoModel, toPhotosModel: photosModel)
    }

    private func insertPhoto(photoModel: TBPhotoModel, toPhotosModel: TBPhotosModel) {
        toPhotosModel.photos.insert(photoModel, at: 0)
    }

    private func movePhotos() {
        guard let photoId = currentPhotoModel?.id else { return }
        let movePhotoVC = TBMovePhotosViewController()
        movePhotoVC.modalPresentationStyle = .fullScreen
        movePhotoVC.photoIds = [String(photoId)]
        movePhotoVC.profilesModel = profilesModel
        movePhotoVC.delegate = self
        AppRouter.shared.navigator.present(movePhotoVC)
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

extension TBPhotoIndividualViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch PhotoIndividualCellType(rawValue: indexPath.row) {
        case .name:
            return TBPhotoEditorInfomationCell.twoLinesCellHeight
        case .type:
            return TBPhotoEditorInfomationCell.twoLinesCellHeight
        case .time:
            return TBPhotoEditorInfomationCell.oneLineCellHeight
        case .description:
            return TBPhotoEditorInputDescriptionCell.cellHeight(with: currentPhotoModel?.caption)
        default:
            return 0
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distance = scrollView.contentSize.height - scrollView.contentOffset.y
        if distance <= scrollView.frame.size.height {
            toolbar.showShadow = false
        } else {
            toolbar.showShadow = showShadow
        }
    }
}

extension TBPhotoIndividualViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let photosModel = currentPhotoAlbum[safe: indexPath.section],
              !photosModel.photos.isEmpty else { return 0 }
        guard let description = currentPhotoModel?.caption?.trimmingCharacters(in: .whitespacesAndNewlines), description.count > 0 else {
            return 3
        }
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard currentPhotoModel != nil else { return cell }
        switch PhotoIndividualCellType(rawValue: indexPath.row) {
        case .name:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInfomationCell.self, for: indexPath) { [weak self] cell in
                guard let self = self else { return }
                cell.setupTwoLinesContentCell(title: "Album Name:", content: self.albumModel.name?.capitalized ?? "")
                cell.maskContent()
            }
        case .type:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInfomationCell.self, for: indexPath) { [weak self] cell in
                guard let self = self else { return }
                cell.setupTwoLinesContentCell(title: "Album Type:", content: self.albumTypeName())
                cell.maskContent(false)
            }
        case .time:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInfomationCell.self, for: indexPath) { [weak self] cell in
                guard let self = self,
                      let type = self.albumModel.albumType,
                      let model = currentPhotoModel
                else { return }
                switch type {
                case .child:
                    guard let week = model.week else { return }
                    cell.setupOneLineContentCell(prefix: "Week", time: week==0 ? "NewBorn" : "\(week)")
                case .pregnant:
                    guard let week = model.week else { return }
                    cell.setupOneLineContentCell(prefix: "Week", time: "\(week)")
                case .toddler:
                    if let year = model.year, year > 2 {
                        cell.setupOneLineContentCell(prefix: "Year", time: "\(year)")
                    } else if let month = model.month {
                        cell.setupOneLineContentCell(prefix: "Month", time: "\(month)")
                    } else if let week = model.week {
                        cell.setupOneLineContentCell(prefix: "Week", time: "\(week)")
                    }
                }
                cell.maskContent(false)
            }
        case .description:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInputDescriptionCell.self, for: indexPath) { [weak self] cell in
                guard let self = self,
                        let model = currentPhotoModel,
                        let text = model.caption else {
                    cell.readOnly(text: "", isShow: false)
                    return
                }
                cell.readOnly(text: text, isShow: true)
            }
        default:
            cell.backgroundColor = .yellow
        }
        return cell
    }
}

extension TBPhotoIndividualViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIDevice.width, height: UIDevice.width)
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

extension TBPhotoIndividualViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentPhotoAlbum.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photosModel = currentPhotoAlbum[safe: section] else { return 0 }
        return photosModel.photos.isEmpty ? 1 : photosModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photosModel = currentPhotoAlbum[safe: indexPath.section] else { return UICollectionViewCell() }
        if photosModel.photos.isEmpty {
            let cell: TBPhotoAddPhotoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            return cell
        } else {
            guard let photoModel = photosModel.photos[safe: indexPath.item],
                  let mediumUrl = photoModel.variantURLs?.medium else { return UICollectionViewCell() }
            let cell: TBPhotoIndividualPhotoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setupCell(urlString: mediumUrl)
            return cell
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == photosCollectionView else { return }
        let offsetX = scrollView.contentOffset.x
        let calculateIndex = Int(abs(offsetX / UIDevice.width))

        index = calculateIndex
        indexPath = fetchIndexPath(fromIndex: calculateIndex)
    }

    private func fetchIndexPath(fromIndex index: Int) -> IndexPath {
        var indexPath = IndexPath(item: 0, section: 0)
        var total: Int = index + 1
        for (section, photosModel) in currentPhotoAlbum.enumerated() {
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

extension TBPhotoIndividualViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photosModel = currentPhotoAlbum[safe: indexPath.section],
              !photosModel.photos.isEmpty else { return }
        let vc = TBPhotoBrowserViewController(albumModel: albumModel, photoAlbum: currentPhotoAlbum, indexPath: indexPath, index: index)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(vc)
    }
}

extension TBPhotoIndividualViewController: TBPhotoAddPhotoCellDelegate {
    func addPhotoCellDidClickAddPhotoButton() {
        let vc = CameraLibraryMultiAlbumViewController()
        vc.delegate = self
        let libraryNav = UINavigationController(rootViewController: vc)
        libraryNav.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(libraryNav)
    }
}

// MARK: - CameraLibraryViewControllerDelegate
extension TBPhotoIndividualViewController: CameraLibraryViewControllerDelegate {
    func didFinishPickingMedia(viewController: UIViewController, imageTaken: UIImage, isFromSavedImage: Bool) {
        viewController.dismiss(animated: false, completion: { [self] in
            let weekDataSource = currentPhotoAlbum.compactMap { $0.week }
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
                              currentWeek: currentPhotoAlbum[safe: indexPath.section]?.week)
            case .child:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel.id,
                              albumName: albumModel.name,
                              albumType: albumModel.albumType,
                              weeks: weekDataSource,
                              currentWeek: currentPhotoAlbum[safe: indexPath.section]?.week)
            case .toddler:
                vc.setupModel(image: imageTaken,
                              albumID: albumModel.id,
                              albumName: albumModel.name,
                              albumType: albumModel.albumType,
                              currentMonth: currentPhotoAlbum[safe: indexPath.section]?.month,
                              currentYear: currentPhotoAlbum[safe: indexPath.section]?.year)
            }
            let libraryNav = UINavigationController(rootViewController: vc)
            libraryNav.modalPresentationStyle = .fullScreen
            AppRouter.shared.navigator.present(libraryNav)
        })
    }
}

// MARK: - PhotoEditorViewControllerV2Delegate
// & TBPhotoBrowserViewControllerDelegate
extension TBPhotoIndividualViewController: TBAddPhotoViewControllerDelegate, TBPhotoBrowserViewControllerDelegate {
    func uploadPhotoModel(viewController: UIViewController, model: TBPhotoModel?, albumId: String?) {
        guard let model = model else { return }
        updatePhotos(photoModel: model, toSection: fetchSection(photoModel: model), toAlbumId: albumId, action: .upload)
    }
}

extension TBPhotoIndividualViewController: TBEditPhotoViewControllerDelegate {
    func editPhotoModel(model: TBPhotoModel?, albumId: String?) {
        guard let model = model else { return }
        let isMovedInCurrentAlbum = albumId == albumModel.id
        guard isMovedInCurrentAlbum else {
            updatePhotos(photoIds: ["\(model.id)"], action: .move)
            return
        }
        var isMoved = false
        switch albumModel.albumType {
        case .pregnant, .child:
            isMoved = model.week != currentPhotoAlbum[safe: indexPath.section]?.week
        case .toddler:
            isMoved = (model.month != currentPhotoAlbum[safe: indexPath.section]?.month) || (model.year != currentPhotoAlbum[safe: indexPath.section]?.year)
        default:
            break
        }
        if isMoved {
            updatePhotos(photoIds: ["\(model.id)"], toSection: fetchSection(photoModel: model), action: .move)
        } else {
            updatePhotos(action: .edit)
        }
    }
}

extension TBPhotoIndividualViewController: TBMovePhotosViewControllerDelegate {
    func photosDidFinishMoving(photoIds: [String], selectAlbum: TBAlbumModel?, selectPhoto: TBPhotosModel?) {
        let isMovedInCurrentAlbum = selectAlbum?.id == albumModel.id
        guard isMovedInCurrentAlbum else {
            updatePhotos(photoIds: photoIds, action: .move)
            return
        }
        var isMoved = false
        if let selectWeek = selectPhoto?.week, currentPhotoModel?.week != selectWeek {
            isMoved = true
        } else if let selectMonth = selectPhoto?.month, currentPhotoModel?.month != selectMonth {
            isMoved = true
        } else if let selectYear = selectPhoto?.year, currentPhotoModel?.year != selectYear {
            isMoved = true
        }
        if isMoved {
            updatePhotos(photoIds: photoIds, toPhotosModel: selectPhoto, action: .move)
        }
    }
}

extension TBPhotoIndividualViewController: TBManagePhotosToolbarDelegate {
    func didTapToolbarShareCTA(sender: Any) {
        guard let cell = self.photosCollectionView.cellForItem(at: indexPath) as? TBPhotoIndividualPhotoCell,
              let image = cell.imageView.image else { return }
        TBShareManager.shared.presentSocialService(type: .system, sender: sender, items: [image]) { [self] in
            let attrString = NSMutableAttributedString(string: "Photo has been shared.", attributes: [.foregroundColor: UIColor.OffWhite, .font: TBFontType.mulishBody3.font])
            TBToastView().display(attributedText: attrString, on: view, bottomSpacing: self.toolbar.height())
            TBAnalyticsManager.trackSharePhoto(userDecisionArea: "photo detail page")
        }
    }

    func didTapToolbarManageCTA(sender: Any) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let moveAction = UIAlertAction(title: "Move Photo", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.movePhotos()
        }
        let downloadAction = UIAlertAction(title: "Download Photo", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.checkPermissions(with: .downloadPhotos) { isAuthorized in
                guard isAuthorized else { return }
                self.loadingHUD.show()
                TBPhotoDownloadManager.shared.downloadPhotosToAlbum(urls: [self.currentPhotoModel?.variantURLs?.medium ?? ""]) { allSuccess, _ in
                    self.loadingHUD.dismiss()
                    if allSuccess {
                        let message = "Photo has been downloaded."
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
        let deleteAction = UIAlertAction(title: "Delete Photo", style: .destructive) { [weak self] _ in
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

    func didTapToolbarEditCTA() {
        photoEditor = TBEditPhotoViewController()
        photoEditor?.delegate = self
        guard let vc = photoEditor else { return }
        guard let cell = self.photosCollectionView.cellForItem(at: indexPath) as? TBPhotoIndividualPhotoCell,
              let image = cell.imageView.image,
              let photosModel = currentPhotoAlbum[safe: indexPath.section],
              let photoModel = currentPhotoModel else { return }
        let profileModel = profilesModel.first(where: {$0.albums?.contains(albumModel) ?? false})
        vc.viewModel.setupModel(image: image,
                      profilesModel: profilesModel,
                      profileModel: profileModel,
                      albumModel: albumModel,
                      photosModel: photosModel,
                      photoModel: photoModel)
        let libraryNav = UINavigationController(rootViewController: vc)
        libraryNav.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(libraryNav)
    }

    private func deleteAlbumPhotos() {
        let alertVC = UIAlertController(title: nil, message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
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
        guard let albumId = albumModel.id,
              let photoModel = currentPhotoModel,
              let photoId = photoModel.id
        else { return }
        loadingHUD.show()
        networkHelper.removePhotos(albumId: albumId, photoIds: ["\(photoId)"]).observeOn(MainScheduler.instance).subscribe { [weak self] (response) in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            guard "\(response.statusCode)".hasPrefix("2") else { return }
            self.updatePhotos(photoIds: ["\(photoId)"], action: .delete)
            TBAnalyticsManager.trackDeletePhoto(userDecisionArea: "photo detail page")
        } onError: { [weak self] _ in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            TBErrorToastView.showErrorMessageToTopVC(message: "An error occurred. Please try again or contact us if the problem persists.".attributedText(.mulishBody3))
        }.disposed(by: disposed)
    }
}

extension TBPhotoIndividualViewController {
    enum PhotoUpdateAction {
        case edit
        case move
        case delete
        case upload

        var tips: String {
            switch self {
            case .edit:
                return "Photo has been edited."
            case .move:
                return "Photo has been moved."
            case .delete:
                return "Photo has been deleted."
            case .upload:
                return "Photo has been uploaded."
            }
        }
    }
}
