import UIKit
import SnapKit

final class TBBottleEditViewController: UIViewController {
    var eventTrackInteractionType: TBAnalyticsManager.BabyTrackerType = .bottle
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
    let bottleToolView: TBBottleToolView = TBBottleToolView()
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
        bottleToolView.delegate = self
        [scrollView, saveView].forEach(view.addSubview)
        scrollView.addSubview(contentView)
        [bottleToolView, deleteCTA].forEach(contentView.addSubview)
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveView.snp.top)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        bottleToolView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        deleteCTA.snp.makeConstraints {
            $0.top.equalTo(bottleToolView.snp.bottom).offset(28)
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
        guard let id = bottleToolView.viewModel.defaultModel?.id else { return }
        bottleToolView.viewModel.editModel.savedTime = Date()
        TBBottleRepository.shared.editModel(id: id, model: bottleToolView.viewModel.editModel)
        dismissEditBottleVC(text: "Changes Saved Successfully")
        TBAnalyticsManager.babyTrackerInteraction(type: eventTrackInteractionType, selectionType: .edit)
    }

    @objc private func didTapDelete(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Are you sure you want to delete this data?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete",
                                   style: .destructive) { [weak self] _ in
            guard let self = self,
                  let model = self.bottleToolView.viewModel.defaultModel else { return }
            TBBottleRepository.shared.deleteModel(id: model.id)
            self.dismissEditBottleVC(text: "Successfully Deleted")
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
        guard let model = bottleToolView.viewModel.defaultModel else {
            saveView.saveCTA.isEnabled = false
            return
        }
        if model.isEqual(bottleToolView.viewModel.editModel) {
            saveView.saveCTA.isEnabled = false
            return
        }
        if bottleToolView.addNoteView.moreThanMaxCharacter {
            saveView.saveCTA.isEnabled = false
            return
        }
        saveView.saveCTA.isEnabled = true
    }

    private func dismissEditBottleVC(text: String? = nil) {
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
                self.dismissEditBottleVC()
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
            dismissEditBottleVC()
        }
    }
}

// MARK: - TBBottleToolViewDelegate
extension TBBottleEditViewController: TBBottleToolViewDelegate {
    func modelDidUpdate() {
        checkSaveEnable()
    }
}
