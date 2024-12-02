//
//  HomeList.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct HomeList: View {
    
    var courses = coursesData
    @State var showContent: Bool = false
    
    var body: some View {
        
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Courses")
                           .font(.largeTitle)
                           .fontWeight(.heavy)
                        Text("Subtitle")
                           .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.leading, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 24.0) {
                       ForEach(courses) { item in
                          Button(action: { self.showContent.toggle() }) {
                             GeometryReader { geometry in
                                CourseView(title: item.title,
                                           image: item.image,
                                           color: item.color,
                                           shadowColor: item.shadowColor)
                                   .rotation3DEffect(Angle(degrees:
                                      Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
                                   .sheet(isPresented: self.$showContent) { ContentView() }
                             }
                             .frame(width: 246, height: 320)
                          }
                       }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                }
                .padding(.bottom, 60)
                CertificateRow()
            }
            .padding(.top, 80)
        }
    }
}

#if DEBUG
struct HomeList_Previews: PreviewProvider {
   static var previews: some View {
      HomeList()
   }
}
#endif
