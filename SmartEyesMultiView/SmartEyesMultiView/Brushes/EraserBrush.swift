//
//  EraserBrush.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

class EraserBrush: PencilBrush {
    
    override func drawInContext(_ context: CGContext) {
        
        context.setBlendMode(CGBlendMode.clear)
        
        super.drawInContext(context)
    }
    
    override func name() -> String{
        return "Eraser"
    }
}
