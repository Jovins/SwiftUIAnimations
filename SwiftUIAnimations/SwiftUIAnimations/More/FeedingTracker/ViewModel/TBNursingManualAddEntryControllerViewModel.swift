import UIKit
import RxSwift

final class TBNursingManualAddEntryControllerViewModel: NSObject {

    private(set) var saveSubject = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    var operationType: OperationType = .add

    func bindData(viewModel: TBNursingManualAddEntryViewModel) {
        viewModel.updateSubject.subscribe { [weak self] _ in
            guard let self = self else { return }
            var saveEnable: Bool = false
            switch self.operationType {
            case .add:
                if self.basicDataSaveEnable(viewModel: viewModel) {
                    saveEnable = true
                }
            case .edit:
                if self.basicDataSaveEnable(viewModel: viewModel),
                   !viewModel.editModel.isEqual(viewModel.defaultModel) {
                    saveEnable = true
                }
            }
            self.saveSubject.onNext(saveEnable)
        }.disposed(by: disposeBag)
    }

    private func basicDataSaveEnable(viewModel: TBNursingManualAddEntryViewModel) -> Bool {
        return viewModel.editModel.leftBreast.duration > 0 || viewModel.editModel.rightBreast.duration > 0
    }
}

extension TBNursingManualAddEntryControllerViewModel {
    enum OperationType {
        case add
        case edit
    }
}
