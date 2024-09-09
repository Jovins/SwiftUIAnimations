import Foundation
import RxSwift
import FirebaseCrashlytics

final class TBWeightTrackerRepository: NSObject {
    @objc static let shared = TBWeightTrackerRepository()
    private(set) var weightsSubject = PublishSubject<[TBWeightTrackerModel]>()
    private(set) var weights = [TBWeightTrackerModel]()
    let cacheKey: String = "TBWeightTracker"
    private var _cache: TBCache<String, [TBWeightTrackerModel]>?
    var cache: TBCache<String, [TBWeightTrackerModel]> {
        if let _cache = _cache {
            return _cache
        } else {
            do {
                let cache = try TBCache<String, [TBWeightTrackerModel]>.readFromDisk(withName: cacheKey)
                _cache = cache
                return cache
            } catch {
                if UserDefaults.standard.hasCacheWeightTracker {
                    TBWeightTrackerLogger.logTheSituationOfFiles(timing: "initCache")
                    Crashlytics.crashlytics().record(error: TBWeightTrackerError.initCacheFailed)
                }
            }
            let cache = TBCache<String, [TBWeightTrackerModel]>()
            _cache = cache
            return cache
        }
    }

    private override init() {}

    func getWeights() {
        TBWeightTrackerLogger.logTheSituationOfFiles(timing: "getWeights")

        _cache = nil
        if let array = cache.value(forKey: cacheKey),
           !array.isEmpty {
            self.weights = array
            weightsSubject.onNext(array)
            return
        }

        if UserDefaults.standard.hasCacheWeightTracker,
           let retryCache: TBCache<String, [TBWeightTrackerModel]> = TBCacheBackupHelper.getCacheFromPath(fileKey: cacheKey),
           let value = retryCache.value(forKey: cacheKey),
           !value.isEmpty {
            self.weights = value
            weightsSubject.onNext(value)
            Crashlytics.crashlytics().record(error: TBWeightTrackerError.getBackDataByLocalPath)
            return
        }

        if UserDefaults.standard.hasCacheWeightTracker,
           let retryCache: TBCache<String, [TBWeightTrackerModel]> = TBCacheBackupHelper.getCacheFromBackup(fileKey: cacheKey, checkCache: {[weak self] cache in
               guard let self else { return false }
               if let value = cache.value(forKey: self.cacheKey),
                  !value.isEmpty {
                   return true
               }
               return false
           }),
           let value = retryCache.value(forKey: cacheKey) {
            self.weights = value
            weightsSubject.onNext(value)
            Crashlytics.crashlytics().record(error: TBWeightTrackerError.getBackDataByBackup)
            return
        }

        if UserDefaults.standard.hasCacheWeightTracker {
            Crashlytics.crashlytics().record(error: TBWeightTrackerError.dataLoss)
        }
        self.weights = []
        weightsSubject.onNext(weights)
    }

    func addWeight(model: TBWeightTrackerModel) {
        weights.insert(model, at: 0)
        sortData()
        storeData()
        if !UserDefaults.standard.hasCacheWeightTracker {
            UserDefaults.standard.hasCacheWeightTracker = true
        }
        TBCacheBackupHelper.backupToLocalFolder(cache: cache, fileKey: cacheKey)
        TBWeightTrackerLogger.logTheSituationOfFiles(timing: "addWeight")
        weightsSubject.onNext(weights)
    }

    func editWeight(id: String, model: TBWeightTrackerModel) {
        guard let currentModel = weights.first(where: { $0.id == id }) else { return }
        currentModel.update(by: model)
        sortData()
        storeData()
        TBWeightTrackerLogger.logTheSituationOfFiles(timing: "editWeight")
        weightsSubject.onNext(weights)
    }

    func deleteWeight(id: String) {
        guard let model = weights.first(where: { $0.id == id }) else { return }
        model.archived = true
        storeData()
        TBWeightTrackerLogger.logTheSituationOfFiles(timing: "deleteWeight")
        weightsSubject.onNext(weights)
    }

    @objc func resetWeights() {
        guard !weights.isEmpty else { return }
        weights.forEach {
            $0.archived = true
        }
        storeData()
        TBWeightTrackerLogger.logTheSituationOfFiles(timing: "resetWeights")
        weightsSubject.onNext(weights)
    }

    @objc func resetCache() {
        weights.removeAll()
        _cache?.removeValue(forKey: cacheKey)
        _cache = nil
    }

    private func sortData() {
        weights = weights.sorted(by: {
            guard $0.calendarDate != $1.calendarDate else {
                return $0.createdDate >= $1.calendarDate
            }
            return $0.calendarDate > $1.calendarDate
        })
    }

    private func storeData() {
        do {
            try cache.insert(weights, forKey: cacheKey)
            try cache.saveToDisk(withName: cacheKey)
            TBWeightTrackerLogger.logTheSituationOfFiles(timing: "storeData success")
            if UserDefaults.standard.hasCacheWeightTracker,
               let array = try TBCache<String, [TBWeightTrackerModel]>.readFromDisk(withName: cacheKey).value(forKey: cacheKey),
               array.isEmpty {
                Crashlytics.crashlytics().record(error: TBWeightTrackerError.storeDataSuccessButEmpty)
            }
        } catch {
            TBWeightTrackerLogger.logTheSituationOfFiles(timing: "storeData failed")
            Crashlytics.crashlytics().record(error: TBWeightTrackerError.storeDataFailed)
        }
    }

    var hasWeights: Bool {
        if !weights.isEmpty {
            return true
        }
        if let array = cache.value(forKey: cacheKey) {
            return !array.isEmpty
        } else {
            return false
        }
    }
}
