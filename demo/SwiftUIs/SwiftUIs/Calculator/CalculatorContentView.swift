//
//  CalculatorContentView.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/24.
//

import SwiftUI

struct CalculatorContentView: View {
    
    let scale = UIScreen.main.bounds.width / 414
    @EnvironmentObject var model: CalculatorModel
    @State private var editingHistory: Bool = false
    @State private var isAlert: Bool = false
    
    var body: some View {
        
        VStack(spacing: 12) {
            Spacer()
            Button("操作履历: \(model.history.count)") {
                self.editingHistory = true
            }.sheet(isPresented: self.$editingHistory) {
                HistoryView(model: self.model, editingHistory: self.$editingHistory)
            }
            
            Text(model.brain.output)
                .font(.system(size: 76))
                .minimumScaleFactor(0.5)
                .padding(.trailing, 24 * scale)
                .lineLimit(1) // 限制一行
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .onTapGesture {
                    self.isAlert = true
                }.alert(isPresented: self.$isAlert) {
                    Alert(title: Text("\(model.historyDetail)"), message: Text("\(model.brain.output)"), primaryButton: .default(Text("复制"), action: {
                        UIPasteboard.general.string = model.brain.output
                    }), secondaryButton: .cancel(Text("取消")))
                }
            CalculatorButtonPad()
                .padding(.bottom)
        }
    }
}

struct CalculatorButtonPad: View {
    
    let pads: [[CalculatorButtonItem]] = [
        [.command(.clear), .command(.flip), .command(.percent), .op(.divide)],
        [.digit(7), .digit(8), .digit(9), .op(.multiply)],
        [.digit(4), .digit(5), .digit(6), .op(.minus)],
        [.digit(1), .digit(2), .digit(3), .op(.plus)],
        [.digit(0), .dot, .op(.equal)]
    ]
    
    var body: some View {
        
        VStack(spacing: 8) {
            ForEach(pads, id: \.self) { row in
                CalculatorButtonRow(row: row)
            }
        }
    }
}

struct CalculatorButtonRow: View {
    
    let row: [CalculatorButtonItem]
    @EnvironmentObject var model: CalculatorModel
    
    var body: some View {
        HStack {
            ForEach(row, id: \.self) { item in
                CalculatorButton(title: item.title, size: item.size, backgroundColorName: item.backgroundColorName) {
                    
                    self.model.apply(item)
                }
            }
        }
    }
}

// MARK: - CalculatorButton
struct CalculatorButton: View {
    
    let fontSize: CGFloat = 38
    let title: String
    let size: CGSize
    let backgroundColorName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .frame(width: size.width, height: size.height)
                .background(Color(backgroundColorName))
                .cornerRadius(size.width / 2)
        })
    }
}

/// MARK: - HistoryView
struct HistoryView: View {
    
    @ObservedObject var model: CalculatorModel
    @Binding var editingHistory: Bool
    
    var body: some View {
        Button {
            self.editingHistory.toggle()
        } label: {
            Text("关闭")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 72, height: 36)
                .background(Color.orange)
                .cornerRadius(30)
        }

        VStack {
            if model.totalCount == 0 {
                Text("没有履历")
            } else {
                HStack {
                    Text("履历").font(.headline)
                    Text("\(model.historyDetail)").lineLimit(nil)
                }
                HStack {
                    Text("履历").font(.headline)
                    Text("\(model.brain.output)")
                }
                Slider(value: $model.slidingIndex, in: 0...Float(model.totalCount))
            }
        }.padding()
    }
}


struct CalculatorContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorContentView().environment(\.colorScheme, .dark) // 适配dark mode
        // CalculatorContentView().previewDevice("iPhone SE") // 预览
        // CalculatorContentView().previewDevice("iPad Air 2")
    }
}


