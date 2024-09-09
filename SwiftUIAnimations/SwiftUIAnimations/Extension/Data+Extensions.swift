extension Data {
    public var deviceTokenString: String {
        return self.map { String(format: "%02.2hhx", $0) }.joined()
    }

    func convertToJSON() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
}
