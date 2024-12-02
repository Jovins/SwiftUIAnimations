import SwiftUI
import CoreTransferable
import UniformTypeIdentifiers
import CryptoKit

struct Transaction: Identifiable, Codable {
    var id: UUID = .init()
    var title: String
    var date: Date
    var amount: Double

    init() {
        self.title = "Sample Text"
        self.date = Calendar.current.date(byAdding: .day, value: .random(in: 1...100), to: .now) ?? .now
        self.amount = .random(in: 5000...10000)
    }
}

struct Transactions: Codable, Transferable {
    var transactions: [Transaction]
    static var transferRepresentation: some TransferRepresentation {

        // encrypt data
        DataRepresentation(exportedContentType: .trnExportType) {
            let data = try JSONEncoder().encode($0)
            guard let encryptedData = try AES.GCM.seal(data, using: .trnKey).combined else {
                throw EncryptionError.failed
            }
            return encryptedData
        }
        .suggestedFileName("Transactions \(Date())")
        /*
         // no encryption
        CodableRepresentation(contentType: UTType.trnUTType)
            .suggestedFileName("Transactions \(Date())")
         */
    }
    
    enum EncryptionError: Error {
        case failed
    }
}

extension SymmetricKey {
    static var trnKey: SymmetricKey {
        let key = "jovins.com.CustomFileExtension.trn".data(using: .utf16) ?? Data()
        let sha256 = SHA256.hash(data: key)
        return .init(data: sha256)
    }
}

extension UTType {
    static var trnExportType = UTType(exportedAs: "jovins.com.CustomFileExtension.trn")
}
