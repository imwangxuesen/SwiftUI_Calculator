//
//  CalculatorModel.swift
//  Calculator
//
//  Created by WangXuesen on 2020/9/6.
//  Copyright © 2020 OneV's Den. All rights reserved.
//

import Foundation
import Combine

class CalculatorModel: ObservableObject {

//    var objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var brain: CalculatorBrain = .left("0")
    
    @Published var history: [CalculatorButtonItem] = []
    
    var historyDetail: String {
        history.map { $0.description }.joined()
    }
    
    var temporaryKept: [CalculatorButtonItem] = []
    
    var totalCount: Int {
        history.count + temporaryKept.count
    }
    
    var slidingIndex: Float = 0 {
        didSet {
            // 维护`history` `temporaryKept`
            keepHistory(upTo: Int(slidingIndex))
        }
    }
    
    func keepHistory(upTo index: Int) {
        precondition(index <= totalCount, "Out of index.")
        let total = history + temporaryKept
        
        history = Array(total[..<index])
        
        temporaryKept = Array(total[index...])
        
        brain = history.reduce(CalculatorBrain.left("0")) { (result, item) in
            result.apply(item: item)
        }
    }
    
    func apply(_ item: CalculatorButtonItem) {
        brain = brain.apply(item: item)
        history.append(item)
        temporaryKept.removeAll()
        slidingIndex = Float(totalCount)
//        objectWillChange.send()
    }
}
