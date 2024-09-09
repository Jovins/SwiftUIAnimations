import UIKit
import SnapKit

final class TBPumpingEditViewController: UIViewController {
    var eventTrackInteractionType: TBAnalyticsManager.BabyTrackerType = .pumping
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
    private let contentView: UIView = UIView()
    let pumpToolView: TBPumpingToolView = TBPumpingToolView()
    private let saveView: TBFeedingSaveView = TBFeedingSaveView()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        setupUI()
    }

    private func setupBarButtonItem() {
        navigationItem.title = "Edit"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back, action: #selector(didTapToBack(sender:))))
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        pumpToolView.delegate = self
        [scrollView, saveView].forEach(view.addSubview)
        scrollView.addSubview(contentView)
        [pumpToolView, deleteCTA].forEach(contentView.addSubview)
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveView.snp.top)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        pumpToolView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        deleteCTA.snp.makeConstraints {
            $0.top.equalTo(pumpToolView.snp.bottom).offset(28)
            $0.height.equalTo(22)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        saveView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        saveView.saveCTA.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        deleteCTA.addTarget(self, action: #selector(didTapDelete(sender:)), for: .touchUpInside)
    }

    @objc private func didTapSave() {
        guard let id = pumpToolView.viewModel.defaultModel?.id else { return }

        let previouslySavedModel = TBPumpRepository.shared.models
            .filter({ !$0.archived })
            .first {
                $0.startTime == pumpToolView.viewModel.editModel.startTime
                && $0.id != pumpToolView.viewModel.defaultModel?.id
            }
        if let previouslySavedModel {
            let sameEntryExistAlert = UIAlertController(
                title: "",
                message: "Entries cannot share the same time.\nPlease, pick another time slot.",
                preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .cancel)
            sameEntryExistAlert.addAction(retryAction)
            AppRouter.shared.navigator.present(sameEntryExistAlert)
        } else {
            pumpToolView.viewModel.editModel.savedTime = Date()
            if !pumpToolView.viewModel.lastBreastViewEnable {
                pumpToolView.viewModel.editModel.lastSide = pumpToolView.viewModel.editModel.leftAmountModel.amount != 0 ? .left : .right
            }
            TBPumpRepository.shared.editModel(id: id, model: pumpToolView.viewModel.editModel)
            dismissEditPumpVC(text: "Changes Saved Successfully")
            TBAnalyticsManager.babyTrackerInteraction(type: eventTrackInteractionType, selectionType: .edit)
        }
    }

    @objc private func didTapDelete(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Are you sure you want to delete this data?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete",
                                   style: .destructive) { [weak self] _ in
            guard let self = self,
                  let model = self.pumpToolView.viewModel.defaultModel else { return }
            TBPumpRepository.shared.deleteModel(id: model.id)
            self.dismissEditPumpVC(text: "Successfully Deleted")
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

    private func checkSaveEnable() {
        guard let model = pumpToolView.viewModel.defaultModel else {
            saveView.saveCTA.isEnabled = false
            return
        }
        if pumpToolView.viewModel.editModel.leftAmountModel.amount == 0,
           pumpToolView.viewModel.editModel.rightAmountModel.amount == 0 {
            saveView.saveCTA.isEnabled = false
            return
        }
        if model.isEqual(pumpToolView.viewModel.editModel) {
            saveView.saveCTA.isEnabled = false
            return
        }
        if pumpToolView.addNoteView.moreThanMaxCharacter {
            saveView.saveCTA.isEnabled = false
            return
        }
        saveView.saveCTA.isEnabled = true
    }

    private func dismissEditPumpVC(text: String? = nil) {
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

    @objc private func didTapToBack(sender: UIButton) {
        if saveView.saveCTA.isEnabled {
            let actionSheet = UIAlertController(title: "Changes have not been saved.\nDo you want to continue?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            let resetAction = UIAlertAction(title: "Yes",
                                            style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.dismissEditPumpVC()
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
            dismissEditPumpVC()
        }
    }
}

// MARK: - TBPumpingToolViewDelegate
extension TBPumpingEditViewController: TBPumpingToolViewDelegate {
    func modelDidUpdate() {
        checkSaveEnable()
    }
}
