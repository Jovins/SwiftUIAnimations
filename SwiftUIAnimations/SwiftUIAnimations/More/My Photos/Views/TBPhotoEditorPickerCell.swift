import UIKit

protocol TBPhotoEditorPickerCellDelegate: class {
    func showPicker(indexPath: IndexPath?)
}

final class TBPhotoEditorPickerCell: UITableViewCell {
    weak var delegate: TBPhotoEditorPickerCellDelegate?
    private let tbtextField: TBTextField = {
        let field = TBTextField()
        field.rightButtonSetImage(image: TBIconList.caretDown.image(), for: .normal)
        return field
    }()
    private let titleLabel = UILabel()
    let contentTextField = UITextField()

    private var indexPath: IndexPath?
    static let cellHeight = 88.0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(tbtextField)
        tbtextField.isUserInteractionEnabled = false
        tbtextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(88-16)
        }

        let control = UIControl()
        control.addTarget(self, action: #selector(didTapControl), for: .touchUpInside)
        contentView.addSubview(control)
        control.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(88-16-20)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupCell(title: String, content: String, indexPath: IndexPath? = nil) {
        tbtextField.hintText = title
        tbtextField.text = content
        self.indexPath = indexPath
    }

    func maskTextField(_ shouldMask: Bool = true) {
        tbtextField.maskInputContent(shouldMask)
    }

    @objc private func didTapControl() {
        delegate?.showPicker(indexPath: self.indexPath)
    }
}
