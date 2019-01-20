//
//  TriangleBrush.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

class TriangleBrush: BaseBrush {
    
    override func drawInContext(_ context: CGContext) {
        
        let startPoint = CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y))
        
        let width = abs(endPoint.x - beginPoint.x)
        let higth = abs(endPoint.y - beginPoint.y)
        
        context.addRect(
            CGRect(origin: startPoint,
                   size: CGSize(width: width, height: higth)
            )
        )
        
        let rect = CGRect(origin: startPoint,
                          size: CGSize(width: width, height: higth)
        )
        
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        
       // context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.60)
        // context.fillPath()
        
        
    }
    
    override func name() -> String{
        return "Triangle"
    }
}
