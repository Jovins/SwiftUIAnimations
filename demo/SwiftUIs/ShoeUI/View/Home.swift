//
//  Home.swift
//  Home
//
//  Created by Jovins on 2021/8/31.
//

import SwiftUI
import simd

struct Home: View {
    
    @Namespace var animation
    @EnvironmentObject var baseData: BaseViewModel
    
    var body: some View {
        
        // Custom Segment Tab
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 8) {
                
                // logo
                HStack {
                    Button {
                        
                    } label: {
                        Image("menu")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                }
                .foregroundColor(.black)
                .overlay(Image(systemName: "applelogo"))
                
                // title
                HStack {
                    Text("Our Products")
                        .font(.title.bold())
                    Spacer()
                    Button {
                        
                    } label: {
                        HStack(spacing: 3) {
                            Text("Sort By")
                                .font(.caption.bold())
                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.black)
                    }
                }
                
                // custom segment tabar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Segment Button
                        SegmentButton(image: "sneaker", title: "Sneakers")
                        SegmentButton(image: "watch", title: "Watch")
                        SegmentButton(image: "backpack", title: "Backpack")
                        SegmentButton(image: "tshirt", title: "T-Shirt")
                        SegmentButton(image: "phone", title: "Phone")
                    }
                }
                
                // Product View
                let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(products) { product in
                        CardView(product: product)
                            .onTapGesture {
                                withAnimation {
                                    self.baseData.currentProduct = product
                                    self.baseData.showDetail = true
                                }
                            }
                    }
                }
            }
            .padding()
            .padding(.bottom, 88)
        }
        .overlay(
            DetailView(animation: animation)
                .environmentObject(self.baseData)
        )
    }
    
    @ViewBuilder
    func CardView(product: Product) -> some View {
        VStack(spacing: 15) {
            Button {
                
            } label: {
                Image(systemName: "suit.heart.fill")
                    .font(.system(size: 13))
                    .foregroundColor(product.isLiked ? .white : .gray)
                    .padding(5)
                    .background(
                        Color.red.opacity(product.isLiked ? 1 : 0), in: Circle()
                    )
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Image(product.productImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .matchedGeometryEffect(id: product.productImage, in: animation)
                .padding()
                .rotationEffect(.init(degrees: -20))
                .background(
                    ZStack {
                        //Circle()
                        //    .fill(product.productBG)
                    }
                )
            Text(product.productTitle)
                .fontWeight(.semibold)
                .padding(.top)
            Text(product.productPrice)
                .font(.title2.bold())
            // Star View
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(product.ProductRating >= index ? .yellow : .gray)
                }
                Text(" (\(product.ProductRating).0)")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    func SegmentButton(image: String, title: String) -> some View {
        
        Button {
            withAnimation {
                self.baseData.homeTab = title
            }
        } label: {
            HStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 27, height: 27)
                Text(title)
                    .font(.system(size: 12.5))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    if self.baseData.homeTab == title {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 5, y: 5)
                    }
                }
            )
        }

    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
