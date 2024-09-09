import UIKit

class TBFeedingTrackerCardBaseCell: UICollectionViewCell {

    let titleLabel: UILabel = UILabel()
    let addIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = TBIconList.plugs.image(sizeOption: .normal, color: .Magenta)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let feedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateImageView(type: FeedingTrackerToolType) {
        switch type {
        case .nursing:
            feedImageView.image = type.iconImage
            feedImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(-12)
                $0.bottom.equalToSuperview().inset(8)
                $0.size.equalTo(60)
            }
        case .bottle:
            feedImageView.image = type.iconImage
            feedImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(-20)
                $0.bottom.equalToSuperview().inset(8)
                $0.size.equalTo(60)
            }
        case .pumping:
            feedImageView.image = type.iconImage
            feedImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(-12)
                $0.bottom.equalToSuperview().inset(8)
                $0.size.equalTo(60)
            }
        case .diapers:
            feedImageView.image = type.iconImage
            feedImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(-12)
                $0.bottom.equalToSuperview()
                $0.size.equalTo(60)
            }
        }
    }

    func setBreastLabel(side: TBNursingModel.Side?, breastLabel: UILabel, subbreastLabel: UILabel) {
        guard let side else {
            subbreastLabel.isHidden = true
            breastLabel.frame = .zero
            return
        }
        switch side {
        case .left:
            breastLabel.attributedText = "LEFT BREAST".attributedText(.mulishOverline2, alignment: .center)
            breastLabel.frame = CGRect(x: 0, y: 0, width: 98, height: 25)
        case .right:
            breastLabel.attributedText = "RIGHT BREAST".attributedText(.mulishOverline2, alignment: .center)
            breastLabel.frame = CGRect(x: 0, y: 0, width: 108, height: 25)
        }
    }

    func getDateString(date: Date) -> String? {
        guard !date.isOverOneYearAs(otherDate: Date()) else {
            return date.convertToMMDDYYYY()
        }
        guard date.isSameDayAs(otherDate: Date()) else {
            return date.convertToMMMdd()
        }
        let seconds = date.seconds(to: Date())
        guard seconds >= 60 else {
            return "< 1 min ago"
        }
        let hour = seconds / 3600
        let minute = seconds % 3600 / 60
        var hourString = ""
        var minuteString = ""
        if hour != 0 {
            hourString = "\(hour) hr".pluralize(with: hour) + ". "
        }
        if minute != 0 {
            minuteString = "\(minute) min".pluralize(with: minute) + ". "
        }
        return hourString + minuteString + "ago"
    }
}
