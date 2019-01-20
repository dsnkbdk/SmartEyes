//
//  LineBrush.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

class LineBrush: BaseBrush {

    override func drawInContext(_ context: CGContext) {
        context.move(to: CGPoint(x: beginPoint.x, y: beginPoint.y))
        context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
    }
    
    override func name() -> String{
        return "Line"
    }

}
