import SwiftUI

extension View {
    @ViewBuilder
    func didFrameChange(result: @escaping (CGRect, CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let frame = $0.frame(in: .scrollView(axis: .vertical))
                    let bounds = $0.bounds(of: .scrollView(axis: .vertical)) ?? .zero
                    Color.clear
                        .preference(key: FrameKey.self, value: .init(frame: frame, bounds: bounds))
                        .onPreferenceChange(FrameKey.self) { value in
                            result(value.frame, value.bounds)
                        }
                }
            }
    }
}
