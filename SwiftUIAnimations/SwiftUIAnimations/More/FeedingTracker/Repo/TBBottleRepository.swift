import UIKit
import RxSwift
import FirebaseCrashlytics

final class TBBottleRepository: NSObject, TBFeedingTrackerRepoProtocol {
    @objc static let shared = TBBottleRepository()
    private(set) var modelsSubject = PublishSubject<[TBBottleModel]>()
    private(set) var models = [TBBottleModel]()
    let fileCacheKey: String = "TBBottle"
    var cacheKey: String {
        guard TBMemberDataManager.shared.isParentSelected,
              let key = TBMemberDataManager.shared.activeStatusModel?.id else { return fileCacheKey }
        return String(key)
    }
    private var _cache: TBCache<String, [TBBottleModel]>?
    var cache: TBCache<String, [TBBottleModel]> {
        if let _cache = _cache {
            return _cache
        } else {
            do {
                let cache = try TBCache<String, [TBBottleModel]>.readFromDisk(withName: fileCacheKey)
                _cache = cache
                return cache
            } catch {
                if UserDefaults.standard.hasCacheBottle {
                    Crashlytics.crashlytics().record(error: TBBottleRepositoryError.initCacheFailed)
                }
            }
            let cache = TBCache<String, [TBBottleModel]>()
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
            self.models = array
            modelsSubject.onNext(models)
            return
        }
        if UserDefaults.standard.hasCacheBottle {
           if let cacheFromPath: TBCache<String, [TBBottleModel]> = TBCacheBackupHelper.getCacheFromPath(fileKey: fileCacheKey),
              let array = cacheFromPath.value(forKey: cacheKey),
              !array.isEmpty {
               self.models = array
               modelsSubject.onNext(array)
               Crashlytics.crashlytics().record(error: TBBottleRepositoryError.getBackDataByLocalPath)
               return
           } else if let cacheFromBackup: TBCache<String, [TBBottleModel]> = TBCacheBackupHelper.getCacheFromBackup(fileKey: fileCacheKey, checkCache: { [weak self] cache in
               if let self,
                  let value = cache.value(forKey: self.cacheKey),
                  !value.isEmpty {
                   return true
               }
               return false
           }), let array = cacheFromBackup.value(forKey: cacheKey) {
               self.models = array
               modelsSubject.onNext(models)
               Crashlytics.crashlytics().record(error: TBBottleRepositoryError.getBackDataByBackup)
               return
           } else {
               Crashlytics.crashlytics().record(error: TBBottleRepositoryError.dataLoss)
           }
        }
        self.models = []
        modelsSubject.onNext(models)
    }

    func addModel(model: TBBottleModel) {
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

    func editModel(id: String, model: TBBottleModel) {
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
            backupBottleCache()
            if UserDefaults.standard.hasCacheBottle,
               let array = try TBCache<String, [TBBottleModel]>.readFromDisk(withName: fileCacheKey).value(forKey: cacheKey),
               array.isEmpty {
                Crashlytics.crashlytics().record(error: TBBottleRepositoryError.storeDataSuccessButEmpty)
            }
        } catch {
            Crashlytics.crashlytics().record(error: TBBottleRepositoryError.storeDataFailed)
        }
    }

    private func backupBottleCache() {
        if !UserDefaults.standard.hasCacheBottle {
            UserDefaults.standard.hasCacheBottle = true
        }
        TBCacheBackupHelper.backupToLocalFolder(cache: cache, fileKey: fileCacheKey)
    }
}

extension TBBottleRepository {
    enum TBBottleRepositoryError: Error {
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
