import UIKit

protocol TBToolsTabBarViewDelegate: AnyObject {
    func toolsTabBarDidSelect(index: Int)
}

final class TBToolsTabBarView: UIView {
    static let cellHeight: CGFloat = 46
    weak var delegate: TBToolsTabBarViewDelegate?
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .DarkGray300
        view.dataSource = self
        view.delegate = self
        view.isScrollEnabled = false
        view.register(TBToolsTabBarCell.self)
        return view
    }()
    private let minimumInteritemSpacing: CGFloat = 1
    var titles: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var selectedIndex: Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addShadow(with: UIColor.Black, alpha: 0.2, radius: 4, offset: CGSize(width: 0, height: 2))
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBToolsTabBarView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIDevice.width - minimumInteritemSpacing * CGFloat(titles.count - 1)) / CGFloat(titles.count), height: TBToolsTabBarView.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDataSource
extension TBToolsTabBarView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TBToolsTabBarCell = collectionView.dequeueReusableCell(for: indexPath)
        let title = titles[indexPath.item]
        cell.setup(title: title, selected: indexPath.item == selectedIndex)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TBToolsTabBarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        delegate?.toolsTabBarDidSelect(index: indexPath.item)
    }
}
