//
//  GradientView.swift
//  StoreSearch
//
//  Created by 123 on 03.04.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        // tells the view that it should change both its width and its height proportionally
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
    }
    
    override func draw(_ rect: CGRect) {
        // better put it in lazy clouser and reuse
        let components: [CGFloat] = [ 0, 0, 0, 0.3,
                                      0, 0, 0, 0.7 ]
        let locations: [CGFloat] = [ 0, 1 ]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace,
                                  colorComponents: components,
                                  locations: locations,
                                  count: 2)

        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y : y)
        let radius = max(x, y)

        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!,
                                    startCenter: centerPoint,
                                    startRadius: 0,
                                    endCenter: centerPoint,
                                    endRadius: radius,
                                    options: .drawsAfterEndLocation)
    }
}

















