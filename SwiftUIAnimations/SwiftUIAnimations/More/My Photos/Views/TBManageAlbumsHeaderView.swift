import UIKit
import FullStory

protocol TBManageAlbumsHeaderViewDelegate: NSObjectProtocol {
    func headerView(headerView: TBManageAlbumsHeaderView, sender: Any, deleteForHeaderInSection section: Int)
}

final class TBManageAlbumsHeaderView: UITableViewHeaderFooterView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Beige
        return view
    }()
    private let titleLabel: UILabel = UILabel()
    private let deleteCTA: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(TBIconList.moreSelected.image(sizeOption: .normal, color: .Navy), for: .normal)
        button.setImage(TBIconList.moreSelected.image(sizeOption: .normal, color: .DarkGray500), for: .disabled)
        button.isEnabled = false
        return button
    }()
    private weak var delegate: TBManageAlbumsHeaderViewDelegate?
    private var section: Int = 0

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        [containerView].forEach(addSubview)
        [titleLabel, deleteCTA].forEach(containerView.addSubview)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        deleteCTA.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(deleteCTA.snp_leading).offset(8)
        }
        deleteCTA.addTarget(self, action: #selector(didTapToDelete(sender:)), for: .touchUpInside)
        FS.mask(views: titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc private func didTapToDelete(sender: Any) {
        if let delegate = delegate {
            delegate.headerView(headerView: self, sender: sender, deleteForHeaderInSection: section)
        }
    }

    func setupData(model: TBAlbumsProfileModel, section: Int, delegate: TBManageAlbumsHeaderViewDelegate) {
        self.section = section
        self.delegate = delegate
        var titleColor: UIColor = .DarkGray500
        if let albums = model.albums, let _ = albums.first(where: { $0.photos?.isEmpty == false }) {
            deleteCTA.isEnabled = true
            titleColor = .CornFlower
        } else {
            deleteCTA.isEnabled = false
            titleColor = .DarkGray500
        }
        if let title = model.name {
            titleLabel.attributedText = title.capitalizedWithoutPreposition.attributedText(.mulishLink3, foregroundColor: titleColor, lineBreakMode: .byTruncatingTail)
        }
    }
}
