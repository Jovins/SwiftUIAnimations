import UIKit
import SnapKit
import RxSwift
import FullStory

protocol TBAddPhotoViewControllerDelegate: class {
    func uploadPhotoModel(viewController: UIViewController, model: TBPhotoModel?, albumId: String?)
}

final class TBAddPhotoViewController: UIViewController {
    weak var delegate: TBAddPhotoViewControllerDelegate?
    private var isReachBottom: Bool = false
    private let viewModel = TBPhotoEditorViewModel()
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
    private lazy var weekPicker: TBOldPickerView = {
        let pickerView = TBOldPickerView(frame: UIScreen.main.bounds)
        let adapter = TBPickerDefaultAdapter()
        pickerView.adapter = adapter
        return pickerView
    }()

    func setupModel(image: UIImage?,
                    albumID: String?,
                    albumName: String?,
                    albumType: TBMyPhotosRepository.AlbumType?,
                    weeks: [Int]?,
                    currentWeek: Int?) {
        viewModel.image = image
        viewModel.albumID = albumID
        viewModel.albumName = albumName
        viewModel.albumType = albumType ?? .pregnant
        guard let weeks = weeks, let currentWeek = currentWeek else { return }
        viewModel.pickerDataSource = weeks.map({ week in
            let model = TBPhotoEditorViewModel.TBPickerModel()
            model.week = week
            if week == 0 && albumType == .child {
                model.title = "Newborn"
            } else {
                model.title = "Week \(week)"
            }
            return model
        })
        viewModel.pickerIndex = albumType == .pregnant ? currentWeek - 4 : currentWeek
    }

    func setupModel(image: UIImage?,
                    albumID: String?,
                    albumName: String?,
                    albumType: TBMyPhotosRepository.AlbumType?,
                    currentMonth: Int?,
                    currentYear: Int?) {
        viewModel.image = image
        viewModel.albumID = albumID
        viewModel.albumName = albumName
        viewModel.albumType = albumType ?? .pregnant
        var array: [TBPhotoEditorViewModel.TBPickerModel] = Array(13...24).map({
            let model = TBPhotoEditorViewModel.TBPickerModel()
            model.month = $0
            model.year = 1
            model.title = "\($0) Months"
            return model
        })
        array.append(contentsOf: Array(25...36).map({
            let model = TBPhotoEditorViewModel.TBPickerModel()
            model.month = $0
            model.year = 2
            model.title = "\($0) Months"
            return model
        }))
        array.append(contentsOf: Array(3...5).map({
            let model = TBPhotoEditorViewModel.TBPickerModel()
            model.year = $0
            model.title = "\($0) Years Old"
            return model
        }))
        viewModel.pickerDataSource = array
        if let currentMonth = currentMonth,
           let index = array.firstIndex(where: {$0.month == currentMonth}) {
            viewModel.pickerIndex = index
        } else if let currentYear = currentYear,
                  let index = array.firstIndex(where: {$0.year == currentYear}) {
            viewModel.pickerIndex = index
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Photo"
        view.backgroundColor = .GlobalBackgroundPrimary
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
        setupPicker()
        setupKeyboardNotification()
        bindData()
    }

    private func bindData() {
        viewModel.uploadPhotoSubject.observeOn(MainScheduler.instance).subscribe { [weak self] event in
            guard let self = self else { return }
            switch event {
            case let .next(model):
                let tuple: (model: TBPhotoModel?, albumId: String?) = model
                self.loadingHUD.dismiss()
                self.dismiss(animated: true) {
                    self.delegate?.uploadPhotoModel(viewController: self, model: tuple.model, albumId: tuple.albumId)
                }
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

    private func setupPicker() {
        guard let titles = viewModel.pickerDataSource?.compactMap({$0.title}) else { return }
        (weekPicker.adapter as? TBPickerDefaultAdapter)?.items = titles
        weekPicker.setupPicker(with: self, showIndex: viewModel.pickerIndex)
        weekPicker.delegate = self
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
extension TBAddPhotoViewController {
    @objc private func didTapClose() {
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
        viewModel.addPhoto()
    }

    @objc private func didTapAssistantDone() {
        view.endEditing(true)
    }
}

// MARK: UITableViewDataSource
extension TBAddPhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch PhotoEditorCellType(rawValue: indexPath.row) {
        case .name:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInfomationCell.self, for: indexPath) { [weak self] cell in
                guard let self = self else { return }
                cell.setupTwoLinesContentCell(title: "Album Name:", content: self.viewModel.albumName?.capitalized ?? "")
                cell.maskContent()
            }
        case .type:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInfomationCell.self, for: indexPath) { [weak self] cell in
                guard let self = self else { return }
                cell.setupTwoLinesContentCell(title: "Album Type:", content: self.viewModel.albumTypeName())
                cell.maskContent(false)
            }
        case .time:
            return tableView.dequeueReusableCell(of: TBPhotoEditorPickerCell.self, for: indexPath) { [weak self] cell in
                guard let self = self,
                      let content = self.viewModel.pickerDataSource?[safe: self.viewModel.pickerIndex]?.title
                else { return }
                switch self.viewModel.albumType {
                case .pregnant, .child:
                    cell.setupCell(title: "Week", content: content)
                case .toddler:
                    cell.setupCell(title: "Month/Year", content: content)
                }
                cell.delegate = self
                cell.maskTextField(false)
            }
        case .description:
            return tableView.dequeueReusableCell(of: TBPhotoEditorInputDescriptionCell.self, for: indexPath) { [weak self] cell in
                guard let self = self else { return }
                cell.delegate = self
                cell.assistantView = self.assistantView
                cell.setupCell(text: viewModel.photoDescription, placeholderText: viewModel.placeholderText)
            }
        default:
            cell.backgroundColor = .yellow
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension TBAddPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch PhotoEditorCellType(rawValue: indexPath.row) {
        case .name:
            return TBPhotoEditorInfomationCell.twoLinesCellHeight
        case .type:
            return TBPhotoEditorInfomationCell.twoLinesCellHeight
        case .time:
            return TBPhotoEditorPickerCell.cellHeight
        case .description:
            return TBPhotoEditorInputDescriptionCell.cellHeight
        default:
            return 0
        }
    }
}

extension TBAddPhotoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isReachBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        guard self.isReachBottom != isReachBottom else { return  }

        self.isReachBottom = isReachBottom
        saveButtonContainerTopLine.isHidden = !isReachBottom
        saveButtonContainer.addShadow(with: .DarkGray400, alpha: self.isReachBottom ? 0 : 1, radius: 2, offset: CGSize.zero)
    }
}

// MARK: PhotoEditorPickerCellDelegate
extension TBAddPhotoViewController: TBPhotoEditorPickerCellDelegate {
    func showPicker(indexPath: IndexPath?) {
        view.endEditing(true)
        weekPicker.showPicker()
    }
}

// MARK: UIPickerViewDataSource
extension TBAddPhotoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        4
    }
}

// MARK: UIPickerViewDelegate
extension TBAddPhotoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return "\(row)".attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
    }
}

// MARK: PhotoEditorInputDescriptionCellDelegate
extension TBAddPhotoViewController: TBPhotoEditorInputDescriptionCellDelegate {
    func updateContent(content: String) {
        viewModel.photoDescription = content
    }
}

// MARK: TBOldPickerViewDelegate
extension TBAddPhotoViewController: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        viewModel.pickerIndex = index
        tableView.reloadData()
    }
}
