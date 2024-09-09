import UIKit

final class TBMoreTableViewCell: UITableViewCell {
    private let dividingLine = UIView()
    private let menuIconImageView = UIImageView()
    private let rightCaretImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.image = TBIconList.caretRight.image(sizeOption: .normal,
                                                      color: .GlobalTextPrimary)
        return imageView
    }()

    private let menuTitleLabel = UILabel()
    private let newLabel: TBNewLabel = {
        let label = TBNewLabel()
        label.isHidden = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        [menuIconImageView, rightCaretImageView].forEach {
            $0.contentMode = .scaleAspectFit
            contentView.addSubview($0)
        }
        [menuTitleLabel, newLabel, dividingLine].forEach(contentView.addSubview)
        dividingLine.backgroundColor = .rgb246_246_248
        setupConstraints()
    }

    private func setupConstraints() {
        menuIconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }

        menuTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(52)
            $0.centerY.equalToSuperview()
        }

        newLabel.snp.makeConstraints {
            $0.leading.equalTo(menuTitleLabel.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(rightCaretImageView.snp.leading).offset(-8)
        }

        rightCaretImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(TBIconList.SizeOption.normal.size)
            make.centerY.equalToSuperview()
        }

        dividingLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setup(menu: TBMoreViewModel.MoreMenu) {
        menuTitleLabel.attributedText = menu.title.attributedText(.mulishLink2, foregroundColor: .GlobalTextPrimary)
        rightCaretImageView.isHidden = !menu.shouldDisplayRightCaret
        let image = menu.icon.image(color: .CornFlower)
        menuIconImageView.image = image
        menuIconImageView.isHidden = image == nil
        menuTitleLabel.snp.updateConstraints {
            $0.leading.equalToSuperview().inset(image == nil ? 20 : 52)
        }
        newLabel.isHidden = !TBNewItemIndicatorManager.shared.shouldShowIndicator(indicatorType: .new, indicatorItemType: menu.indicatorItemType)
    }
}
