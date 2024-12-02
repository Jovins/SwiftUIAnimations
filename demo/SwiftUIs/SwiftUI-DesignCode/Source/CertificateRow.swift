//
//  CertificateRow.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct CertificateRow: View {
    
    let certificates = certificateData
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Certificates")
                .font(.system(size: 20))
                .fontWeight(.heavy)
                .padding(.leading, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(self.certificates) { item in
                        CertificateView(item: item)
                    }
                }
                .padding(.top, 8)
                .padding(.leading, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

#if DEBUG
struct CertificateRow_Previews: PreviewProvider {
   static var previews: some View {
      CertificateRow()
   }
}
#endif

struct Certificate: Identifiable {
    var id = UUID()
    var title: String
    var image: String
    var width: Int
    var height: Int
}

let certificateData = [
   Certificate(title: "UI Design", image: "Certificate1", width: 230, height: 150),
   Certificate(title: "SwiftUI", image: "Certificate2", width: 230, height: 150),
   Certificate(title: "Sketch", image: "Certificate3", width: 230, height: 150),
   Certificate(title: "Framer", image: "Certificate4", width: 230, height: 150)
]
