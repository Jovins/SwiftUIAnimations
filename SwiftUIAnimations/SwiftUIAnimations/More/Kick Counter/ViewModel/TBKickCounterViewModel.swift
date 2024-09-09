import Foundation
import RxSwift

final class TBKickCounterViewModel: NSObject {
    private(set) var kickCounterSubject = PublishSubject<[[TBKickCounterModel]]>()
    private(set) var kickCounterModels: [[TBKickCounterModel]] = []
    private let repo: TBKickCounterRepository = TBKickCounterRepository.shared
    private let disposeBag = DisposeBag()

    override init() {
        super.init()
        bindData()
    }

    private func bindData() {
        TBKickCounterRepository.shared.kickCounterSubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
            guard let self = self else { return }
            self.kickCounterModels = models.compactMap({ $0.filter({ $0.archived == false }) })
            self.kickCounterSubject.onNext(self.kickCounterModels)
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    func getKickCounter() {
        repo.getKickCounterModels()
    }

    func deleteKickCountersOfThisDay(date: Date) {
        repo.deleteKickCountersOfThisDay(date: date)
    }

    func deleteKickCounter(id: String) {
        repo.deleteKickCounter(id: id)
    }
}
