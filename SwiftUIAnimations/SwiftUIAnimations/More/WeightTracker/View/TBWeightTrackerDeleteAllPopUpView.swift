import UIKit

protocol TBWeightTrackerDeleteAllPopUpViewDelegate: AnyObject {
    func confirmToDeleteAllData()
}

final class TBWeightTrackerDeleteAllPopUpView: UIView {

    weak var delegate: TBWeightTrackerDeleteAllPopUpViewDelegate?
    private var isChecked: Bool = false {
        didSet {
            print("check or uncheck")
            updateStatus()
        }
    }
    private let backgroundShadowView: UIView = {
        let view = UIView()
        view.addShadow(with: .black, alpha: 0.2, radius: 4, offset: CGSize(width: 0, height: 2))
        return view
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .OffWhite
        view.cornerRadius = 4
        return view
    }()
    private let topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .validationRed
        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(TBIconList.close.image(color: .DarkGray600), for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return button
    }()
    private let trashIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = 21
        imageView.backgroundColor = .validationRed
        imageView.image = TBIconList.trash.image(color: .OffWhite)
        imageView.contentMode = .center
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let titleAttributedString = "Delete Weight Tracker Data?".attributedText(.mulishLink2, alignment: .center) ?? NSAttributedString()
        let subTitleAttributedString = "\nSelecting Delete Data below will permanently delete all weight entries you have made on The Bump.".attributedText(.mulishBody2, alignment: .center) ?? NSAttributedString()
        var attributedString = NSMutableAttributedString()
        attributedString.append(titleAttributedString)
        attributedString.append(subTitleAttributedString)
        label.attributedText = attributedString
        return label
    }()
    private let checkBoxButton: UIButton = {
        let button = UIButton()
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        button.setImage(TBIconList.OriginalIcon.checkbox.image(), for: .normal)
        button.setImage(TBIconList.OriginalIcon.checkboxSelectedFillValidationRed.image(), for: .selected)
        return button
    }()
    private let checkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = 4
        button.borderWidth = 1
        button.borderColor = .OffWhite
        button.setAttributedTitle("Delete Data".attributedText(.mulishLink2, foregroundColor: .GlobalTextSecondary), for: .normal)
        return button
    }()
    private let cancelButton: UIButton = {
        let button = UIButton()
        let attributedString = "Don't Delete My Weight Data".attributedText(.mulishLink3,
                                                                            additionalAttrsArray: [("Don't Delete My Weight Data", [.underlineStyle: NSUnderlineStyle.single.rawValue])])
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateStatus()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .Navy.withAlphaComponent(0.5)
        [backgroundShadowView, containerView].forEach(addSubview)
        [topLineView, closeButton, trashIconImageView, titleLabel, checkBoxButton, checkLabel, deleteButton, cancelButton].forEach(containerView.addSubview)
        let checkLayoutGuide = UILayoutGuide()
        addLayoutGuide(checkLayoutGuide)
        backgroundShadowView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        if UIDevice.isPad() {
            containerView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.size.equalTo(CGSize(width: 335, height: 433))
            }
        } else {
            containerView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(433)
            }
        }
        topLineView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(5)
        }
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        trashIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(48)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(42)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(trashIconImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        checkLayoutGuide.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalTo(containerView).inset(20)
            $0.bottom.equalTo(deleteButton.snp.top).offset(-20)
        }
        checkBoxButton.snp.makeConstraints {
            $0.top.equalTo(checkLabel)
            $0.leading.equalTo(checkLayoutGuide)
            $0.size.equalTo(24)
        }
        checkLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBoxButton.snp.trailing).offset(4)
            $0.top.trailing.bottom.equalTo(checkLayoutGuide)
        }
        deleteButton.snp.makeConstraints {
            $0.bottom.equalTo(cancelButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 160, height: 40))
        }
        cancelButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(27)
        }
        checkBoxButton.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteData), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    }

    func show() {
        let window = AppDelegate.sharedInstance().window
        window?.addSubview(self)
        self.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func updateStatus() {
        let checkLabelText = "I understand that once I delete my Weight Tracker data it cannot be restored."
        checkBoxButton.isSelected = isChecked
        if isChecked {
            deleteButton.backgroundColor = .validationRed
            checkLabel.attributedText = checkLabelText.attributedText(.mulishLink2)
        } else {
            deleteButton.backgroundColor = .DarkGray400
            checkLabel.attributedText = checkLabelText.attributedText(.mulishBody2)
        }
    }

    @objc private func didTapCheckBox() {
        isChecked = !isChecked
    }

    @objc private func didTapDeleteData() {
        if isChecked {
            delegate?.confirmToDeleteAllData()
            self.removeFromSuperview()
        }
    }

    @objc private func didTapCancel() {
        self.removeFromSuperview()
    }

}
