//
//  MainViewController.swift
//  smartEye
//
//  Created by WENNAN SHI on 5/12/18.
//  Copyright © 2018 FaceAttendance. All rights reserved.
//

import UIKit
import AudioToolbox

class MainViewController: SwitchViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.viewID = "MainViewController"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // remember to call super func
        super.viewDidAppear(animated)
        
        // NOTE: view/alert task should run in this stage
        // otherwise: whose view is not in the window hierarchy
        
        // setup all subView
        if (self.didAppare == false) {
            self.didAppare = true
            self.addSubView(viewID: "MainViewController")
            self.addSubView(viewID: "FatalViewController")
            self.addSubView(viewID: "SignInViewController")
            self.addSubView(viewID: "RegisterViewController")
            self.addSubView(viewID: "StudentsViewController")
        }
        
        _  = self.rootView!.readConfig()
        
        // print("SignInViewController: before switch, doWelcome: \(self.rootView.appTab!.doWelcome), savePassword: \(self.rootView.appTab!.savePassword), username: \(self.rootView.appTab!.username ?? "-"), password: \(self.rootView.appTab!.password ?? "-")\n")
        
            // show welcome view
            print("\(String(describing: self.restorationIdentifier)): enter main view")
        
            Toast.fresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNew(_ sender: UIButton)
    {
        self.rootView!.presentView(viewID: "RegisterViewController")
        AudioServicesPlaySystemSound(1104)
        
    }
    
    @IBAction func signIn(_ sender: UIButton)
    {
        self.rootView!.presentView(viewID: "SignInViewController")
        AudioServicesPlaySystemSound(1104)
    }
    
    @IBAction func checkAttendance(_ sender: UIButton)
    {
        self.rootView!.presentView(viewID: "StudentsViewController")
        AudioServicesPlaySystemSound(1104)
    }
    
    
    
    
}
