//
//  DavidUitl.swift
//  SmartEyesMultiView
//
//  Created by david on 6/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit
import Foundation

// ref: https://mycodetips.com/ios/manually-adding-swift-bridging-header-1290.html

// ref: https://stackoverflow.com/questions/46780451/creating-sha256-hash-with-swift4

class DavidUitl: NSObject {
    
    private var currentView: UIViewController
    
    private var alertResult: Int = -1;
    
    init(currentView: UIViewController){
        self.currentView = currentView;
    }
    
    public func setCurrentView(currentView: UIViewController){
        self.currentView = currentView;
    }
    
    public class func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    public func alertHandler(action:  UIAlertAction!) {
        switch action.style{
        case .default:
            print("default")
            self.alertResult = 0
            break
        case .cancel:
            print("cancel")
            self.alertResult = 1
            break
        case .destructive:
            print("destructive")
            self.alertResult = 3
            break
        }}

    class func alertOK(currentView: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil)  {
        print("alertOK: enter TITLE: \(title), MESSAGE: \(message)\n")

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        // self.currentView.present(alert, animated: true, completion: nil)

        DavidUitl.gotoViewController(from: currentView, to: alert)
        print("alertOK: present, TITLE: \(title), MESSAGE: \(message)\n")

        Toast.fresh()
        //Toast(text: "alertOK: present, TITLE: \(title), MESSAGE: \(message)\n", duration: Delay.short).show()

    }

    public class func gotoViewController(from: UIViewController, to: UIViewController){
        print("gotoViewController: from \(String(describing: from.restorationIdentifier)) => \(String(describing: to.restorationIdentifier))\n");
        from.present(to, animated:true, completion:nil)
    }
    
    public func gotoViewController(to: UIViewController){
        DavidUitl.gotoViewController(from: self.currentView, to: to)
    }
    
    public class func SHA256(data: Data) -> Data {
        return ccSha256(data: data)
    }
    
    public class func SHA256String(data: Data) -> String {
        return ccSha256String(data: data)
    }
    
    public class func ccSha256(data: Data) -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            data.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return digest
    }
    
    public class func ccSha256String(data: Data) -> String {
        let digest = ccSha256(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
}
