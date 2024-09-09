import SnapKit
import FullStory

extension UINavigationController {
    private static var searchButton: UIButton?
    private static var profileImageButton: UIButton?
    private static var profileDropdownView: ProfileDropdownView?
    private static var isOpenProfile = false

    @objc public func setRootNavigationBarStyle() {
        self.createRightItemButton()
        self.createLeftItemButton()
        self.topViewController?.navigationItem.titleView = UIImageView(image: NavigationBarStyle.brandImage)

        self.topViewController?.navigationItem.backBarButtonItem?.title = " "
    }

    @objc public func setLeftNavigationBarStyle() {
        self.createRightItemButton(showSearch: false)
        self.createLeftCloseButton()
        self.topViewController?.navigationItem.titleView = UIImageView(image: NavigationBarStyle.brandImage)
        self.topViewController?.navigationItem.backBarButtonItem?.title = " "
    }

    @objc public func setChildNavigationBarStyle() {
        self.createRightItemButton()
    }

    private func searchButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32.0, height: 32.0))
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16.0
        button.setImage(TBIconList.search.image(), for: .normal)
        button.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        UINavigationController.searchButton = button
        FS.mask(views: button)
        return button
    }

    private func profileImageButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32.0, height: 32.0))
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16.0
        button.setImage(UserAvatar.placeholder, for: .normal)
        button.addTarget(self, action: #selector(didTapAvatar), for: .touchUpInside)
        UINavigationController.profileImageButton = button
        FS.mask(views: button)
        return button
    }

    @objc public func updateUserAvatar() {
        guard !UINavigationController.isOpenProfile else {
            UINavigationController.profileImageButton?.setImage(UIImage(named: "Close"), for: .normal)
            FS.unmask(views: UINavigationController.profileImageButton)
            return
        }
        FS.mask(views: UINavigationController.profileImageButton)
        guard let memberDataObject = TBMemberDataManager.sharedInstance().memberDataObject,
              let avatarUrlString = memberDataObject.avatarUrl else { return }
        if avatarUrlString == "",
           let avatarImage = memberDataObject.getUserAvatarImage() {
            UINavigationController.profileImageButton?.setImage(avatarImage, for: .normal)
        } else {
            let avatarUrl = URL(string: avatarUrlString)
            UINavigationController.profileImageButton?.sd_setImage(with: avatarUrl, for: .normal, placeholderImage: UserAvatar.placeholder, options: .refreshCached)
        }
    }

    private func createLeftItemButton() {
        let menuButton = UIBarButtonItem(image: TBIconList.hamburger.image(sizeOption: .normal), style: .plain, target: self, action: #selector(menuButtonTapped))
        self.topViewController?.navigationItem.leftBarButtonItem = menuButton
    }

    private func createLeftCloseButton() {
        let closeButton = UIBarButtonItem(image: TBIconList.close.image(sizeOption: .normal), style: .plain, target: self, action: #selector(menuButtonTapped))
        self.topViewController?.navigationItem.leftBarButtonItem = closeButton
    }

    @objc public func createRightItemButton(showSearch: Bool = true) {
        var buttons = [UIBarButtonItem]()
        let profileView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        profileView.addSubview(profileImageButton())
        buttons.append(UIBarButtonItem(customView: profileView))
        if showSearch {
            let search = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            search.addSubview(searchButton())
            buttons.append(UIBarButtonItem(customView: search))
        }
        self.topViewController?.navigationItem.rightBarButtonItems = buttons
        updateUserAvatar()
    }

    @objc private func menuButtonTapped() {
        if UINavigationController.isOpenProfile {
            closeProfile()
        }
        if AppDelegate.sharedInstance().getLeftNavigationController()?.isOpen ?? false {
            updateLeftNavState(open: false)
            TBAnalyticsManager.logEventNamed(kAnalyticsEventMenuInteraction,
                                             withProperties: [kAnalyticsKeyAction: "close",
                                                           kAnalyticsKeySelection: "hamburger",
                                                           kAnalyticsKeyPlacement: "header"])
        } else {
            updateLeftNavState(open: true)
            TBAnalyticsManager.logEventNamed(kAnalyticsEventMenuInteraction,
                                             withProperties: [kAnalyticsKeyAction: "open",
                                                           kAnalyticsKeySelection: "hamburger",
                                                           kAnalyticsKeyPlacement: "header"])
        }
    }

    @objc public func didTapAvatar() {
        if AppDelegate.sharedInstance().getLeftNavigationController()?.isOpen == true {
            updateLeftNavState(open: false)
        }
        if UINavigationController.isOpenProfile {
            closeProfile()
        } else {
            guard let window = AppDelegate.sharedInstance().window else { return }
            openProfile(window: window)
        }
    }

    @objc public func didTapSearch() {
        updateLeftNavState(open: false)
        if UINavigationController.isOpenProfile {
            closeProfile()
        }
        TBAnalyticsManager.logEventNamed(kAnalyticsEventMenuInteraction,
                                         withProperties: [kAnalyticsKeyPlacement: "header",
                                                          kAnalyticsKeySelection: "search"])
        AppRouter.navigateToBrowser(url: searchWebviewURL) { setting in
            setting.title = "Search"
            return setting
        }
    }

    @objc public func closeProfile() {
        UINavigationController.profileDropdownView?.closeProfile()
        UINavigationController.isOpenProfile = false
        updateUserAvatar()
    }

    @objc public func updateLeftNavState(open: Bool) {
        if open {
            AppDelegate.sharedInstance().getLeftNavigationController()?.open()
            createLeftCloseButton()
        } else {
            AppDelegate.sharedInstance().getLeftNavigationController()?.close()
            createLeftItemButton()
        }
    }

    public func openProfile(window: UIWindow) {
        UINavigationController.profileDropdownView = ProfileDropdownView()
        UINavigationController.profileDropdownView?.openProfile(window: window, navigationBarHeight: navigationBar.height())
        UINavigationController.isOpenProfile = true
        UINavigationController.profileImageButton?.setImage(UIImage(named: "Close"), for: .normal)
    }
}

@objc class UINavigationControllerStyleUtil: NSObject {
    @objc static func setRootNavigationBarStyle(_ navigationController: UINavigationController ) {
        navigationController.setRootNavigationBarStyle()
    }

    @objc static func setChildNavigationBarStyle(_ navigationController: UINavigationController ) {
        navigationController.setChildNavigationBarStyle()
    }
}
