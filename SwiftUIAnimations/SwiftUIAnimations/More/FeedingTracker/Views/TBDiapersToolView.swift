import UIKit
import RxSwift

protocol TBDiapersToolViewDelegate: AnyObject {
    func toolView(_ toolView: TBDiapersToolView, didSelectDiaper type: TBDiapersButtton.TBDiapersButttonType)
    func toolView(_ toolView: TBDiapersToolView, didSelectStartTime time: Date)
    func toolView(_ toolView: TBDiapersToolView, didChange text: String)
    func textView(_ textView: UITextView, moreThanMaxCharacter isEnabled: Bool)
}

extension TBDiapersToolViewDelegate {
    func toolView(_ toolView: TBDiapersToolView, didSelectDiaper type: TBDiapersButtton.TBDiapersButttonType) {}
    func toolView(_ toolView: TBDiapersToolView, didSelectStartTime time: Date) {}
    func toolView(_ toolView: TBDiapersToolView, didChange text: String) {}
    func textView(_ textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {}
}

final class TBDiapersToolView: UIView {

    var model: TBDiapersModel? {
        didSet {
            setupData()
        }
    }
    weak var delegate: TBDiapersToolViewDelegate?
    private let peeButton: TBDiapersButtton = {
        let button = TBDiapersButtton()
        button.type = .Pee
        return button
    }()
    private let pooButton: TBDiapersButtton = {
        let button = TBDiapersButtton()
        button.type = .Poo
        return button
    }()
    private let mixedButton: TBDiapersButtton = {
        let button = TBDiapersButtton()
        button.type = .Mixed
        return button
    }()
    private let dryButton: TBDiapersButtton = {
        let button = TBDiapersButtton()
        button.type = .Dry
        return button
    }()
    private let timeTextField: TBTextField = {
        let textField = TBTextField()
        textField.isUserInteractionEnabled = false
        textField.hinTextFontType = .mulishLink3
        textField.hintText = "Time"
        textField.rightButtonSetImage(image: UIImage.calendar(color: .Magenta), backgroundColor: .DarkGray200, for: .normal)
        return textField
    }()
    private let timeControl = UIControl()
    private(set) lazy var timePickerView: TBDatePickerView = {
        let picker = TBDatePickerView()
        if #available(iOS 13.4, *) {
            picker.pickerStyle = .wheels
        }
        picker.maximumDate = Date()
        picker.pickerViewHeight = 248
        picker.mode = .dateAndTime
        picker.delegate = self
        return picker
    }()
    private(set) lazy var addNoteView: TBAddNoteTextView = {
        let view = TBAddNoteTextView()
        view.titleLabelText = "Add Note"
        view.delegate = self
        return view
    }()
    private let disposeBag = DisposeBag()
    private var buttonPadding: CGFloat {
        return UIDevice.isPad() ? 48 : 24
    }
    private var buttonTopSpace: CGFloat {
        return UIDevice.isPad() ? 64 : 32
    }
    private(set) var lastDiapersButton: TBDiapersButtton?
    private(set) var startTime: Date = Date()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(true)
    }

    private func setupUI() {
        backgroundColor = .OffWhite
        [peeButton, pooButton, mixedButton, dryButton, timeTextField, addNoteView, timeControl].forEach(addSubview)
        peeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(self.snp.centerX).offset(-buttonPadding)
            $0.size.equalTo(117)
        }
        pooButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(self.snp.centerX).offset(buttonPadding)
            $0.size.equalTo(117)
        }
        mixedButton.snp.makeConstraints {
            $0.top.equalTo(peeButton.snp.bottom).offset(buttonTopSpace)
            $0.leading.equalTo(peeButton)
            $0.size.equalTo(117)
        }
        dryButton.snp.makeConstraints {
            $0.top.equalTo(pooButton.snp.bottom).offset(buttonTopSpace)
            $0.leading.equalTo(pooButton)
            $0.size.equalTo(117)
        }
        timeTextField.snp.makeConstraints {
            $0.top.equalTo(mixedButton.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(73)
        }
        timeControl.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(timeTextField)
            $0.height.equalTo(48)
        }
        addNoteView.snp.makeConstraints {
            $0.top.equalTo(timeTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        peeButton.addTarget(self, action: #selector(didTabDiapersButton(sender:)), for: .touchUpInside)
        pooButton.addTarget(self, action: #selector(didTabDiapersButton(sender:)), for: .touchUpInside)
        mixedButton.addTarget(self, action: #selector(didTabDiapersButton(sender:)), for: .touchUpInside)
        dryButton.addTarget(self, action: #selector(didTabDiapersButton(sender:)), for: .touchUpInside)
        timeControl.addTarget(self, action: #selector(didTapTimeAction), for: .touchUpInside)
        updateTimeFieldIfNeed()
    }

    func recoverAppearance() {
        if let lastDiapersButton {
            lastDiapersButton.isSelected = !lastDiapersButton.isSelected
            self.lastDiapersButton = nil
        }
        startTime = Date()
        timeTextField.text = startTime.feedStartTimeString()
        addNoteView.note = ""
    }

    private func setupData() {
        guard let model else { return }
        if let diapersName = model.diaperName {
            let type = [TBDiapersButtton.TBDiapersButttonType.Pee, TBDiapersButtton.TBDiapersButttonType.Poo, TBDiapersButtton.TBDiapersButttonType.Mixed, TBDiapersButtton.TBDiapersButttonType.Dry].first(where: { $0.rawValue == diapersName })
            switch type {
            case .Pee:
                peeButton.isSelected = true
                lastDiapersButton = peeButton
            case .Poo:
                pooButton.isSelected = true
                lastDiapersButton = pooButton
            case .Mixed:
                mixedButton.isSelected = true
                lastDiapersButton = mixedButton
            case .Dry:
                dryButton.isSelected = true
                lastDiapersButton = dryButton
            default:
                break
            }
        }
        self.startTime = model.startTime
        timeTextField.text = startTime.feedStartTimeString()
        if let noteString = model.note {
            addNoteView.note = noteString
        }
    }

    private func updateTimeFieldIfNeed() {
        timeTextField.text = startTime.feedStartTimeString()
        delegate?.toolView(self, didSelectStartTime: startTime)
    }

    @objc private func didTabDiapersButton(sender: TBDiapersButtton) {
        if let lastDiapersButton {
            if lastDiapersButton != sender {
                lastDiapersButton.isSelected = false
                sender.isSelected = true
                self.lastDiapersButton = sender
            }
        } else {
            sender.isSelected = !sender.isSelected
            lastDiapersButton = sender
        }
        delegate?.toolView(self, didSelectDiaper: sender.type)
    }

    @objc private func didTapTimeAction() {
        endEditing(true)
        timePickerView.date = startTime
        timePickerView.show()
    }
}

// MARK: - TBDatePickerViewDelegate
extension TBDiapersToolView: TBDatePickerViewDelegate {
    func didSelect(view: TBDatePickerView, date: Date) {
        if view == timePickerView {
            startTime = date
            updateTimeFieldIfNeed()
        }
    }
}

// MARK: - TBAddNoteTextViewDelegate
extension TBDiapersToolView: TBAddNoteTextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        delegate?.toolView(self, didChange: textView.text)
    }

    func textView(textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {
        delegate?.textView(textView, moreThanMaxCharacter: isEnabled)
    }
}
