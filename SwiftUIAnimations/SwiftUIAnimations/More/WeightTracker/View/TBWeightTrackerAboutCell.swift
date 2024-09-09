import UIKit
import SnapKit

final class TBWeightTrackerAboutCell: UITableViewCell {

    private let containerView: UIView = UIView()
    private let bulletView: UIView = {
        let view = UIView()
        view.backgroundColor = .GlobalTextPrimary
        view.cornerRadius = 2
        view.isHidden = true
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private var bulletViewLeadingConstraint: Constraint?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(UIDevice.width - 28)
        }
        [bulletView, titleLabel].forEach(containerView.addSubview)
        bulletView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(6)
            $0.top.equalToSuperview().inset(10)
            $0.size.equalTo(4)
        }
        titleLabel.snp.makeConstraints {
            bulletViewLeadingConstraint = $0.leading.equalToSuperview().inset(0).constraint
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.top.equalToSuperview()
        }
    }

    func setupData(data: (attributed: NSMutableAttributedString?, isBullet: Bool)) {
        bulletView.isHidden = !data.isBullet
        bulletViewLeadingConstraint?.update(inset: data.isBullet ? 18 : 0)
        titleLabel.attributedText = data.attributed
    }
}
