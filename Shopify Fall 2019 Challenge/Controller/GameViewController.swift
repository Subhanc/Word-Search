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
