import UIKit
import RxSwift

final class TBToolsRootViewController: UIViewController {

    private let pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let viewModel: TBToolsRootViewModel = TBToolsRootViewModel()
    private let tabBarView: TBToolsTabBarView = TBToolsTabBarView()
    private var pageViewControllers: [TBToolsResourcePageViewController] = []
    private var disposed = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hideBottomHairline()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.showBottomHairline()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    deinit {
        TBToolsDataManager.sharedInstance.cleanSortData()
    }

    private func setupUI() {
        navigationItem.title = "Tools and Resources"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .GlobalBackgroundPrimary
        tabBarView.delegate = self
        addChild(pageViewController)
        [pageViewController.view, tabBarView].forEach(view.addSubview)
        tabBarView.snp.makeConstraints {
           $0.leading.top.trailing.equalToSuperview()
           $0.height.equalTo(TBToolsTabBarView.cellHeight)
        }
        pageViewController.view.snp.makeConstraints {
           $0.leading.bottom.trailing.equalToSuperview()
           $0.top.equalTo(tabBarView.snp.bottom)
        }
    }

    private func bindData() {
        self.tabBarView.selectedIndex = viewModel.currentIndex
        self.tabBarView.titles = self.viewModel.tabBarTitles
        self.pageViewControllerScroll(toIndex: viewModel.currentIndex)
        TBToolsDataManager.sharedInstance.toolListsSubject.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.updateToolsRerourcePageData()
        }, onError: { _ in
        }).disposed(by: disposed)
        TBToolsDataManager.sharedInstance.sortData()
    }

    private func updateToolsRerourcePageData() {
        pageViewControllers.forEach { pageVC in
            guard let index = viewModel.getStageIndex(with: pageVC.viewModel.stageType),
                  let listModel = viewModel.getToolListModel(with: index) else { return }
            pageVC.viewModel.listModel = listModel
        }
    }

    private func pageViewControllerScroll(fromIndex: Int = 0, toIndex: Int) {
        guard let pageController = pageViewController(index: toIndex) else { return }
        let direction: UIPageViewController.NavigationDirection = fromIndex < toIndex ? .forward : .reverse
        pageViewController.setViewControllers([pageController], direction: direction, animated: false)
    }

    private func pageViewController(index: Int) -> TBToolsResourcePageViewController? {
        guard let listModel = viewModel.getToolListModel(with: index) else { return nil }
        guard let pageViewController = pageViewControllers.first(where: { $0.viewModel.listModel?.stage == listModel.stage }) else {
            let pageViewController = TBToolsResourcePageViewController()
            pageViewController.viewModel.listModel = listModel
            pageViewController.delegate = self
            pageViewControllers.append(pageViewController)
            return pageViewController
        }
        return pageViewController
    }
}

// MARK: - TBToolsResourcePageViewControllerDelegate
extension TBToolsRootViewController: TBToolsResourcePageViewControllerDelegate {
    func toolsPageViewController(vc: TBToolsResourcePageViewController, stageType: TBToolsDataManager.StageType, sortType: TBToolSortType) {
        TBToolsDataManager.sharedInstance.recordSortType(stage: stageType, type: sortType)
    }
}

// MARK: - TBToolsTabBarViewDelegate
extension TBToolsRootViewController: TBToolsTabBarViewDelegate {
    func toolsTabBarDidSelect(index: Int) {
        viewModel.currentIndex = index
        guard let listModel = viewModel.getToolListModel(with: index) else { return }
        pageViewControllerScroll(toIndex: index)
        TBAnalyticsManager.toolsMenuInteraction(selection: listModel.stage)
    }
}
