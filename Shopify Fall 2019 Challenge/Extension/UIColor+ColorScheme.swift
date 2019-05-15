//
//  UIColor+ColorScheme.swift
//  Shopify Fall 2019 Challenge
//
//  Created by Subhan Chaudhry on 2019-05-15.
//  Copyright © 2019 Subhan Chaudhry. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     Static method to get colors for wordSearch from Asset bundle
     
     - Returns: Array of UIColors
     */
    static func arrayOfCandyColors() -> [UIColor] {
        return [
            UIColor(named: "DeepBlue")!,
            UIColor(named: "Peach")!,
            UIColor(named: "SunsetYellow")!,
            UIColor(named: "Teal")!,
            UIColor(named: "LeatherBrown")!,
            UIColor(named: "MossyGreen")!
        ]
    }
}
