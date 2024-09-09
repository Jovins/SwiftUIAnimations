import Foundation
import RxSwift

final class TBToolsRootViewModel: NSObject {
    private(set) var toolListsSubject: PublishSubject<Any?> = PublishSubject<Any?>()
    private(set) var toolLists: [TBToolListModel] = []
    private let disposeBag = DisposeBag()
    var currentIndex: Int = {
        switch TBMemberDataManager.shared.activeStatus {
        case .TTC:
            return 0
        case .pregnant:
            return 1
        case .parent:
            return 2
        default:
            return 0
        }
    }()

    var tabBarTitles: [String] {
        return ["Trying to\nConceive", "Pregnancy", "Baby"]
    }

    override init() {
        super.init()
        bindData()
        self.toolLists = TBToolsDataManager.sharedInstance.toolLists ?? []
    }

    private func bindData() {
        TBToolsDataManager.sharedInstance.toolListsSubject.subscribe(on: MainScheduler.instance).subscribe {[weak self] _ in
            guard let self else { return }
            self.toolLists = TBToolsDataManager.sharedInstance.toolLists ?? []
            self.toolListsSubject.onNext(nil)
        } onError: { _ in
        }.disposed(by: disposeBag)
    }

    func getToolListModel(with index: Int) -> TBToolListModel? {
        switch index {
        case 0:
            return toolLists.ttcToolsModel
        case 1:
            guard let week = TBMemberDataManager.shared.memberData?.weeksInCurrentPregnancy,
                              let stage = Date.trimesterForWeek(week: week) else {
                return toolLists.firstTriToolsModel
            }
            switch stage {
            case .first:
                return toolLists.firstTriToolsModel
            case .second:
                return toolLists.secondTriToolsModel
            case .third:
                return toolLists.thirdTriToolsModel
            }
        case 2:
            return toolLists.babyToolsModel
        default:
            return nil
        }
    }

    func getStageIndex(with stage: TBToolsDataManager.StageType) -> Int? {
        switch stage {
        case .TTC:
            return 0
        case .firstTrimester,
             .secondTrimester,
             .thirdTrimester:
            return 1
        case .baby:
            return 2
        }
    }
}
