import UIKit
import RxSwift

protocol TBMovePhotosViewControllerDelegate: NSObjectProtocol {
    func photosDidFinishMoving(photoIds: [String], selectAlbum: TBAlbumModel?, selectPhoto: TBPhotosModel?)
}

final class TBMovePhotosViewController: UIViewController {

    var profilesModel: [TBAlbumsProfileModel]?
    var photoIds = [String]()
    weak var delegate: TBMovePhotosViewControllerDelegate?
    private let closeButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24)))
        button.setImage(TBIconList.close.image(sizeOption: .normal, color: .DarkGray500), for: .normal)
        button.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        return button
    }()
    private let titleLabel: UILabel = UILabel()
    private let albumNameContainerView: UIView = UIView()
    private let albumNameTextField: TBTextField = {
        let textField = TBTextField()
        textField.hintText = "Album Name:"
        textField.placeholder = "Select an ablum profile"
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(), backgroundColor: nil, for: .normal)
        textField.isUserInteractionEnabled = false
        textField.maskInputContent(true)
        return textField
    }()
    private let albumTypeContainerView: UIView = UIView()
    private let albumTypeTextField: TBTextField = {
        let textField = TBTextField()
        textField.hintText = "Album Type:"
        textField.placeholder = "Select an album type"
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(), backgroundColor: nil, for: .normal)
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(sizeOption: .normal, color: .DarkGray500), backgroundColor: nil, for: .disabled)
        textField.isUserInteractionEnabled = false
        textField.isEnable = false
        textField.maskInputContent(true)
        return textField
    }()
    private let collectionContainerView: UIView = UIView()
    private let collectionTextField: TBTextField = {
        let textField = TBTextField()
        textField.hintText = "Collection:"
        textField.placeholder = "Select a week/month/year"
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(), backgroundColor: nil, for: .normal)
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(sizeOption: .normal, color: .DarkGray500), backgroundColor: nil, for: .disabled)
        textField.isUserInteractionEnabled = false
        textField.isEnable = false
        textField.maskInputContent(true)
        return textField
    }()
    private let saveCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.buttonState = .primary
        button.buttonWidthStyle = .stretch
        button.setTitle("Submit", for: .normal)
        button.isEnabled = false
        return button
    }()
    private lazy var pickerView: TBOldPickerView = {
        let picker = TBOldPickerView(frame: UIScreen.main.bounds)
        let adapter = TBPickerDefaultAdapter()
        picker.adapter = adapter
        picker.delegate = self
        return picker
    }()
    private let loadingHUD: TBLoadingHUD = TBLoadingHUD()
    private var selectType: TBAlbumSelectType = .albumName
    private var selectProfile: TBAlbumsProfileModel? {
        didSet {
            guard let selectProfile = selectProfile, selectProfile != oldValue else {
                return
            }
            resetData()
            albumNameTextField.text = selectProfile.name
            albumTypeTextField.isEnable = true
            setAlbumTypeData()
        }
    }
    private var selectAlbums: [TBAlbumModel] {
        guard let selectProfile = selectProfile else { return [] }
        return selectProfile.albums ?? []
    }
    private var selectAlbumTypes: [String] {
        return selectAlbums.compactMap { album -> String? in
            switch album.albumType {
            case .pregnant:
                return "Pregnancy Photos"
            case .child:
                return "Baby Photos"
            case .toddler:
                return "Toddler Photos"
            default:
                return nil
            }
        }
    }
    private var selectAlbumType: String = ""
    private var selectAlbum: TBAlbumModel? {
        didSet {
            guard let selectAlbum = selectAlbum, selectAlbum != oldValue else { return }
            switch selectAlbum.albumType {
            case .pregnant:
                selectPhotos = selectAlbum.pregnancyPhotos
            case .child:
                selectPhotos = selectAlbum.childPhotos
            case .toddler:
                selectPhotos = selectAlbum.toddlerPhotos.flatMap({ $0 })
            default:
                break
            }
            albumTypeTextField.text = selectAlbumType
            collectionTextField.isEnable = true
            collectionTextField.text = ""
        }
    }
    private var selectPhotos = [TBPhotosModel]()
    private var selectPhoto: TBPhotosModel?
    private var selectCollections: [String] {
        guard let album = selectAlbum else { return [] }
        return selectPhotos.compactMap { photo -> String? in
            switch album.albumType {
            case .pregnant:
                guard let week = photo.week else { return nil }
                return "Week \(week)"
            case .child:
                guard let week = photo.week else { return nil }
                return week == 0 ? "Newborn" : "Week \(week)"
            case .toddler:
                guard let year = photo.year else { return nil }
                if year >= 3 {
                    return "\(year) Years Old"
                } else if let month = photo.month {
                   return "\(month) Months"
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
    }
    private let networkHelper = TBMyPhotosNetworkHelper()
    private let disposed = DisposeBag()

    private var originalName = ""
    private var originalType = ""
    private var originalCollection = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAlbumNameData()
        setAlbumTypeData()
        setOriginalData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        titleLabel.attributedText = "Move \("Photo".pluralize(with: photoIds.count)) to:".attributedText(.mulishTitle4)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        [closeButton, titleLabel, albumNameContainerView, albumTypeContainerView, collectionContainerView, saveCTA].forEach(view.addSubview)
        albumNameContainerView.addSubview(albumNameTextField)
        albumTypeContainerView.addSubview(albumTypeTextField)
        collectionContainerView.addSubview(collectionTextField)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIDevice.statusBarHeight + 16)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(UIDevice.statusBarHeight + 58)
        }
        albumNameContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp_bottom).offset(16)
            $0.height.equalTo(72)
        }
        albumNameTextField.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        albumTypeContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(albumNameContainerView.snp_bottom).offset(16)
            $0.height.equalTo(72)
        }
        albumTypeTextField.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        collectionContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(albumTypeContainerView.snp_bottom).offset(16)
            $0.height.equalTo(72)
        }
        collectionTextField.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        saveCTA.snp.makeConstraints {
            $0.top.equalTo(collectionContainerView.snp_bottom).offset(56)
            $0.centerX.equalToSuperview()
        }
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        saveCTA.addTarget(self, action: #selector(didTapSaveCTA), for: .touchUpInside)
        albumNameContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAlbumName)))
        albumTypeContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAlbumType)))
        collectionContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCollection)))
    }

    private func setAlbumNameData() {
        guard let profilesModel = profilesModel, profilesModel.count == 1 else { return }
        selectProfile = profilesModel[0]
        albumNameTextField.text = profilesModel[0].name
        albumTypeTextField.isEnable = true
    }

    private func setAlbumTypeData() {
        guard selectAlbums.count == 1, let album = selectAlbums[safe: 0], let selectAlbumType = selectAlbumTypes[safe: 0] else { return }
        selectAlbum = album
        switch album.albumType {
        case .pregnant:
            selectPhotos = album.pregnancyPhotos
        case .child:
            selectPhotos = album.childPhotos
        case .toddler:
            selectPhotos = album.toddlerPhotos.flatMap({ $0 })
        default:
            break
        }
        albumTypeTextField.text = selectAlbumType
        collectionTextField.isEnable = true
    }

    private func setOriginalData() {
        originalName = albumNameTextField.text ?? ""
        originalType = albumTypeTextField.text ?? ""
        originalCollection = collectionTextField.text ?? ""
    }

    private var userDidEdited: Bool {
        guard originalName == albumNameTextField.text ?? "",
              originalType == albumTypeTextField.text ?? "",
              originalCollection == collectionTextField.text ?? "" else {
            return true
        }
        return false
    }

    private func resetData() {
        albumTypeTextField.text = ""
        albumTypeTextField.isEnable = false
        selectPhotos = []
        selectPhoto = nil
        collectionTextField.text = ""
        collectionTextField.isEnable = false
        saveCTA.isEnabled = false
        setAlbumNameData()
        setAlbumTypeData()
    }

    private func checkSaveCTAState() {
        guard let albumName = albumNameTextField.text, !albumName.isEmpty,
              let albumType = albumTypeTextField.text, !albumType.isEmpty,
              let collection = collectionTextField.text, !collection.isEmpty else {
            saveCTA.isEnabled = false
            return
        }
        saveCTA.isEnabled = true
    }

    @objc private func didTapClose() {
        if userDidEdited {
            let alertView = UIAlertController(title: "You have unsaved changes.\rAre you sure to exit?", message: "", preferredStyle: .alert)
            let actionYes = UIAlertAction(title: "Yes", style: .default) { [self] _ in
                dismiss(animated: true, completion: nil)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .default)
            alertView.addAction(actionYes)
            alertView.addAction(actionCancel)
            alertView.preferredAction = actionCancel
            AppRouter.shared.navigator.present(alertView)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func didTapAlbumName() {
        selectType = .albumName
        (pickerView.adapter as? TBPickerDefaultAdapter)?.items = profilesModel?.compactMap({$0.name}) ?? []
        pickerView.setupPicker(with: self, showIndex: nil)
        pickerView.showPicker()
    }

    @objc private func didTapAlbumType() {
        selectType = .albumType
        guard let albumName = albumNameTextField.text, !albumName.isEmpty else { return }
        (pickerView.adapter as? TBPickerDefaultAdapter)?.items = selectAlbumTypes
        pickerView.setupPicker(with: self, showIndex: nil)
        pickerView.showPicker()
    }

    @objc private func didTapCollection() {
        selectType = .collection
        guard let albumType = albumTypeTextField.text, !albumType.isEmpty else { return }
        (pickerView.adapter as? TBPickerDefaultAdapter)?.items = selectCollections
        pickerView.setupPicker(with: self, showIndex: nil)
        pickerView.showPicker()
    }

    @objc private func didTapSaveCTA() {
        guard let albumId = selectAlbum?.id, let photo = selectPhoto else { return }
        loadingHUD.show()
        networkHelper.moveAlbums(albumId: albumId, photoIds: photoIds,
                                 week: photo.week, month: photo.month, year: photo.year).observeOn(MainScheduler.instance).subscribe { [weak self] (response) in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            guard "\(response.statusCode)".hasPrefix("2") else { return }
            self.delegate?.photosDidFinishMoving(photoIds: self.photoIds, selectAlbum: self.selectAlbum, selectPhoto: self.selectPhoto)
            self.dismiss(animated: true)
        } onError: { [weak self] _ in
            guard let self = self else { return }
            self.loadingHUD.dismiss()
            TBErrorToastView.showErrorMessageToTopVC(edgeInsets: UIEdgeInsets(top: UIDevice.navigationBarHeight + 12, left: 20, bottom: 0, right: 20),
                                                     message: "An error occurred. Please try again or contact us if the problem persists.".attributedText(.mulishBody3))
        }.disposed(by: disposed)
    }
}

extension TBMovePhotosViewController: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        switch selectType {
        case .albumName:
            guard let model = profilesModel?[safe: index] else { return }
            selectProfile = model
            checkSaveCTAState()
        case .albumType:
            guard let album = selectAlbums[safe: index], let albumType = selectAlbumTypes[safe: index] else { return }
            selectAlbumType = albumType
            selectAlbum = album
            checkSaveCTAState()
        case .collection:
            guard let photo = selectPhotos[safe: index], let selectString = selectCollections[safe: index] else { return }
            selectPhoto = photo
            collectionTextField.text = selectString
            checkSaveCTAState()
        }
    }
}

extension TBMovePhotosViewController {
    enum TBAlbumSelectType {
        case albumName
        case albumType
        case collection
    }
}
