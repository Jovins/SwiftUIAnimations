import Foundation

extension DateFormatter {
    static let yyyyMMddTHHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let mMMMddyyyy = "MMMM d, yyyy"
    static let yyyyMMdd = "yyyy-MM-dd"

    func yyyyMMddHHmmssDate(from dateString: String?) -> Date? {
        guard let string = dateString else { return nil }
        timeZone = TimeZone(identifier: "UTC")
        dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return date(from: string)
    }

    func yyyyMMddHHmmssSSSZDate(from dateString: String?) -> Date? {
        guard let string = dateString else { return nil }
        timeZone = TimeZone(identifier: "UTC")
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return date(from: string)
    }

    func yyyyMMddString(from date: Date?) -> String? {
        guard let d = date else { return nil }
        setTimeZoneAndDateFormat(format: "yyyyMMdd")
        return string(from: d)
    }

    func mmDDyyString(from date: Date?) -> String? {
        guard let d = date else { return nil }
        setTimeZoneAndDateFormat(format: "MM/dd/yy")
        return string(from: d)
    }

    func mmmmDDyyyyString(from date: Date?) -> String? {
        guard let d = date else { return nil }
        setTimeZoneAndDateFormat(format: "MMMM dd, yyyy")
        return string(from: d)
    }

    func dMMMString(from date: Date?) -> String? {
        guard let d = date else { return nil }
        setTimeZoneAndDateFormat(format: "d MMM")
        return string(from: d)
    }

    func hhMMaString(from date: Date?) -> String? {
        guard let d = date else { return nil }
        setTimeZoneAndDateFormat(format: "HH:mm a")
        return string(from: d)
    }

    func yyyyMMddHHmm(from date: Date?) -> String? {
        guard let d = date else { return nil }
        setTimeZoneAndDateFormat(format: "yyyy-MM-dd HH:mma")
        return string(from: d)
    }

    private func setTimeZoneAndDateFormat(format: String) {
        timeZone = NSTimeZone.local
        dateFormat = format
    }

    func formatDate(_ dateString: String?, originalFormat: String, targetFormat: String) -> String? {
        guard let dateString = dateString else { return nil }
        timeZone = TimeZone(identifier: "UTC")
        dateFormat = originalFormat

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = targetFormat
        guard let dateValue = date(from: dateString) else { return nil }
        return dateFormatter.string(from: dateValue)
    }

    func covertFormatFromYyyyMMddToMMddyy(_ dateString: String?) -> String? {
        guard let date = yyyyMMddHHmmssDate(from: dateString),
            let string = mmDDyyString(from: date) else {
            return nil
        }
        return string
    }

    func covertFormatFromYyyyMMddToMMMMddyyyy(_ dateString: String?) -> String? {
        guard let date = yyyyMMddHHmmssDate(from: dateString),
            let string = mmmmDDyyyyString(from: date) else {
            return nil
        }
        return string
    }

    func covertFormatFromYyyyMMddToDMMM(_ dateString: String?) -> String? {
        guard let date = yyyyMMddHHmmssDate(from: dateString) else { return nil }
        var string: String?
        if date.isSameDayAs(otherDate: Date()) {
            string = hhMMaString(from: date)
        } else {
            string = dMMMString(from: date)
        }
        return string
    }

    func covertFormatFromYyyyMMddToYyyyMMddHHMM(_ dateString: String?) -> String? {
        guard let date = yyyyMMddHHmmssDate(from: dateString),
            let string = yyyyMMddHHmm(from: date) else {
                return nil
        }
        return string
    }

    func getTimestampAsUniqueIdentifier(with date: Date?) -> String {
        guard let date = date else { return "" }
        setTimeZoneAndDateFormat(format: "yyyyMMddHHmm")
        return string(from: date)
    }

    static func string(from date: Date, with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    static func date(from dateString: String, with format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
}
