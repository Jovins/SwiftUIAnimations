import Foundation
import RxSwift

final class TBWeightTrackerHistoryViewModel: NSObject {
    let weightsSubject: PublishSubject<[TBWeightTrackerModel]> = PublishSubject<[TBWeightTrackerModel]>()
    private(set) var weights: [TBWeightTrackerModel] = []
    private let repo: TBWeightTrackerRepository = TBWeightTrackerRepository.shared
    private(set) var cellTypes: [TBWeightTrackerViewModel.CellType] = []
    private let disposeBag = DisposeBag()
    var showArchivedData: Bool = false

    override init() {
        super.init()
        bindData()
    }

    private func bindData() {
        repo.weightsSubject.observeOn(MainScheduler.instance).subscribe {[weak self] models in
            guard let self = self else { return }
            if self.showArchivedData {
                self.weights = models
            } else {
                self.weights = models.filter { $0.archived == false }
            }
            self.setupCellTypes()
            self.weightsSubject.onNext(models)
        } onError: {[weak self] _ in
            guard let self = self else { return }
            self.weightsSubject.onNext([])
        }.disposed(by: disposeBag)
    }

    func getWeights() {
        repo.getWeights()
    }

    private func setupCellTypes() {
        cellTypes = [.weightListHeader]
        cellTypes.append(contentsOf: weights.map({ _ in
            return .weight
        }))
    }
}
