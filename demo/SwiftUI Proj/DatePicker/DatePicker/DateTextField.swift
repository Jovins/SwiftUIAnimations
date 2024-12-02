import SwiftUI

struct DateTextField: View {
    
    @Binding var date: Date
    var components: DatePickerComponents = [.date, .hourAndMinute]
    var formattedString: (Date) -> String
    
    @State private var viewID: String = UUID().uuidString
    @FocusState private var isActive: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Done") {
                isActive = false
            }
            .tint(Color.primary)

            TextField(viewID, text: .constant(formattedString(date)))
                .padding()
                .multilineTextAlignment(.center) // 字体居中
                .background(Color.gray.opacity(0.25))
                .cornerRadius(10)
                .padding()
                .focused($isActive)
                .toolbar() {
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            isActive = false
                        }
                        .tint(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .allowsHitTesting(false)
                .overlay {
                    AddInputViewToTextField(id: viewID) {
                        DatePicker("", selection: $date, displayedComponents: components)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                    }
                }
                .onTapGesture {
                    isActive = true
                }
        }
        .padding(.top, 0)
    }
}

fileprivate struct AddInputViewToTextField<Content: View>: UIViewRepresentable {

    var id: String
    @ViewBuilder var content: Content

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let window = view.window,
               let textField = window.allSubViews(type: UITextField.self).first(where: { $0.placeholder == id }) {
                
                textField.tintColor = .clear
                if let hostView = UIHostingController(rootView: content).view {
                    hostView.backgroundColor = .clear
                    hostView.frame.size = hostView.intrinsicContentSize
                    textField.inputView = hostView
                    hostView.reloadInputViews()
                }
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

fileprivate extension UIView {
    func allSubViews<T: UIView>(type: T.Type) -> [T] {
        var resultViews = subviews.compactMap({ $0 as? T })
        for view in subviews {
            resultViews.append(contentsOf: view.allSubViews(type: type))
        }
        return resultViews
    }
}

#Preview {
    ContentView()
}
