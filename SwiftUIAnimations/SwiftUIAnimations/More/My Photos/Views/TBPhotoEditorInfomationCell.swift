import UIKit
import FullStory

final class TBPhotoEditorInfomationCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()

    static let oneLineCellHeight = 40.0
    static let twoLinesCellHeight = 64.0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .GlobalBackgroundPrimary
        contentView.clipsToBounds = true
        [titleLabel, contentLabel].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(20)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupTwoLinesContentCell(title: String, content: String) {
        titleLabel.attributedText = title.attributedText(.mulishLink3, foregroundColor: .DarkGray600)
        contentLabel.attributedText = content.attributedText(.mulishLink2, lineBreakMode: .byTruncatingTail)
        contentLabel.snp.remakeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(20)
        }
    }

    func setupOneLineContentCell(prefix: String, time: String) {
        titleLabel.attributedText = prefix.attributedText(.mulishLink3, foregroundColor: .DarkGray600)
        contentLabel.attributedText = time.attributedText(.mulishLink2)
        contentLabel.snp.remakeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.left.equalTo(titleLabel.snp.right).offset(4)
        }
    }

    func maskContent(_ shouldMask: Bool = true) {
        if shouldMask {
            FS.mask(views: contentLabel)
        } else {
            FS.unmask(views: contentLabel)
        }
    }
}
