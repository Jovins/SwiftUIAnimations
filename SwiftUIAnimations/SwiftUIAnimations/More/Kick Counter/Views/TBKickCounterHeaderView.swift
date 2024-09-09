import Foundation
import UIKit
import SnapKit

protocol TBKickCounterHeaderViewDelegate: AnyObject {
    func didTapResetData(model: TBKickCounterModel?, sender: UIControl)
    func didTapViewHistory()
}

extension TBKickCounterHeaderViewDelegate {
    func didTapResetData(model: TBKickCounterModel?, sender: UIControl) {}
    func didTapViewHistory() {}
}

final class TBKickCounterHeaderView: UITableViewHeaderFooterView {
    private let todayLabel: UILabel = UILabel()
    private let resetLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Reset Counter".attributedText(.mulishLink4,
                                                              additionalAttrsArray: [("Reset Counter", [.underlineStyle: NSUnderlineStyle.single.rawValue])])
        return label
    }()
    private let resetIcon: UIImageView = UIImageView(image: TBIconList.refresh.image(sizeOption: .small))
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Start & Stop Time".attributedText(UIDevice.isPad() ? .mulishLink3 : .mulishLink4)
        return label
    }()
    private let lengthLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Length".attributedText(UIDevice.isPad() ? .mulishLink3 : .mulishLink4, alignment: .center)
        return label
    }()
    private let kicksLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Kicks".attributedText(UIDevice.isPad() ? .mulishLink3 : .mulishLink4, alignment: .center)
        return label
    }()
    private let viewHistoryLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "View Kicks History".attributedText(.mulishLink4, additionalAttrsArray: [("View Kicks History", [.underlineStyle: NSUnderlineStyle.single.rawValue])])
        return label
    }()
    private let viewHistoryIcon: UIImageView = UIImageView(image: TBIconList.caretRight.image(sizeOption: .small))
    private let viewHistoryControl: UIControl = UIControl()
    private var model: TBKickCounterModel?
    private let resetControl: UIControl = UIControl()
    weak var delegate: TBKickCounterHeaderViewDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [todayLabel, resetLabel, resetIcon, resetControl,
         viewHistoryLabel, viewHistoryIcon, viewHistoryControl, containerView].forEach(contentView.addSubview)
        [dateLabel, lengthLabel, kicksLabel].forEach(containerView.addSubview)
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        contentView.addSubview(stackView)
        contentView.backgroundColor = .GlobalBackgroundPrimary
        [dateLabel, lengthLabel, kicksLabel].forEach(stackView.addArrangedSubview)
        todayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(18)
        }
        resetLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 87, height: 18))
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(40)
        }
        resetIcon.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalTo(resetLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        resetControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(resetLabel)
            $0.trailing.equalTo(resetIcon)
            $0.bottom.equalTo(containerView.snp.top)
        }
        viewHistoryLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 111, height: 18))
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(40)
        }
        viewHistoryIcon.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalTo(resetLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        viewHistoryControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(viewHistoryLabel)
            $0.trailing.equalTo(viewHistoryIcon)
            $0.bottom.equalTo(containerView.snp.top)
        }
        containerView.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        dateLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 162, height: 18))
            $0.centerY.equalToSuperview()
        }
        lengthLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 18))
            $0.centerY.equalToSuperview()
        }
        kicksLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 18))
            $0.centerY.equalToSuperview()
        }
        resetControl.addTarget(self, action: #selector(didTapResetData(sender:)), for: .touchUpInside)
        viewHistoryControl.addTarget(self, action: #selector(didTapViewHistory(sender:)), for: .touchUpInside)

        if UIDevice.isPad() {
            todayLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(20)
            }
            dateLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
                $0.centerY.equalToSuperview()
            }
            lengthLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
                $0.centerY.equalToSuperview()
            }
            kicksLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 188, height: 20))
                $0.centerY.equalToSuperview()
            }
            stackView.snp.remakeConstraints {
                $0.centerY.equalTo(containerView)
                $0.leading.trailing.equalToSuperview().inset(82)
            }
            containerView.snp.remakeConstraints {
                $0.height.equalTo(44)
                $0.bottom.leading.trailing.equalToSuperview()
            }
        }
    }

    func setup(model: TBKickCounterModel?, displayViewHistory: Bool = false, type: DisplayType) {
        self.model = model
        var text = "Today’s Kicks "
        switch type {
        case .resetCounter:
            [resetIcon, resetLabel, resetControl].forEach({$0.isHidden = false})
            [viewHistoryIcon, viewHistoryLabel, viewHistoryControl].forEach({$0.isHidden = true})
            if !(model?.startTime.isSameDayAs(otherDate: Date()) ?? true),
               let string = model?.startTime.convertToMMMdd() {
                text = string
                [resetIcon, resetLabel, resetControl].forEach({$0.isHidden = true})
            } else {
                [resetIcon, resetLabel, resetControl].forEach({$0.isHidden = false})
            }
        case .viewHistory:
            [resetIcon, resetLabel, resetControl].forEach({$0.isHidden = true})
            [viewHistoryIcon, viewHistoryLabel, viewHistoryControl].forEach({$0.isHidden = !displayViewHistory})
        }
        todayLabel.attributedText = text.attributedText(UIDevice.isPad() ? .mulishLink3 : .mulishLink4, foregroundColor: .DarkGray600)
    }

    @objc private func didTapResetData(sender: UIControl) {
        delegate?.didTapResetData(model: model, sender: sender)
    }

    @objc private func didTapViewHistory(sender: UIControl) {
        delegate?.didTapViewHistory()
    }
}

extension TBKickCounterHeaderView {
    enum DisplayType {
        case viewHistory
        case resetCounter
    }
}
