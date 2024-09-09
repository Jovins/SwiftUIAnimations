import Foundation
import UIKit
import SnapKit
import RxSwift
import FullStory

protocol TBEditPhotoViewControllerDelegate: class {
    func editPhotoModel(model: TBPhotoModel?, albumId: String?)
}

final class TBEditPhotoViewController: UIViewController {
    weak var delegate: TBEditPhotoViewControllerDelegate?
    let viewModel = TBEditPhotoViewModel()
    private var isReachBottom: Bool = false
    private enum PhotoEditorCellType: Int {
        case name = 0
        case type
        case time
        case description
    }
    private let disposed = DisposeBag()
    private let loadingHUD: TBLoadingHUD = TBLoadingHUD()
    private var saveButtonContainerBottomConstraint: Constraint?
    private let assistantView = MemberFeedbackPopupAssistantView(frame: CGRect.zero)
    private let tableViewController: UITableViewController = {
        let tableViewController = UITableViewController(style: .plain)
        tableViewController.tableView.backgroundColor = .GlobalBackgroundPrimary
        tableViewController.tableView.bounces = false
        tableViewController.tableView.separatorStyle = .none
        tableViewController.tableView.clipsToBounds = false
        tableViewController.tableView.register(TBPhotoEditorInfomationCell.self)
        tableViewController.tableView.register(TBPhotoEditorPickerCell.self)
        tableViewController.tableView.register(TBPhotoEditorInputDescriptionCell.self)
        return tableViewController
    }()
    private var tableView: UITableView {
        return self.tableViewController.tableView
    }
    private let tableViewFooter: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIDevice.width, height: 20)
        return view
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        FS.mask(views: imageView)
        return imageView
    }()

    private let saveButtonContainerTopLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        view.isHidden = true
        return view
    }()
    private let saveButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addShadow(with: .DarkGray400, alpha: 1, radius: 2, offset: CGSize.zero)
        return view
    }()
    private let saveButton: TBCommonButton = {
        let button = TBCommonButton()
        button.buttonState = .primary
        button.buttonWidthStyle = .stretch
        button.setTitle("Save", for: .normal)
        return button
    }()

    lazy var pickerContainer = UIView()
    private lazy var profilePicker: TBOldPickerView = {
        let pickerView = TBOldPickerView(frame: UIScreen.main.bounds)
        let adapter = TBPickerDefaultAdapter()
        pickerView.adapter = adapter
        return pickerView
    }()
    private lazy var albumPicker: TBOldPickerView = {
        let pickerView = TBOldPickerView(frame: UIScreen.main.bounds)
        let adapter = TBPickerDefaultAdapter()
        pickerView.adapter = adapter
        return pickerView
    }()
    private lazy var weekPicker: TBOldPickerView = {
        let pickerView = TBOldPickerView(frame: UIScreen.main.bounds)
        let adapter = TBPickerDefaultAdapter()
        pickerView.adapter = adapter
        return pickerView
    }()

    private var errorToastHeightConstraint: Constraint?
    private let errorToastView: TBErrorToastView = {
        let view = TBErrorToastView()
        view.attributedText = "An error occurred. Please try again or contact us if the problem persists.".attributedText(.mulishBody3)
        return view
    }()

    func setupModel(image: UIImage?,
                    profilesModel: [TBAlbumsProfileModel]?,
                    profileModel: TBAlbumsProfileModel?,
                    albumModel: TBAlbumModel?,
                    photosModel: TBPhotosModel?,
                    photoModel: TBPhotoModel) {
        viewModel.image = image
        viewModel.profilesModel = profilesModel
        viewModel.selectedProfile = profileModel
        viewModel.selectedAlbum = albumModel
        viewModel.selectedPhotosModel = photosModel
        viewModel.selectedPhotoModel = photoModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Photo"
        view.backgroundColor = .GlobalBackgroundPrimary
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setup() {
        setupCloseButton()
        setupTableViewController()
        setupTableViewImageHeader()
        setupSaveButtonContainer()
        setupAssistantView()
        setupKeyboardNotification()
        bindData()
    }

    private func bindData() {
        viewModel.editPhotoSubject.observeOn(MainScheduler.instance).subscribe { [weak self] event in
            guard let self = self else { return }
            switch event {
            case let .next(model):
                let tuple: (model: TBPhotoModel?, albumId: String?) = model
                self.loadingHUD.dismiss()
                self.delegate?.editPhotoModel(model: tuple.model, albumId: tuple.albumId)
                self.dismiss(animated: true)
            case let .error(error):
                self.loadingHUD.dismiss()
                TBErrorToastView.showErrorMessageToTopVC(message: "An error occurred. Please try again or contact us if the problem persists.".attributedText(.mulishBody3))
            default:
                break
            }
        } onError: { _ in
        }
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(TBIconList.close.image(), for: .normal)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func setupTableViewController() {
        tableViewController.tableView.delegate = self
        tableViewController.tableView.dataSource = self
        addChild(tableViewController)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
    }

    private func setupTableViewImageHeader() {
        let imageHeader = UIView()
        imageHeader.frame = CGRect(x: 0, y: 0, width: UIDevice.width, height: UIDevice.width + 16)
        imageHeader.backgroundColor = .DarkGray300
        tableView.tableHeaderView = imageHeader

        imageHeader.addSubview(photoImageView)
        photoImageView.image = viewModel.image
        photoImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    private func setupSaveButtonContainer() {
        view.addSubview(saveButtonContainer)
        saveButtonContainer.snp.makeConstraints {
            saveButtonContainerBottomConstraint = $0.bottom.equalToSuperview().inset(0).constraint
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }

        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        saveButtonContainer.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }

        saveButtonContainer.addSubview(saveButtonContainerTopLine)
        saveButtonContainerTopLine.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(saveButtonContainer.snp.top)
            $0.height.equalTo(1)
        }
    }

    private func setupAssistantView() {
        assistantView.donebutton.addTarget(self, action: #selector(didTapAssistantDone), for: .touchUpInside)
    }

    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                guard let self = self else { return }
                self.handleKeyboardAnimation(notification: notification, isShow: true)
            }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                guard let self = self else { return }
                self.handleKeyboardAnimation(notification: notification, isShow: false)
            }
    }

    private func handleKeyboardAnimation(notification: Notification, isShow: Bool) {
        if UIDevice.isPad() && !isShow {
            view.endEditing(true)
        }

        guard let userInfo = notification.userInfo,
              let keyboardAnimationDetail = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let animationCurve: Int = {
            if let keyboardAnimationCurve = keyboardAnimationDetail[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int {
                let curve: Int? = UIView.AnimationCurve(rawValue: keyboardAnimationCurve)?.rawValue
                return curve ?? 0
            } else {
                return 0
            }
        }()

        let duration: Double = {
            if let animationDuration = keyboardAnimationDetail[UIResponder.keyboardAnimationDurationUserInfoKey] as? Int {
                return Double(animationDuration)
            } else {
                return 0
            }
        }()

        let options = UIView.AnimationOptions(rawValue: ((UInt(animationCurve << 16))))
        moveSubmitButton(isUp: isShow, duration: duration, options: options, keyboardHeight: keyboardRect.size.height)
    }

    private func moveSubmitButton(isUp: Bool, duration: TimeInterval, options: UIView.AnimationOptions, keyboardHeight: CGFloat) {
        self.saveButtonContainer.backgroundColor = isUp ? .OffWhite : .clear
        UIView.animate(withDuration: duration, delay: 0.0, options: options) {
            self.saveButtonContainerBottomConstraint?.update(inset: isUp ? keyboardHeight-100 : 0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.saveButtonContainer.backgroundColor = .GlobalBackgroundPrimary
        }
    }
}

// MARK: Button Actions
extension TBEditPhotoViewController {
    @objc private func didTapClose() {
        guard viewModel.saveEnable else {
            navigationController?.dismiss(animated: true)
            return
        }
        let alertView = UIAlertController(title: "You have unsaved changes.\rAre you sure to exit?", message: "", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [self] _ in
            navigationController?.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertView.addAction(yesAction)
        alertView.addAction(cancelAction)
        AppRouter.shared.navigator.present(alertView)
    }

    @objc private func didTapSave() {
        view.endEditing(true)
        loadingHUD.show()
        viewModel.editPhoto()
    }

    @objc private func didTapAssistantDone() {
        view.endEditing(true)
    }
}

// MARK: UITableViewDataSource
extension TBEditPhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch PhotoEditorCellType(rawValue: indexPath.row) {
        case .name:
            let cell: TBPhotoEditorPickerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setupCell(title: "Album Name", content: viewModel.selectedProfile?.name?.capitalized ?? "", indexPath: indexPath)
            cell.delegate = self
            cell.maskTextField()
            return cell
        case .type:
            let cell: TBPhotoEditorPickerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setupCell(title: "Album Type", content: viewModel.albumTypeTitle, indexPath: indexPath)
            cell.delegate = self
            cell.maskTextField(false)
            return cell
        case .time:
            let cell: TBPhotoEditorPickerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setupCell(title: viewModel.timeTitle, content: viewModel.selectedPhotoTime, indexPath: indexPath)
            cell.delegate = self
            cell.maskTextField(false)
            return cell
        case .description:
            let cell: TBPhotoEditorInputDescriptionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            cell.assistantView = self.assistantView
            cell.setupCell(text: viewModel.selectedPhotoModel?.caption, placeholderText: viewModel.placeholderText)
            return cell
        default:
            fatalError("TBEditPhotoViewController could not get the cell")
        }
    }
}

// MARK: UITableViewDelegate
extension TBEditPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch PhotoEditorCellType(rawValue: indexPath.row) {
        case .name:
            return TBPhotoEditorPickerCell.cellHeight
        case .type:
            return TBPhotoEditorPickerCell.cellHeight
        case .time:
            return TBPhotoEditorPickerCell.cellHeight
        case .description:
            return TBPhotoEditorInputDescriptionCell.cellHeight
        default:
            return 0
        }
    }
}

extension TBEditPhotoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isReachBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        guard self.isReachBottom != isReachBottom else { return  }

        self.isReachBottom = isReachBottom
        saveButtonContainerTopLine.isHidden = !isReachBottom
        saveButtonContainer.addShadow(with: .DarkGray400, alpha: self.isReachBottom ? 0 : 1, radius: 2, offset: CGSize.zero)
    }
}

// MARK: PhotoEditorPickerCellDelegate
extension TBEditPhotoViewController: TBPhotoEditorPickerCellDelegate {
    func showPicker(indexPath: IndexPath?) {
        view.endEditing(true)
        guard let indexPath = indexPath else { return }
        switch PhotoEditorCellType(rawValue: indexPath.row) {
        case .name:
            let index = viewModel.profilesModel?.firstIndex(where: {$0.id == viewModel.selectedProfile?.id})
            (profilePicker.adapter as? TBPickerDefaultAdapter)?.items = viewModel.profilesModel?.compactMap({$0.name?.capitalized}) ?? []
            profilePicker.setupPicker(with: self, showIndex: index)
            profilePicker.delegate = self
            profilePicker.showPicker()
        case .type:
            let index = viewModel.selectedProfile?.albums?.firstIndex(where: {$0.id == viewModel.selectedAlbum?.id})
            (albumPicker.adapter as? TBPickerDefaultAdapter)?.items = viewModel.selectedProfile?.albums?.compactMap({
                switch $0.albumType {
                case .pregnant:
                    return "Pregnancy Photos"
                case .child:
                    return "Baby Photos"
                case .toddler:
                    return "Toddler Photos"
                default:
                    return nil
                }
            }) ?? []
            albumPicker.setupPicker(with: self, showIndex: index)
            albumPicker.delegate = self
            albumPicker.showPicker()
        case .time:
            var dataSource: [String] = []
            var index: Int?
            switch viewModel.selectedAlbum?.albumType {
            case .pregnant:
                index = viewModel.selectedAlbum?.pregnancyPhotos.firstIndex(where: { $0.week == viewModel.selectedPhotosModel?.week})
                dataSource = viewModel.selectedAlbum?.pregnancyPhotos.compactMap({ model -> String? in
                    if let week = model.week {
                        return "Week \(week)"
                    }
                    return nil
                }) ?? []
            case .child:
                index = viewModel.selectedAlbum?.childPhotos.firstIndex(where: { $0.week == viewModel.selectedPhotosModel?.week})
                dataSource = viewModel.selectedAlbum?.childPhotos.compactMap({ model -> String? in
                    if let week = model.week {
                        if week == 0 {
                            return "Newborn"
                        }
                        return "Week \(week)"
                    }
                    return nil
                }) ?? []
            case .toddler:
                index = viewModel.selectedAlbum?.toddlerPhotos.flatMap({$0}).firstIndex(where: {
                    guard $0.month == viewModel.selectedPhotosModel?.month,
                          $0.year == viewModel.selectedPhotosModel?.year else { return false }
                    return true
                })
                dataSource = viewModel.selectedAlbum?.toddlerPhotos.flatMap({$0}).compactMap({ model -> String? in
                    guard let year = model.year else { return nil }
                    if year < 3,
                       let month = model.month {
                        return "\(month) Months"
                    } else {
                        return "\(year) Years Old"
                    }
                }) ?? []
            default:
                break
            }
            (weekPicker.adapter as? TBPickerDefaultAdapter)?.items = dataSource
            weekPicker.setupPicker(with: self, showIndex: index)
            weekPicker.delegate = self
            weekPicker.showPicker()
        default:
            break
        }
    }
}

// MARK: UIPickerViewDataSource
extension TBEditPhotoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        4
    }
}

// MARK: UIPickerViewDelegate
extension TBEditPhotoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return "\(row)".attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
    }
}

// MARK: PhotoEditorInputDescriptionCellDelegate
extension TBEditPhotoViewController: TBPhotoEditorInputDescriptionCellDelegate {
    func updateContent(content: String) {
        viewModel.photoDescription = content
    }
}

// MARK: TBOldPickerViewDelegate
extension TBEditPhotoViewController: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        if view.isEqual(profilePicker) {
            viewModel.selectedProfile = viewModel.profilesModel?[safe: index]
        } else if view.isEqual(albumPicker) {
            viewModel.selectedAlbum = viewModel.selectedProfile?.albums?[safe: index]
        } else if view.isEqual(weekPicker) {
            if let albumType = viewModel.selectedAlbum?.albumType {
                switch albumType {
                case .pregnant:
                    viewModel.selectedPhotosModel = viewModel.selectedAlbum?.pregnancyPhotos[safe: index]
                case .child:
                    viewModel.selectedPhotosModel = viewModel.selectedAlbum?.childPhotos[safe: index]
                case .toddler:
                    viewModel.selectedPhotosModel = viewModel.selectedAlbum?.toddlerPhotos.flatMap({$0})[safe: index]
                }
            }
        }
        tableView.reloadData()
    }
}
