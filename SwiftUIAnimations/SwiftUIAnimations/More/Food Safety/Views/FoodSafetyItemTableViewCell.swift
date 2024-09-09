import UIKit

class FoodSafetyItemTableViewCell: UITableViewCell {
    let itemNameLabel = UILabel(frame: CGRect.zero)
    let severityIconContainer = UIView(frame: CGRect.zero)
    let rightArrowImageView = UIImageView(image: TBIconList.caretRight.image(sizeOption: .normal, color: .GlobalTextPrimary))
    private let iconHeight = 20
    private let separatorView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .GlobalBackgroundPrimary

        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        separatorView.backgroundColor = .DarkGray300
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.trailing.leading.equalToSuperview()
        }

        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemNameLabel)

        severityIconContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(severityIconContainer)

        rightArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightArrowImageView)

        let viewsDictionary = ["itemNameLabel": itemNameLabel, "severityIconContainer": severityIconContainer, "rightArrowImageView": rightArrowImageView]

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[itemNameLabel]-20-|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[itemNameLabel]-4-[severityIconContainer(iconHeight)]-8-|",
                                                                  options: .alignAllLeading,
                                                                  metrics: ["iconHeight": iconHeight],
                                                                  views: viewsDictionary))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[severityIconContainer]-20-|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightArrowImageView]-20-|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        contentView.addConstraint(NSLayoutConstraint(item: rightArrowImageView,
                                                     attribute: .centerY,
                                                     relatedBy: .equal,
                                                     toItem: self.contentView,
                                                     attribute: .centerY,
                                                     multiplier: 1,
                                                     constant: 0))
    }

    func setup(model: TBFoodSafetyModel) {

        itemNameLabel.attributedText = model.name?.attributedText(.mulishLink2)
        for view in severityIconContainer.subviews {
            view.removeFromSuperview()
        }

        let restrictions = model.sortedRestrictions()
        if restrictions.count > 0 {
            var constraintString = ""
            var iconsDict = [String: UIView]()
            let iconGap = 8
            var currentIndex = 0

            for restriction in restrictions {
                let icon = FoodSafetyIconView(restriction: restriction)
                icon.layer.cornerRadius = CGFloat(iconHeight/2)
                severityIconContainer.addSubview(icon)

                let iconName = "icon\(currentIndex)"
                iconsDict[iconName] = icon

                if constraintString.count == 0 {
                    constraintString = "H:|[\(iconName)(\(iconHeight))]"
                } else {
                    constraintString += "-\(iconGap)-[\(iconName)(\(iconHeight))]"
                }

                severityIconContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[\(iconName)]|",
                    options: [],
                    metrics: nil,
                    views: iconsDict))

                currentIndex = currentIndex + 1
            }

            severityIconContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraintString,
                                                                                options: [],
                                                                                metrics: nil,
                                                                                views: iconsDict))
        }
    }
}

class FoodSafetyIconView: UIView {
    var customBackgroundColor = UIColor.OffWhite {
        didSet {
            backgroundColor = customBackgroundColor
        }
    }
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != customBackgroundColor {
                backgroundColor = customBackgroundColor
            }
        }
    }

    convenience init(restriction: TBFoodSafetyRestriction) {
        self.init(frame: CGRect())

        translatesAutoresizingMaskIntoConstraints = false

        if let security = restriction.severity,
           let hex = security.hex {
            customBackgroundColor = UIColor(hex: "#\(hex)", alpha: 1)
            backgroundColor = customBackgroundColor
        }

        clipsToBounds = true

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        if let security = restriction.severity,
           let severityIconImageURL = URL(string: security.iconUrl ?? "") {
            iconImageView.sd_setImage(with: severityIconImageURL,
                                      placeholderImage: restriction.placeholderImage,
                                      options: .retryFailed)
        } else {
            iconImageView.image = restriction.placeholderImage
        }
        iconImageView.contentMode = .scaleAspectFill
        addSubview(iconImageView)

        let viewsDictionary = ["iconImageView": iconImageView]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[iconImageView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[iconImageView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }
}
