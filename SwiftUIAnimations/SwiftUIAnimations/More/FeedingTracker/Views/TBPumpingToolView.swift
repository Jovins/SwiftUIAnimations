import Foundation
import SnapKit
import RxSwift

protocol TBPumpingToolViewDelegate: AnyObject {
    func modelDidUpdate()
}

final class TBPumpingToolView: UIView {
    private let leftAmountLabel: UILabel = UILabel()
    private let rightAmountLabel: UILabel = UILabel()
    private let leftLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Left".attributedText(.mulishLink1)
        return label
    }()
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Right".attributedText(.mulishLink1)
        return label
    }()
    private let lastSideLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Last Side".attributedText(.mulishBody4, alignment: .center)
        label.cornerRadius = 6
        label.backgroundColor = .Chartreuse
        label.isHidden = true
        return label
    }()
    private let leftSlider: TBBottleSlider = {
        let view = TBBottleSlider()
        view.maximumTrackTintColor = .clear
        view.minimumTrackTintColor = .clear
        view.thumbTintColor = .Teal
        return view
    }()
    private let leftProgress: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.progressTintColor = .Aqua
        view.trackTintColor = .DarkGray300
        view.cornerRadius = 5
        return view
    }()
    private let rightSlider: TBBottleSlider = {
        let view = TBBottleSlider()
        view.maximumTrackTintColor = .clear
        view.minimumTrackTintColor = .clear
        view.thumbTintColor = .Teal
        return view
    }()
    private let rightProgress: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progressTintColor = .Aqua
        view.trackTintColor = .DarkGray300
        view.cornerRadius = 5
        return view
    }()
    private var unitText: String {
        if UserDefaults.standard.isMetricUnit {
            return "ml"
        } else {
            return "oz."
        }
    }
    private let breastPumpIcon: UIImageView = UIImageView(image: UIImage(named: "Breast Pump"))
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 24
        view.distribution = .equalSpacing
        view.alignment = .center
        return view
    }()
    private let measureLabels: [TBPumpingMeasureLabel] = [TBPumpingMeasureLabel(),
                                                          TBPumpingMeasureLabel(),
                                                          TBPumpingMeasureLabel(),
                                                          TBPumpingMeasureLabel(),
                                                          TBPumpingMeasureLabel(),
                                                          TBPumpingMeasureLabel(),
                                                          TBPumpingMeasureLabel()]
    private let startTimeView: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Session Start Time"
        textField.rightButtonSetImage(image: UIImage.calendar(color: .Magenta), backgroundColor: .DarkGray200, for: .normal)
        return textField
    }()
    private let startTimeControl = UIControl()
    private let lastBreastView: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Last Breast"
        textField.placeholder = "Choose last breast"
        textField.rightButtonSetImage(image: TBIconList.caretDown.image(color: .Navy), for: .normal)
        return textField
    }()
    private let lastBreastControl = UIControl()
    private lazy var lastBreastPicker: TBOldPickerView = {
        let adapter = TBPickerDefaultAdapter()
        let view = TBOldPickerView()
        view.adapter = TBFeedingLastBreastPickerAdapter()
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
    let viewModel: TBPumpingToolViewModel = TBPumpingToolViewModel()
    weak var delegate: TBPumpingToolViewDelegate?
    private let disposeBag: DisposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [breastPumpIcon, leftAmountLabel, rightAmountLabel, leftLabel, rightLabel,
         leftProgress, leftSlider, rightProgress, rightSlider, stackView,
         startTimeView, startTimeControl, lastBreastView,
         lastBreastControl, addNoteView, lastSideLabel].forEach(addSubview)
        breastPumpIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(8)
            $0.size.equalTo(24)
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(breastPumpIcon.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        measureLabels.enumerated().forEach { (index, label) in
            stackView.addArrangedSubview(label)
            label.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(24)
            }
            if index == 0 {
                label.snp.makeConstraints {
                    $0.top.equalToSuperview()
                }
            }
            if (index + 1) == measureLabels.count {
                label.snp.makeConstraints {
                    $0.bottom.equalToSuperview()
                }
            }
        }
        leftLabel.snp.makeConstraints {
            $0.trailing.equalTo(breastPumpIcon.snp.leading).offset(-96)
            $0.top.equalToSuperview().inset(8)
        }
        rightLabel.snp.makeConstraints {
            $0.leading.equalTo(breastPumpIcon.snp.trailing).offset(92)
            $0.top.equalToSuperview().inset(8)
        }
        leftSlider.snp.makeConstraints {
            $0.centerX.equalTo(leftLabel).offset(+2)
            $0.centerY.equalTo(stackView)
            $0.size.equalTo(CGSize(width: 292, height: 10))
        }
        leftProgress.snp.makeConstraints {
            $0.centerX.equalTo(leftLabel)
            $0.centerY.equalTo(leftSlider)
            $0.size.equalTo(CGSize(width: 292, height: 10))
        }
        leftProgress.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        leftSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        rightSlider.snp.makeConstraints {
            $0.centerX.equalTo(rightLabel).offset(+2)
            $0.centerY.equalTo(stackView)
            $0.size.equalTo(CGSize(width: 292, height: 10))
        }
        rightSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        rightProgress.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        rightProgress.snp.makeConstraints {
            $0.centerX.equalTo(rightLabel)
            $0.centerY.equalTo(rightSlider)
            $0.size.equalTo(CGSize(width: 292, height: 10))
        }
        leftAmountLabel.snp.makeConstraints {
            $0.centerX.equalTo(leftLabel)
            $0.top.equalTo(leftLabel.snp.bottom).offset(325)
        }
        rightAmountLabel.snp.makeConstraints {
            $0.centerX.equalTo(rightLabel)
            $0.top.equalTo(rightLabel.snp.bottom).offset(325)
        }
        startTimeView.snp.makeConstraints {
            $0.top.equalTo(leftAmountLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        startTimeControl.snp.makeConstraints {
            $0.bottom.equalTo(startTimeView)
            $0.leading.trailing.equalTo(startTimeView)
            $0.height.equalTo(48)
        }
        lastBreastView.snp.makeConstraints {
            $0.top.equalTo(startTimeView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        lastBreastControl.snp.makeConstraints {
            $0.bottom.equalTo(lastBreastView)
            $0.leading.trailing.equalTo(lastBreastView)
            $0.height.equalTo(48)
        }
        addNoteView.snp.makeConstraints {
            $0.top.equalTo(lastBreastView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        leftSlider.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
        rightSlider.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
        startTimeControl.addTarget(self, action: #selector(didTapTimeAction), for: .touchUpInside)
        lastBreastControl.addTarget(self, action: #selector(didTapLastBreastAction), for: .touchUpInside)
        bindData()
        updateUI()
    }

    private func bindData() {
        viewModel.modelsUpdateSubject.subscribe(on: MainScheduler.instance).subscribe {[weak self] _ in
            guard let self else { return }
            self.updateLastSideUI()
        } onError: { _ in
        }.disposed(by: disposeBag)
    }

    private func updateLastSideUI() {
        guard viewModel.defaultModel == nil,
              leftSlider.value == 0,
              rightSlider.value == 0,
              let model = TBPumpRepository.shared.models.filter({ !$0.archived }).first else {
            lastSideLabel.isHidden = true
            return
        }
        if let side = model.lastSide {
            displayAt(side: side)
        } else {
            if model.leftAmountModel.amount != 0,
               model.rightAmountModel.amount == 0 {
                displayAt(side: .left)
            }
            if model.rightAmountModel.amount != 0,
               model.leftAmountModel.amount == 0 {
                displayAt(side: .right)
            }
        }

        func displayAt(side: TBNursingModel.Side) {
            lastSideLabel.isHidden = false
            lastSideLabel.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 60, height: 20))
            }
            switch side {
            case .left:
                lastSideLabel.snp.makeConstraints {
                    $0.centerX.equalTo(leftLabel)
                    $0.top.equalTo(leftLabel.snp.bottom).offset(4)
                }
            case .right:
                lastSideLabel.snp.makeConstraints {
                    $0.centerX.equalTo(rightLabel)
                    $0.top.equalTo(rightLabel.snp.bottom).offset(4)
                }
            }
        }
    }

    private func updateUI() {
        updateSliderUI(slider: leftSlider, label: leftAmountLabel)
        updateSliderUI(slider: rightSlider, label: rightAmountLabel)
        startTimeView.text = viewModel.editModel.startTime.feedStartTimeString()
        lastBreastView.text = viewModel.lastBreastViewEnable ? viewModel.editModel.lastSide?.normalTitle : nil
        lastBreastView.isEnable = viewModel.lastBreastViewEnable
        updateLastSideUI()

        measureLabels.enumerated().forEach { index, label in
            if UserDefaults.standard.isMetricUnit {
                label.measureLabel.attributedText = "\(viewModel.measureMLs.reversed()[index]) ml".attributedText(.mulishBody2, alignment: .center)
            } else {
                label.measureLabel.attributedText = "\(viewModel.measureOZs.reversed()[index]) oz.".attributedText(.mulishBody2, alignment: .center)
            }
        }
    }

    func resetUI() {
        leftSlider.maximumValue = Float(viewModel.maxValue)
        rightSlider.maximumValue = Float(viewModel.maxValue)
        leftSlider.value = Float(viewModel.editModel.leftAmountModel.amount)
        leftProgress.progress = leftSlider.value / leftSlider.maximumValue
        rightSlider.value = Float(viewModel.editModel.rightAmountModel.amount)
        rightProgress.progress = rightSlider.value / rightSlider.maximumValue
        addNoteView.note = viewModel.editModel.note
        updateUI()
    }

    private func updateSliderUI(slider: TBBottleSlider, label: UILabel) {
        slider.maximumValue = Float(viewModel.maxValue)
        if UserDefaults.standard.isMetricUnit {
            label.attributedText = "\(Int(slider.value)) \(unitText)".attributedText(.mulishLink1)
        } else {
            if slider.value == 0 {
                label.attributedText = "0 \(unitText)".attributedText(.mulishLink1)
            } else {
                let value = String(format: "%.2f", slider.value)
                label.attributedText = "\(value) \(unitText)".attributedText(.mulishLink1)
            }
        }
    }

    @objc private func sliderValueChange(sender: TBBottleSlider) {
        let newValue = roundToNearestHalf(number: Double(sender.value), spacing: viewModel.slideSpacing)
        sender.value = Float(newValue)
        switch sender {
        case leftSlider:
            leftProgress.progress = sender.value / sender.maximumValue
            viewModel.editModel.leftAmountModel.amount = newValue
        case rightSlider:
            rightProgress.progress = sender.value / sender.maximumValue
            viewModel.editModel.rightAmountModel.amount = newValue
        default:
            break
        }
        updateUI()
        delegate?.modelDidUpdate()
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

    @objc private func didTapLastBreastAction() {
        endEditing(true)
        guard lastBreastView.isEnable else { return }
        if let type = viewModel.editModel.lastSide,
           let row = (lastBreastPicker.adapter as? TBFeedingLastBreastPickerAdapter)?.dataSource.firstIndex(where: { $0 == type}) {
            lastBreastPicker.currentSelect = row
        } else {
            lastBreastPicker.currentSelect  = 0
        }
        lastBreastPicker.showPicker()
    }
}

// MARK: - TBOldPickerViewDelegate
extension TBPumpingToolView: TBOldPickerViewDelegate {
    func didSelect(view: TBOldPickerView, index: Int) {
        guard let type = (view.adapter as? TBFeedingLastBreastPickerAdapter)?.dataSource[safe: index] else { return }
        viewModel.editModel.lastSide = type
        updateUI()
        delegate?.modelDidUpdate()
    }
}

// MARK: - TBAddNoteTextViewDelegate
extension TBPumpingToolView: TBAddNoteTextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.editModel.note = textView.text
        delegate?.modelDidUpdate()
    }
}

// MARK: - TBDatePickerViewDelegate
extension TBPumpingToolView: TBDatePickerViewDelegate {
    func didSelect(view: TBDatePickerView, date: Date) {
        viewModel.editModel.startTime = date.deleteSeconds()
        updateUI()
        delegate?.modelDidUpdate()
    }
}

private class TBPumpingMeasureLabel: UIView {
    let measureLabel: UILabel = UILabel()
    private let leftLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray400
        return view
    }()
    private let rightLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray400
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
        [leftLine, measureLabel, rightLine].forEach(addSubview)
        leftLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalTo(36)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(measureLabel.snp.leading).offset(-8)
        }
        measureLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        rightLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalTo(36)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(measureLabel.snp.trailing).offset(8)
        }
    }
}
