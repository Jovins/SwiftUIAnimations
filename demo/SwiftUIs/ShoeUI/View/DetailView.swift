//
//  DetailView.swift
//  DetailView
//
//  Created by Jovins on 2021/8/31.
//

import SwiftUI

struct DetailView: View {
    
    @EnvironmentObject var baseData: BaseViewModel
    var animation: Namespace.ID
    @State var size = "US 6"
    @State var shoeColor: Color = .red
    
    
    var body: some View {
        if let product = self.baseData.currentProduct, self.baseData.showDetail {
            
            VStack(spacing: 0) {
                // top bar
                HStack {
                    Button {
                        withAnimation {
                            self.baseData.showDetail = false
                        }
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "suit.heart.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                Color.red, in: Circle()
                            )
                    }
                }
                .foregroundColor(.black)
                .overlay(Image(systemName: "applelogo"))
                .padding(.horizontal)
                .padding(.bottom)
                
                // Shoe Image
                Image(product.productImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: product.productImage, in: animation) // 转场
                    .frame(width: 250, height: 250)
                    .rotationEffect(.init(degrees: -20))
                    .frame(height: getScreenBounds().height/3)
                
                // Product Details
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        Text(product.productTitle)
                            .font(.title.bold())
                            
                        Spacer(minLength: 10)
                        
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("(\(product.ProductRating))")
                            .foregroundColor(.gray)
                    }
                    
                    Text("We could use a lot of superlatives to describe the Nike Zoom Kobe 2021. We could tell you that we' ve incorporated recycled meterials")
                        .font(.callout)
                        .lineSpacing(10)
                    
                    // Size
                    HStack(spacing: 0) {
                        Text("Size: ")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .padding(.trailing)
                        
                        ForEach(["US 6", "US 7", "US 8", "US 9"], id: \.self) { size in
                            
                            Button {
                                self.size = size
                            } label: {
                                Text(size)
                                    .font(.callout)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue)
                                            .opacity(self.size == size ? 0.25 : 0)
                                    )
                            }

                        }
                    }
                    .padding(.vertical)
                    
                    // Color
                    HStack(spacing: 8) {
                        
                        let colors: [Color] = [.yellow, .orange, .green, .purple, .blue]
                        Text("Available Colors: ")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .padding(.trailing)
                        
                        ForEach(colors, id: \.self) { color in
                            
                            Button {
                                self.shoeColor = color
                            } label: {
                                
                                Circle()
                                    .fill(color.opacity(0.5))
                                    .frame(width: 25, height: 25)
                                    .overlay(
                                        Circle()
                                            .stroke(Color("DarkBlue"))
                                            .opacity(shoeColor == color ? 0.25 : 0)
                                            .padding(-4)
                                    )
                            }

                        }
                    }
                    
                    // Add to cart
                    Button {
                        
                    } label: {
                        HStack(spacing: 16) {
                            Image("cart")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Add to Cart")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color("DarkBlue").opacity(0.05))
                        .clipShape(Capsule())
                    }
                    .padding(.top)
                }
                .padding(.top)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(
                    Color("DarkBlue")
                        .opacity(0.05)
                        .cornerRadius(20)
                        .ignoresSafeArea(.container, edges: .bottom)
                )
                
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.white)
            .transition(.opacity)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    
    func getScreenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
}
