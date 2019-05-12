//
//  WordSearch.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-11.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import Foundation

enum PlacementType: CaseIterable {
    case leftRight
    case rightLeft
    case upDown
    case downUp
    case topLeftBottomRight
    case topRightBottomLeft
    case bottomLeftTopRight
    case bottomRightTopLeft

    var movement:(x: Int, y: Int) {
        switch self {
        case .leftRight:
            return (1,0)
        case .rightLeft:
            return (-1, 0)
        case .upDown:
            return (0, 1)
        case .downUp:
            return (0, -1)
        case .topLeftBottomRight:
             return (1, 1)
        case .topRightBottomLeft:
             return (-1, 1)
        case .bottomLeftTopRight:
             return (1, -1)
        case .bottomRightTopLeft:
             return (-1, -1)
        }
    }
}

enum Difficulty {
    case easy
    case medium
    case hard

    var placementTypes: [PlacementType] {
        switch self {
        case .easy:
            return [.leftRight, .upDown].shuffled()
        case .medium:
            return [.leftRight, .rightLeft, .downUp, .upDown].shuffled()
        case .hard:
            return PlacementType.allCases.shuffled()
//          return [.leftRight, .rightLeft, .downUp, .upDown, .topLeftBottomRight, .topRightBottomLeft,              .bottomLeftTopRight, .bottomRightTopLeft].shuffled()
        }
    }
}

class WordSearch {
    var words = [Word]()
    //two-dimensional array
    var labels = [[Label]]()
    var gridSize: Int
    var difficulty: Difficulty
    
    // an array from A-Z
    var allLettersInAlphabet = (65...90).map { Character(Unicode.Scalar($0))}
    
    init(gridSize: Int, difficulty: Difficulty) {
        self.gridSize = gridSize
        self.difficulty = difficulty
    }
    
    func collapsedLabels() -> [Label] {
        return Array(labels.joined())
    }
    
    func makeWords() {
        words.append(Word(wordItem:"Swift"))
        words.append(Word(wordItem:"Kotlin"))
        words.append(Word(wordItem:"ObjectiveC"))
        words.append(Word(wordItem:"Variable"))
        words.append(Word(wordItem:"Java"))
        words.append(Word(wordItem:"Mobile"))
        
        words.forEach { word in
            word.wordItem = word.wordItem.uppercased()
        }
        //Swift, Kotlin, ObjectiveC, Variable, Java, Mobile
    }
    
    func makeGrid() {
        //array of arrays
        labels = (0..<gridSize).map { _ in
            return (0..<gridSize).map { _ in
                return Label()
            }
        }
        //labels = Array(repeating: Array(repeating: Label(), count: gridSize), count: gridSize)
        placeWords()
        fillEmptySpots()
        printGrid()
    }
    
    private func fillEmptySpots() {
        for column in labels {
            for label in column {
                if label.letter == " " {
                    label.letter = allLettersInAlphabet.randomElement()!
                    allLettersInAlphabet.shuffle()
                }
            }
        }
    }
    
    func printGrid()  {
        for column in labels {
            for row in column {
                print(row.letter, terminator: "")
            }
            print("")
        }
    }
    

    func getAvailableLabels(x: Int, y: Int, word: String, movement: (x: Int, y: Int)) -> [Label]? {
        
        var returnArray = [Label]()
        
        var xPosition = x;
        var yPosition = y;
        
        for letter in word {
            let label = labels[xPosition][yPosition]
            
            //if location can be used as part of our word
            if label.letter == " " || label.letter == letter {
                returnArray.append(label)
                xPosition += movement.x
                yPosition += movement.y
            } else {
                //cannot be used
                return nil
            }
        }
        return returnArray
    }
    
    func didPlace(word: String, movement: (x: Int, y: Int)) -> Bool {
        
        let xLength = movement.x * (word.count - 1)
        let yLength = movement.y * (word.count - 1)
        
        let rows = (0 ..< gridSize).shuffled()
        let cols = (0 ..< gridSize).shuffled()
        
        for row in rows {
            for col in cols {
                let finalX = col + xLength
                let finalY = row + yLength
                
                if (finalX >= 0 && finalX < gridSize && finalY >= 0 && finalY < gridSize) {
                    if let returnArray = getAvailableLabels(x: col, y: row, word: word, movement: movement) {
                        for (index, letter) in word.enumerated() {
                            returnArray[index].letter = letter
                        }
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isPlace(word: String) -> Bool {
        for type in difficulty.placementTypes {
            if (didPlace(word: word, movement: type.movement)) {
                return true
            }
        }
//        return difficulty.placementTypes.contains {
//            didPlace(word: word, movement: $0.movement)
//        }
        return false
    }
    
    func placeWords() -> [Word] {
        words.shuffle()
        
        var usedWords = [Word]()
        
        for word in words {
            if isPlace(word: word.wordItem) {
                usedWords.append(word)
            }
        }
        return usedWords
    }
    
    func setWords(words:[Word]) {
        self.words = words
    }
}






