import UIKit
import SnapKit

final class TBKickCounterAboutPageCell: UITableViewCell {

    private let containerView = UIView()
    private let subtextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = "Baby is getting more active now, and staying familiar with daily kicks and movements can have important benefits for baby’s development. Changes in baby’s movement pattern can alert you to problems early on and help you find solutions faster.".attributedText(.mulishBody3)
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Getting started".attributedText(.mulishTitle4)
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = "Some healthcare providers recommend monitoring baby’s daily kicks from 24 weeks for most pregnancies. Consult your healthcare provider to find out what timeframe is best for your pregnancy. Start the Kick Counter and log every time you feel baby kick. A good approach could be to see how long it takes to record 10 kicks each day. The Kick Counter will keep an ongoing record of baby’s daily times. For the most accurate results, be sure to record at the same time each day, ideally when baby is most active, such as after 9pm. If baby is taking longer than 2 hours to reach 10 kicks, there are a few things you can to prompt some movement. Try lying on your left side to help circulation, eating something sweet, having a cold drink or taking some light exercise to help get baby moving a little more. If baby’s movement still feels a bit low, consult your healthcare provider for more information.".attributedText(.mulishBody3)
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
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(UIDevice.width - 28)
        }
        [subtextLabel, titleLabel, messageLabel].forEach(containerView.addSubview)
        subtextLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(subtextLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview()
        }
    }
}
