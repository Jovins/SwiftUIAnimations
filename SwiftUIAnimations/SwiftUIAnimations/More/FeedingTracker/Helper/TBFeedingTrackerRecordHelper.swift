import Foundation

struct TBFeedingTrackerRecordHelper {

    static func getNursingDetails(nursingModel model: TBNursingModel) -> String {
        var details: String = ""
        if model.leftBreast.duration > 0,
           let leftBreastDurationString = Date.minutesSeconds(timeInterval: TimeInterval(model.leftBreast.duration)) {
            details += "\(leftBreastDurationString) m Left Breast"
        }
        if model.rightBreast.duration > 0,
           let rightBreastDurationString = Date.minutesSeconds(timeInterval: TimeInterval(model.rightBreast.duration)) {
            details += details.isEmpty ? "" : " - "
            details += "\(rightBreastDurationString) m Right Breast"
        }
        return details
    }

    static func getTotalNursingTime(nursingModel model: TBNursingModel) -> String {
        let leftBreastDuration = model.leftBreast.duration
        let rightBreastDuration = model.rightBreast.duration

        guard
            leftBreastDuration > 0
            && rightBreastDuration > 0
        else { return "" }

        let totalNursingTime = TimeInterval(leftBreastDuration) + TimeInterval(rightBreastDuration)
        let totalNursingTimeString = Date.timeIntervalToString(timeInterval: totalNursingTime, unitStyle: .abbreviated) ?? ""

        return totalNursingTimeString
    }

    static func getBottleDetails(bottleModel model: TBBottleModel) -> String {
        let unitText: String = UserDefaults.standard.isMetricUnit ? "ml" : "oz."
        var amountString = "\(String(format: "%.2f", model.amountModel.amount)) \(unitText)"
        if let milkType = model.milkType {
            amountString = amountString + " \(milkType.title) Milk"
        }
        return amountString
    }

    static func getPumpDetails(pumpModel model: TBPumpModel) -> String {
        let format: String = UserDefaults.standard.isMetricUnit ? "%.0f" : "%.2f"
        let unitText: String = UserDefaults.standard.isMetricUnit ? "ml" : "oz."
        var amountString = ""
        if model.leftAmountModel.amount > 0 {
            amountString = "\(String(format: format, model.leftAmountModel.amount)) \(unitText) Left Breast"
        }
        if model.rightAmountModel.amount > 0 {
            amountString += model.leftAmountModel.amount > 0 ? " - " : ""
            amountString += "\(String(format: format, model.rightAmountModel.amount)) \(unitText) Right Breast"
        }
        return amountString
    }

    static func getTotalPumpOutput(pumpModel model: TBPumpModel) -> String {
        guard
            model.leftAmountModel.amount > 0
            && model.rightAmountModel.amount > 0
        else { return "" }

        var amountString = ""
        let format: String = UserDefaults.standard.isMetricUnit ? "%.0f" : "%.2f"
        let unitText: String = UserDefaults.standard.isMetricUnit ? "ml" : "oz."

        let totalAmount = model.leftAmountModel.amount + model.rightAmountModel.amount
        amountString = "\(String(format: format, totalAmount)) \(unitText)"

        return amountString
    }

}
