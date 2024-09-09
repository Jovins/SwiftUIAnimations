import Foundation
import UIKit
import SnapKit

final class TBAllForumsHeaderView: UIView {
    private let welcomeLabel: UILabel = {
       let label = UILabel()
        label.font = TBFontType.mulishTitle1.font
        label.textColor = UIColor.tb_primaryCopy()
        label.text = "Welcome!"
        label.textAlignment = .center
        return label
    }()
    private let contentLabel: UILabel = {
       let label = UILabel()
        label.font = TBFontType.mulishBody1.font
        label.textColor = UIColor.tb_primaryCopy()
        label.text = "Find a board and join in!"
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [welcomeLabel, contentLabel].forEach(addSubview)

        welcomeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(27)
            $0.leading.trailing.equalToSuperview()
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
