import UIKit

class FoodSafetyCategoryDetailSectionHeaderView: UITableViewHeaderFooterView {
    let severitySelector = FoodSafetyCategorySeveritySelector(frame: CGRect.zero)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        severitySelector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(severitySelector)

        let viewsDictionary = ["severitySelector": severitySelector]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[severitySelector]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[severitySelector]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
