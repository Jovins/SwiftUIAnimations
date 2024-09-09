import UIKit

final class TBFeedingTrackerEditButton: TBFeedingTrackerBaseButton {

    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }
    var duration: String = "00:00" {
        didSet {
            updateState()
        }
    }

    let stackView: UIStackView = UIStackView()
    private let sideLabel = UILabel()
    private let timeLabel = UILabel()

    override init(side: TBNursingModel.Side) {
        super.init(side: side)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 12
        addSubview(stackView)
        [sideLabel, timeLabel].forEach(stackView.addArrangedSubview)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        updateState()
    }

    private func updateState() {
        let textColor: UIColor = isSelected ? .OffWhite : .Navy
        sideLabel.attributedText = side.normalTitle.attributedText(.mulishLink2, foregroundColor: textColor, alignment: .center)
        timeLabel.attributedText = duration.attributedText(.mulishLink2, foregroundColor: textColor, alignment: .center)
    }

}
