import UIKit

class TBFeedingBaseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        adjustsImageWhenHighlighted = false
        setBackgroundImage(UIImage(named: "breastFeeding_button_deselected"), for: .normal)
        setBackgroundImage(UIImage(named: "breastFeeding_button_selected"), for: .selected)
    }
}
