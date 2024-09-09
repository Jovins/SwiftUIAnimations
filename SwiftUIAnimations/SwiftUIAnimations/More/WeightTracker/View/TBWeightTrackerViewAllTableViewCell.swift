import UIKit
import SnapKit

final class TBWeightTrackerViewAllTableViewCell: UITableViewCell {
    private let viewAllLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "View All".attributedText(.mulishLink3, additionalAttrsArray: [("View All", [.underlineStyle: NSUnderlineStyle.single.rawValue])])
        return label
    }()
    private let iconImageView: UIImageView = UIImageView(image: TBIconList.caretRight.image(sizeOption: .small))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        [viewAllLabel, iconImageView].forEach(contentView.addSubview)
        let layout = UILayoutGuide()
        contentView.addLayoutGuide(layout)
        layout.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        viewAllLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(2)
            $0.size.equalTo(CGSize(width: 56, height: 19))
            $0.leading.equalTo(layout)
        }
        iconImageView.snp.makeConstraints {
            $0.centerY.equalTo(viewAllLabel)
            $0.leading.equalTo(viewAllLabel.snp.trailing).offset(4)
            $0.size.equalTo(16)
            $0.trailing.equalTo(layout)
        }
    }
}
