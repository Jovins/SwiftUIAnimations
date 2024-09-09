import UIKit
import RxSwift

final class TBNursingManualAddEntryViewModel: NSObject {

    var operationType: TBNursingManualAddEntryControllerViewModel.OperationType = .add
    var title: NSAttributedString? {
        switch operationType {
        case .add:
            return "Select Breast and Duration\nof Breastfeeding".attributedText(.mulishLink1, alignment: .center)
        case .edit:
            return "Tap the Breast to\nmake changes".attributedText(.mulishLink1, alignment: .center)
        }
    }
    var defaultModel: TBNursingModel? {
        didSet {
            guard let defaultModel = defaultModel else { return }
            editModel.update(by: defaultModel)
        }
    }
    let editModel: TBNursingModel = TBNursingModel()
    private(set) var updateSubject: PublishSubject<AnyObject?> = PublishSubject<AnyObject?>()
    var lastBreastEnable: Bool {
        if editModel.leftBreast.duration > 0, editModel.rightBreast.duration == 0 {
            return false
        } else if editModel.leftBreast.duration == 0, editModel.rightBreast.duration > 0 {
            return false
        }
        return true
    }

    func setDuration(side: TBNursingModel.Side, minuteDuration: Int, secondDuration: Int) {
        let timeInterval = minuteDuration * 60 + secondDuration
        var otherSideDuration = side == .left ? editModel.rightBreast.duration : editModel.leftBreast.duration
        switch side {
        case .left:
            editModel.leftBreast.duration = timeInterval
        case .right:
            editModel.rightBreast.duration = timeInterval
        }
    }

    func pickerSelectMinute(editButton: TBFeedingTrackerEditButton) -> Int {
        return pickerSelectRow(editButton: editButton, durationType: .minute)
    }
    func pickerSelectSecond(editButton: TBFeedingTrackerEditButton) -> Int {
        return pickerSelectRow(editButton: editButton, durationType: .second)
    }
    private func pickerSelectRow(editButton: TBFeedingTrackerEditButton, durationType: TBDurationModel.DurationType) -> Int {
        var result: Int = 0
        var duration: Int = 0
        switch editButton.side {
        case .left:
            duration = editModel.leftBreast.duration
        case .right:
            duration = editModel.rightBreast.duration
        }
        switch durationType {
        case .minute:
            result = Int(duration / 60)
        case .second:
            result = Int(duration) % 60
        }
        return result
    }
}
