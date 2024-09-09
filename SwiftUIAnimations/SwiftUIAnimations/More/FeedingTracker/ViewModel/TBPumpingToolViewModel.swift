import Foundation
import RxSwift

final class TBPumpingToolViewModel: NSObject {
    let measureOZs: [Int] = [0, 2, 4, 6, 8, 10, 12]
    let measureMLs: [Int] = [0, 60, 120, 180, 240, 300, 360]
    private(set) var modelsUpdateSubject: PublishSubject<Any?> = PublishSubject<Any?>()
    private let disposeBag: DisposeBag = DisposeBag()

    var maxValue: Float {
        if UserDefaults.standard.isMetricUnit {
            return editModel.leftAmountModel.type.maxML
        } else {
            return editModel.leftAmountModel.type.maxOZ
        }
    }
    var slideSpacing: Double {
        if UserDefaults.standard.isMetricUnit {
            return editModel.leftAmountModel.type.spacingML
        } else {
            return editModel.leftAmountModel.type.spacingOZ
        }
    }
    var defaultModel: TBPumpModel? {
        didSet {
            guard let defaultModel else { return }
            editModel.update(by: defaultModel)
        }
    }
    var editModel: TBPumpModel
    var lastBreastViewEnable: Bool {
        if editModel.leftAmountModel.amount != 0, editModel.rightAmountModel.amount == 0 {
            return false
        } else if editModel.rightAmountModel.amount != 0, editModel.leftAmountModel.amount == 0 {
            return false
        }
        return true
    }

    override init() {
        editModel = TBPumpModel(startTime: Date().deleteSeconds())
        super.init()
        bindData()
    }

    private func bindData() {
        TBPumpRepository.shared.modelsSubject.subscribe(on: MainScheduler.instance).subscribe {[weak self] _ in
            guard let self else { return }
            self.modelsUpdateSubject.onNext(nil)
        } onError: { _ in
        }.disposed(by: disposeBag)
    }
}
