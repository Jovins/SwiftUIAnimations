import UIKit

final class TBFeedingBreastButton: TBFeedingBaseButton {

    var timeText: String? {
        get {
            timeLabel.attributedText?.string
        }
        set {
            timeLabel.attributedText = newValue?.attributedText(.mulishLink2, foregroundColor: buttonState == .select ? .OffWhite : .GlobalTextPrimary)
        }
    }

    var buttonSide: TBNursingModel.Side = .left {
        didSet {
            let titleString = buttonSide == .left ? "L" : "R"
            largeTitleLabel.attributedText = titleString.attributedText(.mulishTitle1, alignment: .center)
        }
    }

    var buttonState: TBFeedingBreastButtonState = .normal {
        didSet {
            remakeConstraintsIfNeed()
        }
    }

    private let largeTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "L".attributedText(.mulishTitle1, alignment: .center)
        label.isHidden = false
        return label
    }()
    private let startImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "FeedingNursing_BreastStart")
        imageView.isHidden = true
        return imageView
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        cornerRadius = 63
        [largeTitleLabel, startImageView, timeLabel].forEach(addSubview)
        largeTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        startImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 34, height: 40))
        }
        timeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(22)
            $0.centerX.equalToSuperview()
        }
    }

    private func remakeConstraintsIfNeed() {
        switch buttonState {
        case .normal:
            largeTitleLabel.isHidden = false
            startImageView.isHidden = true
            timeLabel.isHidden = true
            largeTitleLabel.snp.remakeConstraints {
                $0.center.equalToSuperview()
            }
        case .select:
            largeTitleLabel.isHidden = true
            startImageView.isHidden = false
            timeLabel.isHidden = false
            timeLabel.attributedText = timeText?.attributedText(.mulishLink2, foregroundColor: .OffWhite)
        case .end:
            largeTitleLabel.isHidden = false
            startImageView.isHidden = true
            timeLabel.isHidden = false
            timeLabel.attributedText = timeText?.attributedText(.mulishLink2)
            largeTitleLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().inset(21)
                $0.centerX.equalToSuperview()
            }
        }
    }
}

extension TBFeedingBreastButton {
    enum TBFeedingBreastButtonState {
        case normal
        case select
        case end
    }
}
