import UIKit
import RxSwift

final class TBNursingManualAddEntryViewController: UIViewController {

    var eventTrackInteractionType: TBAnalyticsManager.BabyTrackerType = .nursing
    private let viewModel = TBNursingManualAddEntryControllerViewModel()
    private let disposeBag = DisposeBag()
    private lazy var contentView = TBNursingManualAddEntryView(viewController: self, type: viewModel.operationType)
    private let saveButton: TBCommonButton = {
        let button = TBCommonButton()
        button.setTitle("Save", for: .normal)
        button.buttonHeight = 46
        button.isEnabled = false
        return button
    }()
    private let scrollView: TBScrollView = {
        let scrollView = TBScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        return scrollView
    }()
    private var isEnabledForCharacter: Bool = true {
        didSet {
            saveButton.isEnabled = isSaveEnabled && isEnabledForCharacter
        }
    }
    private var isSaveEnabled: Bool = false {
        didSet {
            saveButton.isEnabled = isSaveEnabled && isEnabledForCharacter
        }
    }

    init(type: TBNursingManualAddEntryControllerViewModel.OperationType = .add, nursingModel: TBNursingModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel.operationType = type
        if let nursingModel = nursingModel {
            contentView.viewModel.defaultModel = nursingModel
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupUI()
        updateUI()
        bindData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presentingViewController != nil {
            navigationController?.navigationBar.hideBottomHairline()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if presentingViewController != nil {
            navigationController?.navigationBar.showBottomHairline()
        }
    }

    private func bindData() {
        viewModel.bindData(viewModel: contentView.viewModel)
        viewModel.saveSubject.subscribe { [weak self] saveEnable in
            guard let self = self else { return }
            self.isSaveEnabled = saveEnable
        }.disposed(by: disposeBag)
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.operationType == .edit ? "Edit" : ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupFeedingTrackerLeftNavigationItem(model: TBFeedingTrackerNavigationBarModel(type: .back, action: #selector(didTapToBack(sender:))))
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        saveButton.addTarget(self, action: #selector(didTapSaveButton(sender:)), for: .touchUpInside)
        scrollView.delegate = self
        contentView.addNoteView.delegate = self
        if viewModel.operationType == .edit {
            contentView.deleteCTA.addTarget(self, action: #selector(didTapDeleteButton(sender:)), for: .touchUpInside)
        contentView.addNoteView.delegate = self
        }
        [scrollView, saveButton].forEach(view.addSubview)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-24)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIDevice.width)
        }
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(46)
        }
    }

    private func updateUI() {
        contentView.viewModel.updateSubject.onNext(nil)
    }

    private func dismissEditNursingVC(text: String? = nil) {
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

    @objc private func didTapSaveButton(sender: UIButton) {
        let nursingModel = contentView.viewModel.editModel
        nursingModel.savedTime = Date()
        if !contentView.viewModel.lastBreastEnable {
            nursingModel.lastBreast = nursingModel.leftBreast.duration > 0 ? .left : .right
        }
        switch viewModel.operationType {
        case .add:
            TBNursingRepository.shared.addModel(model: nursingModel)
            dismissEditNursingVC(text: "Manual Nursing Entry Saved")
            TBAnalyticsManager.babyTrackerInteraction(type: eventTrackInteractionType, selectionType: .save)
        case .edit:
            guard let defaultModel = contentView.viewModel.defaultModel else { return }
            defaultModel.update(by: nursingModel)
            TBNursingRepository.shared.editModel(id: defaultModel.id, model: defaultModel)
            dismissEditNursingVC(text: "Changes Saved Successfully")
            TBAnalyticsManager.babyTrackerInteraction(type: eventTrackInteractionType, selectionType: .edit)
        }
    }

    @objc private func didTapDeleteButton(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Are you sure you want to delete this data?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let defaultModel = self.contentView.viewModel.defaultModel else { return }
            TBNursingRepository.shared.deleteModel(id: defaultModel.id)
            self.dismissEditNursingVC(text: "Successfully Deleted")
            TBAnalyticsManager.babyTrackerInteraction(type: self.eventTrackInteractionType, selectionType: .delete)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
        if saveButton.isEnabled {
            let actionSheet = UIAlertController(title: "Changes have not been saved.\nDo you want to continue?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            let resetAction = UIAlertAction(title: "Yes",
                                       style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.dismissEditNursingVC()
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
            dismissEditNursingVC()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension TBNursingManualAddEntryViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentView.endEditing()
    }
}

// MARK: - TBAddNoteTextViewDelegate
extension TBNursingManualAddEntryViewController: TBAddNoteTextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        updateUI()
    }

    func textViewDidChange(_ textView: UITextView) {
        contentView.viewModel.editModel.note = textView.text
    }

    func textView(textView: UITextView, moreThanMaxCharacter isEnabled: Bool) {
        isEnabledForCharacter = isEnabled
    }
}
