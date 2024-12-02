import SwiftUI

struct Home: View {
    
    @State private var colors: [Color] = [.purple, .red, .blue, .yellow]
    @State private var opacityEffect: Bool = false
    @State private var clipEdges: Bool = false
    var body: some View {
        VStack {
            // Page View
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(colors, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.gradient)
                            .padding(.horizontal, 4)
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
                .overlay(alignment: .bottom) {
                    PageIndicator(activeTintColor: .white,
                                  inActiveTintColor: .white.opacity(0.45),
                                  opacityEffect: opacityEffect,
                                  clipEdges: clipEdges)
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .frame(height: 200)
            .safeAreaPadding(.vertical, 16)
            .safeAreaPadding(.horizontal, 16)

            List {
                Section("Options") {
                    Toggle("Opacity Effect", isOn: $opacityEffect)
                    Toggle("Clip Edges", isOn: $clipEdges)
                    Button("Add Item") {
                        if !colors.contains(.green) {
                            colors.append(.green)
                        }
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 16))
            .padding(16)
        }
        .navigationTitle("Custom Indicator")
    }
}

#Preview {
    ContentView()
}
