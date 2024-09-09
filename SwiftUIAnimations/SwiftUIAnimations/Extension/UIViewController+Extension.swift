import PhotosUI

@objc extension UIViewController {
    func checkPermissions(with permissionType: PermissionType, showAuthorizationAlert: Bool = true, isAuthorized: @escaping ((Bool) -> Void)) {
        switch permissionType {
        case .photos:
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (authorization: PHAuthorizationStatus) in
                    isAuthorized(authorization == .authorized)
                })
            case .denied:
                isAuthorized(false)
                if showAuthorizationAlert { show(permissionType: permissionType) }
            case .authorized: isAuthorized(true)
            default: break
            }
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (authorization) in
                    isAuthorized(authorization)
                })
            case .denied:
                isAuthorized(false)
                if showAuthorizationAlert { show(permissionType: permissionType) }
            case .authorized: isAuthorized(true)
            default: break
            }
        case .downloadPhotos:
            var authorizationStatus: PHAuthorizationStatus = .notDetermined
            if #available(iOS 14, *) {
                authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            } else {
                authorizationStatus = PHPhotoLibrary.authorizationStatus()
            }
            switch authorizationStatus {
            case .notDetermined:
                if #available(iOS 14, *) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorizationStatus in
                        DispatchQueue.main.async {
                            isAuthorized(authorizationStatus == .authorized)
                        }
                    }
                } else {
                    PHPhotoLibrary.requestAuthorization { authorizationStatus in
                        DispatchQueue.main.async {
                            isAuthorized(authorizationStatus == .authorized)
                        }
                    }
                }
            case .authorized, .limited:
                isAuthorized(true)
            default:
                if showAuthorizationAlert {
                    show(permissionType: permissionType)
                }
                isAuthorized(false)
            }
    }
}

    private func show(permissionType: PermissionType) {
        let leftAction = UIAlertAction(title: "Not Now", style: .default, handler: nil)
        let rightAction = UIAlertAction(title: "Update", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })

        showAlert(title: permissionType.title, message: permissionType.message, leftAction: leftAction, rightAction: rightAction, preferredAction: rightAction)
    }

    open func showAlert(title: String, message: String, leftAction: UIAlertAction, rightAction: UIAlertAction, preferredAction: UIAlertAction?, from viewController: UIViewController? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if UIDevice.isPad() {
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width, y: self.view.bounds.height, width: 0, height: 0)
            popoverPresentationController?.sourceView = self.view
        }

        alert.addAction(leftAction)
        alert.addAction(rightAction)
        alert.preferredAction = preferredAction
        alert.showAnimated(true, sourceView: nil, sourceRect: nil, from: viewController)
    }

    @objc public enum PermissionType: Int {
        case photos
        case camera
        case downloadPhotos

        public var title: String {
            switch self {
            case .photos: return "Please Allow Photo Access"
            case .camera: return "Please Allow Camera Access"
            case .downloadPhotos: return "Please Allow Photo Access"
            }
        }

        public var message: String {
            switch self {
            case .photos: return "To upload a photo, you'll need to allow access to your photos by updating your settings."
            case .camera: return "To take and upload a photo, you'll need to allow access to your device's camera by updating your settings."
            case .downloadPhotos: return "To download a photo, you'll need to allow access to your photos by updating your settings."
            }
        }
    }

    var isVisible: Bool {
        return view.window != nil
    }

    func pushPregnancyEditorVC(sourceType: String, analyticsOrigin: String?) {
        let context: [String: Any] = ["sourceType": sourceType,
                                      "analyticsOrigin": analyticsOrigin]
        AppRouter.shared.navigator.push("thebump://pregnancy-editor", context: context)
    }

    func presentToPlannerVC(sourceType: String,
                            needToOpenInterstitial: Bool,
                            title: String? = nil,
                            eventSlug: String? = nil,
                            initialWeekToLoad: NSNumber? = nil,
                            tabBarNavigationDelegate: TBTabBarNavigationDelegate? = nil) {
        AppRouter.presentToPlannerPregnancyTracker(
            initialWeekToLoad: initialWeekToLoad?.intValue,
            tabBarNavigationDelegate: tabBarNavigationDelegate,
            needToOpenInterstitial: needToOpenInterstitial,
            title: title,
            eventSlug: eventSlug,
            sourceType: sourceType
        )
    }
}

extension UIViewController {

    func openAccountsStatusEditorVC(sourceType: String? = nil,
                                    analyticsOrigin: String? = nil,
                                    title: String? = nil,
                                    type: TBMyAccountsEditorBaseViewModel.TBMyAccountsStatusEditorType,
                                    headerType: TBMyAccountsStatusEditorViewController.TBMyAccountsStatusHeaderType,
                                    shouldEditing: Bool,
                                    isComingFromPregnancy: Bool,
                                    pregnancyDictionary: [String: Any]? = nil,
                                    child: TBMemberChild? = nil, action: AppRouter.Action = .push) {

        let model = TBMyAccountsEditorModel()
        model.title = title
        model.type = type
        model.headerType = headerType
        model.shouldEditing = shouldEditing
        model.isComingFromPregnancy = isComingFromPregnancy
        model.pregnancyDictionary = pregnancyDictionary
        model.child = child
        let accountsStatusEditorVC = TBMyAccountsStatusEditorViewController(model: model)
        if let analyticsOrigin = analyticsOrigin {
            accountsStatusEditorVC.analyticsOrigin = analyticsOrigin
        }
        if let sourceType = sourceType {
            accountsStatusEditorVC.source = ["sourceType": sourceType]
        }
        switch action {
        case .push:
            AppRouter.shared.navigator.push(accountsStatusEditorVC)
        case .present:
            let navController = UINavigationController(rootViewController: accountsStatusEditorVC)
            navController.modalPresentationStyle = .fullScreen
            AppRouter.shared.navigator.present(navController)
        default:
            break
        }
    }
}
