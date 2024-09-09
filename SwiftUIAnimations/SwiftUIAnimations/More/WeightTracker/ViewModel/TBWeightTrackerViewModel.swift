import Foundation
import RxSwift

final class TBWeightTrackerViewModel: NSObject {
    let weightsSubject: PublishSubject<[TBWeightTrackerModel]> = PublishSubject<[TBWeightTrackerModel]>()
    private(set) var weights: [TBWeightTrackerModel] = []
    private let repo: TBWeightTrackerRepository = TBWeightTrackerRepository.shared
    private(set) var cellTypes: [CellType] = []
    private let disposeBag = DisposeBag()

    override init() {
        super.init()
        bindData()
    }

    private func bindData() {
        repo.weightsSubject.observeOn(MainScheduler.instance).subscribe {[weak self] models in
            guard let self = self else { return }
            self.weights = models.filter { $0.archived == false }
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

    func resetAll() {
        repo.resetWeights()
    }

    private func setupCellTypes() {
        cellTypes = [.weightListHeader]
        if weights.count > 3 {
            let array = Array(1...3).map({ _ in
                return CellType.weight
            })
            cellTypes.append(contentsOf: array)
            cellTypes.append(CellType.viewAll)
        } else {
            let array = weights.map({ _ in
                return CellType.weight
            })
            cellTypes.append(contentsOf: array)
        }
        cellTypes.append(CellType.totalWeight)
        cellTypes.append(CellType.chart)
    }
}

extension TBWeightTrackerViewModel {
    enum CellType {
        case weightListHeader
        case weight
        case viewAll
        case totalWeight
        case chart
    }
}
