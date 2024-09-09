import Foundation

final class TBFoodSafetyManager: NSObject {

    static let shared: TBFoodSafetyManager = TBFoodSafetyManager()
    private let cacheKey: String = "TBFoodSafety"
    private var _cache: TBCache<String, [TBFoodSafetyModel]>?
    private var cache: TBCache<String, [TBFoodSafetyModel]> {
        if let _cache = _cache {
            return _cache
        } else {
            if let cache = try? TBCache<String, [TBFoodSafetyModel]>.readFromDisk(withName: cacheKey) {
               _cache = cache
               return cache
           } else {
               let cache = TBCache<String, [TBFoodSafetyModel]>()
               _cache = cache
               return cache
           }
       }
    }

    private(set) var foodSafeties = [TBFoodSafetyModel]()
    var foodSafetyCategories: [TBFoodSafetyCategory] {
        return foodSafeties.flatMap({ $0.categories ?? [] }).uniqued({ $0.id }).sorted(by: {
            guard let name0 = $0.name, let name1 = $1.name else { return false }
            return name0 < name1
        })
    }

    func getFoodSafeties() {
        if let array = cache.value(forKey: cacheKey) {
            self.foodSafeties = array
        } else {
            self.foodSafeties = []
            self.storeData()
        }
    }

    func updateFoodSafety(response data: AnyObject?) {
        guard let data = data as? [String: AnyObject],
              let foodData = data["foods"] as? [[String: AnyObject]],
              JSONSerialization.isValidJSONObject(foodData),
              let data = try? JSONSerialization.data(withJSONObject: foodData, options: []),
              let models = try? JSONDecoder().decode([TBFoodSafetyModel].self, from: data) else { return }
        foodSafeties = models
        storeData()
    }

    func foodSafetiesWithSeverity(severity: FoodSafetySeverity, category: TBFoodSafetyCategory) -> [TBFoodSafetyModel] {
        let filterFoods = foodSafeties.filter({ (model: TBFoodSafetyModel) -> Bool in
            guard let categories = model.categories,
                  categories.contains(where: { $0.id == category.id }) else { return false }
            if severity == .safe {
                return model.isSafe
            } else if severity == .avoid {
                return !model.isSafe
            }
            return true
        })
        return filterFoods.sorted(by: {
            guard let name0 = $0.name, let name1 = $1.name else { return false }
            return name0 < name1
        })
    }

    func isOnlySafe(category: TBFoodSafetyCategory) -> Bool {
        return foodSafetiesWithSeverity(severity: .avoid, category: category).count == 0
    }

    func isOnlyAvoid(category: TBFoodSafetyCategory) -> Bool {
        return foodSafetiesWithSeverity(severity: .safe, category: category).count == 0
    }

    private func storeData() {
        try? cache.insert(foodSafeties, forKey: cacheKey)
        try? cache.saveToDisk(withName: cacheKey)
    }

    func deleteFoodSafety() {
        foodSafeties.removeAll()
        _cache?.removeValue(forKey: cacheKey)
        _cache = nil
        storeData()
    }

    @objc func resetCache() {
        foodSafeties.removeAll()
        _cache?.removeValue(forKey: cacheKey)
        _cache = nil
    }
}
