//
//  UIImage+resized.swift
//  StoreSearch
//
//  Created by 123 on 06.04.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        // “Aspect Fit” rules - scales to the longest side
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

