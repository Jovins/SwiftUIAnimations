import UIKit
import RxSwift

final class TBDiapersEditViewController: UIViewController {

    var eventTrackInteractionType: TBAnalyticsManager.BabyTrackerType = .diapers
    var model: TBDiapersModel? {
        didSet {
            toolView.model = model
            viewModel.defaultModel = model
        }
    }
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Tap to make changes".attributedText(.mulishLink1)
        return label
    }()
    private let scrollView: TBScrollView = {
        let scrollView = TBScrollView()
        scrollView.backgroundColor = .GlobalBackgroundPrimary
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delaysContentTouches = false
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .GlobalBackgroundPrimary
        return view
    }()
    private lazy var toolView: TBDiapersToolView = {
        let tool = TBDiapersToolView()
        tool.delegate = self
        return tool
    }()
    private var deleteCTA: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Delete".attributedText(.mulishLink2), for: .normal)
        button.setAttributedTitle("Delete".attributedText(.mulishLink2, foregroundColor: .DarkGray500), for: .highlighted)
        button.setImage(TBIconList.trash.image(sizeOption: .small, color: .GlobalTextPrimary), for: .normal)
        button.setImage(TBIconList.trash.image(sizeOption: .small, color: .DarkGray500), for: .highlighted)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.tb.expandTouchingArea(TBIconList.SizeOption.normal.tapArea)
        return button
    }()
    private let saveView: TBFeedingSaveView = TBFeedingSaveView()
    private var toolViewHeight: CGFloat {
        return UIDevice.isPad() ? 553 : 521
    }
    private let disposeBag = DisposeBag()
    private let viewModel = TBDiapersToolViewModel()
    private var isEnabledForCharacter: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupUI()
    }

    private func setupNavigationItem() {
        navigationItem.title = "Edit"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back, action: #selector(didTapToBack(sender:))))
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        view.addSubview(scrollView)
        [scrollView, saveView].forEach(view.addSubview)
        scrollView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(saveView.snp.top)
        }
        saveView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIDevice.width)
            $0.height.greaterThanOrEqualToSuperview()
        }
        [titleLabel, toolView, deleteCTA].forEach(contentView.addSubview)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.height.equalTo(27)
            $0.centerX.equalToSuperview()
        }
        toolView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(toolViewHeight)
        }
        deleteCTA.snp.makeConstraints {
            $0.top.equalTo(toolView.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 72, height: 22))
            $0.bottom.lessThanOrEqualToSuperview().inset(36)
        }
        saveView.saveCTA.isEnabled = false
        saveView.saveCTA.addTarget(self, action: #selector(didTapSaveCTA), for: .touchUpInside)
        deleteCTA.addTarget(self, action: #selector(didTapDeleteCTA(sender:)), for: .touchUpInside)

        viewModel.updateDiapersSubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldUpdate in
                guard shouldUpdate, let self = self else { return }
                self.dismissEditDiapersVC(text: "Changes Saved Successfully")
        }, onError: { _ in }).disposed(by: disposeBag)

        viewModel.deleteDiapersSubject.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldUpdate in
                guard shouldUpdate, let self = self else { return }
                self.dismissEditDiapersVC(text: "Successfully Deleted")
        }, onError: { _ in }).disposed(by: disposeBag)
    }

    private func dismissEditDiapersVC(text: String? = nil) {
        navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let text else { return }
            let message = text.attributedText(.mulishBody4, foregroundColor: .GlobalTextSecondary)
            let bottomSpacing = UIDevice.tabbarSafeAreaHeight == 0 ? 12 : UIDevice.tabbarSafeAreaHeight
            if let window = AppDelegate.sharedInstance().window {
                TBToastView().display(attributedText: message, on: window, leadingAndTrailingSpacing: 10, bottomSpacing: bottomSpacing)
            }
        }
    }

    @objc private func didTapSaveCTA() {
        view.endEditing(true)
        guard var model else { return }
        model.diaperName = toolView.lastDiapersButton?.type.rawValue
        model.startTime = toolView.startTime
        model.note = toolView.addNoteView.note?.trimmed
        model.savedTime = Date()
        viewModel.updateDiapers(model: model)
        TBAnalyticsManager.babyTrackerInteraction(type: eventTrackInteractionType, selectionType: .edit)
    }

    @objc private func didTapDeleteCTA(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Are you sure you want to delete this data?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete",
                                   style: .destructive) { [weak self] _ in
            guard let self = self, let model = self.model else { return }
            self.viewModel.deleteDiapers(model: model)
            TBAnalyticsManager.babyTrackerInteraction(type: self.eventTrackInteractionType, selectionType: .delete)
        }
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
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
    }

    @objc private func didTapToBack(sender: UIButton) {
        if saveView.saveCTA.isEnabled {
            let actionSheet = UIAlertController(title: "Changes have not been saved.\nDo you want to continue?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            let resetAction = UIAlertAction(title: "Yes",
                                       style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.dismissEditDiapersVC()
            }
            actionSheet.addAction(resetAction)
            actionSheet.addAction(cancelAction)
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
        } else {
            dismissEditDiapersVC()
        }
    }
}

// MARK: - TBDiapersToolViewDelegate
extension TBDiapersEditViewController: TBDiapersToolViewDelegate {

    func toolView(_ toolView: TBDiapersToolView, didSelectDiaper type: TBDiapersButtton.TBDiapersButttonType) {
        guard let editModel = viewModel.editModel else { return }
        editModel.diaperName = type.rawValue
        updateSaveStateIfNeed()
    }

    func toolView(_ toolView: TBDiapersToolView, didSelectStartTime time: Date) {
        guard let editModel = viewModel.editModel else { return }
        editModel.startTime = time
        updateSaveStateIfNeed()
    }

    func toolView(_ toolView: TBDiapersToolView, didChange text: String) {
        guard let editModel = viewModel.editModel else { return }
        editModel.note = text
        updateSaveStateIfNeed()
    }

    func textView(_ textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {
        isEnabledForCharacter = isEnabled
        updateSaveStateIfNeed()
    }

    private func updateSaveStateIfNeed() {
        saveView.saveCTA.isEnabled = viewModel.isEnabled && isEnabledForCharacter
    }
}
