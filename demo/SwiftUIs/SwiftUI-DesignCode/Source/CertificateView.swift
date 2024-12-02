//
//  CertificateView.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct CertificateView: View {
    
    var item = Certificate(title: "UI Design", image: "Certificate1", width: 340, height: 220)

    var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("accent"))
                        .padding(.top)
                    Text("Certificate")
                        .foregroundColor(.white)
                }
                Spacer()
                Image("Logo")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal)
            Spacer()
            
            Image(item.image)
               .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
               .offset(y: 50)
        }
        .frame(width: CGFloat(item.width), height: CGFloat(item.height))
        .background(Color.black)
        .cornerRadius(8)
    }
}
