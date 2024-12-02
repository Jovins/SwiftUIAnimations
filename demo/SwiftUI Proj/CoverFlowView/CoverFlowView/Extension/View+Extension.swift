import SwiftUI

extension View {
    
    /// Inverted reflection For View
    @ViewBuilder
    func reflection(_ added: Bool) -> some View {
        self.overlay {
            if added {
                GeometryReader {
                    let size = $0.size
                    self
                        .scaleEffect(y: -1)
                        .mask {
                            Rectangle()
                                .fill(
                                    .linearGradient(
                                        colors: [
                                            .white,
                                            .white.opacity(0.7),
                                            .white.opacity(0.5),
                                            .white.opacity(0.3),
                                            .white.opacity(0.1),
                                            .white.opacity(0)] + Array(repeating: Color.clear, count: 5),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        .offset(y: size.height + 4)
                        .opacity(0.75)
                }
            }
        }
    }
}
