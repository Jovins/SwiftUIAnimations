import Foundation

extension Date {

    func crossDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        let nextDateString = dateString + " 23:59:59"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: nextDateString)
    }

    func nextMidnight() -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        guard let midnight = calendar.date(from: dateComponents) else { return nil }
        let nextMidnight = Date.addDays(dayNumber: 1, toDate: midnight)
        return nextMidnight
    }

    func isSameDayAs(otherDate: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.compare(self, to: otherDate, toGranularity: .day) == .orderedSame
    }

    func isOverOneYearAs(otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let dateComponnents = calendar.dateComponents([.year], from: self, to: otherDate)
        guard let year = dateComponnents.year else {
            return false
        }
        return year >= 1
    }

    func seconds(to date: Date) -> Int {
        let calendar = Calendar.current
        let dateComponnents = calendar.dateComponents([.hour, .minute, .second], from: self, to: date)
        let hour = dateComponnents.hour ?? 0
        let minute = dateComponnents.minute ?? 0
        let second = dateComponnents.second ?? 0
        return hour * 3600 + minute * 60 + second
    }

    static func lastPeriodStart() -> Date? {
        let calendar = Calendar.current
        let weekNumber: Int = 4

        return calendar.date(byAdding: .day, value: -(7 * weekNumber), to: Date())
    }

    static func dueDate(periodStart: Date) -> Date? {
        let calendar = Calendar.current
        let weekNumber: Int = 40

        return calendar.date(byAdding: .day, value: 7 * weekNumber, to: periodStart)
    }

    static func earliestPeriodStart() -> Date? {
        let calendar = Calendar.current

        return calendar.date(byAdding: .day, value: -252, to: Date())
    }

    static func startDateFor(weekNumber: Int, dueDate: Date, calendar: Calendar = Calendar.gregorianCalendar) -> Date? {
        guard let pregnancyStartDate = calendar.pastDate(dueDate, by: TBTimeUtility.pregnancyTotalDays) else {
            return nil
        }
        return calendar.futureDate(pregnancyStartDate as Date, by: 7 * weekNumber)
    }

    static func daysBetween(firstDate: Date, secondDate: Date) -> Int {
        let calendar = Calendar.current

        let difference = calendar.dateComponents([Calendar.Component.day], from: firstDate, to: secondDate)

        if let dayDifference = difference.day {
            return dayDifference
        }

        return 0
    }

    static func addWeeks(weekNumber: Int, toDate: Date) -> Date? {
        let dayNumber = 7 * weekNumber
        return addDays(dayNumber: dayNumber, toDate: toDate)
    }

    static func addDays(dayNumber: Int, toDate: Date) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: dayNumber, to: toDate)
    }

    static func convertToEST(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        return dateFormatter.date(from: dateString)
    }

    static func convertToEST(date: Date) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        let dateString = dateFormatter.string(from: date)
        return dateFormatter.date(from: dateString)
    }

    static func formateISO8601(dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }

    func convertToLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }

    func timestampOfTheDaysAfterToday(days: Int) -> Double {
        let secondsOfOneDay = 24 * 60 * 60
        return self.timeIntervalSince1970 + Double(secondsOfOneDay * days)
    }

    func timestampOfTheDaysBeforeToday(days: Int) -> Double {
        let secondsOfOneDay = 24 * 60 * 60
        return self.timeIntervalSince1970 - Double(secondsOfOneDay * days)
    }

    func convertToMMDDYYYY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertToMMDDYY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertToYYYYMMDD() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertTohmmssa() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertTohhmmssa(separate: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = separate ? "hh:mm:ss a" : "hh:mm:ssa"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertTohhmma() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertTohmma() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func previousYear(count: Int) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = -count
        return calendar.date(byAdding: components, to: self)
    }

    func convertToMMMMddyyyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertToMMMddyyyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func convertToMMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func nextYear(count: Int) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = count
        return calendar.date(byAdding: components, to: self)
    }

    func deleteMilliseconds() -> Date {
        let timeInterval = Int(self.timeIntervalSince1970)
        return Date(timeIntervalSince1970: TimeInterval(timeInterval))
    }

    func deleteSeconds() -> Date {
        let date = Calendar.current.date(bySetting: .second, value: 0, of: self) ?? self
        return date.deleteMilliseconds()
    }

    static func timeIntervalToString(
        timeInterval: TimeInterval,
        zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = .pad,
        unitStyle: DateComponentsFormatter.UnitsStyle = .positional,
        allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]
    ) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = zeroFormattingBehavior
        formatter.unitsStyle = unitStyle
        formatter.allowedUnits = allowedUnits
        return formatter.string(from: timeInterval)
    }

    static func minutesSeconds(timeInterval: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: timeInterval)
    }

    static func isParentingTrimester4(week: Int) -> Bool {
        return week >= 0 && week <= 13
    }

    static func isPregnancyDateValid(date: Date) -> Bool {
        let calender = NSCalendar.current
        guard let day = calender.dateComponents([.day], from: Date(), to: date).day else { return false }
        return day < 280
    }

    func feedStartTimeString() -> String {
        let dateFormatter = DateFormatter()
        let isToday = isSameDayAs(otherDate: Date())
        if isToday {
            dateFormatter.dateFormat = "'Today,' hh:mm a"
        } else {
            dateFormatter.dateFormat = "MMM dd, yyyy, hh:mm a"
        }
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func isDateExpired() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        let comparison = calendar.compare(self, to: currentDate, toGranularity: .day)

        if comparison == .orderedAscending {
            return true
        } else {
            return false
        }
    }
}

extension Date {
    static let firstTrimesterRange = 1...13
    static let secondTrimesterRange = 14...27
    static let thirdTrimesterRange = 28...42

    static func trimesterForWeek(week: Int) -> TrimesterType? {
        switch week {
        case firstTrimesterRange:
            return .first
        case secondTrimesterRange:
            return .second
        case thirdTrimesterRange:
            return .third
        default:
            return nil
        }
    }

    enum TrimesterType: CaseIterable {
        case first
        case second
        case third

        var range: [Int] {
            switch self {
            case .first:
                return Array(firstTrimesterRange)
            case .second:
                return Array(secondTrimesterRange)
            case .third:
                return Array(thirdTrimesterRange)
            }
        }

        var name: String {
            switch self {
            case .first:
                return "First Trimester"
            case .second:
                return "Second Trimester"
            case .third:
                return "Third Trimester"
            }
        }

        var triString: String {
            switch self {
            case .first:
                return "tri1"
            case .second:
                return "tri2"
            case .third:
                return "tri3"
            }
        }
    }
}
