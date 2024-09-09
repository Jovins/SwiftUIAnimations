import Foundation
import RxSwift

protocol RouterAction {
    func routerAction(params: [String: Any], sourceType: String?)
}

final class TBToolsDataManager: NSObject {
    @objc static let sharedInstance = TBToolsDataManager()
    private let toolsFileName: String = "ToolsAndResourcesData"
    private(set) var toolListsSubject: PublishSubject<Any?> = PublishSubject<Any?>()
    private(set) var toolLists: [TBToolListModel]?
    private(set) var usageCondition: TBToolsUsageCondition?
    private let cacheKey: String = "TBToolConfigs"
    private let disposeBag = DisposeBag()
    private var _cache: TBCache<String, TBToolsUsageCondition>?
    private var cache: TBCache<String, TBToolsUsageCondition> {
        if let _cache = _cache {
            return _cache
        } else {
            if let cache = try? TBCache<String, TBToolsUsageCondition>.readFromDisk(withName: cacheKey) {
                _cache = cache
                return cache
            } else {
                let cache = TBCache<String, TBToolsUsageCondition>()
                _cache = cache
                return cache
            }
        }
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateToolList), name: NSNotification.Name.userAccountDataUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToolList), name: TBNotificationConstant.didSwitchedProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToolList), name: TBNotificationConstant.didDeleteAllWeightTrackerData, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func fetchToolsData() {
        TBWeightTrackerRepository.shared.weightsSubject.take(1).observeOn(MainScheduler.instance).subscribe { [weak self] _ in
            guard let self else { return }
            self.prepareData()
        } onError: { [weak self] _ in
            guard let self else { return }
            self.prepareData()
        }.disposed(by: disposeBag)
        TBWeightTrackerRepository.shared.getWeights()
    }

    @objc private func updateToolList() {
        prepareData { [weak self] in
            guard let self else { return }
            self.sortData()
        }
    }

    func prepareData(complete: (() -> Void)? = nil) {

        DispatchQueue.global().async { [self] in
            var toolLists = getVisibleToolsList(LocalFileLoader.loadDecodedObjectFromJSON(fileName: toolsFileName, objectType: [TBToolListModel].self))
            if let toolsConfig = cache.value(forKey: cacheKey) {
                self.usageCondition = toolsConfig
            } else {
                self.usageCondition = TBToolsUsageCondition()
            }

            var newToolConfigs = TBToolsUsageCondition()
            toolLists?.forEach { list in
                [list.tools, list.more].forEach { tools in
                    tools.forEach { tool in
                        if let record = self.usageCondition?.clickRecordDic[tool.type] {
                            newToolConfigs.clickRecordDic[tool.type] = record
                        } else {
                            newToolConfigs.clickRecordDic[tool.type] = TBToolClickRecord()
                        }
                        if let sortType = self.usageCondition?.sortTypesDic[list.stage] {
                            newToolConfigs.sortTypesDic[list.stage] = sortType
                        } else {
                            newToolConfigs.sortTypesDic[list.stage] = .mostPopular
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.usageCondition = newToolConfigs
                self.toolLists = toolLists
                storeData()
                if let complete {
                    complete()
                }
                toolListsSubject.onNext(nil)
            }
        }
    }

    func sortData(update: Bool = false, complete: (() -> Void)? = nil) {
        if update,
           toolLists?.contains(where: { $0.sortedTools == nil }) ?? true {
            return
        }
        DispatchQueue.global().async { [self] in
            guard var toolLists = toolLists else { return }
            toolLists.enumerated().forEach { index, value in
                guard let sortType = usageCondition?.sortTypesDic[value.stage] else { return }
                toolLists[index].sortedTools = TBSortedToolsModel()
                switch sortType {
                case .mostPopular:
                    toolLists[index].sortedTools?.tools = value.tools
                    toolLists[index].sortedTools?.more = value.more
                case .alphabeticalZtoA:
                    toolLists[index].sortedTools?.tools = sortByAlphabeticalZtoA(tools: value.tools, more: value.more)
                    toolLists[index].sortedTools?.more = []
                case .alphabeticalAtoZ:
                    toolLists[index].sortedTools?.tools = sortByAlphabeticalAtoZ(tools: value.tools, more: value.more)
                    toolLists[index].sortedTools?.more = []
                case .mostFrequentlyUsed:
                    let tuple = sortByFrequentlyUsed(tools: value.tools, more: value.more)
                    toolLists[index].sortedTools?.tools = tuple.tools
                    toolLists[index].sortedTools?.more = tuple.more
                }
            }
            DispatchQueue.main.async {
                self.toolLists = toolLists
                if let complete {
                    complete()
                }
                toolListsSubject.onNext(nil)
            }
        }
    }

    private func sortByAlphabeticalZtoA(tools: [TBToolsModel], more: [TBToolsModel]) -> [TBToolsModel] {
        var newTools = tools + more
        newTools = newTools.sorted { tool1, tool2 in
            return tool1.title.compare(tool2.title, options: .caseInsensitive) == .orderedDescending
        }
        return newTools
    }

    private func sortByAlphabeticalAtoZ(tools: [TBToolsModel], more: [TBToolsModel]) -> [TBToolsModel] {
        var newTools = tools + more
        newTools = newTools.sorted { tool1, tool2 in
            return tool1.title.compare(tool2.title, options: .caseInsensitive) == .orderedAscending
        }
        return newTools
    }

    private func sortByFrequentlyUsed(tools: [TBToolsModel], more: [TBToolsModel]) -> (tools: [TBToolsModel], more: [TBToolsModel]) {
        var neverOpened: [TBToolsModel] = []
        var used: [TBToolsModel] = []
        (tools + more).forEach { tool in
            guard let count = usageCondition?.clickRecordDic[tool.type]?.count else {
                neverOpened.append(tool)
                return
            }
            if count <= 0 {
                neverOpened.append(tool)
            } else {
                used.append(tool)
            }
        }
        used = used.sorted { tool1, tool2 in
            guard let record1 = usageCondition?.clickRecordDic[tool1.type],
                  let record2 = usageCondition?.clickRecordDic[tool2.type] else { return true }
            if record1.count != record2.count {
                return record1.count > record2.count
            } else {
                guard let updateAt1 = record1.updateAt, let updateAt2 = record2.updateAt else { return true }
                return updateAt1 > updateAt2
            }
        }
        return (used, neverOpened)
    }

    func recordSortType(stage: StageType, type: TBToolSortType) {
        usageCondition?.sortTypesDic[stage.rawValue] = type
        storeData()
        sortData(update: true)
    }

    func recordClickCount(type: ToolsModelType) {
        let record = TBToolsDataManager.sharedInstance.usageCondition?.clickRecordDic[type.rawValue]
        record?.count += 1
        record?.updateAt = Date()
        usageCondition?.clickRecordDic[type.rawValue] = record
        storeData()
        sortData(update: true)
    }

    func cleanSortData() {
        toolLists?.forEach({ listModel in
            var model = listModel
            model.sortedTools = nil
        })
    }

    @objc func resetData() {
        toolLists = nil
        usageCondition = TBToolsUsageCondition()
        cache.removeValue(forKey: cacheKey)
        _cache = nil
    }

    func cleanCacheForTest() {
        cache.removeValue(forKey: cacheKey)
        try? cache.saveToDisk(withName: cacheKey)
        usageCondition = nil
    }

    private func storeData() {
        guard let usageCondition else { return }
        try? cache.insert(usageCondition, forKey: cacheKey)
        try? cache.saveToDisk(withName: cacheKey)
    }

    private func getVisibleToolsList(_ toolsList: [TBToolListModel]?) -> [TBToolListModel]? {
        guard var toolsList else { return nil }
        let invisibleToolTypes = invisibleToolTypes()
        for (index, listModel) in toolsList.enumerated() {
            let visibleTools = listModel.tools.filter({
                guard let toolType = TBToolsDataManager.ToolsModelType(rawValue: $0.type) else { return false }
                return !invisibleToolTypes.contains(toolType)
            })
            let visibleMore = listModel.more.filter({
                guard let toolType = TBToolsDataManager.ToolsModelType(rawValue: $0.type) else { return false }
                return !invisibleToolTypes.contains(toolType)
            })
            toolsList[index].tools = visibleTools
            toolsList[index].more = visibleMore
        }
        return toolsList
    }

    func invisibleToolTypes() -> [TBToolsDataManager.ToolsModelType] {
        var invisibleToolTypes: [TBToolsDataManager.ToolsModelType] = []
        if let memberData = TBMemberDataManager.shared.memberData {
            if !memberData.isUserParent && !memberData.isUserPregnant {
                invisibleToolTypes.append(TBToolsDataManager.ToolsModelType.photos)
            }
            if TBWeightTrackerRepository.shared.weights.filter { $0.archived == false }.isEmpty && !memberData.isUserPregnant {
                invisibleToolTypes.append(TBToolsDataManager.ToolsModelType.weightTracker)
                invisibleToolTypes.append(TBToolsDataManager.ToolsModelType.pregnancyWeightTracker)
            }
            if !memberData.isUSUser {
                invisibleToolTypes.append(TBToolsDataManager.ToolsModelType.vaccinationTracker)
            }
        }

        if TBMemberDataManager.shared.activeStatus != .parent {
            invisibleToolTypes.append(TBToolsDataManager.ToolsModelType.feedingTracker)
        }
        return invisibleToolTypes
    }
}

extension TBToolsDataManager {
    enum ToolsModelType: String, RouterAction {
        case babyNameSearch = "Baby Name Finder"
        case babyNameGenerator = "Baby Name Generator"
        case chineseGenderChart = "Chinese Gender Chart"
        case contractionCounter = "Contraction Counter"
        case dueDateCalculator = "Due Date Calculator"
        case foodSafety = "Food Safety"
        case ovulationCalculator = "Ovulation Calculator"
        case photos = "Photos"
        case plannerPregnancyTracker = "Planner+"
        case registry = "Registry"
        case weightTracker = "Weight Tracker"
        case kickCounter = "Kick Counter"
        case hbib = "How Big is Baby"
        case babyBudgeter = "Baby Budgeter"
        case middleNameGenerator = "Middle Name Generator"
        case vaccinationTracker = "Vaccination Tracker"
        case babyWeekByWeek = "Baby Week by Week"
        case babyMonthByMonth = "Baby Month by Month"
        case bumpGuides = "The Bump Guides"
        case feedingTracker = "Baby Tracker"
        case community = "Community"
        case landingPage = "Landing Page"
        case newborn = "Newborn"
        case fertilityCalculator = "Fertility Calculator"
        case saveArticles = "Saved Articles"
        case registryChecklist = "Registry Checklist"
        case savedBabyNames = "Saved Baby Names"
        case babyNamesGame = "Baby Names Game"
        case hospitalBagChecklist = "Hospital Bag Checklist"
        case birthPlan = "Birth Plan"
        case pregnancyWeightTracker = "Pregnancy Weight Tracker"

        var title: String {
            switch self {
            case .babyNameSearch:
                return "Baby Name Finder"
            case .babyNameGenerator:
                return "Baby Name Generator"
            case .chineseGenderChart:
                return "Chinese Gender Chart"
            case .contractionCounter:
                return "Contraction Counter"
            case .dueDateCalculator:
                return "Due Date Calculator"
            case .foodSafety:
                return "Food Safety"
            case .ovulationCalculator:
                return "Ovulation Calculator"
            case .photos:
                return "Photos"
            case .plannerPregnancyTracker:
                return "Planner+"
            case .registry:
                return "Registry"
            case .weightTracker:
                return "Weight Tracker"
            case .kickCounter:
                return "Kick Counter"
            case .hbib:
                return "How Big is Baby"
            case .babyBudgeter:
                return "Baby Budgeter"
            case .middleNameGenerator:
                return "Middle Name Generator"
            case .vaccinationTracker:
                return "Vaccination Tracker"
            case .babyWeekByWeek:
                return "Baby Week by Week"
            case .babyMonthByMonth:
                return "Baby Month by Month"
            case .bumpGuides:
                return "The Bump Guides"
            case .feedingTracker:
                return "Baby Tracker"
            case .community:
                return "Community"
            case .fertilityCalculator:
                return "Fertility Calculator"
            case .saveArticles:
                return "Saved Articles"
            case .registryChecklist:
                return "Registry Checklist"
            case .savedBabyNames:
                return "Saved Baby Names"
            case .babyNamesGame:
                return "Baby Names Game"
            case .hospitalBagChecklist:
                return "Hospital Bag Checklist"
            case .birthPlan:
                return "Birth Plan"
            case .pregnancyWeightTracker:
                return "Pregnancy Weight Tracker"
            case .landingPage,
                 .newborn:
                return ""
            }
        }

        func routerAction(params: [String: Any] = [:], sourceType: String? = nil) {

            TBToolsDataManager.sharedInstance.recordClickCount(type: self)
            switch self {
            case .babyNameSearch:
                AppRouter.navigateToBrowser(url: TBURLConstant.kSearchByNames) { setting in
                    setting.title = "Baby Name Search"
                    return setting
                }
            case .babyNameGenerator:
                AppRouter.navigateToBrowser(url: TBURLConstant.babyNameGenerator) { setting in
                    setting.title = "Baby Name Generator"
                    return setting
                }
            case .chineseGenderChart:
                AppRouter.navigateToBrowser(url: TBURLConstant.chineseGenderChar) { setting in
                    setting.title = "Chinese Gender Chart"
                    return setting
                }
            case .contractionCounter:
                AppRouter.presentToContractionCounter(sourceType: sourceType ?? " ")
            case .dueDateCalculator:
                AppRouter.navigateToBrowser(url: kDueDateCalculator) { setting in
                    setting.title = "Due Date Calculator"
                    return setting
                }
            case .foodSafety:
                AppRouter.navigateToFoodSafety()
            case .ovulationCalculator:
                AppRouter.navigateToBrowser(url: kOvulationCalculator) { setting in
                    setting.title = "Ovulation Calculator"
                    return setting
                }
            case .photos:
                AppRouter.navigateToPhotos(sourceType: sourceType ?? " ")
            case .plannerPregnancyTracker:
                AppRouter.presentToPlannerPregnancyTracker(sourceType: sourceType)
            case .registry:
                AppRouter.openRegistry(sourceType: sourceType ?? " ")
            case .weightTracker, .pregnancyWeightTracker:
                AppRouter.presentToWeightTracker(title: rawValue, sourceType: sourceType ?? " ")
            case .kickCounter:
                AppRouter.presentToKickCounter(sourceType: sourceType ?? " ")
            case .hbib:
                let week = TBMemberDataManager.sharedInstance().memberData?.weeksInCurrentPregnancy
                AppRouter.navigateToPregnancyWeekByWeek(sourceType ?? " ", week: week)
            case .babyBudgeter:
                AppRouter.navigateToBrowser(url: TBURLConstant.babyBudgeter) { setting in
                    setting.title = "Baby Budgeter"
                    return setting
                }
            case .middleNameGenerator:
                AppRouter.navigateToBrowser(url: TBURLConstant.middleNameGenerator) { setting in
                    setting.title = "Middle Name Generator"
                    return setting
                }
            case .vaccinationTracker:
                AppRouter.navigateToBrowser(url: TBURLConstant.vaccinationTracker) { setting in
                    setting.title = "Vaccination Tracker"
                    return setting
                }
            case .babyMonthByMonth:
                AppRouter.navigateToBabyMonthByMonth()
            case .bumpGuides:
                guard let stage = params["stage"] as? TBToolsDataManager.StageType else { return }
                AppRouter.navigateToTheBumpGuides(stage: stage)
            case .community:
                AppRouter.navigateToCommunity(sourceType: sourceType ?? " ")
            case .landingPage:
                AppRouter.navigateToAppTools()
            case .newborn:
                AppRouter.navigateToHBIC(selectedWeek: 0, sourceType: sourceType ?? " ")
            case .babyWeekByWeek:
                var week: Int = 1
                if TBMemberDataManager.shared.isParentSelected && !TBMemberDataManager.shared.isToddlerSelected,
                   let babyId = TBMemberDataManager.shared.activeStatusModel?.id,
                   let child = TBMemberDataManager.shared.memberData?.childWithBabyId(babyId: NSNumber(value: babyId)) {
                    week = TBTimeUtility.parentingAgeWeeksFromBirthDate(birthDate: child.childBirthDate)
                }
                AppRouter.navigateToHBIC(selectedWeek: week, sourceType: sourceType ?? " ")
            case .feedingTracker:
                AppRouter.navigateToFeedingTrackerHistory(action: .present, sourceType: sourceType ?? "")
            case .fertilityCalculator:
                navigateToUrl(TBURLConstant.fertilityCalculator, title: "Fertility Calculator", sourceType: sourceType)
            case .saveArticles:
                AppRouter.navigateToBrowser(url: savedArticlesListURL)
            case .registryChecklist:
                navigateToUrl(TBURLConstant.registryChecklist, title: "Registry Checklist", sourceType: sourceType)
            case .savedBabyNames:
                AppRouter.navigateToBrowser(url: kBabyNamesFavoritesURL)
            case .babyNamesGame:
                AppRouter.navigateToBrowser(url: TBURLConstant.babyNamesGame)
            case .hospitalBagChecklist:
                navigateToUrl(TBURLConstant.hospitalBagChecklist, title: "Hospital Bag Checklist", sourceType: sourceType)
            case .birthPlan:
                navigateToUrl(TBURLConstant.birthPlan, title: rawValue, sourceType: sourceType)
            }
        }

        private func navigateToUrl(_ url: String, title: String? = nil, sourceType: String? = nil) {
            guard let url = URL(string: url) else { return }
            var params: [String: Any] = [:]
            params["title"] = title
            params["source"] = sourceType
            AppRouter.navigateToDeepLinkUrl(url, params: params)
        }
    }
}

extension TBToolsDataManager {
    enum StageType: String, Codable {
        case TTC = "Trying to Conceive"
        case firstTrimester = "First Trimester"
        case secondTrimester = "Second Trimester"
        case thirdTrimester = "Third Trimester"
        case baby = "Baby"
    }
}

extension TBToolsDataManager {
    static func getStage(withStatus status: TBMemberDataManager.TBActiveStatusType) -> TBToolsDataManager.StageType? {
        switch status {
        case .TTC:
            return .TTC
        case .parent:
            return .baby
        case .pregnant:
            guard let week = TBMemberDataManager.shared.memberData?.weeksInCurrentPregnancy,
                  let stage = Date.trimesterForWeek(week: week) else { return nil }
            switch stage {
            case .first:
                return .firstTrimester
            case .second:
                return .secondTrimester
            case .third:
                return .thirdTrimester
            }
        default:
            return nil
        }
    }
}

extension Array where Element == TBToolListModel {
    var ttcToolsModel: TBToolListModel? {
        return first(where: { $0.stage == TBToolsDataManager.StageType.TTC.rawValue })
    }
    var firstTriToolsModel: TBToolListModel? {
        return first(where: { $0.stage == TBToolsDataManager.StageType.firstTrimester.rawValue })
    }
    var secondTriToolsModel: TBToolListModel? {
        return first(where: { $0.stage == TBToolsDataManager.StageType.secondTrimester.rawValue })
    }
    var thirdTriToolsModel: TBToolListModel? {
        return first(where: { $0.stage == TBToolsDataManager.StageType.thirdTrimester.rawValue })
    }
    var babyToolsModel: TBToolListModel? {
        return first(where: { $0.stage == TBToolsDataManager.StageType.baby.rawValue })
    }
}
