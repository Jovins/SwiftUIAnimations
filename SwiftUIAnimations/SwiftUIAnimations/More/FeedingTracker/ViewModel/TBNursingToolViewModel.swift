import UIKit
import RxSwift

final class TBNursingToolViewModel: NSObject {

    var currentModel: TBNursingModel?
    var currentSide: TBNursingModel.Side?
    var lastSide: TBNursingModel.Side?
    private(set) var shouldStartToRecord: Bool = false
    private(set) var updateNursingSubject = PublishSubject<Bool>()
    private let repo: TBNursingRepository = TBNursingRepository.shared
    private let disposeBag = DisposeBag()
    private let oneHalfHours: TimeInterval = 1.5 * 60 * 60

    override init() {
        super.init()
        bindData()
    }

    private func bindData() {
        repo.modelsSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
            guard let self = self else { return }
            self.updateCurrentModel(models: models.filter({ !$0.archived }))
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    private func updateCurrentModel(models: [TBNursingModel]) {

        if let model =  models.first(where: { $0.savedTime == nil }) {
            currentModel = model
        } else if let model = models.first {
            currentModel = model
        } else {
            currentModel = nil
            currentSide = nil
            lastSide = nil
            shouldStartToRecord = false
            updateNursingSubject.onNext(true)
            return
        }
        if let currentModel,
           currentModel.startTime.isSameDayAs(otherDate: Date()),
           currentModel.savedTime != nil {
            lastSide = currentModel.lastBreast
        } else {
            lastSide = nil
        }
        checkNursingAutoToSave()
    }

    func getData() {
        repo.getData()
    }

    func checkNursingAutoToSave() {
        guard let model = currentModel, model.savedTime == nil else {
            currentModel = nil
            shouldStartToRecord = false
            currentSide = nil
            updateNursingSubject.onNext(true)
            return
        }
        if model.startTime.isSameDayAs(otherDate: Date()) {
            let duration = Date().timeIntervalSince1970 - model.updatedTime.timeIntervalSince1970
            if duration > oneHalfHours {
                repo.autoUpdateEndTime(id: model.id, duration: oneHalfHours)
                currentModel = nil
                shouldStartToRecord = false
            } else {
                currentModel = model
                shouldStartToRecord = true
            }
        } else {
            guard let nextDate = model.startTime.crossDate() else { return }
            let duration = nextDate.timeIntervalSince1970 - model.updatedTime.timeIntervalSince1970
            if duration > oneHalfHours {
                repo.autoUpdateEndTime(id: model.id, duration: oneHalfHours)
            } else {
                repo.autoUpdateEndTime(id: model.id, duration: duration)
            }
            currentModel = nil
            shouldStartToRecord = false
        }
        updateNursingSubject.onNext(true)
    }

    var leftDuration: TimeInterval {
        guard let currentModel else { return 0 }
        return TimeInterval(currentModel.leftBreast.duration)
    }

    var rightDuration: TimeInterval {
        guard let currentModel else { return 0 }
        return TimeInterval(currentModel.rightBreast.duration)
    }

    var totalDuration: TimeInterval {
        guard let currentModel else { return 0 }
        return TimeInterval(currentModel.leftBreast.duration + currentModel.rightBreast.duration)
    }

    func startNursing() {
        let model = TBNursingModel()
        var breastModel = currentSide == .left ? model.leftBreast : model.rightBreast
        breastModel.duration = 0
        breastModel.isBreasting = true
        currentModel = model
        shouldStartToRecord = true
        repo.addModel(model: model)
    }

    func updateCurrentNursing(duration: Int = 1, isBreasting: Bool = true, isSave: Bool = false, note: String? = nil) {
        guard var model = currentModel else { return }
        checkNursingAutoToSave()
        if let currentSide, currentSide == .left {
            model.leftBreast.duration += (isSave || !isBreasting ? 0 : duration)
            model.leftBreast.isBreasting = isBreasting
            model.rightBreast.isBreasting = false
            model.lastBreast = currentSide
        } else if currentSide == .right {
            model.rightBreast.duration += (isSave || !isBreasting ? 0 : duration)
            model.rightBreast.isBreasting = isBreasting
            model.leftBreast.isBreasting = false
            model.lastBreast = currentSide
        }
        if isSave {
            if let currentSide {
                var breastModel = currentSide == .left ? model.leftBreast : model.rightBreast
                breastModel.isBreasting = false
                self.currentSide = nil
            }
            model.savedTime = Date()
            model.note = note
            currentModel = nil
        }
        repo.editModel(id: model.id, model: model, shouldSendSubject: isSave)
    }

    func resetCurrentNursing() {
        guard var model = currentModel else { return }
        repo.deleteModel(id: model.id)
        currentModel = nil
    }
}
