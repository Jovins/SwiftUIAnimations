import UIKit

final class FoodSafetyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    private let searchBarView: TBSearchBarView = TBSearchBarView()
    let foodSafetyView = FoodSafetyView(frame: CGRect.zero)
    var foodSafetyCategories = [TBFoodSafetyCategory]()
    var foodSafeties = [TBFoodSafetyModel]()
    var foodSafetyData = [Any]()

    override var descriptionGA: String { "food safety" }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        navigationItem.title = "FOOD SAFETY".capitalizedWithoutPreposition
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        definesPresentationContext = true

        extendedLayoutIncludesOpaqueBars = true
        navigationController?.view.backgroundColor = .GlobalBackgroundPrimary

        view.backgroundColor = .GlobalBackgroundPrimary

        [searchBarView, foodSafetyView].forEach(view.addSubview)
        searchBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
        foodSafetyView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        searchBarView.delegate = self
        searchBarView.attributedPlaceholder = "Search Food".attributedText(.mulishBody2, foregroundColor: .DarkGray600)

        foodSafetyView.requestButton.addTarget(self, action: #selector(requestFoodTouched), for: .touchUpInside)
        foodSafetyView.backToBrowseButton.addTarget(self, action: #selector(backToBrowseButtonTouched), for: .touchUpInside)

        foodSafetyView.foodSafetyTableView.separatorColor = UIColor.tb_lines()
        foodSafetyView.foodSafetyTableView.estimatedRowHeight = 60

        foodSafetyView.foodSafetyTableView.dataSource = self
        foodSafetyView.foodSafetyTableView.delegate = self

        foodSafetyView.foodSafetyTableView.register(FoodSafetyCategoryTableViewCell.self,
                                                    forCellReuseIdentifier: FoodSafetyCategoryTableViewCell.defaultReuseIdentifier)

        foodSafetyView.foodSafetyTableView.register(FoodSafetyTermsTableViewCell.self,
                                                    forCellReuseIdentifier: FoodSafetyTermsTableViewCell.defaultReuseIdentifier)

        foodSafetyView.foodSafetyTableView.register(FoodSafetyItemTableViewCell.self,
                                                    forCellReuseIdentifier: FoodSafetyItemTableViewCell.defaultReuseIdentifier)

        TBFoodSafetyManager.shared.getFoodSafeties()
        self.foodSafeties = TBFoodSafetyManager.shared.foodSafeties
        self.foodSafetyCategories = TBFoodSafetyManager.shared.foodSafetyCategories

        if TBStaleTimeDataManager.isFoodSafetyStale()
            || self.foodSafeties.isEmpty
            || self.foodSafetyCategories.isEmpty {

            foodSafetyView.foodSafetyTableView.alpha = 0
            foodSafetyView.loaderView.alpha = 1
            foodSafetyView.loaderSpinner.startAnimating()

            TBFoodSafetyManager.shared.deleteFoodSafety()

            let foodDataPromise = FoodSafetyNetworkHelper.fetchFoodSafetyData()
            foodDataPromise?.then({ [weak self] (foodSafetyData: AnyObject?) -> Any? in
                guard let self = self else { return nil }
                TBFoodSafetyManager.shared.updateFoodSafety(response: foodSafetyData)
                self.foodSafeties = TBFoodSafetyManager.shared.foodSafeties
                self.foodSafetyCategories = TBFoodSafetyManager.shared.foodSafetyCategories
                self.foodSafetyData = self.foodSafetyCategories

                self.foodSafetyView.foodSafetyTableView.reloadData()
                self.foodSafetyView.foodSafetyTableView.alpha = 1
                self.foodSafetyView.loaderView.alpha = 0
                self.foodSafetyView.loaderSpinner.stopAnimating()

                TBStaleTimeDataManager.updateFoodSafetyStaleTime()
                UserDefaults.standard.foodSafetyUpdatedAt = DateFormatter().yyyyMMddString(from: Date()) ?? ""

                return foodSafetyData
            }, error: { (error: Error?) -> Any? in
                return error
            })
        } else {
            self.foodSafetyData = self.foodSafetyCategories
            self.foodSafetyView.foodSafetyTableView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()

        if let selectedIndexPath = foodSafetyView.foodSafetyTableView.indexPathForSelectedRow {
            foodSafetyView.foodSafetyTableView.deselectRow(at: selectedIndexPath, animated: true)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillBeHidden(_ notification: Notification) {
        foodSafetyView.foodSafetyTableView.contentInset = .zero
        foodSafetyView.foodSafetyTableView.scrollIndicatorInsets = .zero
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching() ? foodSafetyData.count : foodSafetyData.count + 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isSearching() && indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: FoodSafetyTermsTableViewCell.defaultReuseIdentifier) as? FoodSafetyTermsTableViewCell {
                cell.delegate = self
                return cell
            }
        }

        let categoryRow = isSearching() ? indexPath.row : indexPath.row - 1

        if let category = foodSafetyData[categoryRow] as? TBFoodSafetyCategory {
            if let cell = tableView.dequeueReusableCell(withIdentifier: FoodSafetyCategoryTableViewCell.defaultReuseIdentifier) as? FoodSafetyCategoryTableViewCell {
                cell.setup(category: category)
                return cell
            }
        } else if let model = foodSafetyData[categoryRow] as? TBFoodSafetyModel {
            if let cell = tableView.dequeueReusableCell(withIdentifier: FoodSafetyItemTableViewCell.defaultReuseIdentifier) as? FoodSafetyItemTableViewCell {
                cell.setup(model: model)
                return cell
            }
        }

        return UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.defaultReuseIdentifier)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isSearching() && indexPath.row == 0 {
            return UITableView.automaticDimension
        }

        let categoryRow = isSearching() ? indexPath.row : indexPath.row - 1

        if foodSafetyData[categoryRow] is TBFoodSafetyCategory {
            return 90
        } else if foodSafetyData[categoryRow] is TBFoodSafetyModel {
            return 64
        }

        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if !isSearching() && indexPath.row == 0 {
            return
        }

        let categoryRow = isSearching() ? indexPath.row : indexPath.row - 1

        if let category = foodSafetyData[categoryRow] as? TBFoodSafetyCategory {
            TBAnalyticsManager.logEventNamed(kAnalyticsFoodSafetyInteraction,
                                             withProperties: ["type": "view category",
                                                              "selection": category.name ?? "",
                                                              "userDecisionArea": isSearching() ? "search" : "list"])

            let detailController = FoodSafetyCategoryDetailViewController(foodCategory: category)
            AppRouter.shared.navigator.push(detailController)
        } else if let item = foodSafetyData[categoryRow] as? TBFoodSafetyModel {
            TBAnalyticsManager.logEventNamed(kAnalyticsFoodSafetyInteraction,
                                             withProperties: ["type": "food",
                                                              "selection": item.name ?? "",
                                                              "userDecisionArea": "search"])

            let detailController = FoodSafetyItemDetailViewController(model: item)
            AppRouter.shared.navigator.push(detailController)
        }
    }

    private func searchValueChanged(searchText: String) {
        let searchText = searchText
        if searchText.count > 0 {
            var categoryResults = foodSafetyCategories.filter({ (item: TBFoodSafetyCategory) -> Bool in
                return item.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }) as [Any]
            let foodResults = foodSafeties.filter({ (item: TBFoodSafetyModel) -> Bool in
                return item.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }) as [Any]
            categoryResults += foodResults
            foodSafetyData = categoryResults
            if foodSafetyData.count == 0 {
                foodSafetyView.noResultsView.alpha = 1
            } else {
                foodSafetyView.noResultsView.alpha = 0
                foodSafetyView.submittedRequestView.alpha = 0
            }
            foodSafetyView.foodSafetyTableView.reloadData()
        } else {
            hideSearchResults()
        }
    }

    private func searchCancelButtonTouched() {
        hideSearchResults()
    }

    @objc func requestFoodTouched() {
        if let searchText = searchBarView.text {
            if  searchText.count > 0 {
                TBAnalyticsManager.logEventNamed(kAnalyticsFoodSafetyInteraction,
                                                 withProperties: [kAnalyticsKeySelection: "request",
                                                                  "search": searchText])
                UIView.animate(withDuration: 0.3, animations: {
                    self.foodSafetyView.submittedRequestView.alpha = 1
                })
            } else {
                hideSearchResults()
            }
        }
    }

    @objc func backToBrowseButtonTouched() {
        hideSearchResults()
    }

    func hideSearchResults() {
        foodSafetyView.noResultsView.alpha = 0
        foodSafetyView.submittedRequestView.alpha = 0
        foodSafetyData = foodSafetyCategories
        foodSafetyView.foodSafetyTableView.reloadData()
    }

    private func isSearching() -> Bool {
        var isSearching = false
        if let searchText = searchBarView.text {
            isSearching = !searchText.isEmpty
        }
        return isSearching
    }
}

// MARK: - TBSearchBarViewDelegate
extension FoodSafetyViewController: TBSearchBarViewDelegate {
    func textDidChange(searchText: String?) {
        searchValueChanged(searchText: searchText ?? "")
    }

    func didTapCancel() {
        searchCancelButtonTouched()
    }
}

extension FoodSafetyViewController: FoodSafetyTermsTableViewCellDelegate {
    func didTapShowButtonToExpand() {
        foodSafetyView.foodSafetyTableView.reloadData()
    }
}
