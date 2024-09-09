import UIKit
import RxSwift

final class TBFeedingTrackerCardBottleCell: TBFeedingTrackerCardBaseCell {

    private let disposeBag = DisposeBag()
    private let contentStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    private let subtitleLabel: UILabel = UILabel()
    private let subbreastLabel: UILabel = UILabel()
    private let breastLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .Aqua
        label.cornerRadius = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .Blush
        borderWidth = 1
        borderColor = UIColor.GlobalBackgroundSecondary
        cornerRadius = 8
        [titleLabel, addIconImageView, feedImageView, contentStackView].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        addIconImageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(32)
        }
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.lessThanOrEqualTo(addIconImageView.snp.top)
        }
        subbreastLabel.addSubview(breastLabel)
        subbreastLabel.snp.makeConstraints {
            $0.height.equalTo(25)
        }
        [subbreastLabel, subtitleLabel].forEach(contentStackView.addArrangedSubview)
    }

    func setData(model: TBBottleModel?, type: FeedingTrackerToolType?) {

        if let type {
            titleLabel.attributedText = type.title.attributedText(.mulishLink2)
            updateImageView(type: type)
        }

        guard let model else {
            subbreastLabel.isHidden = true
            subtitleLabel.attributedText = "Add your first entry".attributedText(.mulishBody4Italic)
            return
        }
        subbreastLabel.isHidden = false
        let attributedText = "\(String(format: "%.2f", model.amountModel.amount)) \((UserDefaults.standard.isMetricUnit ? "ML" : "OZ."))".attributedText(.mulishOverline2, alignment: .center)
        let width = (attributedText?.width(withConstrainedHeight: 17) ?? 0) + 8
        breastLabel.attributedText = attributedText
        breastLabel.frame = CGRect(x: 0, y: 0, width: width, height: 25)
        if let dateString = getDateString(date: model.startTime) {
            subtitleLabel.attributedText = dateString.attributedText(.mulishBody4)
        }
    }
}
