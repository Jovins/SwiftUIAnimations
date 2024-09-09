import UIKit

final class TBFeedingTrackerEmptyCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [titleLabel, dividerView].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
            $0.bottom.equalTo(dividerView.snp.top).offset(-16)
        }
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func setup(text: String) {
        titleLabel.attributedText = text.attributedText(.mulishBody4, foregroundColor: .DarkGray600)
    }
}
