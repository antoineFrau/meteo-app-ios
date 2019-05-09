//
//  extensionColor.swift
//  MeteoApp
//
//  Created by Antoine Frau on 18/04/2019.
//  Copyright © 2019 Antoine Frau. All rights reserved.
//

import UIKit
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
