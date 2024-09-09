import UIKit

final class TBContractionCounterInfoCell: UITableViewCell {
    private  let textView: UITextView = {
        let view = UITextView()
        let text = "Your body naturally goes through a few different stages of labor before you welcome baby into the world.\n\nOne telltale sign that your experiencing labor: contractions. There are different types of contractions, and not all are associated with labor. Take, for instance, Braxton-Hicks contractions, which are irregular, non-painful contractions that can start as early as six weeks into your pregnancy and last until your delivery date. Then there are preterm contractions, mildly uncomfortable to potentially more painful cramping that occur at regular intervals before the 37th week of pregnancy, but doesn’t necessarily mean you’re going into labor.\n\nIn the early stages of true labor, contractions typically last about 30 to 45 seconds, with anywhere from 5 to 30 minutes of rest between contractions. In early labor, you may feel discomfort or just a squeezing feeling in your abdomen. No need to panic to rush to the hospital or birthing center just yet, but start preparing yourself, especially if your contractions grow more intense, last longer or happen closer together.\n\nIn active labor, contractions typically last about 45 to 60 seconds, with 3 to 5 minutes of rest between each one. That crampy, painful feeling in your back and lower belly will feel more intense over time. If you haven’t already, head to the hospital or birthing center now once your contractions become about 5 minutes apart."
        view.attributedText = text.attributedText(.mulishBody3)
        view.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        view.isEditable = false
        view.isSelectable = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(textView)
        textView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(UIDevice.width - 40)
            $0.bottom.equalToSuperview()
        }
    }
}
