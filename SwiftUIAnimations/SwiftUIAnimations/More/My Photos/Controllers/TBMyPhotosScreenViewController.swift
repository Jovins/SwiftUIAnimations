import Foundation
import UIKit
import SnapKit
import RxSwift
import FullStory

final class TBMyPhotosScreenViewController: UIViewController {
    private let viewModel: TBMyPhotosScreenViewModel = TBMyPhotosScreenViewModel()
    private let disposed = DisposeBag()
    private lazy var albumViews: [UICollectionView] = []
    private let headerView: UIView = UIView()
    private let itemsMenuView: TBItemsMenuView = TBItemsMenuView()
    private let stickyToddlerView: TBStickyToddlerView = {
        let view = TBStickyToddlerView()
        view.isHidden = true
        return view
    }()
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    private let caretDownImageView = UIImageView(image: TBIconList.caretDown.image(sizeOption: .small, color: UIColor.Magenta))
    private let profilePickerControl = UIControl()
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray300
        return view
    }()
    private let manageCTA: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Manage".attributedText(.mulishLink3), for: .normal)
        return button
    }()
    private let profilePickerView: TBOldPickerView = {
        let pickerView = TBOldPickerView.init(frame: UIScreen.main.bounds)
        pickerView.adapter = TBPickerDefaultAdapter()
        return pickerView
    }()
    private let yearPickerView: TBOldPickerView = {
        let pickerView = TBOldPickerView.init(frame: UIScreen.main.bounds)
        pickerView.adapter = TBPickerDefaultAdapter()
        return pickerView
    }()
    private let containerView: UIView = UIView()
    private let loadingHUD: TBLoadingHUD = TBLoadingHUD()
    private lazy var reloadView: ReloadView = {
        let reloadView = ReloadView.create(with: view.bounds, callBack: { [weak self] in
            guard let self else { return }
            self.reloadView.hide()
            self.loadingHUD.show()
            self.viewModel.fetchAlbums()
        })
        return reloadView
    }()
    private var lastSelectedIndex: Int?
    private var selectedProfileIndex = 0
    private var selectedTabIndex = 0
    private var autoSelectProfile: Bool = true
    private var selectedProfile: TBAlbumsProfileModel? {
        return viewModel.profilesModel[safe: selectedProfileIndex]
    }
    private var selectedAlbum: TBAlbumModel? {
        return selectedProfile?.albums?[safe: selectedTabIndex]
    }
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
        viewModel.bindData(repository: TBMyPhotosRepository.shared)
        viewModel.fetchAlbums()
        loadingHUD.show()
    }

    deinit {
        TBMyPhotosRepository.shared.resetRepository()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserDefaults.standard.hasSeenMyPhotos {
            UserDefaults.standard.hasSeenMyPhotos = true
            let modalView = TBModalView.build(title: "The newest version of My Photos is ready",
                                              content: "We've sorted your photos based on baby's due date and birthday, so you can easily manage all your pregnancy photos and baby pics.\r\rIf some of your photos are not appearing, try refreshing the page or reach out to us for help.",
                                              bottomCTATitle: "Got It",
                                              ctaType: .myPhotoNewVersion,
                                              delegate: self)
            modalView.unmaskModalView()
            modalView.show()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lastSelectedIndex = itemsMenuView.selectIndex
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        navigationItem.title = "My Photos"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: manageCTA)
        manageCTA.addTarget(self, action: #selector(didTapManageCTA), for: .touchUpInside)
        view.backgroundColor = .GlobalBackgroundPrimary

        [containerView, headerView].forEach(view.addSubview)
        headerView.snp.makeConstraints {
            $0.height.equalTo(93)
            $0.top.leading.trailing.equalToSuperview()
        }
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(93)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        setupHeaderView()
    }

    private func setupHeaderView() {
        let label = UILabel()
        label.attributedText = "Album Name:".attributedText(.mulishBody3)
        profilePickerControl.addTarget(self, action: #selector(showProfilePicker), for: .touchUpInside)
        itemsMenuView.delegate = self
        [label, albumNameLabel, caretDownImageView, itemsMenuView, lineView, profilePickerControl].forEach(headerView.addSubview)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(20)
            $0.size.equalTo(CGSize(width: 95, height: 20))
        }
        albumNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.leading.equalTo(label.snp.trailing).offset(4)
        }
        caretDownImageView.snp.makeConstraints {
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.leading.equalTo(albumNameLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(albumNameLabel)
            $0.size.equalTo(16)
        }
        profilePickerControl.snp.makeConstraints {
            $0.leading.centerY.equalTo(label)
            $0.trailing.equalTo(caretDownImageView)
            $0.height.equalTo(label)
        }
        itemsMenuView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(29)
        }
        lineView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        FS.mask(views: albumNameLabel)
    }

    private func setupAlbumsUI() {
        guard let albums = selectedProfile?.albums else { return }
        albumViews.forEach({$0.removeFromSuperview()})
        albumViews.removeAll()
        albums.enumerated().forEach {[weak self] (index, _) in
            guard let self = self else { return }
            let layout = UICollectionViewFlowLayout()
            let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
            view.delegate = self
            view.dataSource = self
            view.isHidden = true
            view.tag = index
            view.contentInset = UIEdgeInsets(top: 16, left: 20, bottom: 12, right: 20)
            view.backgroundColor = .GlobalBackgroundPrimary
            view.register(TBMyPhotosCollectionViewCell.self)
            view.registerSectionHeader(for: TBToddlerAlbumHeaderView.self)
            view.registerSectionHeader(for: TBCollectionViewEmptyHeaderFooterView.self)
            view.registerSectionFooter(for: TBCollectionViewEmptyHeaderFooterView.self)
            albumViews.append(view)
        }

        albumViews.forEach({
            containerView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        })
        stickyToddlerView.removeFromSuperview()
        stickyToddlerView.tb.addTapGestureRecognizer(action: {[weak self] in
            self?.showYearPicker()
        })
        containerView.addSubview(stickyToddlerView)
        stickyToddlerView.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    private func bindData() {
        viewModel.profilesModelSubject.observeOn(MainScheduler.instance).subscribe {[weak self] event in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            switch event {
            case let .next(tuple):
                switch tuple.type {
                case .initData:
                    self.autoSelectProfileIfNeeded()
                    self.autoSelectAlbum()
                    self.setupAlbumsUI()
                    self.swithTOLastShowTap()
                    self.updateHeaderView()
                    self.updateAlbumsView()
                    self.scrollToCurrentItem()
                case .refreshData:
                    self.updateAlbumsView(reload: true)
                }
            case .error:
                self.reloadView.show(superView: self.view)
            default:
                break
            }
        } onError: { _ in }
    }

    private func swithTOLastShowTap() {
        if let lastSelectedIndex = lastSelectedIndex {
            selectedTabIndex = lastSelectedIndex
            itemsMenuView.selectIndex = lastSelectedIndex
        }
    }

    private func updateAlbumsView(reload: Bool = false) {
        albumViews.forEach({
            $0.isHidden = true
            if reload {
                $0.reloadData()
            }
        })
        albumViews[safe: selectedTabIndex]?.isHidden = false
        updateToddlerStickyViewIfNeeded()
        if let type = selectedAlbum?.albumType {
            TBAnalyticsManager.trackPhotoScreenView(albumType: type)
        }
    }

    private func updateHeaderView() {
        if viewModel.profilesModel.count == 1 {
            caretDownImageView.isHidden = true
            profilePickerControl.isUserInteractionEnabled = false
            albumNameLabel.attributedText = selectedProfile?.name?.capitalized.attributedText(.mulishLink3, foregroundColor: .GlobalTextPrimary, lineBreakMode: .byTruncatingTail)
        } else {
            albumNameLabel.attributedText = selectedProfile?.name?.capitalized.attributedText(.mulishLink3, foregroundColor: .Magenta, lineBreakMode: .byTruncatingTail)
        }
        guard let albums = selectedProfile?.albums else { return }
        itemsMenuView.titles = albums.compactMap({
            guard let typeString = $0.type,
                  let type = TBMyPhotosRepository.AlbumType(rawValue: typeString) else { return nil }
            switch type {
            case .pregnant:
                return "Pregnancy Photos"
            case .child:
                return "Baby Photos"
            case .toddler:
                return "Toddler Photos"
            }
        })
        itemsMenuView.selectIndex = selectedTabIndex
    }

    private func updateToddlerStickyViewIfNeeded() {
        guard selectedAlbum?.albumType == .toddler,
              let view = albumViews[safe: selectedTabIndex],
              view.contentOffset.y > 0 else {
            stickyToddlerView.isHidden = true
            return
        }
        stickyToddlerView.isHidden = false
        if let cell = view.visibleCells.min(by: {
            view.indexPath(for: $0)?.section <? view.indexPath(for: $1)?.section
        }),
           let indexPath = view.indexPath(for: cell),
           let model = selectedAlbum?.toddlerPhotos[safe: indexPath.section]?.first {
            stickyToddlerView.setup(model: model)
        }
    }

    @objc func showProfilePicker() {
        profilePickerView.delegate = self
        (profilePickerView.adapter as? TBPickerDefaultAdapter)?.items = viewModel.profilesModel.compactMap({$0.name?.capitalized}) ?? []
        profilePickerView.setupPicker(with: self, showIndex: selectedProfileIndex)
        profilePickerView.showPicker()
    }

    @objc func showYearPicker() {
        guard let selectedAlbum = selectedAlbum,
                selectedAlbum.albumType == .toddler else { return }
        let titles = selectedAlbum.toddlerPhotos.map({ model -> String in
            guard let year = model.first?.year else { return "" }
            let yearString = "Year".pluralize(with: year)
            return "\(year) \(yearString) Old"
        })
        yearPickerView.delegate = self
        (yearPickerView.adapter as? TBPickerDefaultAdapter)?.items = titles
        yearPickerView.setupPicker(with: self, showIndex: nil)
        yearPickerView.showPicker()
    }

    private func autoSelectProfileIfNeeded() {
        guard autoSelectProfile else { return }
        autoSelectProfile = false
        if let index = viewModel.profilesModel.firstIndex(where: {$0.id == TBMemberDataManager.shared.activeStatusModel?.id}) {
            selectedProfileIndex = index
        }
    }

    private func autoSelectAlbum() {
        selectedTabIndex = selectedProfile?.albums?.firstIndex(where: {$0.albumType == selectedProfile?.profileType}) ?? 0
    }

    private func scrollToCurrentItem() {
        guard let selectedProfile = selectedProfile,
              let profileType = selectedProfile.profileType,
              profileType == selectedAlbum?.albumType,
              let collectionView = albumViews[safe: selectedTabIndex] else {
            return
        }
        switch profileType {
        case .pregnant:
            guard let dueDate = TBMemberDataManager.sharedInstance().memberDataObject?.pregnancyDueDate,
                  let currentWeek = TBTimeUtility.pregnancyWeeksFromDueDate(dueDate: dueDate)?.intValue,
                  let indexWeek = (currentWeek - 4) as? Int,
                  collectionView.numberOfItems(inSection: 0) >= indexWeek else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                collectionView.scrollToItem(at: IndexPath(item: indexWeek, section: 0), at: .top, animated: true)
            }
        case .child:
            guard let babyId = selectedProfile.id,
                  let child = TBMemberDataManager.sharedInstance().memberData?.childWithBabyId(babyId: babyId as NSNumber),
                  collectionView.numberOfItems(inSection: 0) >= child.week else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                collectionView.scrollToItem(at: IndexPath(item: child.week, section: 0), at: .top, animated: true)
            }
        case .toddler:
            guard let babyId = selectedProfile.id,
                  let child = TBMemberDataManager.sharedInstance().memberData?.childWithBabyId(babyId: babyId as NSNumber),
                  shouldChangeOffset(month: child.months) else { return }
            let year = child.months / 12
            guard collectionView.numberOfSections >= year else { return }
            let month = year > 2 ? 0 : child.months % 12
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                collectionView.performBatchUpdates {
                    collectionView.scrollToItem(at: IndexPath(item: month, section: year - 1 > 0 ? year - 1 : 0), at: .top, animated: true)
                    collectionView.contentOffset.y -= 25
                }
            }
        }
    }

    private func shouldChangeOffset(month: Int) -> Bool {
        guard !UIDevice.isPad() else {
            return month - 12 > 6
        }
        return month - 12 > 3
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TBMyPhotosScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let album = selectedProfile?.albums?[safe: collectionView.tag],
              let albumType = album.albumType else { return 0 }
        switch albumType {
        case .pregnant:
            return album.pregnancyPhotos.count ?? 0
        case .child:
            return album.childPhotos.count ?? 0
        case .toddler:
            return album.toddlerPhotos[safe: section]?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TBMyPhotosCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if let album = selectedProfile?.albums?[safe: collectionView.tag],
           let albumType = album.albumType {
            switch albumType {
            case .pregnant:
                cell.setup(photoModels: album.pregnancyPhotos[safe: indexPath.row], type: albumType)
            case .child:
                cell.setup(photoModels: album.childPhotos[safe: indexPath.row], type: albumType)
            case .toddler:
                cell.setup(photoModels: album.toddlerPhotos[safe: indexPath.section]?[safe: indexPath.row], type: albumType)
            }
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let album = selectedProfile?.albums?[safe: collectionView.tag],
              let albumType = album.albumType else { return 0 }
        switch albumType {
        case .pregnant, .child:
            return 1
        case .toddler:
            return album.toddlerPhotos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let album = selectedProfile?.albums?[safe: collectionView.tag],
              let albumType = album.albumType else { return }
        var photosModel: TBPhotosModel?
        switch albumType {
        case .pregnant:
            photosModel = album.pregnancyPhotos[safe: indexPath.row]
        case .child:
            photosModel = album.childPhotos[safe: indexPath.row]
        case .toddler:
            photosModel = album.toddlerPhotos[safe: indexPath.section]?[safe: indexPath.row]
        }
        if photosModel?.photos.isEmpty ?? true {
            let vc = CameraLibraryMultiAlbumViewController()
            vc.delegate = self
            let libraryNav = UINavigationController(rootViewController: vc)
            libraryNav.modalPresentationStyle = .fullScreen
            selectedIndexPath = indexPath
            AppRouter.shared.navigator.present(libraryNav)
            return
        }
        let photosVC = TBManagePhotosViewController()
        photosVC.photosModel = photosModel
        photosVC.albumModel = album
        photosVC.profilesModel = viewModel.profilesModel
        photosVC.profilesModel = viewModel.profilesModel
        if let cell = collectionView.cellForItem(at: indexPath) as? TBMyPhotosCollectionViewCell {
            photosVC.navigationItem.title = cell.titleLabel.text
        }
        photosVC.delegate = self
        AppRouter.shared.navigator.push(photosVC)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let album = selectedProfile?.albums?[safe: collectionView.tag],
           let albumType = album.albumType {
            switch albumType {
            case .pregnant, .child:
                break
            case .toddler:
                if kind == UICollectionView.elementKindSectionHeader {
                    let headerView: TBToddlerAlbumHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
                    let model = album.toddlerPhotos[safe: indexPath.section]?.first
                    stickyToddlerView.setup(model: model)
                    headerView.setup(model: model, updateTopConstraint: indexPath.section == 0 ? 0 : 24)
                    return headerView
                }
            }
        }
        let headerView: TBCollectionViewEmptyHeaderFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        return headerView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateToddlerStickyViewIfNeeded()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBMyPhotosScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let album = selectedProfile?.albums?[safe: collectionView.tag],
              let albumType = album.albumType else { return .zero}
        switch albumType {
        case .pregnant, .child:
            return CGSize(width: 106, height: 148)
        case .toddler:
            return CGSize(width: 106, height: 148)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let album = selectedProfile?.albums?[safe: collectionView.tag],
              let albumType = album.albumType else { return .zero }
        switch albumType {
        case .pregnant, .child:
            return .zero
        case .toddler:
            return CGSize(width: 0, height: section == 0 ? 30 : 54)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let album = selectedProfile?.albums?[safe: collectionView.tag],
              let albumType = album.albumType else { return .zero }
        switch albumType {
        case .pregnant, .child:
            return .zero
        case .toddler:
            return section == (album.toddlerPhotos.count-1) ? CGSize(width: 0, height: collectionView.frame.size.height - 148 - 54) : .zero
        }
    }

    @objc private func didTapManageCTA() {
        let manageVC = TBManageAlbumsViewController()
        manageVC.profilesModel = viewModel.profilesModel
        manageVC.delegate = self
        AppRouter.shared.navigator.push(manageVC)
    }
}

// MARK: - TBManageAlbumsViewControllerDelegate
extension TBMyPhotosScreenViewController: TBManageAlbumsViewControllerDelegate {
    func albumPhotosDidFinishDeleting(albumIds: [String]) {
        viewModel.deleteAlbums(albumIds: albumIds)
    }
}

// MARK: - TBManagePhotosViewControllerDelegate
extension TBMyPhotosScreenViewController: TBManagePhotosViewControllerDelegate {

    func photosDidFinishDeleting(photos: [String]) {
        viewModel.deletePhotos(photosIds: photos)
    }

    func movePhotosDidFinish() {
        viewModel.fetchAlbums()
    }
}

// MARK: - TBItemsMenuViewDelegate
extension TBMyPhotosScreenViewController: TBItemsMenuViewDelegate {
    func didSelectedIndex(view: TBItemsMenuView, index: Int) {
        selectedTabIndex = index
        updateAlbumsView()
    }
}

// MARK: - TBOldPickerViewDelegate
extension TBMyPhotosScreenViewController: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        if view.isEqual(profilePickerView) {
            selectedProfileIndex = index
            autoSelectAlbum()
            updateHeaderView()
            setupAlbumsUI()
            updateAlbumsView()
            scrollToCurrentItem()
        } else if view.isEqual(yearPickerView),
                  let view = albumViews[safe: selectedTabIndex],
                  index < view.numberOfSections {
            if index == view.numberOfSections-1 {
                view.scrollToItem(at: IndexPath(row: 0, section: index), at: .top, animated: true)
            } else {
                view.performBatchUpdates {
                    view.scrollToItem(at: IndexPath(item: 0, section: index), at: .top, animated: true)
                    view.contentOffset.y -= 25
                }
            }
        }
    }
}

// MARK: - TBModalViewDelegate
extension TBMyPhotosScreenViewController: TBModalViewDelegate {
    func didTapBottomCTA(_ modal: TBModalView, actionString: String?) {
        modal.dismiss()
    }
}

// MARK: - CameraLibraryViewControllerDelegate
extension TBMyPhotosScreenViewController: CameraLibraryViewControllerDelegate {
    func didFinishPickingMedia(viewController: UIViewController, imageTaken: UIImage, isFromSavedImage: Bool) {
        viewController.dismiss(animated: false, completion: { [self] in
            var weekDataSource = [Int]()
            var albumModels: [TBPhotosModel]?
            if let album = selectedAlbum,
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

            let vc = TBAddPhotoViewController()
            vc.delegate = self
            guard let albumType = selectedAlbum?.albumType,
                  let selectedIndexPath = selectedIndexPath else { return }
            switch albumType {
            case .pregnant:
                vc.setupModel(image: imageTaken,
                              albumID: selectedAlbum?.id,
                              albumName: selectedAlbum?.name,
                              albumType: selectedAlbum?.albumType,
                              weeks: weekDataSource,
                              currentWeek: selectedAlbum?.pregnancyPhotos[safe: selectedIndexPath.row]?.week)
            case .child:
                vc.setupModel(image: imageTaken,
                              albumID: selectedAlbum?.id,
                              albumName: selectedAlbum?.name,
                              albumType: selectedAlbum?.albumType,
                              weeks: weekDataSource,
                              currentWeek: selectedAlbum?.childPhotos[safe: selectedIndexPath.row]?.week)
            case .toddler:
                vc.setupModel(image: imageTaken,
                              albumID: selectedAlbum?.id,
                              albumName: selectedAlbum?.name,
                              albumType: selectedAlbum?.albumType,
                              currentMonth: selectedAlbum?.toddlerPhotos[safe: selectedIndexPath.section]?[safe: selectedIndexPath.row]?.month,
                              currentYear: selectedAlbum?.toddlerPhotos[safe: selectedIndexPath.section]?[safe: selectedIndexPath.row]?.year)
            }
            let libraryNav = UINavigationController(rootViewController: vc)
            libraryNav.modalPresentationStyle = .fullScreen
            AppRouter.shared.navigator.present(libraryNav)
        })
    }
}

// MARK: - TBAddPhotoViewControllerDelegate
extension TBMyPhotosScreenViewController: TBAddPhotoViewControllerDelegate {
    func uploadPhotoModel(viewController: UIViewController, model: TBPhotoModel?, albumId: String?) {
        TBToastView().display(attributedText: ("Photo has been uploaded.").attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary),
                              on: self.view)
        TBMyPhotosRepository.shared.uploadPhotoModel(model: model, albumId: albumId)
    }
}
