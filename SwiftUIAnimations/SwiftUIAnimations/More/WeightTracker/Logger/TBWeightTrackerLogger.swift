import Foundation
import FirebaseCrashlytics

final class TBWeightTrackerLogger {

    static func logTheSituationOfFiles(timing: String) {
        do {
            let fileManager = FileManager.default
            guard let documentsURL = try TBCache<String, Any>.folderURL(pathDirection: .applicationSupportDirectory) else { return }
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

            var results: [String] = []

            for url in fileURLs {
                if url.lastPathComponent.contains("TBWeightTracker") {
                    let path = url.path
                    let jsonString = try TBCache<String, [TBWeightTrackerModel]>().jsonStringFromDisk(url: url)
                    var logString = "timing: \(timing) "
                    logString += "fileURL: \(path), jsonString: \(jsonString)"
                    if logString.count > 500 {
                        results.append(contentsOf: logString.splitIntoChunks(ofLength: 400))
                    } else {
                        results.append(logString)
                    }
                } else {
                    let path = url.path
                    var logString = "timing: \(timing) "
                    logString += "fileURL: \(path)"
                    results.append(logString)
                }
            }
            results.forEach {
                Crashlytics.crashlytics().log($0)
            }
        } catch {
            guard UserDefaults.standard.hasCacheWeightTracker else { return }
            Crashlytics.crashlytics().record(error: TBWeightTrackerError.otherError)
        }
    }
}

enum TBWeightTrackerError: Error {
    case initCacheFailed
    case dataLoss
    case getBackDataByLocalPath
    case getBackDataByBackup
    case storeDataSuccessButEmpty
    case storeDataFailed
    case otherError
    case iCloudDataOutOfDate
}

extension String {
    func splitIntoChunks(ofLength length: Int) -> [String] {
        var result: [String] = []
        var currentIndex = startIndex

        while currentIndex < endIndex {
            let endIndex = self.index(currentIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = self[currentIndex..<endIndex]
            result.append(String(chunk))
            currentIndex = endIndex
        }

        return result
    }
}
