//
//  LabelCollectionViewCell.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-12.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import UIKit

class LabelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    func set(withText text: String) {
        label.text = text
    }
}
