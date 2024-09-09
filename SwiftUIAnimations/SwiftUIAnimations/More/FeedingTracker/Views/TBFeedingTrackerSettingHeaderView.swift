import UIKit

final class TBFeedingTrackerSettingHeaderView: UITableViewHeaderFooterView {

    private let titlelabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .Blush
        contentView.addSubview(titlelabel)
        titlelabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
        }
    }

    func setup(title: String) {
        titlelabel.attributedText = title.attributedText(.mulishLink4)
    }

}
