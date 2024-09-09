import UIKit

protocol TBFeedingToolbarDelegate: AnyObject {
    func toolbar(_ toolbar: TBFeedingToolbar, didSelectIndexAt index: Int, item: TBFeedingToolbarItem)
}

final class TBFeedingToolbar: UIView {

    var selectedIndex: Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    weak var delegate: TBFeedingToolbarDelegate?
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .OffWhite
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        view.register(TBFeedingToolbarIconCell.self)
        return view
    }()
    private var items: [TBFeedingToolbarItem] {
        let allItem = TBFeedingToolbarItem(title: "All", size: CGSize(width: 24, height: 72), iconImage: TBIconList.history.image(sizeOption: .normal))
        let nursingItem = TBFeedingToolbarItem(title: "Nursing",
                                               size: CGSize(width: 51, height: 72),
                                               iconImage: FeedingTrackerToolType.nursing.iconImage)
        let bottleItem = TBFeedingToolbarItem(title: "Bottle",
                                              size: CGSize(width: 39, height: 72),
                                              iconImage: FeedingTrackerToolType.bottle.iconImage)
        let pumpingItem = TBFeedingToolbarItem(title: "Pumping",
                                               size: CGSize(width: 59, height: 72),
                                               iconImage: FeedingTrackerToolType.pumping.iconImage)
        let diapersItem = TBFeedingToolbarItem(title: "Diapers",
                                               size: CGSize(width: 51, height: 72),
                                               iconImage: FeedingTrackerToolType.diapers.iconImage)
        return [allItem, nursingItem, bottleItem, pumpingItem, diapersItem]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TBFeedingToolbar: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TBFeedingToolbarIconCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(item: items[indexPath.row], selected: indexPath.item == selectedIndex)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBFeedingToolbar: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset: CGFloat = UIDevice.isPad() ? 24 :  14
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.row]
        return item.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard items.count - 1 != 0 else { return 0 }
        let itemsWidth: CGFloat = items.reduce(0) { (res, item) in
            return res + item.size.width
        }
        let inset: CGFloat = UIDevice.isPad() ? 24 :  14
        return (UIDevice.width - inset * 2 - itemsWidth) / CGFloat(items.count - 1)
    }
}

// MARK: - UICollectionViewDelegate
extension TBFeedingToolbar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        delegate?.toolbar(self, didSelectIndexAt: selectedIndex, item: items[selectedIndex])
    }
}
