import UIKit

protocol TBFeedingTrackerSettingCellDelegate: AnyObject {
    func didTapSwitchVisibleButton(model: TBFeedingTrackerSettingModel, sender: UIButton)
}

final class TBFeedingTrackerSettingCell: UITableViewCell {

    weak var delegate: TBFeedingTrackerSettingCellDelegate?
    private var settingModel: TBFeedingTrackerSettingModel?
    private let leadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "setting_drag")
        return imageView
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.backgroundColor = .Aqua
        imageView.cornerRadius = 20
        return imageView
    }()
    private let titleLabel = UILabel()
    private let visibleSwitchButton: UIButton = {
        let button = UIButton()
        button.setImage(TBIconList.eyeOpened.image(), for: .normal)
        button.setImage(TBIconList.eyeClosed.image(), for: .selected)
        return button
    }()
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()
    private let translucentMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .OffWhite.withAlphaComponent(0.5)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [leadingImageView, iconImageView, titleLabel, visibleSwitchButton, dividerView, translucentMaskView].forEach(contentView.addSubview)
        leadingImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(CGSize(width: 6, height: 18))
        }
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(leadingImageView.snp.trailing).offset(12)
            $0.size.equalTo(40)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
        }
        visibleSwitchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(40)
        }
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        translucentMaskView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        visibleSwitchButton.addTarget(self, action: #selector(didTapSwitchVisible(sender:)), for: .touchUpInside)
    }

    @objc private func didTapSwitchVisible(sender: UIButton) {
        guard let settingModel else { return }
        sender.isSelected = !sender.isSelected
        translucentMaskView.isHidden = !sender.isSelected
        delegate?.didTapSwitchVisibleButton(model: settingModel, sender: sender)
    }

    func setup(model: TBFeedingTrackerSettingModel) {
        settingModel = model
        iconImageView.image = model.type.iconImage?.resizeImage(newSize: CGSize(width: 24, height: 24))
        titleLabel.attributedText = model.type.title.attributedText(.mulishLink3)
        visibleSwitchButton.isSelected = !model.isVisible
        translucentMaskView.isHidden = model.isVisible
    }

}
