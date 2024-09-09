import UIKit

class FoodSafetyItemDetailViewController: UITableViewController, UITextViewDelegate {
    var foodSafetyModel: TBFoodSafetyModel?
    var foodRestrictions = [TBFoodSafetyRestriction]()

    convenience init(model: TBFoodSafetyModel) {
        self.init(style: .grouped)

        self.foodSafetyModel = model
        if let restrictions = model.restrictions {
            self.foodRestrictions = Array(restrictions)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = foodSafetyModel?.name?.capitalizedWithoutPreposition
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        tableView.separatorStyle = .none
        tableView.backgroundColor = .GlobalBackgroundPrimary

        tableView.register(FoodSafetyItemHeaderView.self, forHeaderFooterViewReuseIdentifier: FoodSafetyItemHeaderView.defaultReuseIdentifier)

        tableView.register(FoodSafetyItemRestrictionTableViewCell.self, forCellReuseIdentifier: FoodSafetyItemRestrictionTableViewCell.defaultReuseIdentifier)

        tableView.estimatedSectionHeaderHeight = 100
        tableView.estimatedRowHeight = 100

        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let model = foodSafetyModel else { return nil }
        if let description = model.description, !description.isEmpty {
            if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FoodSafetyItemHeaderView.defaultReuseIdentifier) as? FoodSafetyItemHeaderView {
                headerView.setup(details: description,
                                 sourceDetails: model.disclaimer,
                                 sourceText: model.sourceName,
                                 sourceURL: model.sourceUrl)
                headerView.itemDisclaimerTextView.delegate = self
                return headerView
            }
        }
        return nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodRestrictions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FoodSafetyItemRestrictionTableViewCell.defaultReuseIdentifier, for: indexPath) as? FoodSafetyItemRestrictionTableViewCell {

            let restriction = foodRestrictions[indexPath.row]
            if let hex = restriction.severity?.hex {
                cell.setup(imageURL: restriction.severity?.iconUrl,
                           placeholderImage: restriction.placeholderImage,
                           imageBackgroundHex: "#\(hex)",
                           title: restriction.name,
                           details: restriction.description,
                           sourceDetails: restriction.disclaimer,
                           sourceText: restriction.sourceName,
                           sourceURL: restriction.sourceUrl)
            }
            cell.restrictionDisclaimerTextView.delegate = self
            cell.isFirstCell = (foodRestrictions.first == restriction)
            cell.isLastCell = (foodRestrictions.last == restriction)

            return cell
        }

        return UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.defaultReuseIdentifier)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        TBAnalyticsManager.logScreenNamed("WebView",
                                          withProperties: ["url": URL.absoluteString])
        AppRouter.navigateToBrowser(url: URL) {[weak self] setting in
            guard let self else { return setting }
            setting.title = ""
            setting.customNavBarColor = self.navigationController?.navigationBar.barTintColor ?? setting.customNavBarColor
            return setting
        }
        return false
    }
}
