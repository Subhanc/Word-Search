//
//  LabelCollectionViewCell.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-12.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import UIKit

class LabelCollectionViewCell: UICollectionViewCell {
    
    /// UILabel for letter Character
    @IBOutlet weak var label: UILabel!
    
    /// Var to check if cell is used for a winning word
    var isWord = false
    
    override var isSelected: Bool {
        didSet {
            // if used in a word, do not change backgroundColor back to white or gray
            if !isWord {
                self.backgroundColor = self.isSelected ? UIColor(named: "DeepPurple")! : UIColor(named: "DarkPurple")!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // cell design
        self.layer.cornerRadius = 8
        self.isUserInteractionEnabled = false
    }
    
    /**
     Sets backgroundColor to specified color
     
     - Parameter to: color to be changed to
     */
    func setColor(to color: UIColor) {
        self.backgroundColor = color
        isWord = true
    }
    
    /**
     Sets the label to specified text
     
     - Parameter text: text to be used
     */
    func set(withText text: String) {
        label.text = text
    }
}
