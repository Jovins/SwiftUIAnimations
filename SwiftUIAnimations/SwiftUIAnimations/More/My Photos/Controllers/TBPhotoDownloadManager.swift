import UIKit
import Photos

extension TBPhotoDownloadManager {
    typealias TBPhotoDownloadProgressBlock = (_ index: Int, _ total: Int, _ success: Bool) -> Void
    typealias TBPhotoDownloadCompletedBlock = (_ allSuccess: Bool, _ failUrlStrings: [String]?) -> Void
}

class TBPhotoDownloadManager: NSObject {

    static let shared: TBPhotoDownloadManager = TBPhotoDownloadManager()
    private let albumTitle = "The Bump"
    private var urlModels: [PhotoDownloadModel] = []
    private var workItems: [DispatchWorkItem] = []
    private var isPause: Bool = false
    private var completedBlock: TBPhotoDownloadCompletedBlock?
    private var failUrlStrings: [String] {
        return urlModels.compactMap({ $0.isSaved ? nil : $0.urlString })
    }

    func downloadPhotosToAlbum(urls: [String],
                               progress progressBlock: TBPhotoDownloadProgressBlock? = nil,
                               completed completedBlock: TBPhotoDownloadCompletedBlock? = nil) {
        self.completedBlock = completedBlock
        workItems.removeAll()
        guard !urls.isEmpty else {
            DispatchQueue.main.async {
                completedBlock?(true, nil)
            }
            return
        }
        createAlbum(albumTitle: albumTitle) { [weak self] album in
            guard let album = album, let self = self else {
                completedBlock?(false, urls)
                return
            }

            DispatchQueue.global().async {
                self.urlModels = urls.map({ PhotoDownloadModel(urlString: $0) })
                urls.enumerated().forEach { (index, urlString) in

                    let workItem = DispatchWorkItem {
                        let url = URL(string: urlString)
                        SDWebImageManager.shared.loadImage(with: url, progress: nil) { image, _, _, _, _, _ in
                            self.workItems.removeFirst()
                            if let image = image {
                                self.saveImageToAlbum(image: image, toAlbum: album) { success in
                                    var urlModel = self.urlModels[index]
                                    urlModel.isSaved = success
                                    if self.workItems.isEmpty {
                                        let failUrlStrings = self.failUrlStrings
                                        completedBlock?(failUrlStrings.isEmpty, failUrlStrings)
                                    } else {
                                        progressBlock?(index, urls.count, success)
                                        self.runNextWorkItem()
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    if self.workItems.isEmpty {
                                        let failUrlStrings = self.failUrlStrings
                                        completedBlock?(failUrlStrings.isEmpty, failUrlStrings)
                                    } else {
                                        progressBlock?(index, urls.count, false)
                                        self.runNextWorkItem()
                                    }
                                }
                            }
                        }
                    }

                    self.workItems.append(workItem)
                }
                self.startDownloading()
            }
        }
    }

    private func runNextWorkItem() {
        guard !self.isPause else { return }
        if let workItem = self.workItems.first {
            DispatchQueue.global().sync(execute: workItem)
        }
    }

    private func startDownloading() {
        isPause = false
        if let workItem = workItems.first {
            DispatchQueue.global().sync(execute: workItem)
        }
    }

    func pauseDownloading() {
        isPause = true
    }

    func resumeDownloading() {
        startDownloading()
    }

    func cancelDownloading() {
        SDWebImageDownloader.shared.cancelAllDownloads()
        let failUrlStrings = self.failUrlStrings
        completedBlock?(failUrlStrings.isEmpty, failUrlStrings)
    }

    private func createAlbum(albumTitle: String, completion: @escaping (PHAssetCollection?) -> Void) {
        fetchAlbum(albumTitle: albumTitle) { album in
            if let album = album {
                completion(album)
            } else {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                } completionHandler: { _, _ in
                    self.fetchAlbum(albumTitle: albumTitle) { album in
                        completion(album)
                    }
                }
            }
        }
    }

    private func fetchAlbum(albumTitle: String, completion: @escaping (PHAssetCollection?) -> Void) {
        DispatchQueue.global().async {
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            var album: PHAssetCollection?
            fetchResult.enumerateObjects { collection, _, stop in
                if let title = collection.localizedTitle, title == albumTitle {
                    album = collection
                    stop.initialize(to: true)
                }
            }
            DispatchQueue.main.async {
                completion(album)
            }
        }
    }

    private func saveImageToAlbum(image: UIImage, toAlbum album: PHAssetCollection? = nil, completion: ((Bool) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges {
            let assetChangeRequest: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            assetChangeRequest.creationDate = Date()
            if let album = album, album.assetCollectionType == .album {
                let placeHolder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([placeHolder] as NSFastEnumeration)
            }
        } completionHandler: { success, _ in
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }

}

extension TBPhotoDownloadManager {
    final class PhotoDownloadModel {
        var urlString: String
        var isSaved: Bool = false

        init(urlString: String) {
            self.urlString = urlString
        }
    }
}
