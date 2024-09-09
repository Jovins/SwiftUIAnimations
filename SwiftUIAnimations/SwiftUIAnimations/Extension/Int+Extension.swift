extension Int {
    func roundToDecimalPlaces(_ decimalPlaces: Int) -> String {
        let divisor = pow(10.0, Double(decimalPlaces))
        var value = self < 100 ? "\(self)" : "\(Double(self/(1000/Int(divisor))).rounded() / divisor)K"
        value = self > 1000000 ? "\(Double(self/(1000000/Int(divisor))).rounded() / divisor)M" : value
        return value
    }
}
