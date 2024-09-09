import Foundation

final class TBBottleHomePageViewModel: NSObject {

    func getData() {
        TBBottleRepository.shared.getData()
    }

    func addModel(model: TBBottleModel) {
        TBBottleRepository.shared.addModel(model: model)
    }
}
