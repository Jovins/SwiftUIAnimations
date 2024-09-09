import UIKit

final class TBFeedingLastBreastPickerAdapter: NSObject {

    let dataSource: [TBNursingModel.Side] = [.left, .right]

}

// MARK: - UIPickerViewDataSource
extension TBFeedingLastBreastPickerAdapter: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

// MARK: - UIPickerViewDelegate
extension TBFeedingLastBreastPickerAdapter: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel: UILabel
        if let label = view as? UILabel {
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
        }
        if let side = dataSource[safe: row] {
            pickerLabel.attributedText = side.normalTitle.attributedText(.mulishBody2, foregroundColor: .DarkGray600, alignment: .center)
        }
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let label = pickerView.view(forRow: row, forComponent: component) as? UILabel,
              let side = dataSource[safe: row] else { return }
        label.attributedText = side.normalTitle.attributedText(.mulishLink1, alignment: .center)
    }
}
