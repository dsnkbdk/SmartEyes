//
//  FatalViewController.swift
//  SmartEyesMultiView
//
//  Created by david on 6/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

//
class FatalViewController: WorkViewController {

    public var onSendFeedBack: ((UIAlertAction) -> Swift.Void)? = nil

    private var pendingTitle: String = "-null-"

    private var pendingMessage: String = "-null-"

    private var returnViewID: String = "-null-"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        self.viewID = "FatalViewController"

        self.storyBoard  = UIStoryboard(name: "Main", bundle:nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        // remember to call super func
        super.viewWillAppear(animated)

        if (self.pendingTitle != "-null-"){
            self.fatalTitlelbl.text = self.pendingTitle
        }
        if (self.pendingMessage != "-null-"){
            self.fatalMessageTF.text = self.pendingMessage
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // remember to call super func
        super.viewDidAppear(animated)

        _  = self.rootView!.readConfig()

        // print("\(String(describing: self.restorationIdentifier)), appTabHandler.initTable() OK, self.errCount = ", self.errCount)
        // print("intent to show FatalViewController: \(self.restorationIdentifier ?? "unknowView")")
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
    @IBOutlet weak var fatalTitlelbl: UILabel!

    @IBOutlet weak var fatalMessageTF: UITextField!

    @IBOutlet weak var fatalFeedbackTF: UITextField!


    public func getFatalFeedBackText() -> String? {
        return fatalFeedbackTF.text
    }

    public func setFatalTitle( text: String){
        self.pendingTitle = text
    }

    public func setFatalMessage( text: String){
        self.pendingMessage = text
    }

    @IBAction func clickSendFeedback(_ sender: Any) {
        // save feedback and goto welcome view
        
        if (self.onSendFeedBack != nil){
            // TODO: how to call a function
            // self.onSendFeedBack
        }

        //
        self.returnViewID = "MainViewController"
        if (self.returnViewID == "-null-"){
            self.dismiss(animated: true, completion: nil)
        } else {
            self.rootView!.goNextView(viewID: self.returnViewID, caller: self)
        }
    }
}
