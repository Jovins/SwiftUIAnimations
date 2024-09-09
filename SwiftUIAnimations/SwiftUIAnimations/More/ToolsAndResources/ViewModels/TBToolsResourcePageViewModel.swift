import Foundation
import RxSwift

final class TBToolsResourcePageViewModel: NSObject {

    var listModel: TBToolListModel? {
        didSet {
            guard let listModel else { return }
            stageType = TBToolsDataManager.StageType(rawValue: listModel.stage) ?? .TTC
            sortType = TBToolsDataManager.sharedInstance.usageCondition?.sortTypesDic[listModel.stage] ?? .mostPopular
            configData()
            listModelSubject.onNext(nil)
        }
    }
    private(set) var models: [[Any]] = []
    private(set) var sectionTitles: [String?] = []
    private(set) var sortType: TBToolSortType = .mostPopular
    private(set) var stageType: TBToolsDataManager.StageType = .TTC
    private(set) var listModelSubject: PublishSubject<Any?> = PublishSubject<Any?>()

    private func configData() {
        guard let listModel = listModel, let sortedTool = listModel.sortedTools else { return }
        var dataSource: [[Any]] = []
        var sectionTitles: [String?] = []
        if stageType != .TTC {
            sectionTitles.append(nil)
            dataSource.append([sortType.title])
        }
        if !sortedTool.tools.isEmpty {
            sectionTitles.append(nil)
            dataSource.append(sortedTool.tools)
        }
        if !sortedTool.more.isEmpty {
            switch sortType {
            case .mostFrequentlyUsed:
                sectionTitles.append("Never Opened")
            default:
                sectionTitles.append("More Tools")
            }
            dataSource.append(sortedTool.more)
        }
        self.sectionTitles = sectionTitles
        self.models = dataSource
    }

    func bottomInset(section: Int) -> CGFloat {
        if section == 0 &&
           models.count == 2 &&
           sortType == .mostFrequentlyUsed {
            return 24
        }
        guard let tools = models[safe: section] as? [TBToolsModel],
              !tools.isEmpty else { return 0 }
        let lastLineToolsCount: Int = (tools.count % 3) == 0 ? 3 : (tools.count % 3)
        var topTitleHeight: CGFloat = 0
        for tool in tools[(tools.count - lastLineToolsCount)..<tools.count] {
            let titleHeight = tool.title.attributedText(.mulishLink4, alignment: .center)?.boundingRect(with: CGSize(width: 92, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height ?? 0
            topTitleHeight = max(topTitleHeight, titleHeight)
        }
        let bottomInset: CGFloat = min(topTitleHeight, 36)
        return bottomInset
    }
}
