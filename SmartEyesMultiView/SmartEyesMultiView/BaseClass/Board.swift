//
//  Board.swift
//  SmartEyes
//
//  Created by david on 23/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

// screen touch
enum TouchState {
    case Down, Move, Up
}

class DrawBoardImageView: UIImageView {
    
    var strokeWidth: CGFloat
    var strokeColor: UIColor
    
    var brush: BaseBrush?
    
    private var touchState: TouchState!
    
    private var origImage: UIImage? // default is nil
    
    // currentImage
    private var realImage: UIImage?
    
    override init(frame: CGRect) {
        self.strokeColor = UIColor.black
        self.strokeWidth = 1
        
        super.init(frame: frame)
        
        self.origImage = self.image;
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.strokeColor = UIColor.black
        self.strokeWidth = 1
        
        super.init(coder: aDecoder)
        
        self.origImage = self.image;
    }
    
    func takeImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
        
        self.image?.draw(in: self.bounds)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // handle screen touch event
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.lastPoint = nil
            
            brush.beginPoint = touches.first!.location(in: self)
            brush.endPoint = brush.beginPoint
            
            self.touchState = .Down
            
            self.drawingImage()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.touchState = .Move
            
            self.drawingImage()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.touchState = .Up
            
            self.drawingImage()
        }
    }
    
    //
    func loadImage(image: UIImage){
        self.image = image
        self.realImage = image

        // print("imagePickerController: image loaded")
        
        // Show a toast message to refresh view in OSX-KVM virtual machine
        Toast.fresh()
        // Toast(text: "Image loaded", duration: Delay.short).show()
    }
    
    func ClearScreen(uv: UIViewController) {
        
        self.realImage = nil
        
        UIView.transition(with: self,
                          duration: 2,
                          options: .transitionFlipFromLeft,
                          animations: {
                            self.image = self.origImage
        }, completion: nil)
        
        print("Draw Screen cleared")
        // Show a toast message to refresh view in OSX-KVM virtual machine
        Toast.fresh()
        // Toast(text: "All drawing Cleared", duration: Delay.short).show()
    }
    
    private func drawingImage() {
        if let brush = self.brush {
            
            UIGraphicsBeginImageContext(self.bounds.size)
            
            let context = UIGraphicsGetCurrentContext()
            
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(self.strokeWidth)
            context?.setStrokeColor(self.strokeColor.cgColor)
            
            if let realImage = self.realImage {
                realImage.draw(in: self.bounds)
            }
            
            brush.strokeWidth = self.strokeWidth
            brush.drawInContext(context!)
            context?.strokePath()
            
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.touchState == .Up || brush.supportedContinuousDrawing() {
                self.realImage = previewImage
            }
            
            UIGraphicsEndImageContext()
            
            self.image = previewImage
            
            brush.lastPoint = brush.endPoint
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

