//
//  WorkViewController.swift
//  SmartEyesMultiView
//
//  Created by david on 8/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

//
class WorkViewController: RootViewController,UITextFieldDelegate {

    /// common for very view

    var rootView: SwitchViewController!

    ////

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewID = "WorkViewController"

    }

    override func viewWillAppear(_ animated: Bool) {
        // remember to call super func
        super.viewWillAppear(animated)
        
        // NOTE: view/alert task should run in this stage
        // otherwise: whose view is not in the window hierarchy

    }

    override func viewDidAppear(_ animated: Bool) {
        // remember to call super func
        super.viewDidAppear(animated)

        _  = self.rootView!.readConfig()
        
        // print("\(String(describing: self.restorationIdentifier)), appTabHandler.initTable() OK, self.errCount = ", self.errCount)
        // print("intent to show WorkViewController: \(self.restorationIdentifier ?? "unknowView")")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
