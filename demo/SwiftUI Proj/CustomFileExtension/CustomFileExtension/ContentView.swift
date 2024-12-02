import SwiftUI
import CryptoKit

struct ContentView: View {

    @State private var transactions: [Transaction] = []
    @State private var shouldImportTransaction: Bool = false
    
    var body: some View {

        NavigationStack {
            List(transactions) { transaction in
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(transaction.title)
                        Text(transaction.date.formatted(date: .numeric, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    Spacer(minLength: 0)
                    Text("$ \(Int(transaction.amount))")
                        .font(.callout.bold())
                }
            }
            .navigationTitle("Transactions")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "plus") {
                        transactions.append(.init())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "square.and.arrow.down.fill") {
                        shouldImportTransaction.toggle()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: Transactions(transactions: transactions), preview: SharePreview("Share", image: "square.and.arrow.up.fill"))
                }
            })
        }
        .padding(.horizontal, 8)
        .fileImporter(isPresented: $shouldImportTransaction, allowedContentTypes: [.trnExportType]) { result in
            switch result {
            case .success(let url):
                do {
                    let encryptedData = try Data(contentsOf: url)
                    let decryptedData = try AES.GCM.open(.init(combined: encryptedData), using: .trnKey)
                    let decodeTransaction = try JSONDecoder().decode(Transactions.self, from: decryptedData)
                    self.transactions = decodeTransaction.transactions
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
