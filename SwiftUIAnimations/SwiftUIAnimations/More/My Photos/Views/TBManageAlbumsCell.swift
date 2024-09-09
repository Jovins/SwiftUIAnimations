import UIKit

final class TBManageAlbumsCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray300
        view.isHidden = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        [titleLabel, dividerLine].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(32)
            $0.trailing.equalToSuperview().inset(20)
        }
        dividerLine.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(32)
            $0.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(album: TBAlbumModel, shouldShowDividerLine: Bool = false) {
        if let type = album.type {
            var title = ""
            switch type {
            case "pregnant":
                title = "Pregnancy Photos"
            case "child":
                title = "Baby Photos"
            case "toddler":
                title = "Toddler Photos"
            default:
                break
            }
            titleLabel.attributedText = title.attributedText(.mulishLink3,
                                                             foregroundColor: album.photos?.isEmpty == false ? .GlobalTextPrimary : .DarkGray500)
        }
        dividerLine.isHidden = !shouldShowDividerLine
    }
}
