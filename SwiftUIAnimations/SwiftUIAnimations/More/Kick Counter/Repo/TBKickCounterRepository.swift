import Foundation
import RxSwift
import FirebaseCrashlytics

final class TBKickCounterRepository: NSObject {
    @objc static let shared = TBKickCounterRepository()
    private(set) var kickCounterSubject = PublishSubject<[[TBKickCounterModel]]>()
    private(set) var kickCounterModels: [[TBKickCounterModel]] = []
    private(set) var cacheKey: String = "TBKickCounter"
    private var _cache: TBCache<String, [[TBKickCounterModel]]>?
    var cache: TBCache<String, [[TBKickCounterModel]]> {
        if let _cache = _cache {
            return _cache
        } else {
            do {
                let cache = try TBCache<String, [[TBKickCounterModel]]>.readFromDisk(withName: cacheKey)
                _cache = cache
                return cache
            } catch {
                if UserDefaults.standard.hasCacheKickCounter {
                    Crashlytics.crashlytics().record(error: TBKickCounterError.initCacheFailed)
                }
            }
            let cache = TBCache<String, [[TBKickCounterModel]]>()
            _cache = cache
            return cache
        }
    }

    private override init() {}

    func getKickCounterModels() {
        _cache = nil
        if let array = cache.value(forKey: cacheKey),
           !array.isEmpty {
            self.kickCounterModels = array
            kickCounterSubject.onNext(kickCounterModels)
            return
        }
        if UserDefaults.standard.hasCacheKickCounter {
           if let cacheFromPath: TBCache<String, [[TBKickCounterModel]]> = TBCacheBackupHelper.getCacheFromPath(fileKey: cacheKey),
              let array = cacheFromPath.value(forKey: cacheKey),
              !array.isEmpty {
               self.kickCounterModels = array
               kickCounterSubject.onNext(kickCounterModels)
               Crashlytics.crashlytics().record(error: TBKickCounterError.getBackDataByLocalPath)
               return
           } else if let cacheFromBackup: TBCache<String, [[TBKickCounterModel]]> = TBCacheBackupHelper.getCacheFromBackup(fileKey: cacheKey, checkCache: { [weak self] cache in
               if let self,
                  let value = cache.value(forKey: self.cacheKey),
                  !value.isEmpty {
                   return true
               }
               return false
           }), let array = cacheFromBackup.value(forKey: cacheKey) {
               self.kickCounterModels = array
               kickCounterSubject.onNext(kickCounterModels)
               Crashlytics.crashlytics().record(error: TBKickCounterError.getBackDataByBackup)
               return
           } else {
               Crashlytics.crashlytics().record(error: TBKickCounterError.dataLoss)
           }
        }
        self.kickCounterModels = []
        kickCounterSubject.onNext(kickCounterModels)
    }

    func startNewCount(model: TBKickCounterModel) {
        if kickCounterModels.isEmpty {
            kickCounterModels.insert([model], at: 0)
        } else if var models = kickCounterModels.first,
                  let date = models.first?.startTime {
            if model.startTime.isSameDayAs(otherDate: date) {
                models.insert(model, at: 0)
                kickCounterModels[0] = models
            } else {
                kickCounterModels.insert([model], at: 0)
            }
        }
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    func finishKickCounter(id: String) {
        guard let currentModel = kickCounterModels.flatMap({$0}).first(where: {$0.id == id}) else { return }
        currentModel.endTime = Date()
        currentModel.lastUpdatedTime = Date()
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    func recordCount(id: String) {
        guard let currentModel = kickCounterModels.flatMap({$0}).first(where: {$0.id == id}) else { return }
        currentModel.kickCounterCount += 1
        currentModel.lastUpdatedTime = Date()
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    func autoUpdateEndTime(id: String, duration: TimeInterval) {
        guard let currentModel = kickCounterModels.flatMap({$0}).first(where: {$0.id == id}) else { return }
        let endTime = currentModel.lastUpdatedTime.addingTimeInterval(duration)
        currentModel.endTime = endTime
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    func deleteKickCounter(id: String) {
        guard let sectionIndex = kickCounterModels.firstIndex(where: {$0.contains(where: {$0.id == id})}),
              let model = kickCounterModels[sectionIndex].first(where: { $0.id == id }) else { return }
        model.archived = true
        kickCounterModels = kickCounterModels.filter({!$0.isEmpty})
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    func deleteKickCountersOfThisDay(date: Date) {
        guard let sectionIndex = kickCounterModels.firstIndex(where: {$0.contains(where: {$0.startTime.isSameDayAs(otherDate: date)})}),
        let models = kickCounterModels[safe: sectionIndex] else { return }
        models.forEach({ $0.archived = true })
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    @objc func resetAllKickCounters() {
        kickCounterModels.forEach({ $0.forEach({ $0.archived = true }) })
        storeData()
        kickCounterSubject.onNext(kickCounterModels)
    }

    @objc func resetCache() {
        kickCounterModels.removeAll()
        _cache?.removeValue(forKey: cacheKey)
        _cache = nil
    }

    private func storeData() {
        do {
            try cache.insert(kickCounterModels, forKey: cacheKey)
            try cache.saveToDisk(withName: cacheKey)
            backupKickCounter()
            if UserDefaults.standard.hasCacheKickCounter,
               let array = try TBCache<String, [[TBKickCounterModel]]>.readFromDisk(withName: cacheKey).value(forKey: cacheKey),
               array.isEmpty {
                Crashlytics.crashlytics().record(error: TBKickCounterError.storeDataSuccessButEmpty)
            }
        } catch {
            Crashlytics.crashlytics().record(error: TBKickCounterError.storeDataFailed)
        }
    }

    private func backupKickCounter() {
        if !UserDefaults.standard.hasCacheKickCounter {
            UserDefaults.standard.hasCacheKickCounter = true
        }
        TBCacheBackupHelper.backupToLocalFolder(cache: cache, fileKey: cacheKey)
    }
}

extension TBKickCounterRepository {
    enum TBKickCounterError: Error {
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
