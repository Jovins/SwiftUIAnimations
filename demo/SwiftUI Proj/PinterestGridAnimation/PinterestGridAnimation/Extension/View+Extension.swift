import SwiftUI

struct ScrollViewExtractor: UIViewRepresentable {

    var result: (UIScrollView) -> ()

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if let scrollView = view.superview?.superview?.superview as? UIScrollView {
                result(scrollView)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {

    var safeArea: UIEdgeInsets {
        if let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets {
            return safeArea
        }
        return .zero
    }

    @ViewBuilder
    func offsetY(result: @escaping (CGFloat) -> ()) -> some View {
        self.overlay {
            GeometryReader {
                let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
                Color.clear
                    .preference(key: OffsetKey.self, value: minY)
                    .onPreferenceChange(OffsetKey.self, perform: { value in
                        result(value)
                    })
            }
        }
    }
}
