//
//  GameLogic.swift
//  SwiftUI-2048
//
//  Created by Jovins on 2021/7/27.
//

import Foundation
import SwiftUI
import Combine

final class GameLogic: ObservableObject {
    
    enum Direction {
        case left
        case right
        case up
        case down
    }
    
    typealias BlockMatrixType = BlockMatrix<IdentifiedBlock>
    let objectWillChange = PassthroughSubject<GameLogic, Never>()
    
    @Published fileprivate(set) var lastGestureDirection: Direction = .up
    
    fileprivate var _blockMatrix: BlockMatrixType!
    var blockMatrix: BlockMatrixType {
        return _blockMatrix
    }
    
    fileprivate var _globalID = 0
    fileprivate var newGlobalID: Int {
        _globalID += 1
        return _globalID
    }
    
    init() {
        
        newGame()
    }
    
    
    // MARK: - fileprivate
    fileprivate func newGame() {
        
        _blockMatrix = BlockMatrixType()
        resetLastGestureDirection()
        generateNewBlocks()
        objectWillChange.send(self)
    }
    
    fileprivate func resetLastGestureDirection() {
        lastGestureDirection = .up
    }
    
    @discardableResult fileprivate func generateNewBlocks() -> Bool {
        var blankLocations = [BlockMatrixType.Index]()
        for rowIndex in 0..<4 {
            for colIndex in 0..<4 {
                let index = (colIndex, rowIndex)
                if _blockMatrix[index] == nil {
                    blankLocations.append(index)
                }
            }
        }
        
        guard blankLocations.count >= 2 else {
            return false
        }
        
        // Don't forget to sync data.
        defer {
            objectWillChange.send(self)
        }
        
        // Place the first block.
        var placeLocIndex = Int.random(in: 0..<blankLocations.count)
        _blockMatrix.place(IdentifiedBlock(id: newGlobalID, number: 2), to: blankLocations[placeLocIndex])
        
        // Place the second block.
        guard let lastLoc = blankLocations.last else {
            return false
        }
        blankLocations[placeLocIndex] = lastLoc
        placeLocIndex = Int.random(in: 0..<(blankLocations.count - 1))
        _blockMatrix.place(IdentifiedBlock(id: newGlobalID, number: 2), to: blankLocations[placeLocIndex])
        
        return true
    }
    
    fileprivate func merge(blocks: inout [IdentifiedBlock], reverse: Bool) {
        if reverse {
            blocks = blocks.reversed()
        }
        
        blocks = blocks
            .map { (false, $0) }
            .reduce([(Bool, IdentifiedBlock)]()) { acc, item in
                if acc.last?.0 == false && acc.last?.1.number == item.1.number {
                    var accPrefix = Array(acc.dropLast())
                    var mergedBlock = item.1
                    mergedBlock.number *= 2
                    accPrefix.append((true, mergedBlock))
                    return accPrefix
                } else {
                    var accTmp = acc
                    accTmp.append((false, item.1))
                    return accTmp
                }
            }
            .map { $0.1 }
        
        if reverse {
            blocks = blocks.reversed()
        }
    }
    
    // MARK: - Public
    func move(_ direction: Direction) {
        
        defer {
            objectWillChange.send(self)
        }
        
        lastGestureDirection = direction
        var moved = false
        let axis = direction == .left || direction == .right
        
        for row in 0..<4 {
            var rowSnapshot = [IdentifiedBlock?]()
            var compactRow = [IdentifiedBlock]()
            for col in 0..<4 {
                // Transpose if necessary.
                if let block = _blockMatrix[axis ? (col, row) : (row, col)] {
                    rowSnapshot.append(block)
                    compactRow.append(block)
                }
                rowSnapshot.append(nil)
            }
            
            merge(blocks: &compactRow, reverse: direction == .down || direction == .right)
            
            var newRow = [IdentifiedBlock?]()
            compactRow.forEach { newRow.append($0) }
            if compactRow.count < 4 {
                for _ in 0..<(4 - compactRow.count) {
                    if direction == .left || direction == .up {
                        newRow.append(nil)
                    } else {
                        newRow.insert(nil, at: 0)
                    }
                }
            }
            
            newRow.enumerated().forEach {
                if rowSnapshot[$0]?.number != $1?.number {
                    moved = true
                }
                _blockMatrix.place($1, to: axis ? ($0, row) : (row, $0))
            }
        }
        
        if moved {
            generateNewBlocks()
        }
    }
}
