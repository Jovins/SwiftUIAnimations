import Foundation
import SwiftUI

@Observable
class Toast {
    static let shared = Toast()
    var toasts: [ToastItem] = []
    private(set) var direction: Direction = .bottom
    
    func present(title: String, symbol: String? = nil, tintColor: Color = .primary, isUserInteractionEnabled: Bool = false, timing: ToastItem.ToastTime = .medium, direction: Direction = .bottom) {
        self.direction = direction
        withAnimation(.snappy) {
            toasts.append(.init(title: title, symbol: symbol, tintColor: tintColor, isUserInteractionEnabled: isUserInteractionEnabled, timing: timing))
        }
    }

    enum Direction {
        case top
        case bottom
    }
}

struct ToastItem: Identifiable {

    enum ToastTime: CGFloat {
        case short  = 1.0
        case medium = 2.0
        case long   = 3.5
    }

    let id: UUID = .init()
    var title: String
    var symbol: String?
    var tintColor: Color
    var isUserInteractionEnabled: Bool
    var timing: ToastTime = .medium
}

struct ToastGroup: View {
    var model = Toast.shared
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack {
                ForEach(model.toasts) { item in
                    ToastView(size: size, item: item)
                        .offset(y: model.direction == .bottom ? offsetY(item) : -offsetY(item))
                        .scaleEffect(scale(item))
                        .zIndex(Double(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,
                   alignment: model.direction == .bottom ? .bottom : .top)
        }
    }

    func offsetY(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count - 1)
        return totalCount - index >= 2 ? -20 : (totalCount - index) * -10
    }
    
    func scale(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count - 1)
        return 1.0 - (totalCount - index >= 2 ? -0.2 : (totalCount - index) * -0.1)
    }
}

fileprivate struct ToastView: View {
    
    var size: CGSize
    var item: ToastItem
    
    // MARK: - Properties
    @State private var delayTask: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 4) {
            if let symbol = item.symbol {
                Image(systemName: symbol)
                    .font(.title3)
                    .padding(.trailing, 4)
            }
            Text("\(item.title)")
                .lineLimit(1)
        }
        .foregroundStyle(item.tintColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            .background
                .shadow(.drop(color: .primary.opacity(0.06), radius: 6, x: 4, y: 4))
                .shadow(.drop(color: .primary.opacity(0.06), radius: 8, x: -4, y: -4)),
            in: .capsule
        )
        .containerShape(.capsule)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded({ value in
                    guard item.isUserInteractionEnabled else { return }
                    let endY = value.translation.height
                    let velocityY = value.velocity.height
                    if endY + velocityY > 100 {
                        removeToast()
                    }
                })
        )
        .onAppear {
            guard delayTask == nil else { return }
            delayTask = .init(block: {
                removeToast()
            })

            if let delayTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + item.timing.rawValue, execute: delayTask)
            }
        }
        .frame(maxWidth: size.width * 0.7)
        .transition(.offset(y: Toast.shared.direction == .bottom ? 150 : -150))
    }

    var offsetY: CGFloat {
        return 0
    }

    func removeToast() {
        withAnimation(.snappy, completionCriteria: .logicallyComplete) {
            Toast.shared.toasts.removeAll(where: { $0.id == item.id })
        } completion: {
            if let delayTask {
                delayTask.cancel()
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
