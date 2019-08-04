//
//  UIScrollView+Utils.swift
//  Outside Now
//
//  Created by Dave on 2/17/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

extension UIScrollView {
    // Resets content offset to (0, 0)
    //
    func resetScrollPositionToTop() {
        self.contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
    }
}
