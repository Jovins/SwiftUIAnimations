import Foundation

final class TBBottleMileTypePickerAdapter: NSObject {

    let dataSource: [TBBottleModel.MilkType] = [.breast, .formula]
}

// MARK: - UIPickerViewDataSource
extension TBBottleMileTypePickerAdapter: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

// MARK: - UIPickerViewDelegate
extension TBBottleMileTypePickerAdapter: UIPickerViewDelegate {
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
        if let type = dataSource[safe: row] {
            pickerLabel.attributedText = type.title.attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
        }
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let label = pickerView.view(forRow: row, forComponent: component) as? UILabel,
              let type = dataSource[safe: row] else { return }
        label.attributedText = type.title.attributedText(.mulishLink1, alignment: .center)
    }
}
