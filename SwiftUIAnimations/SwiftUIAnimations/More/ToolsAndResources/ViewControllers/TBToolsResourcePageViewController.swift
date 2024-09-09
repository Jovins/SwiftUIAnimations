import UIKit
import RxSwift

protocol TBToolsResourcePageViewControllerDelegate: AnyObject {
    func toolsPageViewController(vc: TBToolsResourcePageViewController, stageType: TBToolsDataManager.StageType, sortType: TBToolSortType)
}

final class TBToolsResourcePageViewController: UIViewController {
    let viewModel = TBToolsResourcePageViewModel()
    private let sortTyps: [TBToolSortType] = [.mostPopular, .alphabeticalAtoZ, .alphabeticalZtoA, .mostFrequentlyUsed]
    private lazy var pickerView: TBPickerView = {
        let picker = TBPickerView()
        picker.titleString = "SORT BY"
        picker.buttonString = "Apply"
        picker.items = sortTyps.compactMap({ $0.title })
        picker.delegate = self
        picker.selectIndex = sortTyps.firstIndex(where: { $0 == viewModel.sortType }) ?? 0
        return picker
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.register(TBToolsSortCollectionViewCell.self)
        view.register(TBToolsCollectionViewCell.self)
        view.registerSectionHeader(for: TBToolsResourcePageSectionHeader.self)
        return view
    }()
    private var toolsWidth: CGFloat  = 50
    private var toolsHeight: CGFloat  = 126
    private var titleHeight: CGFloat  = 21
    private var headerHeight: CGFloat  = 29
    private var minimumLineSpace: CGFloat  = 36
    private var collectionViewTopInset: CGFloat  = 24
    private var toolsPadding: CGFloat {
        return UIDevice.isPad() ? 120 : 90
    }
    private var paddingInset: CGFloat {
        return UIDevice.isPad() ? 120 : 20
    }
    weak var delegate: TBToolsResourcePageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bindData() {
        viewModel.listModelSubject.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.collectionView.reloadData()
        })
    }
}

// MARK: - UICollectionViewDataSource
extension TBToolsResourcePageViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.models.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tools = viewModel.models[safe: section]
        return tools?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.models[safe: indexPath.section]?[safe: indexPath.item] {
        case let titleString as String:
            let cell: TBToolsSortCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setupTitle(title: titleString)
            cell.delegate = self
            return cell
        case let toolModel as TBToolsModel:
            let cell: TBToolsCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            if let color = UIColor.init(hex: viewModel.listModel?.color ?? "") {
                cell.setup(model: toolModel, color: color)
            }
            return cell
        default:
            fatalError("no data")
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader: TBToolsResourcePageSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        if let sectionTitle = viewModel.sectionTitles[safe: indexPath.section], let sectionTitle {
            sectionHeader.setTitle(sectionTitle)
        }
        return sectionHeader
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBToolsResourcePageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard viewModel.models[safe: indexPath.section] is [TBToolsModel] else {
            return CGSize(width: UIDevice.width, height: titleHeight)
        }
        return CGSize(width: toolsWidth, height: toolsHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let title = viewModel.sectionTitles[safe: section], let title else {
            return .zero
        }
        return CGSize(width: .zero, height: headerHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard viewModel.models[safe: section] is [TBToolsModel] else {
            return .zero
        }
        return minimumLineSpace
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard viewModel.models[safe: section] is [TBToolsModel] else {
            return .zero
        }
        let spacesBetweenTools: CGFloat  = 3
        let lateralPaddings: CGFloat  = 2
        return (UIDevice.width - paddingInset * lateralPaddings - toolsPadding * spacesBetweenTools) / lateralPaddings
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomInset = viewModel.bottomInset(section: section)
        return UIEdgeInsets(top: collectionViewTopInset, left: paddingInset, bottom: bottomInset, right: paddingInset)
    }
}

// MARK: - TBPickerViewDelegate
extension TBToolsResourcePageViewController: TBPickerViewDelegate {
    func pickerView(pickerView: TBPickerView, didApplyAt index: Int) {
        delegate?.toolsPageViewController(vc: self, stageType: viewModel.stageType, sortType: sortTyps[index])
    }
}

// MARK: - TBToolsSortCollectionViewCellDelegate
extension TBToolsResourcePageViewController: TBToolsSortCollectionViewCellDelegate {
    func didTapToSortData() {
        pickerView.show()
    }
}

// MARK: - UICollectionViewDelegate
extension TBToolsResourcePageViewController: UICollectionViewDelegate, TBImpressionEventUICollectionViewHandler {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        impressionEventHandler(willDisplay: collectionView, cell: cell, forItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        impressionEventHandler(didEndDisplaying: collectionView, cell: cell, forItemAt: indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let scrollView = scrollView as? UICollectionView else { return }
        impressionEventHandler(collectionViewDidScroll: scrollView)
    }

    func containerViewForCheckWhetherInView() -> UIView? {
        return view
    }

    func trackFeedCardImpressionEvent(with indexPath: IndexPath, cell: UICollectionViewCell) {
        DispatchQueue.global().async {
            guard let models = self.viewModel.models[safe: indexPath.section] as? [TBToolsModel], let toolModel = models[safe: indexPath.item],
                  let cardPosition = models.flatMap({ $0 }).firstIndex(where: { $0.type == toolModel.type }) else { return }
            TBAnalyticsManager.toolsAndResourcesCardImpression(cardPosition: cardPosition, cardTitle: toolModel.title, userDecisionArea: .toolsLandingPage)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let models = self.viewModel.models[safe: indexPath.section] as? [TBToolsModel], let toolModel = models[safe: indexPath.item],
              let listModel = viewModel.listModel,
              let stage = TBToolsDataManager.StageType(rawValue: listModel.stage),
              let tool = TBToolsDataManager.ToolsModelType(rawValue: toolModel.type),
              let cardPosition = models.flatMap({ $0 }).firstIndex(where: { $0.type == toolModel.type }) else { return }
        tool.routerAction(params: ["stage": stage], sourceType: ScreenAnalyticsSourceType.toolsAndResourcesLP)
        TBAnalyticsManager.toolsAndResourcesCardInteraction(cardPosition: cardPosition, cardTitle: toolModel.title)
    }
}
