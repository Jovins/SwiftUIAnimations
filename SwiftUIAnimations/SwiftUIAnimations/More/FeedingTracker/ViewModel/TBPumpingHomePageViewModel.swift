import Foundation

final class TBPumpingHomePageViewModel: NSObject {

    func getData() {
        TBPumpRepository.shared.getData()
    }

    func addModel(model: TBPumpModel) {
        TBPumpRepository.shared.addModel(model: model)
    }
}
