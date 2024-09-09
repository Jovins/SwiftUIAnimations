import UIKit
extension UIViewController {
    var fullScreenLoader: TBFullScreenLoader {
        return TBFullScreenLoader.sharedInstance
    }

    @objc var loader: TBLoadingView {
        return TBLoadingView.sharedInstance
    }

    @objc var errorView: ErrorView {
        return ErrorView.sharedInstance
    }

}

extension UITableView {
    @objc var loader: TBLoadingView {
        return TBLoadingView.sharedInstance
    }

    @objc var errorView: ErrorView {
        return ErrorView.sharedInstance
    }

    var visibleFooterViews: [UITableViewHeaderFooterView] {
        guard let visibleSectionsIndexPaths = indexPathsForVisibleRows?.compactMap({ $0.section }) else { return [] }

        return Set(visibleSectionsIndexPaths).compactMap { footerView(forSection: $0) }
    }

}
