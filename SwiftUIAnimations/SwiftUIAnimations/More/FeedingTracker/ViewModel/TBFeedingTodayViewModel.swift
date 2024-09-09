import UIKit
import RxSwift

final class TBFeedingTodayViewModel: NSObject {

    private(set) var updateTodaySubject = PublishSubject<Bool>()
    private var repo: TBFeedingTrackerRepoProtocol?
    private let disposeBag = DisposeBag()
    private var type: FeedingTrackerToolType = .nursing
    private(set) var models = [Any]()
    private(set) var todayModels = [Any]()
    private(set) var displayViewHistory: Bool = false
    private(set) var tableViewHeight: CGFloat = 0

    init(type: FeedingTrackerToolType = .nursing) {
        super.init()
        switch type {
        case .nursing:
            repo = TBNursingRepository.shared
        case .diapers:
            repo = TBDiapersRepository.shared
        case .bottle:
            repo = TBBottleRepository.shared
        case .pumping:
            repo = TBPumpRepository.shared
        default:
            break
        }
        bindData()
    }

    private func bindData() {
        switch repo {
        case let repo as TBNursingRepository:
            repo.modelsSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                let nursingModels = models.filter({ !$0.archived && $0.savedTime != nil })
                self.models = nursingModels
                self.todayModels = nursingModels.filter({ $0.startTime.isSameDayAs(otherDate: Date()) })
                self.displayViewHistory = nursingModels.contains(where: { !$0.startTime.isSameDayAs(otherDate: Date()) })
                self.updateTableViewHeight()
                self.updateTodaySubject.onNext(true)
            }, onError: { _ in }).disposed(by: disposeBag)
        case let repo as TBDiapersRepository:
            repo.modelsSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                let diapers = models.filter({ $0.archived == false })
                self.models = diapers
                self.todayModels = diapers.filter({ ($0.startTime.isSameDayAs(otherDate: Date()) ?? false) })
                self.displayViewHistory = diapers.contains(where: { !($0.startTime.isSameDayAs(otherDate: Date()) ?? false) })
                self.updateTableViewHeight()
                self.updateTodaySubject.onNext(true)
            }, onError: { _ in }).disposed(by: disposeBag)
        case let repo as TBBottleRepository:
            repo.modelsSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                let bottles = models.filter({ $0.archived == false })
                self.models = bottles
                self.todayModels = bottles.filter({ ($0.startTime.isSameDayAs(otherDate: Date()) ?? false) })
                self.displayViewHistory = bottles.contains(where: { !($0.startTime.isSameDayAs(otherDate: Date()) ?? false) })
                self.updateTableViewHeight()
                self.updateTodaySubject.onNext(true)
            }, onError: { _ in }).disposed(by: disposeBag)
        case let repo as TBPumpRepository:
            repo.modelsSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                let pumpingModels = models.filter({ !$0.archived })
                self.models = pumpingModels
                self.todayModels = pumpingModels.filter({ ($0.startTime.isSameDayAs(otherDate: Date()) ?? false) })
                self.displayViewHistory = pumpingModels.contains(where: { !($0.startTime.isSameDayAs(otherDate: Date()) ?? false) })
                self.updateTableViewHeight()
                self.updateTodaySubject.onNext(true)
            }, onError: { _ in }).disposed(by: disposeBag)
        default:
            break
        }
    }

    func getData() {
        repo?.getData()
    }

    func deleteModel(model: Any) {
        switch repo {
        case let repo as TBNursingRepository:
            guard let model = model as? TBNursingModel else { return }
            repo.deleteModel(id: model.id)
        case let repo as TBDiapersRepository:
            guard let model = model as? TBDiapersModel else { return }
            repo.deleteModel(id: model.id)
        case let repo as TBBottleRepository:
            guard let model = model as? TBBottleModel else { return }
            repo.deleteModel(id: model.id)
        case let repo as TBPumpRepository:
            guard let model = model as? TBPumpModel else { return }
            repo.deleteModel(id: model.id)
        default:
            break
        }
        updateTodaySubject.onNext(true)
    }

    private func updateTableViewHeight() {
        let tableViewHeaderHeight: CGFloat = 42
        guard !todayModels.isEmpty else {
            tableViewHeight = tableViewHeaderHeight + 50
            return
        }
        var rowsHeight: CGFloat = 0
        for row in 0..<todayModels.count where row < 3 {
            rowsHeight += recordCellRowHeight(model: todayModels[row])
        }
        tableViewHeight = min(rowsHeight + tableViewHeaderHeight, 282)
    }

    private func recordCellRowHeight(model: Any) -> CGFloat {
        switch model {
        case let nursingModel as TBNursingModel:
            var noteHeight: CGFloat = 0
            if let note = nursingModel.note, !note.isEmpty {
                noteHeight = note.attributedText(.mulishBody4)?.height(withConstrainedWidth: UIScreen.width - 122) ?? 0
            }
            return noteHeight == 0 ? 80 : 82 + noteHeight
        case let diapersModel as TBDiapersModel:
            var noteHeight: CGFloat = 0
            if let note = diapersModel.note, !note.isEmpty {
                noteHeight = note.attributedText(.mulishBody4)?.height(withConstrainedWidth: UIScreen.width - 122) ?? 0
            }
            return noteHeight <= 17 ? 80 : (61 + noteHeight)
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
        default:
            return 80
        }
    }
}
