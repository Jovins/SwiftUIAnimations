import SwiftUI

struct PinterestContent: View {
    var body: some View {
        LazyVStack(spacing: 15) {
            PinterestSection(title: "Social Media")
            PinterestSection(title:"Sales", isLong: true)
            
            ImageView("Pic1")
            PinterestSection(title: "Busniess",isLong: true)
            PinterestSection(title: "Promotion",isLong: true)
            
            ImageView("Pic2")
            PinterestSection(title: "YouTube")
            PinterestSection(title: "Twitter (X)")
            PinterestSection(title:"Marketing Campaign",isLong: true)
            ImageView("Pic3")
            PinterestSection(title:"Conclusion", isLong: true)
        }
        .padding(15)
    }

    @ViewBuilder
    func PinterestSection(title: String, isLong: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title.bold( ))
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\(isLong ? "It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged." : "")")
                .multilineTextAlignment(.leading)
                .kerning(1.2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func ImageView(_ image: String) -> some View {
        GeometryReader {
            let size = $0.size
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width,height: size.height)
                .clipped()
        }
        .frame(height: 400)
    }
}

#Preview {
    PinterestContent()
}
