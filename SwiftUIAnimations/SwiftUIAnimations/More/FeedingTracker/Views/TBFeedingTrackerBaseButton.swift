import UIKit

class TBFeedingTrackerBaseButton: UIButton {

    var side: TBNursingModel.Side = .left

    init(side: TBNursingModel.Side) {
        super.init(frame: .zero)
        self.side = side
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        setBackgroundImage(UIImage(named: "breastFeeding_button_deselected"), for: .normal)
        setBackgroundImage(UIImage(named: "breastFeeding_button_selected"), for: .selected)
        addTarget(self, action: #selector(didTapSelf), for: .touchUpInside)
    }

    @objc func didTapSelf() {
        isSelected = !isSelected
    }

}
