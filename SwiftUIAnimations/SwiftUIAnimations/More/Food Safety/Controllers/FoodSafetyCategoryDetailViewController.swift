import UIKit

class FoodSafetyCategoryDetailViewController: UITableViewController {
    var foodCategory: TBFoodSafetyCategory?
    var foodSafeties = [TBFoodSafetyModel]()
    var severitySelectionView = FoodSafetyCategorySeveritySelector()

    private var gradient: CAGradientLayer!

    convenience init(foodCategory: TBFoodSafetyCategory) {
        self.init(nibName: nil, bundle: nil)
        self.foodCategory = foodCategory
        foodSafeties = TBFoodSafetyManager.shared.foodSafetiesWithSeverity(severity: .all, category: foodCategory)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = self.foodCategory?.name?.capitalizedWithoutPreposition

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        tableView.backgroundColor = .GlobalBackgroundPrimary
        tableView.register(FoodSafetyItemTableViewCell.self,
                           forCellReuseIdentifier: FoodSafetyItemTableViewCell.defaultReuseIdentifier)

        tableView.register(FoodSafetyCategoryDetailSectionHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: FoodSafetyCategoryDetailSectionHeaderView.defaultReuseIdentifier)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 36, right: 0)
        guard let foodCategory = foodCategory else { return }
        let header = FoodSafetyCategoryDetailHeaderView( with: foodCategory)
        header.delegate = self
        tableView.tableHeaderView = header
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodSafeties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FoodSafetyItemTableViewCell.defaultReuseIdentifier) as? FoodSafetyItemTableViewCell {
            cell.setup(model: foodSafeties[indexPath.row])
            return cell
        }

        return UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.defaultReuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TBAnalyticsManager.logEventNamed(kAnalyticsFoodSafetyInteraction,
                                         withProperties: ["type": "food",
                                                          "selection": foodSafeties[indexPath.row].name ?? "",
                                                          "userDecisionArea": "category"])

        let detailController = FoodSafetyItemDetailViewController(model: foodSafeties[indexPath.row])
        AppRouter.shared.navigator.push(detailController)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = foodCategory else {
            return nil
        }
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FoodSafetyCategoryDetailSectionHeaderView.defaultReuseIdentifier) as? FoodSafetyCategoryDetailSectionHeaderView {
            severitySelectionView = header.severitySelector
            severitySelectionView.addTarget(self, action: #selector(selectedSeverityChanged), for: .valueChanged)

            if TBFoodSafetyManager.shared.isOnlySafe(category: category) {
                severitySelectionView.enableOnly(severity: .safe)
            } else if TBFoodSafetyManager.shared.isOnlyAvoid(category: category) {
                severitySelectionView.enableOnly(severity: .avoid)
            }
            return header
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 84
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    @objc func selectedSeverityChanged() {
        if let category = foodCategory {
            foodSafeties = TBFoodSafetyManager.shared.foodSafetiesWithSeverity(severity: severitySelectionView.selectedSeverity(),
                                                                               category: category)
            tableView.reloadData()
        }
    }
}

extension FoodSafetyCategoryDetailViewController: FoodSafetyCategoryDetailHeaderDelegate {
    func actionButtonDidTap() {
        self.tableView.reloadData()
    }
    func linkDidTap(_ URL: URL) {
        TBAnalyticsManager.logScreenNamed("WebView",
                                          withProperties: ["url": URL.absoluteString])
        AppRouter.navigateToBrowser(url: URL) {[weak self] setting in
            guard let self else { return setting }
            setting.title = ""
            setting.customNavBarColor = self.navigationController?.navigationBar.barTintColor ?? setting.customNavBarColor
            return setting
        }
    }
}
