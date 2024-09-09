import UIKit

final class TBAboutPageTableViewCell: UITableViewCell {

    private let containerView: UIView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var linkTextView = TBLinkTextView.buildLinkTextView { (url, _)  in
        AppRouter.navigateToDeepLinkUrl(url)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.removeFromSuperview()
        linkTextView.removeFromSuperview()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(UIDevice.width - 28)
        }
    }

    func setupData(data: (attributed: NSMutableAttributedString?, isTextLink: Bool)) {
        if data.isTextLink {
            containerView.addSubview(linkTextView)
            linkTextView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview().inset(12)
                $0.bottom.top.equalToSuperview()
            }
            linkTextView.linkTextAttributes = [:]
            linkTextView.attributedText = data.attributed
        } else {
            containerView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview().inset(12)
                $0.bottom.top.equalToSuperview()
            }
            titleLabel.attributedText = data.attributed
        }
    }
}
