import Foundation

extension String {
    func pluralize(with count: Int, singularCharacter: String = "", pluralCharacter: String = "s") -> String {
        return count == 1 ? self + singularCharacter : self + pluralCharacter
    }
}
