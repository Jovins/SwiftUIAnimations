import UIKit

class FoodSafetyTableViewHeader: UIView {
    let headerLabel = UILabel(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.OffWhite

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = TBFontType.mulishTitle3.font
        headerLabel.textColor = UIColor.tb_primaryCopy()
        addSubview(headerLabel)

        let viewsDictionary = ["headerLabel": headerLabel]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerLabel]-10-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerLabel]-10-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
