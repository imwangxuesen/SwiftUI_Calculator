//
//  ContentView.swift
//  Calculator
//
//  Created by Wang Wei on 2019/06/17.
//  Copyright © 2019 OneV's Den. All rights reserved.
//
//  我们看到了 SwiftUI 中的几种处理数据和逻辑的方式。根据适用范围和存储状态的复杂度的不同，需要选取合适的方案。@State 和 @Binding 提供 View 内部的状态存储，它们应该是被标记为 private 的简单值类型，仅在内部使用。ObservableObject 和 @ObservedObject 则针对跨越 View 层级的状态共享，它可以处理更复杂的数据类型，其引用类型的特点，也让我们需要在数据变化时通过某种手段向外发送通知 (比如手动调用 objectWillChange.send() 或者使用 @Published)，来触发界面刷新。对于“跳跃式”跨越多个 View 层级的状态，@EnvironmentObject 能让我们更方便地使用 ObservableObject，以达到简化代码的目的。”
//
//摘录来自: 王 巍. “SwiftUI 和 Combine 编程。” Apple Books.

import SwiftUI
import Combine

let scale = UIScreen.main.bounds.width / 414

struct ContentView : View {
    
    
    // 这里也可以用@ObservedObject来进行数据流传递,但是需要
    // 向其子层`CalculatorButtonPad` `CalculatorButtonRow`
    // 进行`$model`的绑定传餐,但是,
    // 显然我们在 `CalculatorButtonPad`中并没有用到model中任何
    // 内容,它只是作为中间人又传给了`CalculatorButtonRow`,那
    // 这样就没有什么意义,不如用@EnvironmentObject做一个全局的
    // 数据流,直达要害
    @EnvironmentObject var model: CalculatorModel
    // 控制回溯信息是否以alert形式弹出
    @State private var showingResult = false
    // 控制回溯sheet是否弹出
    @State private var editingHistory = false
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            //弹出回溯信息alert按钮
//            Button("操作履历:\(model.history.count)") {
//                self.showingResult = true
//            }
            HistoryView()
            // 回溯信息alert
            .alert(isPresented: self.$showingResult, content: {
                return Alert(title: Text("履历"), message: Text("\(model.historyDetail)"), primaryButton: Alert.Button.destructive(Text("确定"), action: {
                    self.showingResult = false
                }), secondaryButton: Alert.Button.cancel({
                    self.showingResult = false
                }))
            })
            
//            .sheet(isPresented: self.$editingHistory, content: {
//                Button("取消") {
//                    self.editingHistory = false
//                }
//                HistoryView()
//            })
            
            
            Text(self.model.brain.output)
                .font(.system(size: 76))
                .minimumScaleFactor(0.5)
                .padding(.trailing, 24 * scale)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .trailing)
                
            
            CalculatorButtonPad()
                .padding(.bottom)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView().previewDevice("iPhone SE")
            ContentView().previewDevice("iPad Air 2")
        }
    }
}

struct CalculatorButton : View {
    let fontSize: CGFloat = 38
    let title: String
    let size: CGSize
    let backgroundColorName: String
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize * scale))
                .foregroundColor(foregroundColor)
                .frame(width: size.width * scale, height: size.height * scale)
                .background(Color(backgroundColorName))
                .cornerRadius(size.width * scale / 2)
        }
    }
}

struct CalculatorButtonRow : View {
    @EnvironmentObject var model: CalculatorModel
    let row: [CalculatorButtonItem]
    var body: some View {
        HStack {
            ForEach(row, id: \.self) { item in
                CalculatorButton(
                    title: item.title,
                    size: item.size,
                    backgroundColorName: item.backgroundColorName,
                    foregroundColor: item.foregroundColor)
                {
                    self.model.apply(item)
                }
            }
        }
    }
}

struct CalculatorButtonPad: View {
    let pad: [[CalculatorButtonItem]] = [
        [.command(.clear), .command(.flip),
         .command(.percent), .op(.divide)],
        [.digit(7), .digit(8), .digit(9), .op(.multiply)],
        [.digit(4), .digit(5), .digit(6), .op(.minus)],
        [.digit(1), .digit(2), .digit(3), .op(.plus)],
        [.digit(0), .dot, .op(.equal)]
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(pad, id: \.self) { row in
                CalculatorButtonRow(row: row)
            }
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject var model: CalculatorModel
    
    var body: some View {
        VStack {
            if model.totalCount == 0 {
                Text("没有履历")
            } else {
                HStack {
                    Text("显示").font(.headline)
                    Text("\(model.historyDetail)").lineLimit(nil)
                }
                
                HStack {
                    Text("显示").font(.headline)
                    Text("\(model.brain.output)")
                }
                
                Slider(
                    value: $model.slidingIndex,
                    in: 0...Float(model.totalCount),
                    step: 1
                )
            }
        }.padding()
    }
}


struct AlertContent: View {
    @EnvironmentObject var model: CalculatorModel
    
    var body: some View {
        VStack {
            Text("\(model.historyDetail)")
            Text("\(model.brain.output)")
        }
    }
}
