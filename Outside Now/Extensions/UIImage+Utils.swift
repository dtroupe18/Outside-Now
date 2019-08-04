//
//  UIImage+Utils.swift
//  Outside Now
//
//  Created by Dave Troupe on 8/3/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import UIKit

extension UIImage {
    /// Draws text on image at the point provided
    func addTextToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage? {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica", size: 12)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]

        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
