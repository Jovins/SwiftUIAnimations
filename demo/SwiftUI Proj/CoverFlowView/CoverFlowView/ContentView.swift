//
//  ContentView.swift
//  CoverFlowView
//
//  Created by Jovins.Huang on 2024/7/19.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @State private var items: [CoverFlowItem] = ["Pic1", "Pic2", "Pic3", "Pic4", "Pic5"].compactMap({ CoverFlowItem(image: UIImage(named: $0)) })
    
    @State private var spacing: CGFloat = 0
    @State private var rotation: CGFloat = .zero
    @State private var enableReflection: Bool = true

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 0)

                CoverFlowView(
                    itemWidth: 280,
                    spacing: spacing,
                    rotation: rotation,
                    items: items,
                    enableReflection: enableReflection
                ) { item in
                    ImageView(item)
                }
                .frame(height: 180)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Toggle Reflection", isOn: $enableReflection)
                    Text("Card Spacing")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Slider(value: $spacing, in: -120...20)
                    Text("Card Rotation")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Slider(value: $rotation, in: 0...180)
                }
                .padding(16)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .padding(8)
            }
            .navigationTitle("Cover Flow")
        }
        .padding(8)
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    func ImageView(_ item: CoverFlowItem) -> some View {
        GeometryReader {
            let size = $0.size
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}

#Preview {
    ContentView()
}
