import Foundation

final class TBKickCounterModel: NSObject, Codable {
    let id: String
    let startTime: Date
    var endTime: Date?
    var lastUpdatedTime: Date
    var kickCounterCount: Int = 0
    var archived: Bool = false

    init(startTime: Date) {
        self.id = UUID().uuidString
        self.startTime = startTime
        self.lastUpdatedTime = startTime
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        self.lastUpdatedTime = try container.decode(Date.self, forKey: .lastUpdatedTime)
        self.kickCounterCount = try container.decodeIfPresent(Int.self, forKey: .kickCounterCount) ?? 0
        self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }

    func startTimeToEndTimeString() -> String {
        let startTimeString = startTime.convertTohhmmssa()
        var endTimeString = ""
        if let endTime = endTime {
            endTimeString = endTime.convertTohhmmssa()
            return startTimeString.lowercased() + " - " + endTimeString.lowercased()
        } else {
            endTimeString = "Counting"
            return startTimeString.lowercased() + " - " + endTimeString
        }
    }

    func startTimeToEndTimeLengthString() -> String {
        if let endTime = endTime {
            let diff = Calendar.current.dateComponents([Calendar.Component.second], from: startTime.deleteMilliseconds(), to: endTime.deleteMilliseconds())
            return Date.timeIntervalToString(timeInterval: Double(diff.second ?? 0)) ?? ""
        } else {
            return "Counting"
        }
    }
}
