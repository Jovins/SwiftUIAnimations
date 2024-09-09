import UIKit
import RxSwift

final class TBFeedingTrackerCardDiapersCell: TBFeedingTrackerCardBaseCell {

    private let disposeBag = DisposeBag()
    private let subtitleLabel: UILabel = UILabel()
    private let contentStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    private let topStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    private let bottomStackview: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    private let peeView = TBDiapersItemView(diaperName: "Pee")
    private let pooView = TBDiapersItemView(diaperName: "Poo")
    private let mixedView = TBDiapersItemView(diaperName: "Mixed")
    private let dryView = TBDiapersItemView(diaperName: "Dry")

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
        [peeView, pooView].forEach(topStackView.addArrangedSubview)
        [mixedView, dryView].forEach(bottomStackview.addArrangedSubview)
        [subtitleLabel, topStackView, bottomStackview].forEach(contentStackView.addArrangedSubview)
    }

    func setData(models: [TBDiapersModel], type: FeedingTrackerToolType?) {

        if let type {
            titleLabel.attributedText = type.title.attributedText(.mulishLink2)
            updateImageView(type: type)
        }

        let diapers = models.filter({ $0.startTime.isSameDayAs(otherDate: Date()) })
        guard !diapers.isEmpty else {
            subtitleLabel.isHidden = false
            topStackView.isHidden = true
            bottomStackview.isHidden = true
            subtitleLabel.attributedText = "Add your first entry".attributedText(.mulishBody4Italic)
            return
        }
        subtitleLabel.isHidden = true
        topStackView.isHidden = false
        bottomStackview.isHidden = false
        let pees = diapers.filter({ TBDiapersButtton.TBDiapersButttonType(rawValue: $0.diaperName ?? "") == .Pee })
        let poos = diapers.filter({ TBDiapersButtton.TBDiapersButttonType(rawValue: $0.diaperName ?? "") == .Poo })
        let mixeds = diapers.filter({ TBDiapersButtton.TBDiapersButttonType(rawValue: $0.diaperName ?? "") == .Mixed })
        let drys = diapers.filter({ TBDiapersButtton.TBDiapersButttonType(rawValue: $0.diaperName ?? "") == .Dry })
        peeView.update(with: pees.isEmpty ? "x0" : "x\(pees.count)")
        pooView.update(with: poos.isEmpty ? "x0" : "x\(poos.count)")
        mixedView.update(with: mixeds.isEmpty ? "x0" : "x\(mixeds.count)")
        dryView.update(with: drys.isEmpty ? "x0" : "x\(drys.count)")
    }
}
