import Foundation
import SnapKit

extension TBAllForumsCategoryTableViewCell {

    @objc func setupAllForumsCategoryCellConstraints() {
        categoryTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
        }
        expansionArrow.snp.makeConstraints {
            $0.leading.equalTo(categoryTitleLabel.snp.trailing)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(15)
        }
    }

}
