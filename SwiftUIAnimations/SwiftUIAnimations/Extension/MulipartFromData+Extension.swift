import Moya

extension MultipartFormData {
    static func build(stringValue: String, key: String) -> MultipartFormData {
        let valueData = stringValue.data(using: .utf8) ?? Data()
        return MultipartFormData(provider: .data(valueData), name: key)
    }

    static func build(intValue: Int, key: String) -> MultipartFormData {
        let valueData = String(intValue).data(using: .utf8) ?? Data()
        return MultipartFormData(provider: .data(valueData), name: key)
    }
}
