import Foundation

extension UINavigationItem {
    func setToTemplateImage(buttonItem: UIBarButtonItem) {
        guard let button = buttonItem.customView as? UIButton,
            let image = button.image(for: .normal)
            else { return }
        let templateImage = image.withRenderingMode(.alwaysTemplate)
        button.setImage(templateImage, for: .normal)
    }

    func setTemplateImageForButtonItems() {
        leftBarButtonItems?.forEach { setToTemplateImage(buttonItem: $0) }
        rightBarButtonItems?.forEach { setToTemplateImage(buttonItem: $0) }
    }

    func setEmptyTitleForBackButtonItem() {
        backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
