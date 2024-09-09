import UIKit
import RxSwift

protocol TBEditWeightTrackerViewControllerDelegate: AnyObject {
    func didFinishToEditWeight(message: String)
}

final class TBEditWeightTrackerViewController: UIViewController {

    var model: TBWeightTrackerModel?
    weak var delegate: TBEditWeightTrackerViewControllerDelegate?
    private let addWeightTrackerView = TBWeightTrackerEnterView(type: .edit)
    private let modalView = TBModalView.build(content: "Please note: The Bump and the materials and information it contains are not intended to, and do not constitute, medical or other health advice or diagnosis and should not be used as such. You should always consult with a qualified physician or health professional about your specific circumstances.", ctaType: .medicalDisclaimer)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = .GlobalBackgroundPrimary
        navigationItem.title = "Edit"
        view.addSubview(addWeightTrackerView)
        addWeightTrackerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.bottom.trailing.equalToSuperview()
        }

        addWeightTrackerView.model = model
        addWeightTrackerView.deleteWeightSubject.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] complete in
            guard let self = self, complete else { return }
            if let memberData = TBMemberDataManager.shared.memberData,
               !memberData.isUserPregnant && TBWeightTrackerRepository.shared.weights.isEmpty {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: TBNotificationConstant.didDeleteAllWeightTrackerData, object: nil)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.delegate?.didFinishToEditWeight(message: "Successfully Deleted")
                }
            }
        }, onError: { _ in
        }).disposed(by: disposeBag)

        addWeightTrackerView.editWeightSubject.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] complete in
            guard let self = self, complete else { return }
            self.navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.didFinishToEditWeight(message: "Changes Saved Successfully")
            }
        }, onError: { _ in
        }).disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: TBIconList.caretLeft.image(sizeOption: .normal), style: .plain, target: self, action: #selector(didTapToBack(sender:)))
        addWeightTrackerView.medicalDisclaimerCTA.addTarget(self, action: #selector(didTapMedicalDisclaimerCTA), for: .touchUpInside)
    }

    @objc private func didTapToBack(sender: UIBarButtonItem) {
        guard addWeightTrackerView.shouldSaveWeightTracker else {
            navigationController?.popViewController(animated: true)
            return
        }
        let alertVC = UIAlertController(title: nil, message: "Changes have not been saved.\nDo you want to continue?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        if let popoverController = alertVC.popoverPresentationController {
            if let sender = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sender
            } else if let sender = sender as? UIView {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            popoverController.permittedArrowDirections = [.down, .up]
        }
        AppRouter.shared.navigator.present(alertVC)
    }

    @objc private func didTapMedicalDisclaimerCTA() {
        modalView.show()
    }
}
