//
//  WordCell.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-11.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import Foundation

/// Word to hold each word string
class Word {
    ///
    var wordItem: String
    /**
     Initializer
     - Parameter wordItem: string to set wordItem to
     */
    init(wordItem: String) {
        self.wordItem = wordItem
    }
}

/// Label class to hold characters
class Label {
    /// Character for the cell
    var letter: Character = " "
}
