import Foundation

extension UserDefaults {
    @objc public var hasCheckCustomNotificationPermission: Bool {
        get {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return true }
            return UserDefaults.standard.bool(forKey: "hasCheckCustomNotificationPermission+\(String(describing: user.memberUserId))")
        }
        set {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return }
            UserDefaults.standard.setValue(newValue, forKey: "hasCheckCustomNotificationPermission+\(String(describing: user.memberUserId))")
        }
    }

    public var hasUsedPCM: Bool {
        get {
            UserDefaults.standard.bool(forKey: "HasUsedPCM")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HasUsedPCM")
        }
    }

    public var hasSeenSaveArticleTooltip: Bool {
        get {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return true }
            return UserDefaults.standard.bool(forKey: "hasSeenSaveArticleTooltip+\(String(describing: user.memberUserId))")
        }
        set {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return }
            UserDefaults.standard.setValue(newValue, forKey: "hasSeenSaveArticleTooltip+\(String(describing: user.memberUserId))")
        }
    }

    public var hasClickedToQuicklyJumpToHBIB: Bool {
        get {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return true }
            return UserDefaults.standard.bool(forKey: "hasClickedToQuicklyJumpToHBIB+\(String(describing: user.memberUserId))")
        }
        set {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return }
            UserDefaults.standard.setValue(newValue, forKey: "hasClickedToQuicklyJumpToHBIB+\(String(describing: user.memberUserId))")
        }
    }

    public var feedbackReviewPopupStatus: Int {
        get {
            return UserDefaults.standard.integer(forKey: "feedbackReviewPopupStatus")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "feedbackReviewPopupStatus")
        }
    }

    public var feedbackReviewCardStatus: Int {
        get {
            return UserDefaults.standard.integer(forKey: "feedbackReviewCardStatus")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "feedbackReviewCardStatus")
        }
    }

    public var twoMonthsAfterFeedbackReviewPopupShowed: Double {
        get {
            return UserDefaults.standard.double(forKey: "twoMonthsAfterFeedbackReviewPopupShowed")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "twoMonthsAfterFeedbackReviewPopupShowed")
        }
    }

    public var fullScreenLoaderStayAtLeastTimeInterval: Double {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: "fullScreenLoaderStayAtLeastTimeInterval")
            return timeInterval == 0 ? 3 : timeInterval
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "fullScreenLoaderStayAtLeastTimeInterval")
        }
    }

    public var fullScreenLoaderDisplayOrHideAnimationTimeInterval: Double {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: "fullScreenLoaderDisplayOrHideAnimationTimeInterval")
            return timeInterval == 0 ? 1 : timeInterval
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "fullScreenLoaderDisplayOrHideAnimationTimeInterval")
        }
    }

    @objc public var hasExperiencedAloss: Bool {
        get {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return false }
            return UserDefaults.standard.bool(forKey: "hasExperiencedAloss+\(String(describing: user.memberUserId))")
        }
        set {
            guard let user = TBMemberDataManager.sharedInstance().memberDataObject else { return }
            UserDefaults.standard.setValue(newValue, forKey: "hasExperiencedAloss+\(String(describing: user.memberUserId))")
        }
    }

    public var appVersionOfFeedbackReviewPopupShow: String? {
        get {
            return UserDefaults.standard.string(forKey: "appVersionOfFeedbackReviewPopupShow")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "appVersionOfFeedbackReviewPopupShow")
        }
    }

    public var firstAppOpenDate: TimeInterval? {
        get {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return nil }
            let timeInterval = UserDefaults.standard.double(forKey: TBUserDefaultsConstant.firstAppOpenDate + memberUserId)
            return timeInterval == 0.0 ? nil : timeInterval
        }
        set {
            guard let memberUserId = TBMemberDataManager.memberUUID,
                  firstAppOpenDate == nil,
                  let timeInterval = newValue else { return }
            UserDefaults.standard.set(timeInterval, forKey: TBUserDefaultsConstant.firstAppOpenDate + memberUserId)
        }
    }

    public var lastUsedDate: TimeInterval? {
        get {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return nil }
            let timeInterval = UserDefaults.standard.double(forKey: TBUserDefaultsConstant.lastUsedDate + memberUserId)
            return timeInterval == 0.0 ? nil : timeInterval
        }
        set {
            guard let memberUserId = TBMemberDataManager.memberUUID,
            let timeInterval = newValue else { return }
            UserDefaults.standard.set(timeInterval, forKey: TBUserDefaultsConstant.lastUsedDate + memberUserId)
        }
    }

    public var foodSafetyUpdatedAt: String {
        get {
            UserDefaults.standard.string(forKey: "foodSafetyUpdatedAt") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "foodSafetyUpdatedAt")
        }
    }

    @objc func recordLastUsedDate() {
        lastUsedDate = Date().timeIntervalSince1970
    }

    @objc func recordFirstAppOpenDateIfNeeded() {
        guard firstAppOpenDate == nil || firstAppOpenDate == 0.0 else { return }
        firstAppOpenDate = Date().timeIntervalSince1970
    }

    public var perksVersion: NSNumber? {
        get {
            return UserDefaults.standard.value(forKey: TBUserDefaultsConstant.perksVersion) as? NSNumber
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: TBUserDefaultsConstant.perksVersion)
        }
    }

    public var dateOfFetchingDailyFeedData: Date? {
        get {
            return UserDefaults.standard.value(forKey: TBUserDefaultsConstant.dateOfFetchingDailyFeedData) as? Date
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: TBUserDefaultsConstant.dateOfFetchingDailyFeedData)
        }
    }

    var remoteConfigNewItems: TBRemoteConfigModel.TBRemoteConfigNewItem? {
        get {
            return getObject(forKey: TBUserDefaultsConstant.remoteConfigNewItems, type: TBRemoteConfigModel.TBRemoteConfigNewItem.self)
        }
        set {
            setObject(newValue, forKey: TBUserDefaultsConstant.remoteConfigNewItems)
        }
    }

    @objc public var hasUpdateStatus: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasUpdateStatus")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "hasUpdateStatus")
        }
    }

    public var babyECommerceRandomizeNumberDic: [String: [Int]]? {
        get {
            return UserDefaults.standard.value(forKey: "babyECommerceRandomizeNumberDic") as? [String: [Int]]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "babyECommerceRandomizeNumberDic")
        }
    }

    @objc var hasOpenedHBIB: Bool {
        get {
            bool(forKey: "HasOpenedHBIB")
        }
        set {
            setValue(newValue, forKey: "HasOpenedHBIB")
        }
    }

    @objc var hasOpenedContractionCounter: Bool {
        get {
            bool(forKey: "hasOpenedContractionCounter")
        }
        set {
            setValue(newValue, forKey: "hasOpenedContractionCounter")
        }
    }

    @objc public var sessionCount: NSNumber? {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return object(forKey: TBMemberDataManager.appLaunchSessionForVersion + currentVersion) as? NSNumber
    }

    @objc public var hasUserSignedUpThroughApp: Bool {
        return bool(forKey: TBMemberDataManager.userSignedUpOnThisDevice)
    }

    @objc var userSignedUpVersion: NSNumber? {
        return object(forKey: TBMemberDataManager.userSignedUpOnThisDeviceVersion) as? NSNumber
    }

    @objc var userSignedUpDate: Date? {
        return object(forKey: TBMemberDataManager.userSignedUpOnThisDeviceDate) as? Date
    }

    func setUserHasSignedUpThroughAppinVersion(appVersion: String, date: Date) {
        guard let appVersion = Int(appVersion) else { return }
        setValue(true, forKey: TBMemberDataManager.userSignedUpOnThisDevice)
        setValue(NSNumber.init(value: appVersion), forKey: TBMemberDataManager.userSignedUpOnThisDeviceVersion)
        set(date, forKey: TBMemberDataManager.userSignedUpOnThisDeviceDate)
    }

    @objc func resetUserSignedUpThroughApp() {
        setValue(false, forKey: TBMemberDataManager.userSignedUpOnThisDevice)
        removeObject(forKey: TBMemberDataManager.userSignedUpOnThisDeviceVersion)
        removeObject(forKey: TBMemberDataManager.userSignedUpOnThisDeviceDate)
    }

    @objc var hasUserCreatedAProfile: Bool {
        get {
            bool(forKey: "UserCreatedAProfile")
        }
        set {
            setValue(newValue, forKey: "UserCreatedAProfile")
        }
    }

    public var hasSeenMyPhotos: Bool {
        get {
            return UserDefaults.standard.bool(forKey: TBUserDefaultsConstant.myPhotos)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: TBUserDefaultsConstant.myPhotos)
        }
    }

    public var isMetricUnit: Bool {
        get {
            let unitsSelected = UserDefaults.standard.integer(forKey: "UnitsSelected")
            if unitsSelected != TBUnits.none.rawValue {
                return unitsSelected == TBUnits.metric.rawValue
            } else {
                return NSLocale.current.usesMetricSystem
            }
        }
        set {
            UserDefaults.standard.set(newValue ? TBUnits.metric.rawValue : TBUnits.imperial.rawValue, forKey: "UnitsSelected")
            UserDefaults.standard.synchronize()
        }
    }

    @objc public var registryRetailerIndex: NSNumber? {
        get {
            return UserDefaults.standard.value(forKey: "registryRecordIndex") as? NSNumber
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "registryRecordIndex")
        }
    }

    @objc public var registryRetailers: [String]? {
        get {
            return UserDefaults.standard.array(forKey: "registryRetailers") as? [String]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "registryRetailers")
        }
    }

    public var shouldShowWelcomeWall: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shouldShowWelcomeWall")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldShowWelcomeWall")
        }
    }
    public var hasSeenWeightTracker: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenWeightTracker")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenWeightTracker")
        }
    }
    public var hasSeenWeightTrackeriCloud: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenWeightTrackeriCloud")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenWeightTrackeriCloud")
        }
    }
    public var hasSeenKickCounter: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenKickCounter")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenKickCounter")
        }
    }
    public var hasSeenFeedingTracker: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenFeedingTracker")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenFeedingTracker")
        }
    }
    public var hasNetworkAuthorized: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasNetworkAuthorized")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasNetworkAuthorized")
        }
    }
    public var feedingTrackerSettings: [TBFeedingTrackerSettingModel]? {
        get {
            UserDefaults.standard.getObject(forKey: "feedingTrackerSettingsKey", type: [TBFeedingTrackerSettingModel].self)
        }
        set {
            UserDefaults.standard.setObject(newValue, forKey: "feedingTrackerSettingsKey")
        }
    }
    public var hasCacheWeightTracker: Bool {
        get {
            guard let memberID = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheWeightTracker+\(memberID)")
        }
        set {
            guard let memberID = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheWeightTracker+\(memberID)")
        }
    }
    public var hasCacheFeedingTrackerNursing: Bool {
        get {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheFeedingTrackerNursing+\(memberUserId)")
        }
        set {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheFeedingTrackerNursing+\(memberUserId)")
        }
    }
    public var hasCacheFeedingTrackerPumping: Bool {
        get {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheFeedingTrackerPumping+\(memberUserId)")
        }
        set {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheFeedingTrackerPumping+\(memberUserId)")
        }
    }
    public var hasCacheKickCounter: Bool {
        get {
            guard let memberID = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheKickCounter+\(memberID)")
        }
        set {
            guard let memberID = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheKickCounter+\(memberID)")
        }
    }
    public var hasCacheBottle: Bool {
        get {
            guard let memberID = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheBottle+\(memberID)")
        }
        set {
            guard let memberID = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheBottle+\(memberID)")
        }
    }
    public var hasCacheDiapers: Bool {
        get {
            guard let memberID = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheDiapers+\(memberID)")
        }
        set {
            guard let memberID = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheDiapers+\(memberID)")
        }
    }
    public var hasCacheContractionCounter: Bool {
        get {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return false }
            return UserDefaults.standard.bool(forKey: "hasCacheContractionCounter+\(memberUserId)")
        }
        set {
            guard let memberUserId = TBMemberDataManager.memberUUID else { return }
            UserDefaults.standard.set(newValue, forKey: "hasCacheContractionCounter+\(memberUserId)")
        }
    }
    public var medicalDisclaimerRecordedClasses: Set<String>? {
        get {
            UserDefaults.standard.getObject(forKey: "medicalDisclaimerRecordedClassesKey", type: Set<String>.self)
        }
        set {
            UserDefaults.standard.setObject(newValue, forKey: "medicalDisclaimerRecordedClassesKey")
        }
    }
    public var showPlannerCardInHBIBCarousel: Bool {
        get {
            guard let idString = TBMemberDataManager.shared.memberData?.idString else { return false }
            return (value(forKey: "showPlannerCardInHBIBCarousel+\(idString)") as? NSNumber)?.boolValue ?? true
        }
        set {
            guard let idString = TBMemberDataManager.shared.memberData?.idString else { return }
            return setValue(NSNumber(value: newValue), forKey: "showPlannerCardInHBIBCarousel+\(idString)")
        }
    }
    public var promoBannerForceClosed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "promoBannerForceClosed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "promoBannerForceClosed")
        }
    }
    public var promoBannerDisplayStartSession: NSNumber? {
        get {
            return UserDefaults.standard.value(forKey: "promoBannerDisplayStartSession") as? NSNumber
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "promoBannerDisplayStartSession")
        }
    }
    public var promoBannerUpdateAt: String? {
        get {
            UserDefaults.standard.string(forKey: "promoBannerUpdateAtKey")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "promoBannerUpdateAtKey")
        }
    }
    public var newIndicatorItemsResetIdentity: Int {
        get {
            UserDefaults.standard.integer(forKey: "newIndicatorItemsResetIdentity")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "newIndicatorItemsResetIdentity")
        }
    }
    public var hasTapToHideHomefeedToolTips: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasTapToHideHomefeedToolTips")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasTapToHideHomefeedToolTips")
        }
    }
    public var checkUpdatesFromTheBump: Bool {
        get {
            return (UserDefaults.standard.value(forKey: "checkUpdatesFromTheBump_new") as? NSNumber)?.boolValue ?? true
        }
        set {
            UserDefaults.standard.setValue(NSNumber(value: newValue), forKey: "checkUpdatesFromTheBump_new")
        }
    }
    public var firstUseApp: Bool {
        get {
            return (UserDefaults.standard.value(forKey: "firstUseApp") as? NSNumber)?.boolValue ?? true
        }
        set {
            UserDefaults.standard.setValue(NSNumber(value: newValue), forKey: "firstUseApp")
        }
    }
    public var systemNotificationPermission: Bool? {
        get {
            return (UserDefaults.standard.value(forKey: "systemNotificationPermission") as? NSNumber)?.boolValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "systemNotificationPermission")
        }
    }
    public var shouldShowRebrandBanner: Bool? {
        get {
            let shouldShowRebrandBanner = UserDefaults.standard.value(forKey: "shouldShowRebrandBanner") as? NSNumber
            return shouldShowRebrandBanner?.boolValue
        }
        set {
            guard let newValue else { return }
            let shouldShowRebrandBanner = NSNumber.init(value: newValue)
            UserDefaults.standard.set(shouldShowRebrandBanner, forKey: "shouldShowRebrandBanner")
        }
    }
    public var pregnancyId: String? {
        get {
            guard let idString = TBMemberDataManager.shared.memberData?.idString else { return nil }
            return UserDefaults.standard.value(forKey: "pregnancyIdForWeightTracker\(idString)") as? String
        }
        set {
            guard let idString = TBMemberDataManager.shared.memberData?.idString else { return }
            UserDefaults.standard.setValue(newValue, forKey: "pregnancyIdForWeightTracker\(idString)")
        }
    }
    public var pregnancyDueDate: Date? {
        get {
            guard let idString = TBMemberDataManager.shared.memberData?.idString else { return nil }
            let date = UserDefaults.standard.value(forKey: "dueDateForWeightTracker\(idString)") as? Date
            return date
        }
        set {
            guard let idString = TBMemberDataManager.shared.memberData?.idString else { return }
            UserDefaults.standard.setValue(newValue, forKey: "dueDateForWeightTracker\(idString)")
        }
    }
}
