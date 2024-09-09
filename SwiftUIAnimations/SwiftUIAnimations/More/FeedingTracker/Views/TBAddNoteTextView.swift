import UIKit

protocol TBAddNoteTextViewDelegate: AnyObject {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewDidEndEditing(_ textView: UITextView)
    func textViewDidChange(_ textView: UITextView)
    func textViewDidChangeSelection(_ textView: UITextView)
    func textView(textView: UITextView, moreThanMaxCharacter isEnabled: Bool)
}

extension TBAddNoteTextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {}
    func textViewDidEndEditing(_ textView: UITextView) {}
    func textViewDidChange(_ textView: UITextView) {}
    func textViewDidChangeSelection(_ textView: UITextView) {}
    func textView(textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {}
}

final class TBAddNoteTextView: UIView {

    weak var delegate: TBAddNoteTextViewDelegate?
    private(set) var moreThanMaxCharacter: Bool = false
    var titleLabelText: String? {
        get {
            titleLabel.attributedText?.string
        }
        set {
            titleLabel.attributedText = newValue?.attributedText(.mulishLink3)
        }
    }
    var note: String? {
        get {
            textView.text
        }
        set {
            textView.text = newValue
            characterCount = newValue?.count ?? 0
            if characterCount <= maxCharacterCount {
                moreThanMaxCharacter = false
            }
            updateTextViewAppearance()
        }
    }

    private lazy var assistantView: MemberFeedbackPopupAssistantView = {
        let view = MemberFeedbackPopupAssistantView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.width, height: 40)))
        view.donebutton.addTarget(self, action: #selector(didTapAssistantDone), for: .touchUpInside)
        return view
    }()

    private let titleLabel: UILabel = UILabel()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 2
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.Navy.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 28, right: 8)
        textView.font = .mulishBody2
        textView.textColor = .GlobalTextPrimary
        textView.delegate = self
        textView.inputAccessoryView = assistantView
        return textView
    }()
    private var scrollView: UIScrollView? {
        var parentView = self.superview
        while let next = parentView?.superview {
            if let scrollView = next as? UIScrollView {
                return scrollView
            }
            parentView = next
        }
        return nil
    }
    private let tipsLabel: UILabel = UILabel()
    private let countLabel: UILabel = UILabel()
    private var lastOffset: CGPoint = .zero
    private let maxCharacterCount: Int = 150
    private var characterCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateTextViewAppearance()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [titleLabel, textView, tipsLabel, countLabel].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview()
        }
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(4)
            $0.bottom.equalToSuperview()
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview()
        }
    }

    private func updateTextViewAppearance() {
        let isHighlighted = characterCount > maxCharacterCount
        titleLabel.attributedText = titleLabelText?.attributedText(.mulishLink3, foregroundColor: isHighlighted ? .validationRed : .GlobalTextPrimary)
        textView.borderColor = isHighlighted ? .validationRed : .GlobalTextPrimary
        tipsLabel.attributedText = "Please limit your input to \(maxCharacterCount) characters or less.".attributedText(.mulishBody4, foregroundColor: isHighlighted ? .validationRed : .DarkGray600)
        countLabel.attributedText = "\(characterCount)/\(maxCharacterCount)".attributedText(.mulishBody4, foregroundColor: isHighlighted ? .validationRed : .DarkGray600, alignment: .right)
    }

    @objc private func keyboardWasShown(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let scrollView else {
            return
        }
        var noteFrame: CGRect = .zero
        if let window = AppDelegate.sharedInstance().window, frame != .zero {
            noteFrame = convert(bounds, to: window)
        }
        lastOffset = scrollView.contentOffset
        var offset = noteFrame.maxY - keyboardFrame.minY
        if offset > 0 {
            offset += lastOffset.y + 16
            scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
    }

    @objc private func keyboardWillBeHidden(_ notification: Notification) {
        guard let scrollView else { return }
        scrollView.setContentOffset(lastOffset, animated: true)
    }

    @objc private func didTapAssistantDone() {
        endEditing(true)
    }
}

// MARK: - UITextViewDelegate
extension TBAddNoteTextView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { return true }
        let addingCount = text.count - range.length
        characterCount = self.textView.text.count + addingCount
        updateTextViewAppearance()
        moreThanMaxCharacter = characterCount > maxCharacterCount
        delegate?.textView(textView: textView, moreThanMaxCharacter: characterCount <= maxCharacterCount)
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing(textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection(textView)
    }
}
