import UIKit
import SnapKit
import FullStory

protocol TBPhotoEditorInputDescriptionCellDelegate: class {
    func updateContent(content: String)
}

final class TBPhotoEditorInputDescriptionCell: UITableViewCell {
    static let cellHeight = 218.0
    static func cellHeight(with text: String?) -> CGFloat {
        guard let text = text,
              let attributedText = text.attributedText(.mulishBody2, foregroundColor: .DarkGray600)
        else {return 0}

        let constraintRect = CGSize(width: UIDevice.width-40.0, height: .greatestFiniteMagnitude)
        let boundingBox = attributedText.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin], context: nil)
        return CGFloat(boundingBox.size.height + 60 + 6) // MARK: 6 for textView inside spacing
    }
    private var titleLeftConstraint: Constraint?
    var assistantView: MemberFeedbackPopupAssistantView? {
        didSet {
            feedbackTextView.inputAccessoryView = assistantView
        }
    }
    weak var delegate: TBPhotoEditorInputDescriptionCellDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Description (optional)".attributedText(.mulishBody3)
        return label
    }()
    private let placeholderLabel: UILabel = UILabel()
    private let feedbackTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.Navy.cgColor
        textView.layer.cornerRadius = 2
        textView.textColor = .GlobalTextPrimary
        textView.font = TBFontType.mulishBody2.font
        FS.mask(views: textView)
        return textView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        feedbackTextView.delegate = self
        [titleLabel, placeholderLabel, feedbackTextView].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(20)
            titleLeftConstraint = $0.left.equalToSuperview().offset(24).constraint
        }
        feedbackTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(158)
        }
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(feedbackTextView).offset(12)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(text: String?, placeholderText: String?) {
        placeholderLabel.attributedText = placeholderText?.attributedText(.mulishBody3, foregroundColor: .DarkGray600)
        guard let text = text,
              !text.isEmpty else { return }
        placeholderLabel.isHidden = true
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 14, left: 4, bottom: 12, right: 4)
        feedbackTextView.attributedText = text.attributedText(.mulishBody2)
    }

    func readOnly(text: String, isShow: Bool) {
        titleLabel.isHidden = !isShow
        titleLabel.attributedText = "Description:".attributedText(.mulishLink3, foregroundColor: .DarkGray600)
        titleLeftConstraint?.update(offset: 20)

        placeholderLabel.removeFromSuperview()

        feedbackTextView.isScrollEnabled = false
        feedbackTextView.isHidden = !isShow
        feedbackTextView.isEditable = false
        feedbackTextView.layer.borderWidth = 0
        feedbackTextView.textContainerInset = .zero
        feedbackTextView.textContainer.lineFragmentPadding = 0
        feedbackTextView.attributedText = text.attributedText(.mulishBody2)
        feedbackTextView.snp.remakeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.bottom.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

extension TBPhotoEditorInputDescriptionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.updateContent(content: textView.text)
    }
}
