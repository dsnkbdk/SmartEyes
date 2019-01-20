//
//  CircleBrush.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

class CircleBrush: BaseBrush {

    override func drawInContext(_ context: CGContext) {
        // circle
        // context.addArc(center: CGPoint(x: beginPoint.x,y: beginPoint.y), radius: 30, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        
        context.addEllipse(in: CGRect(origin: CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y)), size: CGSize(width: abs(endPoint.x - beginPoint.x), height: abs(endPoint.y - beginPoint.y))))
    }
    
    override func name() -> String{
        // return "Circle"
        return "Ellipse"
    }
    
}
