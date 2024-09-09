import UIKit
import RxSwift

final class TBDiapersToolViewModel: NSObject {

    var defaultModel: TBDiapersModel? {
        didSet {
            guard let defaultModel else { return }
            editModel = TBDiapersModel()
            editModel?.update(by: defaultModel)
        }
    }
    private(set) var editModel: TBDiapersModel?
    private(set) var saveDiapersSubject = PublishSubject<Bool>()
    private(set) var updateDiapersSubject = PublishSubject<Bool>()
    private(set) var deleteDiapersSubject = PublishSubject<Bool>()
    private let repo: TBDiapersRepository = TBDiapersRepository.shared
    private let disposeBag = DisposeBag()

    var isEnabled: Bool {
        guard let defaultModel, let editModel else { return false }
        return !defaultModel.isEqual(editModel)
    }

    func saveDiapers(model: TBDiapersModel) {
        repo.addModel(model: model)
        saveDiapersSubject.onNext(true)
    }

    func updateDiapers(model: TBDiapersModel) {
        repo.editModel(id: model.id, model: model)
        updateDiapersSubject.onNext(true)
    }

    func deleteDiapers(model: TBDiapersModel) {
        repo.deleteModel(id: model.id)
        deleteDiapersSubject.onNext(true)
    }
}
