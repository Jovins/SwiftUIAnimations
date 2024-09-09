import Foundation
import SnapKit

extension TBAllForumsIndividualForumTableViewCell {

    @objc func setupAllForumsIndividualForumCellConstraints() {
        favoriteButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-3)
            $0.width.equalTo(40)
        }
        forumTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(favoriteButton.snp.trailing)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        openForumImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
            $0.width.equalTo(15)
        }
    }

    @objc func updateFavoriteButtonWidth(_ width: CGFloat) {
        favoriteButton.snp.updateConstraints {
            $0.width.equalTo(width)
        }
    }

}
