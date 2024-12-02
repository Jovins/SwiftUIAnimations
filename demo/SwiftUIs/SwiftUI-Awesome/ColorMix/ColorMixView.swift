//
//  ColorMixView.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/7/29.
//

import SwiftUI

struct ColorMixView: View {
    
    @State var colorRed: Double
    @State var colorGreen: Double
    @State var colorBlue: Double
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: colorRed, green: colorGreen, blue: colorBlue, opacity: 1.0))
                .edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    ZStack {
                        // 顶部矩形
                        Rectangle()
                            .cornerRadius(16)
                            .frame(height: 100)
                            .foregroundColor(Color(red: 1.25 - (colorRed + colorGreen * 2.0 + colorBlue) / 3.0, green: 1.25 - (colorRed + colorGreen * 2.0 + colorBlue) / 3.0, blue: 1.25 - (colorRed + colorGreen * 2.0 + colorBlue) / 3.0, opacity: 0.5))
                        HStack {
                            Text("R: \(Int(colorRed * 255.0))")
                            Text("G: \(Int(colorGreen * 255.0))")
                            Text("B: \(Int(colorBlue * 255.0))")
                        }
                        .font(Font.custom("Futura", size: 28))
                        .foregroundColor(Color(red: colorRed, green: colorGreen, blue: colorBlue, opacity: 0.8))
                    }
                }
                .padding(.all, 32)
                .padding(.top, 51)
                Rectangle()
                    .hidden()
                ZStack {
                    // 顶部矩形
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color(red: 1.0 - max(colorRed, max(colorGreen, colorBlue)), green: 1.0 - max(colorRed, max(colorGreen, colorBlue)), blue: 1.0 - max(colorRed, max(colorGreen, colorBlue)), opacity: 0.25), radius: 16, x: 0, y: 8)
                    VStack {
                        HStack {
                            Image(systemName: "r.circle")
                                .foregroundColor(Color.red.opacity(0.5))
                                .font(.system(size: 20))
                            Slider(value: $colorRed, in: 0.0 ... 1.0)
                                .accentColor(Color.red.opacity(colorRed))
                            Image(systemName: "r.circle.fill")
                                .foregroundColor(Color.red)
                                .font(.system(size: 24))
                        }.padding()
                        
                        HStack {
                            Image(systemName: "g.circle")
                                .foregroundColor(Color.green.opacity(0.5))
                                .font(.system(size: 20))
                            Slider(value: $colorGreen, in: 0.0 ... 1.0)
                                .accentColor(Color.green.opacity(colorGreen))
                            Image(systemName: "g.circle.fill")
                                .foregroundColor(Color.green)
                                .font(.system(size: 25))
                                .accentColor(Color.blue.opacity(colorBlue))
                        }.padding()
                        
                        HStack {
                            Image(systemName: "b.circle")
                                .foregroundColor(Color.blue.opacity(0.5))
                                .font(.system(size: 20))
                            Slider(value: $colorBlue, in: 0.0 ... 1.0)
                            Image(systemName: "b.circle.fill")
                                .foregroundColor(Color.blue)
                                .font(.system(size: 25))
                        }.padding()
                    }
                }
                .padding(.all, 32)
                .frame(height: 320)
            }
        }
    }
}

#if DEBUG
struct ColorMixView_Previews: PreviewProvider {
    static var previews: some View {
        ColorMixView(colorRed: 0.5, colorGreen: 0.5, colorBlue: 0.5)
    }
}
#endif
