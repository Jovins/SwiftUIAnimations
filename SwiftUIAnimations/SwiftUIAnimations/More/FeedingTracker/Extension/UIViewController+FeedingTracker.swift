import Foundation

extension UIViewController {

    func setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel) {
        let barButtonItem = UIBarButtonItem(customView: createLeftightNavigationItem(model: model))
        navigationItem.leftBarButtonItems = [barButtonItem]
    }

    func setupFeedingTrackerRightNavigationItems(_ itemModels: [TBFeedingTrackerNavigationBarModel]) {
        let stackView = UIStackView()
        stackView.spacing = 16
        itemModels.forEach({
            let button = initBarButton(type: $0.type, action: $0.action)
            button.snp.makeConstraints {
                $0.width.equalTo(24)
            }
            stackView.addArrangedSubview(button)
        })
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }

    private func createLeftightNavigationItem(model: TBFeedingTrackerNavigationBarModel) -> TBBackButton {
        let button = TBBackButton()
        if model.type == .back {
            button.alignmentRectInsetsOverride = UIEdgeInsets(top: 1, left: 18, bottom: -1, right: -18)
        } else if model.type == .close {
            button.alignmentRectInsetsOverride = UIEdgeInsets(top: 2, left: 10, bottom: -2, right: -10)
        }
        button.setImage(model.type.image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: model.action ?? defaultSelector(type: model.type), for: .touchUpInside)
        return button
    }

    private func initBarButton(type: TBFeedingTrackerNavigationBarModel.NavigationButtonType, action: Selector?) -> UIButton {
        let button = UIButton()
        button.tag = type.rawValue
        button.setImage(type.image, for: .normal)
        button.tb.expandTouchingArea(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        button.addTarget(self, action: action ?? defaultSelector(type: type), for: .touchUpInside)
        return button
    }

    private func defaultSelector(type: TBFeedingTrackerNavigationBarModel.NavigationButtonType) -> Selector {
        switch type {
        case .setting:
            return #selector(emptySelector)
        case .help:
            return #selector(emptySelector)
        case .back:
            return #selector(didTapToBackForBabyTracker)
        case .close:
            return #selector(didTapToCloseForBabyTracker)
        default:
            return #selector(emptySelector)
        }
    }

    @objc private func didTapToBackForBabyTracker() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapToCloseForBabyTracker() {
        dismiss(animated: true)
    }

    @objc private func emptySelector() {}

    private func present(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        AppRouter.shared.navigator.present(navigationController)
    }
}
