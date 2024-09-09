import UIKit

class FoodSafetyCategoryTableViewCell: UITableViewCell {
    let nameLabel = UILabel(frame: CGRect.zero)
    let categoryImageView = UIImageView(frame: CGRect.zero)
    let rightArrowImageView = UIImageView(image: TBIconList.caretRight.image(sizeOption: .normal, color: .GlobalTextPrimary))
    private let separatorView = UIView()
    private let selectView: UIView = {
        let view = UIView()
        view.backgroundColor = .Beige
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .GlobalBackgroundPrimary

        layoutMargins = .zero
        separatorInset = .zero
        selectedBackgroundView = selectView
        separatorView.backgroundColor = .DarkGray300

        categoryImageView.backgroundColor = UIColor.tb_lines()
        categoryImageView.contentMode = .scaleAspectFill
        categoryImageView.layer.masksToBounds = true

        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byTruncatingTail

        [categoryImageView, nameLabel, separatorView, rightArrowImageView].forEach { addSubview($0)}
        setupConstraints()
    }

    private func setupConstraints() {
        categoryImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(74)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(categoryImageView)
            make.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            make.trailing.equalTo(rightArrowImageView.snp.leading).offset(8)
        }

        rightArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(TBIconList.SizeOption.normal.size)
            make.centerY.equalTo(categoryImageView)
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.trailing.leading.equalToSuperview()
        }
    }

    func setup(category: TBFoodSafetyCategory) {
        nameLabel.attributedText = category.name?.attributedText(.mulishLink2,
                                                                 lineBreakMode: .byWordWrapping)
        categoryImageView.image = nil
        if let imageURL = URL(string: category.imageUrl ?? "") {
            categoryImageView.sd_setImage(with: imageURL)
        }
    }
}
