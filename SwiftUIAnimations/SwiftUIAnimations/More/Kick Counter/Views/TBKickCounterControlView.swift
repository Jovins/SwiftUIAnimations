import UIKit
import RxSwift

final class TBKickCounterControlView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.attributedText = "Tap the feet when\n your baby kicks!".attributedText(.mulishTitle3)
        return label
    }()
    private let kickCTA: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kickcounter_normal"), for: .normal)
        button.setImage(UIImage(named: "kickcounter_highlight"), for: .highlighted)
        button.addShadow(with: UIColor.black, alpha: 0.1, radius: 8, offset: CGSize(width: 0, height: 2))
        return button
    }()
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Kicks in progress".attributedText(.mulishBody3)
        return label
    }()
    private let progressLeftLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray300
        return view
    }()
    private let progressRightLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray300
        return view
    }()
    private let kicksLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Kicks".attributedText(.mulishBody1, alignment: .center)
        return label
    }()
    private let kicksNumberLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "0".attributedText(.mulishTitle3, alignment: .center)
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Time".attributedText(.mulishBody1, alignment: .center)
        return label
    }()
    private let timeNumberLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "00:00:00".attributedText(.mulishTitle3, alignment: .center)
        return label
    }()
    private let resetCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Reset", for: .normal)
        button.buttonState = .secondary
        button.buttonWidthStyle = .fixed
        button.buttonWidth = 128
        button.isEnabled = false
        return button
    }()
    private let finishCTA: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Finish", for: .normal)
        button.buttonState = .primary
        button.buttonWidthStyle = .fixed
        button.buttonWidth = 128
        button.isEnabled = false
        return button
    }()
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .DarkGray200
        return view
    }()
    private let disposeBag = DisposeBag()
    private var kickCounterTimer: Timer?
    private var viewModel: TBKickCounterControlViewModel

    override init(frame: CGRect) {
        viewModel = TBKickCounterControlViewModel()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        invalidateTimer()
    }

    private func setupUI() {
        [titleLabel, kickCTA, progressView, kicksLabel, kicksNumberLabel,
         timeLabel, timeNumberLabel, resetCTA, finishCTA, bottomLine].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        kickCTA.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(36)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(170)
        }
        progressView.snp.makeConstraints {
            $0.top.equalTo(kickCTA.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        [progressLeftLine, progressLabel, progressRightLine].forEach(progressView.addSubview)
        progressLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        progressLeftLine.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(progressLabel.snp.leading).offset(-8)
            $0.centerY.equalTo(progressLabel)
            $0.height.equalTo(1)
        }
        progressRightLine.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(progressLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(progressLabel)
            $0.height.equalTo(1)
        }
        let kickLayout = UILayoutGuide()
        let timeLayout = UILayoutGuide()
        [kickLayout, timeLayout].forEach(addLayoutGuide)
        kickLayout.snp.makeConstraints {
            $0.top.equalTo(kickCTA.snp.bottom).offset(52)
            $0.trailing.equalTo(snp.centerX).offset(-10)
            $0.size.equalTo(CGSize(width: 158, height: 66))
        }
        timeLayout.snp.makeConstraints {
            $0.top.equalTo(kickCTA.snp.bottom).offset(52)
            $0.leading.equalTo(snp.centerX).offset(10)
            $0.size.equalTo(CGSize(width: 158, height: 66))
        }
        kicksLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(kickLayout)
            $0.height.equalTo(28)
        }
        kicksNumberLabel.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(kickLayout)
            $0.top.equalTo(kicksLabel.snp.bottom).offset(4)
        }
        timeLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(timeLayout)
            $0.height.equalTo(28)
        }
        timeNumberLabel.snp.makeConstraints {
            $0.top.equalTo(kicksLabel.snp.bottom).offset(4)
            $0.centerX.equalTo(timeLabel)
            $0.size.equalTo(CGSize(width: 100, height: 34))
        }
        resetCTA.snp.makeConstraints {
            $0.top.equalTo(kickLayout.snp.bottom).offset(36)
            $0.trailing.equalTo(snp.centerX).offset(-25)
        }
        finishCTA.snp.makeConstraints {
            $0.top.equalTo(timeLayout.snp.bottom).offset(36)
            $0.leading.equalTo(snp.centerX).offset(25)
        }
        bottomLine.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        startKickCounterTimer()
        updateAppearance()
        kickCTA.addTarget(self, action: #selector(didTapKickCTA), for: .touchUpInside)
        resetCTA.addTarget(self, action: #selector(didTapResetCTA(sender:)), for: .touchUpInside)
        finishCTA.addTarget(self, action: #selector(didTapFinishCTA), for: .touchUpInside)
        viewModel.kickCounterSubject
                 .subscribeOn(MainScheduler.instance)
                 .subscribe(onNext: { [weak self] shouldUpdate in
            guard shouldUpdate, let self = self else { return }
            self.updateAppearance()
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    private func updateAppearance() {
        progressView.isHidden = !viewModel.shouldStartToKick
        resetCTA.isEnabled = viewModel.shouldStartToKick
        finishCTA.isEnabled = viewModel.shouldStartToKick
        setup(totalDuration: viewModel.shouldStartToKick ? viewModel.totalDuration : 0)
        let kickString = "Kick".pluralize(with: viewModel.kickCounterCount)
        kicksLabel.attributedText = kickString.attributedText(.mulishBody1, alignment: .center)
        kicksNumberLabel.attributedText = "\(viewModel.kickCounterCount)".attributedText(.mulishTitle3, alignment: .center)
    }

    private func startKickCounterTimer() {
        invalidateTimer()
        let timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.repeatKickCounter()
        })
        kickCounterTimer = timer
        RunLoop.current.add(timer, forMode: .common)
    }

    private func invalidateTimer() {
        guard let timer = kickCounterTimer else { return }
        timer.invalidate()
        kickCounterTimer = nil
    }

    private func setup(totalDuration: TimeInterval) {
        guard let timeString = Date.timeIntervalToString(timeInterval: totalDuration) else { return }
        timeNumberLabel.attributedText = "\(timeString)".attributedText(.mulishTitle3, alignment: .left)
    }

    @objc private func repeatKickCounter() {
        setup(totalDuration: viewModel.totalDuration)
        viewModel.updateKickCounter()
    }

    @objc private func didTapKickCTA() {
        if !viewModel.shouldStartToKick {
            viewModel.shouldStartToKick = true
            viewModel.startNewKickCounter()
            startKickCounterTimer()
            TBAnalyticsManager.trackKickCounterInteraction(selection: .start)
        }
        viewModel.recordKickCounter()
    }

    @objc private func didTapResetCTA(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Are you sure you want to reset this kick session?\nThese Kicks will be deleted.",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Reset",
                                   style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.resetKickCounter()
        }
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(actionSheet)
        TBAnalyticsManager.trackKickCounterInteraction(selection: .reset)
    }

    @objc private func didTapFinishCTA() {
        viewModel.finishKickCounter()
        TBAnalyticsManager.trackKickCounterInteraction(selection: .finish)
    }
}
