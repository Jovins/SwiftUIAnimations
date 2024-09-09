import UIKit

protocol TBPhotoDownloadProgressBarDelegate: AnyObject {
    func didTapClose(progressBar: TBPhotoDownloadProgressBar)
}

final class TBPhotoDownloadProgressBar: UIView {

    weak var delegate: TBPhotoDownloadProgressBarDelegate?
    private let backMask: UIView = {
        let view = UIView()
        view.backgroundColor = .Black.withAlphaComponent(0.5)
        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(TBIconList.close.image(sizeOption: .normal), for: .normal)
        button.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        return button
    }()
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.progressTintColor = .CornFlower
        progressBar.trackTintColor = .GlobalBackgroundPrimary
        return progressBar
    }()
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Downloading".attributedText(.mulishBody4)
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
        self.backgroundColor = .GlobalBackgroundPrimary
        closeButton.addTarget(self, action: #selector(didTapCloseButton(sender:)), for: .touchUpInside)
        [closeButton, progressBar, bottomLabel].forEach(addSubview)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.right.equalToSuperview().inset(12)
            $0.size.equalTo(CGSize(width: 16, height: 16))
        }
        progressBar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(36)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(4)
        }
        bottomLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(progressBar.snp.bottom).offset(12)
        }
    }

    @objc private func didTapCloseButton(sender: UIButton) {
        delegate?.didTapClose(progressBar: self)
    }

    func updateProgress(_ progress: Float) {
        progressBar.setProgress(progress, animated: true)
    }

    func setHidden(_ hidden: Bool) {
        [self, backMask].forEach({ $0.isHidden = hidden })
    }

    func show() {
        progressBar.progress = 0
        setHidden(false)
        guard let window = UIApplication.shared.keyWindow else { return }
        [backMask, self].forEach(window.addSubview)
        let bottomSafeAreaHeight = window.safeAreaInsets.bottom
        self.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(76 + bottomSafeAreaHeight)
        }
        backMask.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func dismiss() {
        [self, backMask].forEach({ $0.removeFromSuperview() })
    }
}
