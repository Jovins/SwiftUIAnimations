import UIKit

enum FoodSafetySeverity: Int {
    case all
    case safe
    case avoid
}

class FoodSafetyCategorySeveritySelector: UIControl {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Filter By:".attributedText(.mulishBody3,
                                                           alignment: .center)
        return label
    }()

    private let viewAllButton = FoodSafetySeverityButton(image: nil)
    private let safeButton = FoodSafetySeverityButton(image: TBIconList.check.image(sizeOption: .small, color: .validationGreen))

    private let avoidButton = FoodSafetySeverityButton(image: TBIconList.abandon.image(sizeOption: .small, color: .rgb199_024_041))

    private let buttonSize: CGSize = CGSize(width: 104, height: 36)
    private let betweenButtonSpacing: CGFloat = UIDevice.isPad() ? 120 : 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .DarkGray200
        [titleLabel, viewAllButton, safeButton, avoidButton].forEach {
            addSubview($0)
        }

        viewAllButton.customTitleLabel.text = "All"
        viewAllButton.color = .Navy
        viewAllButton.isSelected = true
        viewAllButton.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)

        safeButton.customTitleLabel.text = "Safe"
        safeButton.color = .validationGreen
        safeButton.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)

        avoidButton.customTitleLabel.text = "Avoid"
        avoidButton.color = .rgb199_024_041
        avoidButton.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }

        viewAllButton.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
            make.centerY.equalTo(safeButton)
            make.trailing.equalTo(safeButton.snp.leading).offset(-betweenButtonSpacing)
        }

        safeButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(buttonSize)
        }

        avoidButton.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
            make.centerY.equalTo(safeButton)
            make.leading.equalTo(safeButton.snp.trailing).offset(betweenButtonSpacing)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func enableOnly(severity: FoodSafetySeverity) {
        viewAllButton.isEnabled = severity == .all
        viewAllButton.isSelected = severity == .all

        safeButton.isEnabled = severity == .safe
        safeButton.isSelected = severity == .safe

        avoidButton.isEnabled = severity == .avoid
        avoidButton.isSelected = severity == .avoid
    }

    @objc func buttonTouched(sender: UIButton) {
        let initialSeverity = selectedSeverity()
        viewAllButton.isSelected = sender == viewAllButton
        safeButton.isSelected = sender == safeButton
        avoidButton.isSelected = sender == avoidButton
        if selectedSeverity() != initialSeverity {
            sendActions(for: .valueChanged)
        }
    }

    func selectedSeverity() -> FoodSafetySeverity {
        if viewAllButton.isSelected {
            return .all
        } else if safeButton.isSelected {
            return .safe
        }
        return .avoid
    }
}

class FoodSafetySeverityButton: UIButton {
    var color = UIColor.tb_cta() {
        didSet {
            layer.borderColor = color.cgColor
            backgroundColor = .GlobalBackgroundPrimary
            customTitleLabel.textColor = color
            customImageView.tintColor = color
        }
    }
    override var isSelected: Bool {
        didSet {
            if isEnabled {
                backgroundColor = isSelected ? color : UIColor.OffWhite
                customTitleLabel.textColor = isSelected ? UIColor.OffWhite : color
                customTitleLabel.font = isSelected ? TBFontType.mulishLink3.font : TBFontType.contentBody3.font
                customImageView.tintColor = isSelected ? UIColor.OffWhite : color
                customImageView.image = isSelected ? selectedImage : normalImage
            }
        }
    }
    override var isEnabled: Bool {
        didSet {
            backgroundColor = .GlobalBackgroundPrimary
            layer.borderColor = isEnabled ? color.cgColor : UIColor.DarkGray400.cgColor
            customImageView.tintColor = isEnabled ? color : .DarkGray400
            customImageView.image = isEnabled ? normalImage : disableImage
            customTitleLabel.textColor = isEnabled ? color : .DarkGray400
        }
    }

    var customTitleLabel = UILabel()
    let customImageView = UIImageView()
    private var normalImage: UIImage?
    private var selectedImage: UIImage? {
        normalImage?.withRenderingMode(.alwaysTemplate)
            .imageMaskedAndTinted(with: .OffWhite)
    }

    private var disableImage: UIImage? {
        normalImage?.withRenderingMode(.alwaysTemplate)
            .imageMaskedAndTinted(with: .DarkGray400)
    }

    convenience init(image: UIImage?) {
        self.init(frame: CGRect.zero)
        self.normalImage = image

        layer.cornerRadius = CGFloat(FoodSafetySeverityButton.preferedHeight() / 2.0)
        layer.borderWidth = 2

        backgroundColor = .GlobalBackgroundPrimary

        customTitleLabel.font = TBFontType.contentBody3.font
        customTitleLabel.textAlignment = .center
        addSubview(customTitleLabel)

        if let iconImage = image {
            customImageView.image = iconImage
            customImageView.contentMode = .scaleAspectFit
            addSubview(customImageView)

            customImageView.snp.makeConstraints { make in
                make.centerY.equalTo(customTitleLabel)
                make.size.equalTo(TBIconList.SizeOption.small.size)
            }
        }

        customTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if image == nil {
                make.centerX.equalToSuperview()
            } else {
                make.leading.equalTo(customImageView.snp.trailing).offset(4)
                let layout = UILayoutGuide()
                addLayoutGuide(layout)
                layout.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.leading.equalTo(customImageView)
                    $0.trailing.equalTo(customTitleLabel)
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title?.uppercased(), for: state)
    }

    class func preferedHeight() -> Float {
        return 36.0
    }
}
