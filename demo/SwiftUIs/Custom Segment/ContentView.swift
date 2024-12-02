//
//  ContentView.swift
//  Custom Segment
//
//  Created by Jovins on 2021/8/30.
//

import SwiftUI

struct ContentView: View {
    
    @State var selected: Int = 0
    
    var body: some View {
        
        VStack(spacing: 8) {
            TopBar(selected: self.$selected)
                .padding(.top)
            if self.selected == 0 {
                Home()
            } else {
                Account()
            }
        }
        .background(Color("Color").edgesIgnoringSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TopBar: View {
    
    @Binding var selected: Int
    
    var body: some View {
        
        HStack {
            Button(action:  {
                self.selected = 0
            }) {
                Image(systemName: "message")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(self.selected == 0 ? Color.white : Color.clear)
                    .clipShape(Capsule())
            }
            .foregroundColor(self.selected == 0 ? .pink : .gray)
            
            Button(action:  {
                self.selected = 1
            }) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(self.selected == 1 ? Color.white : Color.clear)
                    .clipShape(Capsule())
            }
            .foregroundColor(self.selected == 1 ? .pink : .gray)
        }
        .padding(8)
        .background(Color("ColorBar"))
        .clipShape(Capsule())
    }
}

struct Home: View {
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 16) {
                ForEach(1...8, id: \.self) { i in
                    
                    HStack(spacing: 16) {
                        
                        Image("pic1")
                            .renderingMode(.original)
                            .frame(width: 44, height: 44, alignment: .center)
                            .cornerRadius(22)
                            
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Catherine")
                            Text("msg \(i)")
                        }
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct Account: View {
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack(spacing: 15) {
                
                Image("pic2").renderingMode(.original)
                    .frame(width: 44, height: 44, alignment: .center)
                    .cornerRadius(22)
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Ellea")
                    Text("@Ellea_20")
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            
            HStack(spacing: 15) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Followers").fontWeight(.bold)
                        Text("89").fontWeight(.bold).font(.system(size: 20))
                    }
                    Spacer(minLength: 0)
                }
                .padding()
                .frame(width: (UIScreen.main.bounds.width - 45)/2)
                .background(Color("BlueColor"))
                .cornerRadius(16)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Following").fontWeight(.bold)
                        Text("220").fontWeight(.bold).font(.system(size: 20))
                    }
                    Spacer(minLength: 0)
                }
                .padding()
                .frame(width: (UIScreen.main.bounds.width - 45)/2)
                .background(Color("RedColor"))
                .cornerRadius(16)
            }
            .foregroundColor(.white)
            .padding(.top)
            
            Button(action: {
                
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "location.circle")
                        .resizable()
                        .foregroundColor(Color.pink)
                        .frame(width: 24, height: 24)
                    Text("Address")
                    Spacer()
                    Image(systemName: "arrow.right")
                        .resizable()
                        .foregroundColor(Color.black)
                        .frame(width: 18, height: 16)
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
            }
            .cornerRadius(8)
            
            Button(action: {
                
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "network")
                        .resizable()
                        .foregroundColor(Color.pink)
                        .frame(width: 24, height: 24)
                    Text("Language")
                    Spacer()
                    Image(systemName: "arrow.right")
                        .resizable()
                        .foregroundColor(Color.black)
                        .frame(width: 18, height: 16)
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
            }
            .cornerRadius(8)
            
            Button(action: {
                
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "network")
                        .resizable()
                        .foregroundColor(Color.pink)
                        .frame(width: 24, height: 24)
                    Text("Language")
                    Spacer()
                    Image(systemName: "arrow.right")
                        .resizable()
                        .foregroundColor(Color.black)
                        .frame(width: 18, height: 16)
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
            }
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
}
