//
//  CourseView.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct CourseView: View {
    
    var title = "Build an app with SwiftUI"
    var image = "Illustration1"
    var color = Color("background3")
    var shadowColor = Color("backgroundShadow3")
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(self.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(16)
                .padding(.leading, 20)
                .lineLimit(4)
            Spacer()
            Image(self.image)
               .resizable()
               .renderingMode(.original)
               .aspectRatio(contentMode: .fit)
               .frame(width: 240, height: 150)
               .padding(.bottom, 30)
        }
        .background(self.color)
        .cornerRadius(16)
        .frame(width: 240, height: 320)
    }
}

#if DEBUG
struct CourseView_Previews: PreviewProvider {
   static var previews: some View {
    CourseView()
   }
}
#endif

struct Course: Identifiable {
   var id = UUID()
   var title: String
   var image: String
   var color: Color
   var shadowColor: Color
}

let coursesData = [
    
   Course(title: "Build an app with SwiftUI",
          image: "Illustration1",
          color: Color("background3"),
          shadowColor: Color("backgroundShadow3")),
   Course(title: "Design and animate your UI",
          image: "Illustration2",
          color: Color("background4"),
          shadowColor: Color("backgroundShadow4")),
   Course(title: "Swift UI Advanced",
          image: "Illustration3",
          color: Color("background7"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Course(title: "Framer Playground",
          image: "Illustration4",
          color: Color("background8"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Course(title: "Flutter for Designers",
          image: "Illustration5",
          color: Color("background9"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
]
