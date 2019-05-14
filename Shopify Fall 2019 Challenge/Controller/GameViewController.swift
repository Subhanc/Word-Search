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
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var wordsListView: TagListView!
    
    var labels = [Label]()
    let wordSearch = WordSearch(gridSize: 10, difficulty: .hard)
    
    var lastSelectedIndexPath = IndexPath()
    var isFirstSelectedCell = true
    var firstSelectedCell: IndexPath?
    var direction: (x: Int, y: Int)?

    override func viewDidLoad() {
        super.viewDidLoad()
        wordSearch.makeWords()
        wordSearch.makeGrid()
        labels = wordSearch.collapsedLabels()
        wordsListView.addTags(wordSearch.words.map { word in
            return word.wordItem
        })
        wordsListView.alignment = .center
        wordsListView.tagViews.map { tagView in
            tagView.tagBackgroundColor = .red
        }
        
        self.setCollectionView()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
        let width = Double(collectionView.frame.width) / (Double(wordSearch.gridSize) * 1.4)
        return CGSize(width: width, height: width)
    }
}

// MARK: Swipe Selection
extension GameViewController: UIGestureRecognizerDelegate {
    func setCollectionView() {
        myCollectionView.canCancelContentTouches = false
        myCollectionView.allowsMultipleSelection = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(toSelectLabelCells:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        myCollectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func didPan(toSelectLabelCells panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            myCollectionView.isScrollEnabled = false
            myCollectionView.isUserInteractionEnabled = false
            isFirstSelectedCell = true
            direction = nil
            break
        case .changed:
            let location = panGestureRecognizer.location(in: myCollectionView)
            if let indexPath = myCollectionView.indexPathForItem(at: location) {
                if isValidIndexPath(for: indexPath) {
                    if let direction = direction {
                        if isValidDirection(for: indexPath, with: direction) {
                            self.selectCell(for: indexPath, selected: true)
                            lastSelectedIndexPath = indexPath
                        }
                    } else {
                        self.selectCell(for: indexPath, selected: true)
                        lastSelectedIndexPath = indexPath
                    }
                    if let cell = firstSelectedCell {
                        direction = getDirection(for: indexPath, withFirst: cell)
                        firstSelectedCell = nil
                    }
                }
                if isFirstSelectedCell {
                    firstSelectedCell = indexPath
                    isFirstSelectedCell = false
                }
            }
            break
        case .ended:
            myCollectionView.isUserInteractionEnabled = true
            myCollectionView.indexPathsForSelectedItems?.forEach { indexPath in
                self.myCollectionView.deselectItem(at: indexPath, animated: true)
            }
            break
        default:
            break
        }
    }
    
    func isValidIndexPath(for indexPath: IndexPath) -> Bool {
        return indexPath != lastSelectedIndexPath
    }
    
    func isValidDirection(for indexPath: IndexPath, with direction: (x: Int, y: Int)) -> Bool {
        return getDirection(for: indexPath, withFirst: lastSelectedIndexPath) == direction
    }
    
    func getDirection(for indexPath: IndexPath, withFirst firstCell: IndexPath) -> (x: Int, y: Int) {
        let rowDifference = indexPath.row - firstCell.row
        
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
    
    func selectCell(for indexPath: IndexPath, selected: Bool) {
        if let cell = myCollectionView.cellForItem(at: indexPath) {
            if !cell.isSelected {
                myCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                handleWin()
            }
        }
    }
    
    func didWinWordSearch() -> Bool {
        let selectedWord = self.myCollectionView.indexPathsForSelectedItems!.map { labels[$0.row].letter }.sorted()
        for word in wordSearch.words {
            if word.wordItem.sorted() == selectedWord {
                return true
            }
        }
        return false
    }
    
    func handleWin() {
        if didWinWordSearch() {
            // TODO: Finish word search winning
        }
    }
}
