import UIKit

final class TBFeedingSaveView: UIView {

    var saveCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Save", for: .normal)
        button.buttonWidth = UIDevice.width - 40
        button.buttonHeight = 46
        button.isEnabled = false
        return button
    }()
    private let divideLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .OffWhite
        heightConstraint.constant = 86
        widthConstraint.constant = UIDevice.width
        [divideLine, saveCTA].forEach(addSubview)
        divideLine.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        saveCTA.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private(set) lazy var heightConstraint: NSLayoutConstraint = {
        let heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        return heightConstraint
    }()

    private(set) lazy var widthConstraint: NSLayoutConstraint = {
        let widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive = true
        return widthConstraint
    }()
}
