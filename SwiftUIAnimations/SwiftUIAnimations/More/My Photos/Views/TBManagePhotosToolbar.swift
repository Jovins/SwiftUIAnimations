import UIKit
import SnapKit

protocol TBManagePhotosToolbarDelegate: NSObjectProtocol {
    func didTapToolbarShareCTA(sender: Any)
    func didTapToolbarEditCTA()
    func didTapToolbarManageCTA(sender: Any)
}

extension TBManagePhotosToolbarDelegate {
    func didTapToolbarShareCTA(sender: Any) {}
    func didTapToolbarEditCTA() {}
    func didTapToolbarManageCTA(sender: Any) {}
}

final class TBManagePhotosToolbar: UIView {

    var isEditing: Bool = false {
        didSet {
            editCTA.isHidden = !isEditing
            manageCTALeadingConstraint?.update(offset: isEditing ? 90 : 24)
        }
    }
    var isEnabled: Bool = false {
        didSet {
            guard isEnabled != oldValue else { return }
            shareCTA.isEnabled = isEnabled
            editCTA.isEnabled = isEnabled
            manageCTA.isEnabled = isEnabled
        }
    }
    var showShadow: Bool = false {
        didSet {
            guard showShadow != oldValue else { return }
            layer.shadowColor = showShadow ? UIColor.rgb173_173_173.withAlphaComponent(0.15).cgColor : UIColor.clear.cgColor
            borderColor = showShadow ? UIColor.clear : .DarkGray200
        }
    }
    weak var delegate: TBManagePhotosToolbarDelegate?
    static let toolbarHeight: CGFloat = 84
    private let shareCTA: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 42, height: 48)))
        button.setAttributedTitle("Share".attributedText(.mulish_regular_10_16, foregroundColor: UIColor.DarkGray600), for: .normal)
        button.setAttributedTitle("Share".attributedText(.mulish_regular_10_16, foregroundColor: UIColor.DarkGray400), for: .disabled)
        button.setImage(TBIconList.externalLink.image(), for: .normal)
        button.setImage(TBIconList.externalLink.image(sizeOption: .normal, color: .DarkGray400), for: .disabled)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: -32, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -24, left: 9, bottom: 0, right: -9)
        button.contentEdgeInsets = UIEdgeInsets.zero
        return button
    }()
    private let editCTA: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 42, height: 48)))
        button.setAttributedTitle("Edit".attributedText(.mulish_regular_10_16, foregroundColor: UIColor.DarkGray600), for: .normal)
        button.setAttributedTitle("Edit".attributedText(.mulish_regular_10_16, foregroundColor: UIColor.DarkGray400), for: .disabled)
        button.setImage(TBIconList.edit.image(), for: .normal)
        button.setImage(TBIconList.edit.image(sizeOption: .normal, color: .DarkGray400), for: .disabled)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: -32, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -24, left: 9, bottom: 0, right: -9)
        button.contentEdgeInsets = UIEdgeInsets.zero
        button.isHidden = true
        return button
    }()
    private let manageCTA: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 42, height: 48)))
        button.setAttributedTitle("Manage".attributedText(.mulish_regular_10_16, foregroundColor: UIColor.DarkGray600), for: .normal)
        button.setAttributedTitle("Manage".attributedText(.mulish_regular_10_16, foregroundColor: UIColor.DarkGray400), for: .disabled)
        button.setImage(TBIconList.moreSelected.image(), for: .normal)
        button.setImage(TBIconList.moreSelected.image(sizeOption: .normal, color: .DarkGray400), for: .disabled)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: -32, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -24, left: 9, bottom: 0, right: -9)
        button.contentEdgeInsets = UIEdgeInsets.zero
        return button
    }()
    private var manageCTALeadingConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .GlobalBackgroundPrimary
        borderWidth = 1
        borderColor = .DarkGray200
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 5
        heightConstraint.constant = TBManagePhotosToolbar.toolbarHeight
        widthConstraint.constant = UIScreen.width
        [shareCTA, editCTA, manageCTA].forEach(addSubview)
        shareCTA.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(12)
            $0.size.equalTo(CGSize(width: 42, height: 48))
        }
        editCTA.snp.makeConstraints {
            $0.leading.equalTo(shareCTA.snp_trailing).offset(24)
            $0.top.equalToSuperview().inset(12)
            $0.size.equalTo(CGSize(width: 42, height: 48))
        }
        manageCTA.snp.makeConstraints {
            manageCTALeadingConstraint = $0.leading.equalTo(shareCTA.snp_trailing).offset(24).constraint
            $0.top.equalToSuperview().inset(12)
            $0.size.equalTo(CGSize(width: 42, height: 48))
        }
        shareCTA.isEnabled = isEnabled
        editCTA.isEnabled = isEnabled
        manageCTA.isEnabled = isEnabled
        shareCTA.addTarget(self, action: #selector(didTapShareCTA(sender:)), for: .touchUpInside)
        editCTA.addTarget(self, action: #selector(didTapEditCTA), for: .touchUpInside)
        manageCTA.addTarget(self, action: #selector(didTapManageCTA(sender:)), for: .touchUpInside)
    }

    private lazy var heightConstraint: NSLayoutConstraint = {
        let heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        return heightConstraint
    }()

    private lazy var widthConstraint: NSLayoutConstraint = {
        let widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive = true
        return widthConstraint
    }()

    @objc private func didTapShareCTA(sender: Any) {
        delegate?.didTapToolbarShareCTA(sender: sender)
    }

    @objc private func didTapEditCTA() {
        delegate?.didTapToolbarEditCTA()
    }

    @objc private func didTapManageCTA(sender: Any) {
        delegate?.didTapToolbarManageCTA(sender: sender)
    }
}
