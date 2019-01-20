//
//  RectBrush.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

class RectBrush: BaseBrush {

    override func drawInContext(_ context: CGContext) {
        
        let startPoint = CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y))
        
        let width = abs(endPoint.x - beginPoint.x)
        let higth = abs(endPoint.y - beginPoint.y)
        
        context.addRect(
            CGRect(origin: startPoint,
                   size: CGSize(width: width, height: higth)
                    )
        )
    }
    
    override func name() -> String{
        return "Rectangle"
    }
}
