import UIKit

protocol TBPhotoDownloadFailViewControllerDelegate: AnyObject {
    func photoDownloadFailViewController(_ viewController: TBPhotoDownloadFailViewController, tryAgain photoModels: [TBPhotoModel])
}

final class TBPhotoDownloadFailViewController: UIViewController {

    weak var delegate: TBPhotoDownloadFailViewControllerDelegate?
    var dataSource: [TBPhotoModel] = []

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TBPhotoCell.self)
        collectionView.registerSectionHeader(for: TBPhotoDownloadFailHeaderView.self)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()
    private let tryAgainButton: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Try Again", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Manage Photos"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: TBIconList.close.image(), style: .plain, target: self, action: #selector(didTapClose))
        view.backgroundColor = .GlobalBackgroundPrimary
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenViewed()
    }

    private func setupUI() {
        tryAgainButton.addTarget(self, action: #selector(didTapTryAgain), for: .touchUpInside)
        [collectionView, dividerView, tryAgainButton].forEach(view.addSubview)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(dividerView.snp.top)
        }
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalTo(tryAgainButton.snp.top).offset(-19)
        }
        tryAgainButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    @objc private func didTapClose() {
        self.dismiss(animated: true)
    }

    @objc private func didTapTryAgain() {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.photoDownloadFailViewController(self, tryAgain: self.dataSource)
        }
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TBPhotoDownloadFailViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TBPhotoCell = collectionView.dequeueReusableCell(for: indexPath)
        let photoModel = dataSource[indexPath.item]
        cell.setup(photoModel: photoModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader: TBPhotoDownloadFailHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            return sectionHeader
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width(), height: 88)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TBPhotoDownloadFailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 106)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
