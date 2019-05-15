//
//  WordSearch.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-11.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import Foundation

/// Type of direction where placement needs to be
enum PlacementType: CaseIterable {
    case leftRight
    case rightLeft
    case upDown
    case downUp
    case topLeftBottomRight
    case topRightBottomLeft
    case bottomLeftTopRight
    case bottomRightTopLeft
    
    /// Directional unit vectors method
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

/// Difficulty levels as enum types
enum Difficulty {
    case easy
    case medium
    case hard
    
    /// Placement types to be used fo difficulty type
    var placementTypes: [PlacementType] {
        switch self {
        case .easy:
            return [.leftRight, .upDown].shuffled()
        case .medium:
            return [.leftRight, .rightLeft, .downUp, .upDown].shuffled()
        case .hard:
            return PlacementType.allCases.shuffled()
        }
    }
}

/**
 Word Search Object Model to draw words in 1-D and 2-D Arrays as Labels
 
 Use by:
 ```
 let wordSearch = WordSearch(usingGridSize: 10, withDifficulty: .hard)
 wordSearch.getDefaultLabels()
 wordSearch.make()
 let labels = wordSearch.collapsedLabels()
 ```
 
 - Author: Subhan Chaudhry
 */
class WordSearch {
    /// Array of words that need to be found in game
    var words = [Word]()
    
    /// Two-dimensional array of Labels of all letters to be placed in wordSearch grid
    var labels = [[Label]]()
    
    /// Size of wordSearch grid
    var gridSize: Int
    
    /// Difficulty of game
    var difficulty: Difficulty
    
    /// An array of alphabets from A-Z, using Unicode scalars
    var allLettersInAlphabet = (65...90).map { Character(Unicode.Scalar($0))}
    
    /**
     Initializes new game with given gridSize and difficulty type
     
     - Parameters:
         - usingGridSize: using grid size of wordSearch
         - withDifficulty: difficulty of the game
     */
    init(usingGridSize gridSize: Int, withDifficulty difficulty: Difficulty) {
        self.gridSize = gridSize
        self.difficulty = difficulty
    }
    
    /**
     Convenience initializer for setting a custom words list as string, with gridSixe and Difficulty type
     
     - Parameters:
         - fromWordsAsStrings: string array for words to be searched by user
         - usingGridSize: length and height of grid
         - withDifficulty: difficulty type of game
     */
    convenience init(fromWordsAsStrings strings: [String], usingGridSize gridSize: Int, withDifficulty difficulty: Difficulty) {
        self.init(usingGridSize: gridSize, withDifficulty: difficulty)
        self.words = strings.map { Word(wordItem: $0.uppercased()) }
    }
    
    /**
     Collapses 2-D Labels array to 1-D for CollectionView use
     - Returns: 1-D array from 2-D array
     */
    func collapsedLabels() -> [Label] {
        return Array(labels.joined())
    }
    
    /// Sets words to default values as per instructions
    func setDefaultWords() {
        // Shopify words: Swift, Kotlin, ObjectiveC, Variable, Java, Mobile
        words.append(Word(wordItem:"Swift"))
        words.append(Word(wordItem:"Kotlin"))
        words.append(Word(wordItem:"ObjectiveC"))
        words.append(Word(wordItem:"Variable"))
        words.append(Word(wordItem:"Java"))
        words.append(Word(wordItem:"Mobile"))
        
        // Capitalize default words
        words.forEach { word in
            word.wordItem = word.wordItem.uppercased()
        }
    }
    
    /// Sets up the game
    func make() {
        // Initializes array of arrays of labels
        labels = (0..<gridSize).map { _ in
            return (0..<gridSize).map { _ in
                return Label()
            }
        }
        // Place all words in their respective indices
        placeWords()
        // Fill all remaining spots with random letters
        fillEmptySpots()
    }
    
    /// Fills the empty spots in grid after placing words
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
    
    /// Prints the grid to console
    func printGrid()  {
        for column in labels {
            for row in column {
                print(row.letter, terminator: "")
            }
            print("")
        }
    }
    
    
    /**
     Returns label location for which the word is to be placed
     
     - Parameters:
         - x: start x position
         - y: start y position
         - word: word to be placed
         - movement: Tuple for x and y unit vectors
     
     - Returns: Array of labels locations
     */
    func getAvailableLabels(x: Int, y: Int, for word: String, withMovement movement: (x: Int, y: Int)) -> [Label]? {
        
        var returnArray = [Label]()
        
        var xPosition = x;
        var yPosition = y;
        
        for letter in word {
            let label = labels[xPosition][yPosition]
            
            // If location can be used as part of our word
            if label.letter == " " || label.letter == letter {
                returnArray.append(label)
                xPosition += movement.x
                yPosition += movement.y
            } else {
                // Cannot be used
                return nil
            }
        }
        return returnArray
    }
    
    /**
     Checks if a word can be placed in given movement unit vector direction
     
     - Parameters:
         - word: word item to be placed
         - movement: Tuple that indicates direction of word to be placed
     
     - Returns: true if word was correctly placed
     */
    func didPlace(_ word: String, withMovement movement: (x: Int, y: Int)) -> Bool {
        
        let xLength = movement.x * (word.count - 1)
        let yLength = movement.y * (word.count - 1)
        
        let rows = (0 ..< gridSize).shuffled()
        let cols = (0 ..< gridSize).shuffled()
        
        for row in rows {
            for col in cols {
                let finalX = col + xLength
                let finalY = row + yLength
                
                if (finalX >= 0 && finalX < gridSize && finalY >= 0 && finalY < gridSize) {
                    if let returnArray = getAvailableLabels(x: col, y: row, for: word, withMovement: movement) {
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
    
    /**
     Checks to see if word can be placed in any direction within the difficulty placementTypes
     
     - Parameter word: word item to be placed
     
     - Returns: true if word is able to be placed
     */
    func isPlace(_ word: String) -> Bool {
        for type in difficulty.placementTypes {
            if (didPlace(word, withMovement: type.movement)) {
                return true
            }
        }
        return false
    }
    
    /**
     Places the words in the grid
     - Returns: the word array that were placed
     */
    func placeWords() -> [Word] {
        words.shuffle()
        
        var usedWords = [Word]()
        
        for word in words {
            if isPlace(word.wordItem) {
                usedWords.append(word)
            }
        }
        return usedWords
    }
    
    /**
     Sets words to words object of WordSearch
     - Parameter words: given Word array
     */
    func setWords(_ words:[Word]) {
        self.words = words
    }
}
