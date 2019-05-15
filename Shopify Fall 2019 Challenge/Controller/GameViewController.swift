//
//  GameViewController.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-12.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import UIKit
import TagListView

class GameViewController: UIViewController {
    
    // MARK: IB Outlets
    /// Collection View that holds the word search game.
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    /// Tag List View for displaying words collection found / to be found.
    @IBOutlet weak var wordsListView: TagListView!
    
    /// Label to display number of words currently collected.
    @IBOutlet weak var wordsCollectedLabel: UILabel!
    
    // MARK: WordSearch Vars
    /// Collapsed 1-D wordSearch labels array to display letters in myCollectionView
    var labels = [Label]()
    
    /// WordSearch object model to generate word search grid.
    var wordSearch = WordSearch(usingGridSize: 10, withDifficulty: .hard)
    
    /// Dictionary to hold found words in wordSearch by user.
    var foundWords = [String: Bool]()
    
    // MARK: Selection Vars
    /// Index Path to cell that was last selected, initially a blank object
    var lastSelectedIndexPath = IndexPath()
    
    /// If the last selected cell is the first in selection, used to determine direction
    var isFirstSelectedCell = true
    
    /// First cell in drag selection
    var firstSelectedCell: IndexPath?
    
    /// Direction of current selection in unit vector form
    var direction: (x: Int, y: Int)?
    
    // MARK: Word Count and Color Vars
    /// Number of words currently found
    var wordCount = 0
    
    /// Next color index
    var nextColor = 0
    
    /// Colors from Asset bundle using static method from custom UIColor extension
    var colors: [UIColor] = UIColor.arrayOfCandyColors()
    
    
    /// Handles button to reset game
    @IBAction func didPressResetButton(_ sender: UIBarButtonItem) {
        self.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWordSearch()
        self.setupWordsListView()
        wordsSelectedDidChange()
        
        self.setCollectionView()
        
        // Disables swipe to go back in navigation controller
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    /// Resets the Game, returning to the main screen
    func reset() {
        self.navigationController!.popViewController(animated: true)
    }
    
    /// Sets up wordSearch by getting words
    func setupWordSearch() {
        wordSearch.setDefaultWords()
        wordSearch.make()
        labels = wordSearch.collapsedLabels()
    }
    
    /// Updates wordsCollectedLabel's text to new wordCount value
    func wordsSelectedDidChange() {
        wordsCollectedLabel.text = "Words Collected: \(wordCount <= labels.count ? wordCount : wordSearch.words.count) out of \(wordSearch.words.count) words"
    }
    
    /// Sets up TagListView, adding words to be found from wordSearch
    func setupWordsListView() {
        wordsListView.removeAllTags()
        // Adds tags by getting each word's word item
        wordsListView.addTags(wordSearch.words.map { word in
            return word.wordItem
        })
        // Align center for tags
        wordsListView.alignment = .center
        wordsListView.textColor = .white
        wordsListView.tagViews.map { tagView in
            tagView.tagBackgroundColor = UIColor(named: "DarkPurple")!
        }
    }
}

// MARK: UICollectionView Protocol Conformations
extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! LabelCollectionViewCell
        cell.set(withText: String(labels[indexPath.row].letter))
        return cell
    }
}

extension GameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Width of cells depend on number of items in wordSearch's grid's row
        let width = Double(collectionView.frame.width) / (Double(wordSearch.gridSize) * 1.4)
        return CGSize(width: width, height: width)
    }
}

// MARK: Swipe Selection Gesture Delegate Conformation
extension GameViewController: UIGestureRecognizerDelegate {
    
    /// Sets up myCollectionView with Swipe Gesture recognizer
    func setCollectionView() {
        myCollectionView.canCancelContentTouches = false
        myCollectionView.allowsMultipleSelection = true
        
        // Initialize pan gesture recognizer to handle swiping on collectionView
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(toSelectLabelCells:)))
        // limit to one finger
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.minimumNumberOfTouches = 1
        // sets the gestureRecognizer's delegate
        panGestureRecognizer.delegate = self
        myCollectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    /**
     Handles UIPanGestureRecognizer states
     
     - Parameter toSelectLabelCells: pan gesture recognizer to be handled
     
     Uses @objc flag for selector support in setCollectionView()
     */
    @objc func didPan(toSelectLabelCells panGestureRecognizer: UIPanGestureRecognizer) {
        // Handles all gesture recognizer states
        switch panGestureRecognizer.state {
        case .began:
            // Disable scrolling and all user interaction to limit touches
            myCollectionView.isScrollEnabled = false
            myCollectionView.isUserInteractionEnabled = false
            isFirstSelectedCell = true
            direction = nil
            implementDrag(with: panGestureRecognizer)
            break
        case .changed:
            implementDrag(with: panGestureRecognizer)
            break
        case .ended:
            // Turns user interaction back on
            myCollectionView.isUserInteractionEnabled = true
            // Deselects all selected items
            myCollectionView.indexPathsForSelectedItems?.forEach { indexPath in
                self.myCollectionView.deselectItem(at: indexPath, animated: true)
            }
            break
        default:
            break
        }
    }
    
    /**
     Handles drag motion changes to constrain swipe direction and communicate wins to the user
     
     - Parameter with: pan gesture recognizer to be handled
     */
    func implementDrag(with panGestureRecognizer: UIPanGestureRecognizer) {
        // Location of view as CGPoint
        let location = panGestureRecognizer.location(in: myCollectionView)
        // Convert point to indexPath in myCollectionView
        if let indexPath = myCollectionView.indexPathForItem(at: location) {
            // Check if indexPath is valid
            if isValidIndexPath(for: indexPath) {
                // Check if direction stored exists, if so, select the cell by first checking if
                // the direction is consistent
                if let direction = direction {
                    if isValidDirection(for: indexPath, with: direction) {
                        self.selectCell(at: indexPath)
                        // save last indexPath for next gesture event
                        lastSelectedIndexPath = indexPath
                    }
                } else {
                    // direction has not been set, so just select the cell
                    self.selectCell(at: indexPath)
                    lastSelectedIndexPath = indexPath
                }
                // if the last cell was the first cell, then get the direction
                if let cell = firstSelectedCell {
                    direction = getDirection(for: indexPath, withFirst: cell)
                    // once done, set the first cell as nil
                    firstSelectedCell = nil
                }
            }
            // if this cell is the first cell, save it to firstSelected Cell
            if isFirstSelectedCell {
                firstSelectedCell = indexPath
                isFirstSelectedCell = false
            }
        }
    }
    
    /**
     Checks if indexPath is not the lastSelectedIndexPath
     
     - Parameter for: indexPath to be checked
     - Returns: true if indexPath is not equivalent to lastSelectedIndexPath
     */
    func isValidIndexPath(for indexPath: IndexPath) -> Bool {
        return indexPath != lastSelectedIndexPath
    }
    
    /**
     Checks if direction is the same as one previously determined
     
     - Parameters:
         - for: indexPath to be checked
         - with: direction as unit vector tuple to be checked
     
     - Returns: true if direction is the same
     */
    func isValidDirection(for indexPath: IndexPath, with direction: (x: Int, y: Int)) -> Bool {
        return getDirection(for: indexPath, withFirst: lastSelectedIndexPath) == direction
    }
    
    /**
     Calculates direction based on two index paths, using PlacementType enum from WordSearch
     
     - Parameters:
         - for: index path of last cell
         - withFirst: index path of first cell
     
     - Returns: Direction as a unit vector Tuple
     */
    func getDirection(for indexPath: IndexPath, withFirst firstCell: IndexPath) -> (x: Int, y: Int) {
        // get the difference of two indices
        let rowDifference = indexPath.row - firstCell.row
        
        // return appropriate direction with help of PlacementType member function
        switch rowDifference {
        case 1:
            return PlacementType.leftRight.movement
        case -1:
            return PlacementType.rightLeft.movement
        case (-1 * wordSearch.gridSize):
            return PlacementType.downUp.movement
        case wordSearch.gridSize:
            return PlacementType.upDown.movement
        case wordSearch.gridSize + 1:
            return PlacementType.topLeftBottomRight.movement
        case wordSearch.gridSize - 1:
            return PlacementType.topRightBottomLeft.movement
        case (-1 * wordSearch.gridSize) + 1:
            return PlacementType.bottomRightTopLeft.movement
        case (-1 * wordSearch.gridSize) - 1:
            return PlacementType.bottomLeftTopRight.movement
        default:
            return PlacementType.downUp.movement
        }
    }
    
    /**
     Selects the cell at given IndexPath
     
     - Parameter at: index path for cell to be selected
     */
    func selectCell(at indexPath: IndexPath) {
        if let cell = myCollectionView.cellForItem(at: indexPath) {
            // if cell is not selected, then select it, and handle the win
            if !cell.isSelected {
                myCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                handleDidFindNewWord()
            }
        }
    }
    
    /**
     Checks if user just found a new word
     
     - Returns: Tuple with didWin: true if new word found, and word: the word found as [Character]
     */
    func didFindNewWord() -> (didWin: Bool, word: [Character]?) {
        // Get all indices that are selected, map them by getting correct labels from array and taking each one's letter char
        // then sort it, returning a [Character] array
        let selectedWord = self.myCollectionView.indexPathsForSelectedItems!.map { labels[$0.row].letter }.sorted()
        // check if foundWord contains this word, aka already found, respond that no new word has been found
        // to prevent more score for no additional effort
        if foundWords.contains(where: { $0.key == String(selectedWord) }) {
            return (false, nil)
        }
        // see if the word selected exists in the wordSearch model's word array, then a new word has been found, so
        // return accordingly
        for word in wordSearch.words {
            if word.wordItem.sorted() == selectedWord {
                foundWords[String(selectedWord)] = true
                return (true, selectedWord)
            }
        }
        return (false, nil)
    }
    
    /// Changes wordCount and wordLabelDisplay, changes color for word, and changes correct tag's color
    func handleDidFindNewWord() {
        // get the win tuple from helper method
        let win = didFindNewWord()
        // if the user did win, then increment wordCount, update wordLabel,
        // and update color for collectionViewCells and word list tags
        if win.didWin {
            if let selectedPaths = myCollectionView.indexPathsForSelectedItems {
                wordCount += 1
                wordsSelectedDidChange()
                
                let color = colors[nextColor % colors.count] // makes sure not to overflow
                nextColor += 1
                
                for indexPath in selectedPaths {
                    let cell = myCollectionView.cellForItem(at: indexPath) as! LabelCollectionViewCell
                    cell.setColor(to: color)
                    wordsListView.tagViews.forEach { tagView in
                        if tagView.titleLabel!.text!.sorted() == win.word {
                            tagView.tagBackgroundColor = color
                        }
                    }
                }
                handleWin()
            }
        }
    }
    
    /// Displays Alert to share or restart the game
    func handleWin() {
        if wordCount == wordSearch.words.count {
            let alertController = UIAlertController(title: "Congratulations, You Won!", message: "You found all the words", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Restart Game", style: .destructive, handler: { (action) in
                self.reset()
            }))
            alertController.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
                let actionSheet = UIActivityViewController(activityItems: ["I got all \(self.wordCount) words in the Shopify Word Search Game!"], applicationActivities: nil)
                self.present(actionSheet, animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
