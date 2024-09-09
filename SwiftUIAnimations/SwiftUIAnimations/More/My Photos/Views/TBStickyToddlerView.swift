import Foundation
import UIKit

class TBStickyToddlerView: UIView {
    private let titleLabel: UILabel = UILabel()
    private let caretDownImageView: UIImageView = UIImageView(image: TBIconList.caretDown.image(sizeOption: .small, color: .Navy))

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .Beige
        addShadow(with: UIColor.teal500, alpha: 0.1, radius: 4, offset: CGSize(width: 0, height: 2))
        [titleLabel, caretDownImageView].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.width.equalTo(69)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        caretDownImageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
        }
    }

    func setup(model: TBPhotosModel?) {
        guard let year = model?.year else { return }
        let yearString = "Year".pluralize(with: year)
        titleLabel.attributedText = "\(year) \(yearString) Old".attributedText(.mulishLink4, alignment: .right)
    }
}
