import UIKit
import RxSwift
import FullStory

protocol TBManageAlbumsViewControllerDelegate: NSObjectProtocol {
    func albumPhotosDidFinishDeleting(albumIds: [String])
}

final class TBManageAlbumsViewController: UIViewController {

    var profilesModel: [TBAlbumsProfileModel]?
    weak var delegate: TBManageAlbumsViewControllerDelegate?
    private let contactView = TBManageAlbumsContactView()
    private var downloadingPhotoModels: [TBPhotoModel] = []
    private lazy var progressBar: TBPhotoDownloadProgressBar = {
        let progressBar = TBPhotoDownloadProgressBar()
        progressBar.delegate = self
        return progressBar
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TBManageAlbumsCell.self)
        tableView.register(TBManageAlbumsHeaderView.self)
        return tableView
    }()
    private let loadingHUD: TBLoadingHUD = TBLoadingHUD()
    private var showShadow: Bool {
        guard let profiles = profilesModel else { return false }
        var height: CGFloat = 0
        profiles.forEach { profile in
            height += CGFloat(40 + (profile.albums?.count ?? 0) * 52)
        }
        let standHeight = view.bounds.height - TBManageAlbumsContactView.contactUsHeight - UIDevice.navigationBarHeight - UIDevice.tabbarHeight
        return height > standHeight
    }
    private let networkHelper = TBMyPhotosNetworkHelper()
    private let disposed = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationItem.title = "Manage Photos"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TBAnalyticsManager.trackManageAlbumPhotosScreenView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        [tableView, contactView].forEach(view.addSubview)
        contactView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(contactView.snp_top)
        }
        contactView.showShadow = showShadow
    }

    private func downloadPhotos(photoUrls: [String]) {
        DispatchQueue.main.async {
            self.progressBar.show()
        }
        TBPhotoDownloadManager.shared.downloadPhotosToAlbum(urls: photoUrls) { [weak self] index, total, _ in
            self?.progressBar.updateProgress(Float(index+1)/Float(total))
        } completed: { [weak self] allSuccess, failUrlStrings in
            guard let self = self else { return }
            self.progressBar.dismiss()
            if allSuccess {
                self.downloadingPhotoModels.removeAll()
                let message = "Album has been downloaded."
                TBToastView().display(attributedText: message.attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary), on: self.view)
            } else {
                guard let failUrlStrings = failUrlStrings else { return }
                let failPhotoModels = self.downloadingPhotoModels.filter({ failUrlStrings.contains($0.variantURLs?.medium ?? "") })
                let failViewController = TBPhotoDownloadFailViewController()
                failViewController.delegate = self
                failViewController.dataSource = failPhotoModels
                let navController = UINavigationController(rootViewController: failViewController)
                navController.modalPresentationStyle = .fullScreen
                AppRouter.shared.navigator.present(navController)
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TBManageAlbumsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let profiles = profilesModel else { return 0 }
        return profiles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let profiles = profilesModel, let albums = profiles[section].albums else { return 0 }
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TBManageAlbumsCell.self, for: indexPath)
        if let albums = profilesModel?[indexPath.section].albums {
            let album = albums[indexPath.row]
            cell.setup(album: album, shouldShowDividerLine: albums.count - 1 != indexPath.row)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TBManageAlbumsHeaderView.defaultReuseIdentifier) as? TBManageAlbumsHeaderView else { return nil }
        if let profile = profilesModel?[section] {
            headerView.setupData(model: profile, section: section, delegate: self)
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distance = scrollView.contentSize.height - scrollView.contentOffset.y - 20
        if distance <= scrollView.frame.size.height {
            contactView.showShadow = false
        } else {
            contactView.showShadow = showShadow
        }
    }
}

// MARK: - TBManagePhotosHeaderViewDelegate
extension TBManageAlbumsViewController: TBManageAlbumsHeaderViewDelegate {

    func headerView(headerView: TBManageAlbumsHeaderView, sender: Any, deleteForHeaderInSection section: Int) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let downloadAction = UIAlertAction(title: "Download Album", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.checkPermissions(with: .downloadPhotos) { isAuthorized in
                guard isAuthorized else { return }
                DispatchQueue.global().async {
                    self.downloadingPhotoModels = self.getAllPhotoModelsFromProfile(section: section)
                    let photoUrls = self.downloadingPhotoModels.compactMap({ $0.variantURLs?.medium })
                    self.downloadPhotos(photoUrls: photoUrls)
                }
            }
        }
        let deleteAction = UIAlertAction(title: "Delete Album", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteAlbumPhotos(section: section)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
        FS.unmask(alertVC.view)
        present(alertVC, animated: true)
    }

    private func getAllPhotoModelsFromProfile(section: Int) -> [TBPhotoModel] {
        guard let albums = self.profilesModel?[section].albums else { return [] }
        let albumPhotosModels = albums.compactMap { albumModel in
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
        }
        let photosModels = albumPhotosModels.flatMap({ $0 })
        let photoModels = photosModels.flatMap({ $0.photos })
        return photoModels
    }

    private func deleteAlbumPhotos(section: Int) {
        let alertVC = UIAlertController(title: nil, message: "Are you sure you want to delete these album photos ?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteAlbums(section: section)
        }
        alertVC.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertVC.addAction(cancelAction)
        alertVC.preferredAction = cancelAction
        present(alertVC, animated: true)
        FS.unmask(views: alertVC.view)
    }

    private func deleteAlbums(section: Int) {
        guard let albums = profilesModel?[section].albums else { return }
        var albumIds = albums.compactMap { album -> String? in
            guard let photos = album.photos,
                  !photos.isEmpty,
                  let id = album.id else { return nil }
            album.photos?.removeAll()
            return id
        }
        loadingHUD.show()
        networkHelper.removeAlbums(albumIds: albumIds).observeOn(MainScheduler.instance).subscribe { [weak self] (response) in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            guard "\(response.statusCode)".hasPrefix("2") else { return }
            self.tableView.reloadData()
            self.delegate?.albumPhotosDidFinishDeleting(albumIds: albumIds)
            TBToastView().display(attributedText: "Photos have been deleted.".attributedText(.mulishBody3, foregroundColor: .GlobalTextSecondary), on: self.view)
            TBAnalyticsManager.trackDeletePhoto(userDecisionArea: "manage album")
        } onError: { [weak self] _ in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            TBErrorToastView.showErrorMessageToTopVC(message: "An error occurred. Please try again or contact us if the problem persists.".attributedText(.mulishBody3))
        }.disposed(by: disposed)
    }
}

// MARK: - TBPhotoDownloadProgressBarDelegate
extension TBManageAlbumsViewController: TBPhotoDownloadProgressBarDelegate {
    func didTapClose(progressBar: TBPhotoDownloadProgressBar) {
        TBPhotoDownloadManager.shared.pauseDownloading()
        progressBar.setHidden(true)
        let cancelDownloadAlert = UIAlertController(title: "Are you sure you want to cancel the download?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            TBPhotoDownloadManager.shared.cancelDownloading()
        }
        let noAction = UIAlertAction(title: "No", style: .default) { _ in
            progressBar.setHidden(false)
            TBPhotoDownloadManager.shared.resumeDownloading()
        }
        cancelDownloadAlert.addAction(yesAction)
        cancelDownloadAlert.addAction(noAction)
        present(cancelDownloadAlert, animated: true)
    }
}

// MARK: - TBPhotoDownloadFailViewControllerDelegate
extension TBManageAlbumsViewController: TBPhotoDownloadFailViewControllerDelegate {

    func photoDownloadFailViewController(_ viewController: TBPhotoDownloadFailViewController, tryAgain photoModels: [TBPhotoModel]) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let photoUrls = photoModels.compactMap({ $0.variantURLs?.medium })
            self.downloadPhotos(photoUrls: photoUrls)
        }
    }
}
