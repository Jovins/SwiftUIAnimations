extension UITabBarController {
    func setTabBarVisible(_ visible: Bool, animated: Bool, duration: CGFloat = 0.3) {
        let frame = tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        })
    }

    var tabBarIsVisible: Bool { return tabBar.frame.origin.y < UIScreen.main.bounds.height }
}

// MARK: - Quick Actions
extension UITabBarController {
    enum QuickActionType: String {
        case registry = "Registry"
        case savedArticles = "Saved Articles"
        case search = "Search"
        case community = "Community"
    }

    @objc func handleQuickActions(notification: Notification? = nil) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate,
              let shortcutItem = notification != nil ?
                notification?.userInfo?["shortcut"] as? UIApplicationShortcutItem : delegate.getShortCutItem(),
              let navigationController = self.selectedViewController as? UINavigationController,
              let quickAction = QuickActionType(rawValue: shortcutItem.type) else { return }
        navigationController.popToRootViewController(animated: false)
        switch quickAction {
        case .registry:
            AppRouter.navigateToRegistry(sourceType: ScreenAnalyticsSourceType.appIconMenu)
        case .savedArticles:
            AppRouter.navigateToMySavedArticle(from: navigationController)
            TBAnalyticsManager.logEventNamed("Enter Saved Articles page", withProperties: [kAnalyticsKeyUserDecisionArea: "quick action",
                                                                                           kAnalyticsKeySelection: "click-through to saved articles page"])
        case .search:
            AppRouter.navigateToSearch(from: navigationController)
        case .community:
            AppRouter.navigateToCommunity(from: navigationController, sourceType: ScreenAnalyticsSourceType.appIconMenu)
        }
        delegate.closeAllSideNavigationController()
        delegate.resetShortCutItem()
        TBAnalyticsManager.logEventNamed(kAnalyticsEventMenuInteraction, withProperties: [kAnalyticsKeyPlacement: "quick action",
                                                                                          kAnalyticsKeySelection: quickAction.rawValue])
    }
}
