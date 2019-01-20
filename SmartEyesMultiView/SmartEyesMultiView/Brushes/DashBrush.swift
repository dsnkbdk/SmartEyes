//
//  DashBrush.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

class DashBrush: BaseBrush {
    
    override func drawInContext(_ context: CGContext) {
        
        let lengths: [CGFloat] = [self.strokeWidth * 3, self.strokeWidth * 3]
        
        context.setLineDash(phase: 0, lengths: lengths    )
        
        context.move(to: CGPoint(x: beginPoint.x, y: beginPoint.y))
        context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
    }
    
    override func name() -> String{
        return "Dash Line"
    }
}
