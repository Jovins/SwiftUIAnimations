import UIKit

final class TBFeedingDurationPickerAdapter: NSObject {

    let dataSource: [TBDurationModel] = {
        let minuteModel = TBDurationModel(type: .minute, data: Array(0...59))
        let secondModel = TBDurationModel(type: .second, data: Array(0...59))
        return [minuteModel, secondModel]
    }()
    var minuteDuration: Int = 0
    var secondDuration: Int = 0

}

// MARK: - UIPickerViewDataSource
extension TBFeedingDurationPickerAdapter: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[safe: component]?.data.count ?? 0
    }
}

// MARK: - UIPickerViewDelegate
extension TBFeedingDurationPickerAdapter: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        // It's '31' on spec, but the actual height is two px higher than what we set.
        return 29
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 95
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel: UILabel
        if let label = view as? UILabel {
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
        }
        if let duration = dataSource[safe: component]?.data[safe: row],
           let typeString = dataSource[safe: component]?.type.unitTitle {
            pickerLabel.attributedText = "\(duration) \(typeString)".attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
        }
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let label = pickerView.view(forRow: row, forComponent: component) as? UILabel,
              let component = dataSource[safe: component],
              let duration = component.data[safe: row] else { return }
        let typeString = component.type.unitTitle
        label.attributedText = "\(duration) \(typeString)".attributedText(.mulishLink1, alignment: .center)
        switch component.type {
        case .minute:
            minuteDuration = duration
        case .second:
            secondDuration = duration
        }
    }
}
