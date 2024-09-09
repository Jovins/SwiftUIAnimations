import Foundation

final class TBWeightTrackerModel: NSObject, Codable {
    static let kgTolbs: Double = 2.2046
    let id: String
    var createdDate: Date
    private var _archived: Bool?
    var archived: Bool {
        get { _archived ?? false }
        set { _archived = newValue }
    }
    var week: Double {
        if let dueDate = TBMemberDataManager.sharedInstance().memberDataObject?.pregnancyDueDate,
           let week = TBTimeUtility.pregnancyWeeksFromDueDate(fromDate: calendarDate, dueDate: dueDate) {
            return Double(week)
        } else if let dueDate = UserDefaults.standard.pregnancyDueDate,
                  let week = TBTimeUtility.pregnancyWeeksFromDueDate(fromDate: calendarDate, dueDate: dueDate) {
            return Double(week)
        }
        return 0
    }
    private var _calendarDate: Date
    var calendarDate: Date {
        let date = Calendar.current.dateComponents([.hour, .minute, .second], from: createdDate)
        if let hour = date.hour,
           let minute = date.minute,
           let second = date.second {
            let result: TimeInterval = TimeInterval(hour * 60 * 60 + minute * 60 + second)
            return _calendarDate.addingTimeInterval(result)
        } else {
            return _calendarDate
        }
    }
    private var _weight: Double
    var weight: Double {
        if UserDefaults.standard.isMetricUnit {
            return _weight
        } else {
            return _weight * TBWeightTrackerModel.kgTolbs
        }
    }
    var weightString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        guard let string = numberFormatter.string(from: weight as NSNumber) else {
            return weight.keepFractionDigits(digit: 1)
        }
        return string
    }
    var unitType: String {
        return UserDefaults.standard.isMetricUnit ? "kg." : "lbs."
    }

    func update(by model: TBWeightTrackerModel) {
        self._calendarDate = model._calendarDate
        self._weight = model._weight
    }

    init(id: String, calendarDate: Date, weight: Double) {
        self.id = id
        self._calendarDate = calendarDate
        self.createdDate = Date()
        self._weight = weight
        self._archived = false
        super.init()
    }
}
