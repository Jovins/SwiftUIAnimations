import Foundation
import RxSwift

final class TBKickCounterControlViewModel: NSObject {

    private(set) var kickCounterSubject = PublishSubject<Bool>()
    private let repo: TBKickCounterRepository = TBKickCounterRepository.shared
    private let disposeBag = DisposeBag()
    private let towHours: TimeInterval = 2 * 60 * 60
    private var currentModel: TBKickCounterModel?
    var shouldStartToKick: Bool = false

    override init() {
        super.init()
        bindData()
    }

    private func bindData() {
        TBKickCounterRepository.shared.kickCounterSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
            guard let self = self else { return }
            self.updateCurrentModel(models: models.compactMap({ $0.filter({ $0.archived == false }) }))
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    private func updateCurrentModel(models: [[TBKickCounterModel]]) {
        guard let model = models.first?.first else {
            currentModel = nil
            shouldStartToKick = false
            kickCounterSubject.onNext(true)
            return
        }
        currentModel = model
        updateKickCounter()
    }

    func updateKickCounter() {
        guard let model = currentModel, model.endTime == nil else {
            currentModel = nil
            shouldStartToKick = false
            kickCounterSubject.onNext(true)
            return
        }
        if model.startTime.isSameDayAs(otherDate: Date()) {
            let duration = Date().timeIntervalSince1970 - model.lastUpdatedTime.timeIntervalSince1970
            if duration > towHours {
                repo.autoUpdateEndTime(id: model.id, duration: towHours)
                currentModel = nil
                shouldStartToKick = false
            } else {
                currentModel = model
                shouldStartToKick = true
            }
        } else {
            guard let nextDate = model.startTime.crossDate() else { return }
            let duration = nextDate.timeIntervalSince1970 - model.lastUpdatedTime.timeIntervalSince1970
            if duration > towHours {
                repo.autoUpdateEndTime(id: model.id, duration: towHours)
            } else {
                repo.autoUpdateEndTime(id: model.id, duration: duration)
            }
            currentModel = nil
            shouldStartToKick = false
        }
        kickCounterSubject.onNext(true)
    }

    var totalDuration: TimeInterval {
        guard let currentModel else { return 0 }
        return Date().timeIntervalSince1970 - currentModel.startTime.timeIntervalSince1970
    }

    var kickCounterCount: Int {
        guard let currentModel else { return 0 }
        return currentModel.kickCounterCount
    }

    func startNewKickCounter() {
        let model = TBKickCounterModel(startTime: Date())
        currentModel = model
        repo.startNewCount(model: model)
    }

    func finishKickCounter() {
        guard let model = currentModel else { return }
        repo.finishKickCounter(id: model.id)
        currentModel = nil
    }

    func recordKickCounter() {
        guard let currentModel else { return }
        repo.recordCount(id: currentModel.id)
    }

    func resetKickCounter() {
        guard var model = currentModel else { return }
        repo.deleteKickCounter(id: model.id)
        currentModel = nil
    }
}
