import UIKit
import RxSwift
import FirebaseCrashlytics

final class TBNursingRepository: NSObject, TBFeedingTrackerRepoProtocol {
    @objc static let shared = TBNursingRepository()
    private(set) var modelsSubject = PublishSubject<[TBNursingModel]>()
    private(set) var models = [TBNursingModel]()
    let fileCacheKey: String = "TBNursing"
    var memoryCacheKey: String {
        guard TBMemberDataManager.shared.isParentSelected,
              let id = TBMemberDataManager.shared.activeStatusModel?.id else { return fileCacheKey }
        return String(id)
    }
    private var _cache: TBCache<String, [TBNursingModel]>?
    var cache: TBCache<String, [TBNursingModel]> {
        if let _cache {
            return _cache
        } else {
            do {
                let cache = try TBCache<String, [TBNursingModel]>.readFromDisk(withName: fileCacheKey)
                _cache = cache
                return cache
            } catch {
                if UserDefaults.standard.hasCacheFeedingTrackerNursing {
                    Crashlytics.crashlytics().record(error: TBNursingRepositoryError.initCacheFailed)
                }
            }
            let cache = TBCache<String, [TBNursingModel]>()
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
        if let array = cache.value(forKey: memoryCacheKey),
           !array.isEmpty {
            models = array
            modelsSubject.onNext(models)
            return
        }
        if UserDefaults.standard.hasCacheFeedingTrackerNursing {
            if let cacheFromPath: TBCache<String, [TBNursingModel]> = TBCacheBackupHelper.getCacheFromPath(fileKey: fileCacheKey),
               let array = cacheFromPath.value(forKey: memoryCacheKey),
               !array.isEmpty {
                models = array
                modelsSubject.onNext(models)
                Crashlytics.crashlytics().record(error: TBNursingRepositoryError.getBackDataByLocalPath)
                return
            } else if let cacheFromBackup: TBCache<String, [TBNursingModel]> = TBCacheBackupHelper.getCacheFromBackup(fileKey: fileCacheKey, checkCache: { [weak self] cache in
                if let self,
                   let value = cache.value(forKey: self.memoryCacheKey),
                   !value.isEmpty {
                    return true
                }
                return false
            }), let array = cacheFromBackup.value(forKey: memoryCacheKey) {
                models = array
                modelsSubject.onNext(models)
                Crashlytics.crashlytics().record(error: TBNursingRepositoryError.getBackDataByBackup)
                return
            } else {
                Crashlytics.crashlytics().record(error: TBNursingRepositoryError.dataLoss)
            }
        }
        self.models = []
        modelsSubject.onNext(models)
    }

    func addModel(model: TBNursingModel) {
        models.insert(model, at: 0)
        sortData()
        storeData()
        modelsSubject.onNext(models)
    }

    func editModel(id: String, model: TBNursingModel, shouldSendSubject: Bool = true) {
        guard let currentModel = models.first(where: { $0.id == id }) else { return }
        currentModel.update(by: model)
        sortData()
        storeData()
        if shouldSendSubject {
            modelsSubject.onNext(models)
        }
    }

    func deleteModel(id: String) {
        guard let model = models.first(where: { $0.id == id }) else { return }
        model.archived = true
        storeData()
        modelsSubject.onNext(models)
    }

    func autoUpdateEndTime(id: String, duration: TimeInterval) {
        guard var currentModel = models.first(where: { $0.id == id }) else { return }
        let endTime = currentModel.updatedTime.addingTimeInterval(duration)
        currentModel.savedTime = endTime
        if currentModel.leftBreast.isBreasting {
            currentModel.lastBreast = .left
            updateBreastModel(model: currentModel.leftBreast, duration: duration)
        }
        if currentModel.rightBreast.isBreasting {
            currentModel.lastBreast = .right
            updateBreastModel(model: currentModel.rightBreast, duration: duration)
        }
        storeData()
        modelsSubject.onNext(models)
    }

    private func updateBreastModel(model: TBBreastModel, duration: TimeInterval) {
        let oneHalfHours = Int(1.5 * 60 * 60)
        model.isBreasting = false
        var totalDuration = model.duration + Int(duration)
        totalDuration = min(totalDuration, oneHalfHours)
        model.duration = totalDuration
    }

    @objc func resetCache() {
        models.removeAll()
        cache.removeValue(forKey: fileCacheKey)
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
            try cache.insert(models, forKey: memoryCacheKey)
            try cache.saveToDisk(withName: fileCacheKey)
            backupNursingData()
            if UserDefaults.standard.hasCacheFeedingTrackerNursing,
               let array = try TBCache<String, [TBNursingModel]>.readFromDisk(withName: fileCacheKey).value(forKey: memoryCacheKey),
               array.isEmpty {
                Crashlytics.crashlytics().record(error: TBNursingRepositoryError.storeDataSuccessButEmpty)
            }
        } catch {
            Crashlytics.crashlytics().record(error: TBNursingRepositoryError.storeDataFailed)
        }
    }

    private func backupNursingData() {
        if !UserDefaults.standard.hasCacheFeedingTrackerNursing {
            UserDefaults.standard.hasCacheFeedingTrackerNursing = true
        }
        TBCacheBackupHelper.backupToLocalFolder(cache: cache, fileKey: fileCacheKey)
    }
}

extension TBNursingRepository {
    enum TBNursingRepositoryError: Error {
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
