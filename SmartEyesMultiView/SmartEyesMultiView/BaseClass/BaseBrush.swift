//
//  BaseBrush.swift
//  SmartEyes
//
//  Created by david on 23/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

import CoreGraphics

protocol PaintBrush {
    
    func supportedContinuousDrawing() -> Bool
    
    func drawInContext(_ context: CGContext)
}

class BaseBrush: NSObject, PaintBrush {
    
    var beginPoint: CGPoint!
    var endPoint: CGPoint!
    var lastPoint: CGPoint?
    
    var strokeWidth: CGFloat!
    
    func supportedContinuousDrawing() -> Bool {
        return false
    }
    
    func drawInContext(_ context: CGContext) {
        assert(false, "drawInContext must implements in subclass.")
    }
    
    func name() -> String{
        assert(false, "name must implements in subclass.")
        return "BaseBrush"
    }
}
