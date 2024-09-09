import Foundation
import FirebaseCrashlytics
import RxSwift

struct TBFeedingTrackerSettingHelper {

    static let shared = TBFeedingTrackerSettingHelper()
    private(set) var updatedPublishSubject: PublishSubject = PublishSubject<Any?>()

    var defaultSettingModels: [TBFeedingTrackerSettingModel] {
        return [TBFeedingTrackerSettingModel(type: .nursing),
                TBFeedingTrackerSettingModel(type: .bottle),
                TBFeedingTrackerSettingModel(type: .pumping),
                TBFeedingTrackerSettingModel(type: .diapers)]
    }

    func getSettingModels() -> [TBFeedingTrackerSettingModel] {
        guard let settingModels = UserDefaults.standard.feedingTrackerSettings as? [TBFeedingTrackerSettingModel] else {
            return defaultSettingModels
        }
        return settingModels
    }

    func saveSettingModels(_ settingModels: [TBFeedingTrackerSettingModel]) {
        UserDefaults.standard.feedingTrackerSettings = settingModels
        updatedPublishSubject.onNext(nil)
    }

}
