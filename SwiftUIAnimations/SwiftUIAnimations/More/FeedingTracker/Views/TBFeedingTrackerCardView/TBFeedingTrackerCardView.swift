import UIKit

final class TBFeedingTrackerCardView: UIView {

    var dataSources = [TBFeedingTrackerSettingModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var isFirstOpen: Bool = false
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .GlobalBackgroundPrimary
        view.dataSource = self
        view.delegate = self
        view.register(TBFeedingTrackerCardNursingCell.self)
        view.register(TBFeedingTrackerCardBottleCell.self)
        view.register(TBFeedingTrackerCardPumpingCell.self)
        view.register(TBFeedingTrackerCardDiapersCell.self)
        view.register(TBFeedingTrackerCardViewEmptyCell.self)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TBFeedingTrackerCardView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !dataSources.isEmpty else { return 1 }
        return dataSources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !dataSources.isEmpty else {
            let cell: TBFeedingTrackerCardViewEmptyCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setupData(action: isFirstOpen ? .present : .push)
            return cell
        }
        let type = dataSources[indexPath.item].type
        switch type {
        case .nursing:
            let cell: TBFeedingTrackerCardNursingCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setData(model: TBNursingRepository.shared.models.filter({ !$0.archived && $0.savedTime != nil }).first, type: type)
            return cell
        case .bottle:
            let cell: TBFeedingTrackerCardBottleCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setData(model: TBBottleRepository.shared.models.filter({ $0.archived == false }).first, type: type)
            return cell
        case .pumping:
            let cell: TBFeedingTrackerCardPumpingCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setData(model: TBPumpRepository.shared.models.filter({ !$0.archived }).first, type: type)
            return cell
        case .diapers:
            let cell: TBFeedingTrackerCardDiapersCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setData(models: TBDiapersRepository.shared.models.filter({ $0.archived == false }), type: type)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = dataSources[safe: indexPath.item]?.type else { return }
        let sourceType = isFirstOpen ? ScreenAnalyticsSourceType.homeFeed : ScreenAnalyticsSourceType.babyTracker
        AppRouter.navigateToFeedingTracker(with: type, action: isFirstOpen ? .present : .push, sourceType: sourceType)
        if isFirstOpen {
            var selectionType: TBAnalyticsManager.BabyTrackerSelectionType
            switch type {
            case .nursing:
                selectionType = .nursing
            case .bottle:
                selectionType = .bottle
            case .pumping:
                selectionType = .pumping
            case .diapers:
                selectionType = .diapers
            }
            TBAnalyticsManager.trackBabyTrackerInteractionEvent(selectionType: selectionType)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBFeedingTrackerCardView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard !dataSources.isEmpty else {
            return CGSize(width: UIDevice.width - 40, height: 82)
        }
        return CGSize(width: (UIScreen.width - 56)/2, height: 142)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return dataSources.isEmpty ? 0 : 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return dataSources.isEmpty ? 0 : 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 20, bottom: 10, right: 20)
    }
}
