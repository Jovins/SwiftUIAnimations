import Foundation
import UIKit

final class TBKickCounterEmptyCell: UITableViewCell {
    private let titleLabel: UILabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(18)
            $0.centerX.equalToSuperview()
        }
    }

    func setup(text: String?) {
        titleLabel.attributedText = text?.attributedText(.mulishLink4, alignment: .center)
    }
}
