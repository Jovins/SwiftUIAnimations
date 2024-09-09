import UIKit
import RxSwift
import FirebaseCrashlytics

final class TBPumpRepository: NSObject, TBFeedingTrackerRepoProtocol {

    @objc static let shared = TBPumpRepository()
    private(set) var modelsSubject = PublishSubject<[TBPumpModel]>()
    private(set) var models = [TBPumpModel]()
    let fileCacheKey: String = "TBPump"
    var cacheKey: String {
        guard TBMemberDataManager.shared.isParentSelected,
              let key = TBMemberDataManager.shared.activeStatusModel?.id else { return fileCacheKey }
        return String(key)
    }
    private var _cache: TBCache<String, [TBPumpModel]>?
    var cache: TBCache<String, [TBPumpModel]> {
        if let _cache {
            return _cache
        } else {
            do {
                let cache = try TBCache<String, [TBPumpModel]>.readFromDisk(withName: fileCacheKey)
                _cache = cache
                return cache
            } catch {
                if UserDefaults.standard.hasCacheFeedingTrackerPumping {
                    Crashlytics.crashlytics().record(error: TBPumpRepositoryError.initCacheFailed)
                }
            }
            let cache = TBCache<String, [TBPumpModel]>()
            _cache = cache
            return cache
        }
    }

    private override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: TBNotificationConstant.didSwitchedProfile, object: nil, queue: OperationQueue.current) {[weak self] _ in
            guard let self else { return }
            self.resetCache()
        }
    }

    func getData() {
        _cache = nil
        if let array = cache.value(forKey: cacheKey),
           !array.isEmpty {
            models = array
            modelsSubject.onNext(models)
            return
        }
        if UserDefaults.standard.hasCacheFeedingTrackerPumping {
            if let cacheFromPath: TBCache<String, [TBPumpModel]> = TBCacheBackupHelper.getCacheFromPath(fileKey: fileCacheKey),
               let array = cacheFromPath.value(forKey: cacheKey),
               !array.isEmpty {
                models = array
                modelsSubject.onNext(models)
                Crashlytics.crashlytics().record(error: TBPumpRepositoryError.getBackDataByLocalPath)
                return
            } else if let cacheFromBackup: TBCache<String, [TBPumpModel]> = TBCacheBackupHelper.getCacheFromBackup(fileKey: fileCacheKey, checkCache: { [weak self] cache in
                if let self,
                   let value = cache.value(forKey: self.cacheKey),
                   !value.isEmpty {
                    return true
                }
                return false
            }), let array = cacheFromBackup.value(forKey: cacheKey) {
                models = array
                modelsSubject.onNext(models)
                Crashlytics.crashlytics().record(error: TBPumpRepositoryError.getBackDataByBackup)
                return
            } else {
                Crashlytics.crashlytics().record(error: TBPumpRepositoryError.dataLoss)
            }
        }
        self.models = []
        modelsSubject.onNext(models)
    }

    func addModel(model: TBPumpModel) {
        models.insert(model, at: 0)
        sortData()
        storeData()
        modelsSubject.onNext(models)
    }

    func deleteModel(id: String) {
        guard let model = models.first(where: { $0.id == id }) else { return }
        model.archived = true
        storeData()
        modelsSubject.onNext(models)
    }

    func editModel(id: String, model: TBPumpModel) {
        guard let currentModel = models.first(where: { $0.id == id }) else { return }
        currentModel.update(by: model)
        sortData()
        storeData()
        modelsSubject.onNext(models)
    }

    @objc func resetCache() {
        models.removeAll()
        cache.removeValue(forKey: cacheKey)
        _cache = nil
    }

    private func sortData() {
        models = models.sorted(by: {
            guard $0.startTime != $1.startTime else {
                return $0.startTime >=? $1.startTime
            }
            return $0.startTime >? $1.startTime
        })
    }

    private func storeData() {
        do {
            try cache.insert(models, forKey: cacheKey)
            try cache.saveToDisk(withName: fileCacheKey)
            backupPumpingData()
            if UserDefaults.standard.hasCacheFeedingTrackerPumping,
               let array = try TBCache<String, [TBPumpModel]>.readFromDisk(withName: fileCacheKey).value(forKey: cacheKey),
               array.isEmpty {
                Crashlytics.crashlytics().record(error: TBPumpRepositoryError.storeDataSuccessButEmpty)
            }
        } catch {
            Crashlytics.crashlytics().record(error: TBPumpRepositoryError.storeDataFailed)
        }
    }

    private func backupPumpingData() {
        if !UserDefaults.standard.hasCacheFeedingTrackerPumping {
            UserDefaults.standard.hasCacheFeedingTrackerPumping = true
        }
        TBCacheBackupHelper.backupToLocalFolder(cache: cache, fileKey: fileCacheKey)
    }
}

extension TBPumpRepository {
    enum TBPumpRepositoryError: Error {
        case initCacheFailed
        case dataLoss
        case getBackDataByLocalPath
        case getBackDataByBackup
        case storeDataSuccessButEmpty
        case storeDataFailed
        case otherError
        case iCloudDataOutOfDate
    }
}
