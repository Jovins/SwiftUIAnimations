import UIKit

class FoodSafetyItemDetailView: UIView {
    let backgroundScrollView = UIScrollView(frame: CGRect.zero)
    let contentView = UIView(frame: CGRect.zero)

    let itemImageView = UIImageView(frame: CGRect.zero)
    let imageMaskView = UIView(frame: CGRect.zero)

    let restrictionTitleLabel = UILabel(frame: CGRect.zero)
    let itemTitleLabel = UILabel(frame: CGRect.zero)

    let severityBackgroundView = UIView(frame: CGRect.zero)
    let severityIconView = UIImageView(frame: CGRect.zero)
    let severityNameLabel = UILabel(frame: CGRect.zero)
    let detailsBackgroundView = UIView(frame: CGRect.zero)
    let detailsLabel = UILabel(frame: CGRect.zero)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.tb_lines()

        backgroundScrollView.translatesAutoresizingMaskIntoConstraints = false
        backgroundScrollView.backgroundColor = UIColor.tb_lines()
        backgroundScrollView.showsVerticalScrollIndicator = false
        addSubview(backgroundScrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.tb_lines()
        backgroundScrollView.addSubview(contentView)

        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.layer.masksToBounds = true
        contentView.addSubview(itemImageView)

        imageMaskView.translatesAutoresizingMaskIntoConstraints = false
        imageMaskView.backgroundColor = UIColor(hex: "#04133A", alpha: 0.4)
        itemImageView.addSubview(imageMaskView)

        restrictionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        restrictionTitleLabel.backgroundColor = UIColor.tb_alertsAndTimestamps()
        restrictionTitleLabel.font = TBFontType.mulishLink4.font
        restrictionTitleLabel.textColor = UIColor.OffWhite
        restrictionTitleLabel.textAlignment = .center
        itemImageView.addSubview(restrictionTitleLabel)

        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.font = TBFontType.mulishTitle2.font
        itemTitleLabel.textColor = UIColor.OffWhite
        itemTitleLabel.textAlignment = .center
        itemImageView.addSubview(itemTitleLabel)

        severityBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(severityBackgroundView)

        severityIconView.translatesAutoresizingMaskIntoConstraints = false
        severityIconView.contentMode = .scaleAspectFit
        severityBackgroundView.addSubview(severityIconView)

        severityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        severityNameLabel.font = TBFontType.mulishLink3.font
        severityBackgroundView.addSubview(severityNameLabel)

        detailsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        detailsBackgroundView.backgroundColor = .GlobalBackgroundPrimary
        contentView.addSubview(detailsBackgroundView)

        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = TBFontType.mulishBody1.font
        detailsLabel.textColor = UIColor.tb_primaryCopy()
        detailsLabel.numberOfLines = 0
        detailsBackgroundView.addSubview(detailsLabel)

        let viewsDictionary = ["backgroundScrollView": backgroundScrollView, "contentView": contentView, "itemImageView": itemImageView, "imageMaskView": imageMaskView, "restrictionTitleLabel": restrictionTitleLabel, "itemTitleLabel": itemTitleLabel, "severityBackgroundView": severityBackgroundView, "severityIconView": severityIconView, "severityNameLabel": severityNameLabel, "detailsBackgroundView": detailsBackgroundView, "detailsLabel": detailsLabel]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundScrollView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundScrollView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        backgroundScrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|",
                                                                           options: [],
                                                                           metrics: nil,
                                                                           views: viewsDictionary))

        backgroundScrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|",
                                                                           options: [],
                                                                           metrics: nil,
                                                                           views: viewsDictionary))

        addConstraint(NSLayoutConstraint(item: contentView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .width,
                                         multiplier: 1,
                                         constant: 0))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[itemImageView(160)][severityBackgroundView(40)][detailsBackgroundView]|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[itemImageView]|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[severityBackgroundView]|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[detailsBackgroundView]|",
                                                                  options: [],
                                                                  metrics: nil,
                                                                  views: viewsDictionary))

        itemImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageMaskView]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: viewsDictionary))

        itemImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageMaskView]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: viewsDictionary))

        itemImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-37-[restrictionTitleLabel(25)]-(>=0)-[itemTitleLabel]-38-|",
                                                                    options: .alignAllCenterX,
                                                                    metrics: nil,
                                                                    views: viewsDictionary))

        itemImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[restrictionTitleLabel(>=190)]",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: viewsDictionary))

        itemImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[itemTitleLabel]-20-|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: viewsDictionary))

        severityBackgroundView.addConstraint(NSLayoutConstraint(item: severityIconView,
                                                                attribute: .trailing,
                                                                relatedBy: .equal,
                                                                toItem: severityBackgroundView,
                                                                attribute: .centerX,
                                                                multiplier: 1,
                                                                constant: -5))

        severityBackgroundView.addConstraint(NSLayoutConstraint(item: severityIconView,
                                                                attribute: .width,
                                                                relatedBy: .equal,
                                                                toItem: nil,
                                                                attribute: .notAnAttribute,
                                                                multiplier: 1,
                                                                constant: 20))

        severityBackgroundView.addConstraint(NSLayoutConstraint(item: severityIconView,
                                                                attribute: .height,
                                                                relatedBy: .equal,
                                                                toItem: severityIconView,
                                                                attribute: .width,
                                                                multiplier: 1,
                                                                constant: 0))

        severityBackgroundView.addConstraint(NSLayoutConstraint(item: severityIconView,
                                                                attribute: .centerY,
                                                                relatedBy: .equal,
                                                                toItem: severityBackgroundView,
                                                                attribute: .centerY,
                                                                multiplier: 1,
                                                                constant: 0))

        severityBackgroundView.addConstraint(NSLayoutConstraint(item: severityNameLabel,
                                                                attribute: .centerY,
                                                                relatedBy: .equal,
                                                                toItem: severityBackgroundView,
                                                                attribute: .centerY,
                                                                multiplier: 1,
                                                                constant: 1))

        severityBackgroundView.addConstraint(NSLayoutConstraint(item: severityNameLabel,
                                                                attribute: .leading,
                                                                relatedBy: .equal,
                                                                toItem: severityBackgroundView,
                                                                attribute: .centerX,
                                                                multiplier: 1,
                                                                constant: 5))

        detailsBackgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[detailsLabel]-20-|",
                                                                            options: [],
                                                                            metrics: nil,
                                                                            views: viewsDictionary))

        detailsBackgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[detailsLabel]-20-|",
                                                                            options: [],
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
    }

}
