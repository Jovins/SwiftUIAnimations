import Foundation
import UIKit
import SnapKit

final class TBKickCounterTableViewCell: UITableViewCell {
    private let containerView: UIView = UIView()
    private let dateLabel: UILabel = UILabel()
    private let lengthLabel: UILabel = UILabel()
    private let kicksLabel: UILabel = UILabel()
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()

    private var model: TBKickCounterModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superview else { return }
        for subview in superview.subviews where String(describing: subview).range(of: "UISwipeActionPullView") != nil {
            for view in subview.subviews where String(describing: view).range(of: "UISwipeActionStandardButton") != nil {
                for sub in view.subviews {
                    if let label = sub as? UILabel {
                        label.textColor = .OffWhite
                    }
                }
            }
        }
    }

    private func setupUI() {
        selectionStyle = .none
        [containerView, lineView].forEach(contentView.addSubview)
        [dateLabel, lengthLabel, kicksLabel].forEach(containerView.addSubview)
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        containerView.addSubview(stackView)
        [dateLabel, lengthLabel, kicksLabel].forEach(stackView.addArrangedSubview)
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(51)
        }
        lineView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        dateLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 162, height: 18))
        }
        lengthLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 18))
        }
        kicksLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 18))
        }
        if UIDevice.isPad() {
            dateLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
            }
            lengthLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
            }
            kicksLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
            }
            containerView.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(82)
                $0.height.equalTo(52)
            }
        }
    }

    func setup(model: TBKickCounterModel) {
        self.model = model
        dateLabel.attributedText = model.startTimeToEndTimeString().attributedText(UIDevice.isPad() ? .mulishBody3 : .mulishBody4)
        lengthLabel.attributedText = model.startTimeToEndTimeLengthString().attributedText(UIDevice.isPad() ? .mulishBody3 : .mulishBody4, alignment: .center)
        kicksLabel.attributedText = "\(model.kickCounterCount)".attributedText(UIDevice.isPad() ? .mulishBody3 : .mulishBody4, alignment: .center)
    }
}
