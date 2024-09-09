import UIKit
import RxSwift

final class TBFeedingTrackerCardViewEmptyCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Blush
        view.borderColor = .Navy
        view.borderWidth = 1
        view.cornerRadius = 8
        return view
    }()

    private lazy var textView = TBLinkTextView.buildLinkTextView { [weak self] (_, _) in
        guard let self else { return }
        self.didTapSetting()
    }
    private var action: AppRouter.Action = .present

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        containerView.addSubview(textView)
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        let additionalAttrsArray = ["Tracker Settings".linkAttrs(fontType: .contentLink3, showUnderline: true)]
        let titleAttrString = "All of your tracker items are hidden. Go to\nyour Tracker Settings to unhide.".attributedText(.mulishBody3, alignment: .center, additionalAttrsArray: additionalAttrsArray)
        textView.attributedText = titleAttrString
        textView.linkTextAttributes = [.foregroundColor: UIColor.GlobalTextPrimary,
                                       .underlineColor: UIColor.GlobalTextPrimary]
        textView.backgroundColor = .clear
    }

    private func didTapSetting() {
        AppRouter.navigateToFeedingTrackerSettingPage(action: action)
    }

    func setupData(action: AppRouter.Action) {
        self.action = action
    }
}
