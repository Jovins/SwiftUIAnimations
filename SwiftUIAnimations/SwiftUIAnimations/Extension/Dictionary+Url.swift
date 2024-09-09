import Foundation

extension Dictionary {
    // This method cannot handle nested dictionaries.
    public func toQueryString() -> String {
        let keys = self.keys
        var queryArray = [String]()
        for key in keys {
            if let currentValue = self[key] {
                queryArray.append("\(key)=\(currentValue)")
            }
        }
        return queryArray.joined(separator: "&")
    }
}
