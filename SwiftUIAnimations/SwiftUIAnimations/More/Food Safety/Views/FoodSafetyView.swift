import UIKit

final class FoodSafetyView: UIView {
    let foodSafetyTableView = UITableView(frame: CGRect.zero, style: .plain)
    var noResultsView = UIView()
    let noResultsLabel = UILabel()
    let requestButton = UIButton()

    let loaderView = UIView(frame: CGRect.zero)
    let loaderSpinner = UIActivityIndicatorView(style: .gray)

    var submittedRequestView = UIView()
    let submittedRequestLabel = UILabel()
    let backToBrowseButton = UIButton()
    private let separatorView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        separatorView.backgroundColor = .DarkGray300
        [noResultsView, submittedRequestView].forEach {
            $0.addSubview(separatorView)
            $0.bringSubviewToFront(separatorView)
        }
        separatorView.snp.makeConstraints { make in
            make.trailing.leading.top.equalToSuperview()
            make.height.equalTo(1)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.minimumLineHeight = 24
        paragraphStyle.maximumLineHeight = 24

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.DarkGray500,
                                                                                                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                                                                        NSAttributedString.Key.font: TBFontType.mulishBody2.font]

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.DarkGray500,
                                                                                                                                                         NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                                                                                                                         NSAttributedString.Key.font: TBFontType.mulishBody2.font])

        foodSafetyTableView.translatesAutoresizingMaskIntoConstraints = false
        foodSafetyTableView.backgroundColor = .GlobalBackgroundPrimary
        foodSafetyTableView.tableFooterView = UIView()
        foodSafetyTableView.cellLayoutMarginsFollowReadableWidth = false
        foodSafetyTableView.separatorStyle = .none
        let bottomSpace = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 36))
        foodSafetyTableView.tableFooterView = bottomSpace
        addSubview(foodSafetyTableView)

        noResultsView.translatesAutoresizingMaskIntoConstraints = false
        noResultsView.alpha = 0
        noResultsView.backgroundColor = .GlobalBackgroundPrimary
        addSubview(noResultsView)

        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        let noResultsString = "Sorry, we can't find any foods that\nmatch your search. Please check\nyour spelling and try again."
        noResultsLabel.attributedText = noResultsString.attributedText(.mulishBody2,
                                                                       alignment: .center,
                                                                       lineBreakMode: .byWordWrapping)
        noResultsLabel.numberOfLines = 0
        noResultsView.addSubview(noResultsLabel)

        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.setTitle("Request Food", for: .normal)
        requestButton.setTitleColor(.Magenta, for: .normal)
        requestButton.titleLabel?.font = TBFontType.mulishLink2.font
        requestButton.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        noResultsView.addSubview(requestButton)

        submittedRequestView.translatesAutoresizingMaskIntoConstraints = false
        submittedRequestView.alpha = 0
        submittedRequestView.backgroundColor = .GlobalBackgroundPrimary
        addSubview(submittedRequestView)

        submittedRequestLabel.translatesAutoresizingMaskIntoConstraints = false
        let submitRequestString = "We’ve received your suggestion.\rYour feedback is important to us. Check back soon!"
        submittedRequestLabel.attributedText = submitRequestString.attributedText(.mulishBody2,
                                                                                  alignment: .center,
                                                                                  lineBreakMode: .byWordWrapping)
        submittedRequestLabel.numberOfLines = 0
        submittedRequestView.addSubview(submittedRequestLabel)

        backToBrowseButton.translatesAutoresizingMaskIntoConstraints = false
        backToBrowseButton.setTitle("Back to Browse", for: .normal)
        backToBrowseButton.setTitleColor(.Magenta, for: .normal)
        backToBrowseButton.titleLabel?.font = TBFontType.mulishLink2.font
        backToBrowseButton.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        submittedRequestView.addSubview(backToBrowseButton)

        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.alpha = 0
        loaderView.backgroundColor = .GlobalBackgroundPrimary
        addSubview(loaderView)

        loaderSpinner.translatesAutoresizingMaskIntoConstraints = false
        loaderView.addSubview(loaderSpinner)

        let viewsDictionary: [String: Any] = ["foodSafetyTableView": foodSafetyTableView, "noResultsView": noResultsView, "noResultsLabel": noResultsLabel, "submittedRequestView": submittedRequestView, "submittedRequestLabel": submittedRequestLabel, "loaderView": loaderView, "loaderSpinner": loaderSpinner]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[foodSafetyTableView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noResultsView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[noResultsView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[loaderView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[loaderView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        loaderView.addConstraint(NSLayoutConstraint(item: loaderSpinner,
                                                    attribute: .centerX,
                                                    relatedBy: .equal,
                                                    toItem: loaderView,
                                                    attribute: .centerX,
                                                    multiplier: 1,
                                                    constant: 0))

        loaderView.addConstraint(NSLayoutConstraint(item: loaderSpinner,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: loaderView,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[submittedRequestView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[submittedRequestView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[foodSafetyTableView]-0-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: viewsDictionary))

        noResultsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[noResultsLabel]-20-|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: viewsDictionary))

        noResultsView.addConstraint(NSLayoutConstraint(item: noResultsLabel,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: noResultsView,
                                                       attribute: .centerY,
                                                       multiplier: 1,
                                                       constant: -146))

        noResultsView.addConstraint(NSLayoutConstraint(item: requestButton,
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: noResultsView,
                                                       attribute: .centerX,
                                                       multiplier: 1,
                                                       constant: 0))

        noResultsView.addConstraint(NSLayoutConstraint(item: requestButton,
                                                       attribute: .top,
                                                       relatedBy: .equal,
                                                       toItem: noResultsLabel,
                                                       attribute: .bottom,
                                                       multiplier: 1,
                                                       constant: 24))

        noResultsView.addConstraint(NSLayoutConstraint(item: requestButton,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1,
                                                       constant: 24))

        submittedRequestView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[submittedRequestLabel]-20-|",
                                                                           options: [],
                                                                           metrics: nil,
                                                                           views: viewsDictionary))

        submittedRequestView.addConstraint(NSLayoutConstraint(item: submittedRequestLabel,
                                                              attribute: .centerY,
                                                              relatedBy: .equal,
                                                              toItem: submittedRequestView,
                                                              attribute: .centerY,
                                                              multiplier: 1,
                                                              constant: -146))

        submittedRequestView.addConstraint(NSLayoutConstraint(item: backToBrowseButton,
                                                              attribute: .centerX,
                                                              relatedBy: .equal,
                                                              toItem: submittedRequestView,
                                                              attribute: .centerX,
                                                              multiplier: 1,
                                                              constant: 0))

        submittedRequestView.addConstraint(NSLayoutConstraint(item: backToBrowseButton,
                                                              attribute: .top,
                                                              relatedBy: .equal,
                                                              toItem: submittedRequestLabel,
                                                              attribute: .bottom,
                                                              multiplier: 1,
                                                              constant: 24))

        submittedRequestView.addConstraint(NSLayoutConstraint(item: backToBrowseButton,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1,
                                                              constant: 24))

        submittedRequestView.addConstraint(NSLayoutConstraint(item: backToBrowseButton,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1,
                                                              constant: 150))

    }
}
