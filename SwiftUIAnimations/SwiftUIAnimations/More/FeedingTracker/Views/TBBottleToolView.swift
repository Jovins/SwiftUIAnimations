import UIKit
import SnapKit

protocol TBBottleToolViewDelegate: AnyObject {
    func modelDidUpdate()
}

final class TBBottleToolView: UIView {

    private let amountLabel: UILabel = UILabel()
    private let minLabel: UILabel = UILabel()
    private var unitText: String {
        if UserDefaults.standard.isMetricUnit {
            return "ml"
        } else {
            return "oz."
        }
    }
    private let maxLabel: UILabel = UILabel()
    private let slider: TBBottleSlider = {
        let view = TBBottleSlider()
        view.maximumTrackTintColor = .DarkGray300
        view.minimumTrackTintColor = .Aqua
        view.thumbTintColor = .Teal
        return view
    }()
    private let bottleView: UIImageView = UIImageView(image: UIImage(named: "empty_bottle"))
    private let fillContentView: UIView = UIView()
    private let fillColorView: UIView = {
        let view = UIView()
        view.backgroundColor = .Aqua
        return view
    }()
    private let fillHeight: CGFloat = 44.8
    private let startTimeView: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Start Time"
        textField.rightButtonSetImage(image: UIImage.calendar(color: .Magenta), backgroundColor: .DarkGray200, for: .normal)
        return textField
    }()
    private let startTimeControl = UIControl()
    private let milkTypeView: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Milk Type"
        textField.placeholder = "Choose milk type"
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(color: .Navy), for: .normal)
        return textField
    }()
    private let milkTypeControl = UIControl()
    private lazy var milkTypePicker: TBOldPickerView = {
        let adapter = TBPickerDefaultAdapter()
        let view = TBOldPickerView()
        view.adapter = TBBottleMileTypePickerAdapter()
        view.delegate = self
        return view
    }()
    private(set) lazy var addNoteView: TBAddNoteTextView = {
        let view = TBAddNoteTextView()
        view.titleLabelText = "Add Note"
        view.delegate = self
        return view
    }()
    private(set) lazy var timePickerView: TBDatePickerView = {
        let picker = TBDatePickerView()
        if #available(iOS 13.4, *) {
            picker.pickerStyle = .wheels
        }
        picker.pickerViewHeight = 248
        picker.mode = .dateAndTime
        picker.delegate = self
        return picker
    }()
    let viewModel: TBBottleToolViewModel = TBBottleToolViewModel()
    weak var delegate: TBBottleToolViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .GlobalBackgroundPrimary
        [amountLabel, minLabel, maxLabel, slider, fillContentView, bottleView,
         startTimeView, startTimeControl, milkTypeView, milkTypeControl, addNoteView].forEach(addSubview)
        fillContentView.addSubview(fillColorView)
        amountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(24)
            $0.height.equalTo(27)
        }
        bottleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(CGSize(width: 69, height: 100))
        }
        fillContentView.snp.makeConstraints {
            $0.bottom.equalTo(bottleView).offset(-14.8)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(fillHeight)
            $0.width.equalTo(38)
        }
        fillColorView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(fillHeight)
        }
        slider.snp.makeConstraints {
            $0.top.equalTo(amountLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(bottleView.snp.leading).offset(-10)
            $0.height.equalTo(10)
        }
        minLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(8)
            $0.leading.equalTo(slider)
        }
        maxLabel.snp.makeConstraints {
            $0.trailing.equalTo(slider).offset(10)
            $0.top.equalTo(minLabel)
        }
        startTimeView.snp.makeConstraints {
            $0.top.equalTo(minLabel.snp.bottom).offset(42)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        startTimeControl.snp.makeConstraints {
            $0.bottom.equalTo(startTimeView)
            $0.leading.trailing.equalTo(startTimeView)
            $0.height.equalTo(48)
        }
        milkTypeView.snp.makeConstraints {
            $0.top.equalTo(startTimeView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        milkTypeControl.snp.makeConstraints {
            $0.bottom.equalTo(milkTypeView)
            $0.leading.trailing.equalTo(milkTypeView)
            $0.height.equalTo(48)
        }
        addNoteView.snp.makeConstraints {
            $0.top.equalTo(milkTypeView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }

        slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        startTimeControl.addTarget(self, action: #selector(didTapTimeAction), for: .touchUpInside)
        milkTypeControl.addTarget(self, action: #selector(didTapMilkTypeAction), for: .touchUpInside)
        updateUI()
    }

    func updateUI() {
        updateSliderUI()
        startTimeView.text = viewModel.editModel.startTime.feedStartTimeString()
        milkTypeView.text = viewModel.editModel.milkType?.title
    }

    private func updateSliderUI() {
        slider.maximumValue = Float(viewModel.maxValue)
        if UserDefaults.standard.isMetricUnit {
            amountLabel.attributedText = "Amount: \(Int(slider.value)) \(unitText)".attributedText(.mulishLink1)
        } else {
            if slider.value == 0 {
                amountLabel.attributedText = "Amount: 0 \(unitText)".attributedText(.mulishLink1)
            } else {
                let value = String(format: "%.2f", slider.value)
                amountLabel.attributedText = "Amount: \(value) \(unitText)".attributedText(.mulishLink1)
            }
        }

        minLabel.attributedText = "0 \(unitText)".attributedText(.mulishBody2)
        maxLabel.attributedText = "\(Int(viewModel.maxValue)) \(unitText)".attributedText(.mulishBody2)
        let percent: CGFloat = CGFloat(slider.value / Float(viewModel.maxValue))
        fillColorView.snp.updateConstraints {
            $0.height.equalTo(percent * fillHeight)
        }
    }

    @objc private func sliderValueChange() {
        let newValue = roundToNearestHalf(number: Double(slider.value), spacing: viewModel.slideSpacing)
        slider.value = Float(newValue)
        viewModel.editModel.amountModel.amount = newValue
        updateUI()
        delegate?.modelDidUpdate()
    }

    func resetUI() {
        slider.maximumValue = Float(viewModel.maxValue)
        slider.value = Float(viewModel.editModel.amountModel.amount)
        addNoteView.note = viewModel.editModel.note
        updateUI()
    }

    private func roundToNearestHalf(number: Double, spacing: Double) -> Double {
        let roundedValue = round(number / spacing) * spacing
        return roundedValue
    }

    @objc private func didTapTimeAction() {
        endEditing(true)
        timePickerView.show()
        timePickerView.date = viewModel.editModel.startTime
    }

    @objc private func didTapMilkTypeAction() {
        endEditing(true)
        if let type = viewModel.editModel.milkType,
           let row = (milkTypePicker.adapter as? TBBottleMileTypePickerAdapter)?.dataSource.firstIndex(where: { $0 == type}) {
            milkTypePicker.currentSelect = row
        } else {
            milkTypePicker.currentSelect  = 0
        }
        milkTypePicker.showPicker()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(true)
    }
}

// MARK: - TBDatePickerViewDelegate
extension TBBottleToolView: TBDatePickerViewDelegate {
    func didSelect(view: TBDatePickerView, date: Date) {
        viewModel.editModel.startTime = date
        updateUI()
        delegate?.modelDidUpdate()
    }
}

// MARK: - TBOldPickerViewDelegate
extension TBBottleToolView: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        guard let type = (view.adapter as? TBBottleMileTypePickerAdapter)?.dataSource[safe: index] else { return }
        viewModel.editModel.milkType = type
        updateUI()
        delegate?.modelDidUpdate()
    }
}

// MARK: - TBAddNoteTextViewDelegate
extension TBBottleToolView: TBAddNoteTextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.editModel.note = textView.text
        delegate?.modelDidUpdate()
    }
}
