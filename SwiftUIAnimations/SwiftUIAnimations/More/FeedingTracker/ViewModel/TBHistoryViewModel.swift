import Foundation
import RxSwift
import FirebaseCrashlytics

final class TBHistoryViewModel {

    static let shared = TBHistoryViewModel()
    private(set) var allHistorys = [[TBFeedingTrackerModelProtocol]]()
    private(set) var nursingHistorys = [[TBFeedingTrackerModelProtocol]]()
    private(set) var bottleHistorys = [[TBFeedingTrackerModelProtocol]]()
    private(set) var pumpingHistorys = [[TBFeedingTrackerModelProtocol]]()
    private(set) var diaperHistorys = [[TBFeedingTrackerModelProtocol]]()

    private var allHistory = [TBFeedingTrackerModelProtocol]()
    private var nursings = [TBFeedingTrackerModelProtocol]()
    private var bottles = [TBFeedingTrackerModelProtocol]()
    private var pumps = [TBFeedingTrackerModelProtocol]()
    private var diapers = [TBFeedingTrackerModelProtocol]()

    private(set) var reloadSubject = PublishSubject<Bool>()

    private let allRepos: [TBFeedingTrackerRepoProtocol] = [
        TBNursingRepository.shared,
        TBBottleRepository.shared,
        TBPumpRepository.shared,
        TBDiapersRepository.shared
    ]
    private let disposeBag = DisposeBag()

    init() {
        bindData()
    }

    private func bindData() {
        Observable.combineLatest(TBNursingRepository.shared.modelsSubject,
                                 TBBottleRepository.shared.modelsSubject,
                                 TBPumpRepository.shared.modelsSubject,
                                 TBDiapersRepository.shared.modelsSubject)
        .subscribe(onNext: { [weak self] (nursings, bottles, pumps, diapers) in
            guard let self = self else { return }
            self.nursings = nursings.filter({ !$0.archived && $0.savedTime != nil })
            self.bottles = bottles.filter({ !$0.archived })
            self.pumps = pumps.filter({ !$0.archived })
            self.diapers = diapers.filter({ !$0.archived })
            self.sortDataAndUpdateUI()
        }).disposed(by: disposeBag)
    }

    private func sortDataAndUpdateUI() {
        allHistory = nursings + bottles + pumps + diapers
        sortHistory()
        allHistorys = getDoubleDimensionalArray(historys: allHistory)
        nursingHistorys = getDoubleDimensionalArray(historys: nursings)
        bottleHistorys = getDoubleDimensionalArray(historys: bottles)
        pumpingHistorys = getDoubleDimensionalArray(historys: pumps)
        diaperHistorys = getDoubleDimensionalArray(historys: diapers)
        reloadSubject.onNext(true)
    }

    private func sortHistory() {
        nursings.sort { $0.startTime > $1.startTime }
        bottles.sort { $0.startTime > $1.startTime }
        pumps.sort { $0.startTime > $1.startTime }
        diapers.sort { $0.startTime > $1.startTime }
        allHistory.sort { $0.startTime > $1.startTime }
    }

    private func getDoubleDimensionalArray(historys: [TBFeedingTrackerModelProtocol]) -> [[TBFeedingTrackerModelProtocol]] {
        var dic: [String: [TBFeedingTrackerModelProtocol]] = [:]
        historys.forEach {
            let key = $0.startTime.convertToYYYYMMDD()
            if let array = dic[key] {
                dic[key] = array + [$0]
            } else {
                dic[key] = [$0]
            }
        }
        return dic.keys.sorted(by: { $0 > $1 }).compactMap({ key in
            return dic[key]
        })
    }

    private func recordCellRowHeight(model: Any) -> CGFloat {
        switch model {
        case let nursingModel as TBNursingModel:
            var noteHeight: CGFloat = 0
            if let note = nursingModel.note, !note.isEmpty {
                noteHeight = note.attributedText(.mulishBody4)?.height(withConstrainedWidth: UIScreen.width - 122) ?? 0
            }
            return noteHeight == 0 ? 80 : 82 + noteHeight
        case let bottleModel as TBBottleModel:
            var noteHeight: CGFloat = 0
            if let note = bottleModel.note, !note.isEmpty {
                noteHeight = note.attributedText(.mulishBody4)?.height(withConstrainedWidth: UIScreen.width - 122) ?? 0
            }
            return noteHeight == 0 ? 80 : 82 + noteHeight
        case let pumpModel as TBPumpModel:
            var noteHeight: CGFloat = 0
            if let note = pumpModel.note, !note.isEmpty {
                noteHeight = note.attributedText(.mulishBody4)?.height(withConstrainedWidth: UIScreen.width - 122) ?? 0
            }
            return noteHeight == 0 ? 80 : 82 + noteHeight
        case let diapersModel as TBDiapersModel:
            var noteHeight: CGFloat = 0
            if let note = diapersModel.note, !note.isEmpty {
                noteHeight = note.attributedText(.mulishBody4)?.height(withConstrainedWidth: UIScreen.width - 122) ?? 0
            }
            return noteHeight <= 17 ? 80 : (61 + noteHeight)
        default:
            return 80
        }
    }

    private func csvStringFromHistory() -> String {
        var sectionString = ["Date,Time,Item,Notes"]
        let contentString = allHistory.map {
            var detail = ""
            switch $0.type {
            case .nursing:
                if let model = $0 as? TBNursingModel {
                    detail = TBFeedingTrackerRecordHelper.getNursingDetails(nursingModel: model)
                }
            case .diapers:
                break
            case .bottle:
                if let model = $0 as? TBBottleModel {
                    detail = TBFeedingTrackerRecordHelper.getBottleDetails(bottleModel: model)
                }
            case .pumping:
                if let model = $0 as? TBPumpModel {
                    detail = TBFeedingTrackerRecordHelper.getPumpDetails(pumpModel: model)
                }
            }
            let modelNote = $0.note ?? ""
            let needReturn = !detail.isEmpty && !modelNote.isEmpty
            let note = detail + (needReturn ? "\r" : "" ) + modelNote
            var stringArray = [String]()
            stringArray.append($0.startTime.convertToMMMddyyyy().csvFriendly)
            stringArray.append($0.startTime.convertTohmma().csvFriendly)
            stringArray.append($0.item?.csvFriendly ?? "")
            stringArray.append(note.csvFriendly ?? "")
            let csvString = stringArray.joined(separator: ",")
            return csvString
        }
        sectionString.append(contentsOf: contentString)
        let csvString = sectionString.joined(separator: "\n")
        return csvString
    }

    // MARK: - Publich Methods
    func getCellsHeight(historys: [[TBFeedingTrackerModelProtocol]]) -> CGFloat {
        var tableViewContentHeight: CGFloat = 0
        historys.forEach { models in
            tableViewContentHeight += 42
            models.forEach { model in
                tableViewContentHeight += recordCellRowHeight(model: model)
            }
        }
        return tableViewContentHeight
    }

    func getAllHistory() {
        allRepos.forEach({ $0.getData() })
    }

    func outputDataAsCSV(sender: Any) {
        let csvString = csvStringFromHistory()
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("Baby_Tracker_Records.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            let objectsToShare = [fileURL]
            TBShareManager.shared.presentSocialService(type: .system, sender: sender, items: objectsToShare, completion: nil)
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func deleteModel(model: TBFeedingTrackerModelProtocol) {
        switch model {
        case let model as TBNursingModel:
            guard let repo = allRepos.first(where: { $0 is TBNursingRepository }) as? TBNursingRepository else { return }
            repo.deleteModel(id: model.id)
        case let model as TBBottleModel:
            guard let repo = allRepos.first(where: { $0 is TBBottleRepository }) as? TBBottleRepository else { return }
            repo.deleteModel(id: model.id)
        case let model as TBPumpModel:
            guard let repo = allRepos.first(where: { $0 is TBPumpRepository }) as? TBPumpRepository else { return }
            repo.deleteModel(id: model.id)
        case let model as TBDiapersModel:
            guard let repo = allRepos.first(where: { $0 is TBDiapersRepository }) as? TBDiapersRepository else { return }
            repo.deleteModel(id: model.id)
        default:
            break
        }
    }
}
