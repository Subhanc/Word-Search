//
//  GameViewController.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-02.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var words = [Word]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wordSearch = WordSearch(gridSize: 10, difficulty: .hard)
        wordSearch.makeWords()
        wordSearch.makeGrid()
    }
    
    func makeWords() {
        words.append(Word(wordItem:"Coding"))
        words.append(Word(wordItem:"Shopify"))
        words.append(Word(wordItem:"Developer"))
        words.append(Word(wordItem:"Toronto"))
        words.append(Word(wordItem:"Canada"))
    }
}

//extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
//
//    
//}



