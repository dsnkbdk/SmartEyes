//
//  Colors.swift
//  SmartEyes
//
//  Created by david on 24/03/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

// alpha level of transparent color
let colorAlpha = CGFloat(0.3)

class BrushColor: NSObject {
    
    var colorName: String
    
    public var color: UIColor
    
    init(color: UIColor,colorName: String) {
        self.colorName = colorName
        self.color = color
        super.init()
    }
    
    class var Blue: BrushColor {
        return BrushColor(color: UIColor.blue, colorName: "Blue")
    }
    
    class var  BlueTran: BrushColor  {
        return  BrushColor(color: UIColor.blue.withAlphaComponent(colorAlpha), colorName: "Transparent Blue")
    }
    
    class var  Red: BrushColor  {
        return  BrushColor(color: UIColor.red, colorName: "Red")
    }
    
    class var  RedTran: BrushColor {
        return BrushColor(color: UIColor.red.withAlphaComponent(colorAlpha), colorName: "Transparent Red")
    }
    
    class var  Yellow: BrushColor {
        return  BrushColor(color: UIColor.yellow, colorName: "Yellow")
    }
    
    class var  YellowTran: BrushColor  {
        return  BrushColor(color: UIColor.yellow.withAlphaComponent(colorAlpha), colorName: "Transparent Yellow")
    }
    
    class var  Purple: BrushColor {
        return BrushColor(color: UIColor.purple, colorName: "Purple")
    }
    
    class var  PurpleTran: BrushColor {
        return  BrushColor(color: UIColor.purple.withAlphaComponent(colorAlpha), colorName: "Transparent Purple")
    }
    
    class var  Green: BrushColor {
        return  BrushColor(color: UIColor.green, colorName: "Green")
    }
    
    class var  GreenTran: BrushColor {
        return BrushColor(color: UIColor.green.withAlphaComponent(colorAlpha), colorName: "Transparent Green")
    }
    
    // return name of color
    func name() -> String{
        if self.colorName.count > 0 {
            return self.colorName
        }
        return self.color.toRGBAString()
    }
}

// from https://stackoverflow.com/a/46221636
extension UIColor {
    
    //Convert RGBA String to UIColor object
    //"rgbaString" must be separated by space "0.5 0.6 0.7 1.0" 50% of Red 60% of Green 70% of Blue Alpha 100%
    public convenience init?(rgbaString : String){
        self.init(ciColor: CIColor(string: rgbaString))
    }
    
    //Convert UIColor to RGBA String
    func toRGBAString()-> String {
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "\(r) \(g) \(b) \(a)"
        
    }
    
    //return UIColor from Hexadecimal Color string
    public convenience init?(hexaDecimalString: String) {
        
        let r, g, b, a: CGFloat
        
        if hexaDecimalString.hasPrefix("#") {
            let start = hexaDecimalString.index(hexaDecimalString.startIndex, offsetBy: 1)
            let hexColor = hexaDecimalString[start...]
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: String(hexColor))
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    // Convert UIColor to Hexadecimal String
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
}


// from: https://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-an-uiimage-in-swift-programmatically
// UIImage+Alpha.swift
extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

