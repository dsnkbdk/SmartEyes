//
//  SwitchViewController.swift
//  SmartEyesMultiView
//
//  Created by david on 9/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit
import CoreData

//
class SwitchViewController: RootViewController {

    internal var didAppare: Bool = false

    var appTab: AppTab!
    
    
    var appTabHandler: AppTabHandler!

    private var appCheckTab: AppTab?
    
    var userDataTab:[UserDataTab]!
    
    var userDataTabHandler:UserDataTabHandler!
    
    private var userDataCheckTab:[UserDataTab]?

    var accountTab: AccountTab!

    var accountTabHandler: AccountTabHandler!

    private var accountCheckTab: AccountTab?

    var commentTab: CommentTab!

    var commentTabHandler: CommentTabHandler!

    private var commentCheckTab: CommentTab?

    var subViews: [String:WorkViewController] = [String:WorkViewController]()

    var nextViewID: String = "-null-"

    var nextView: WorkViewController? = nil

    var rootView: SwitchViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

       self.viewID = "SwitchViewController"

       //
       self.appTabHandler = AppTabHandler()

        self.accountTabHandler = AccountTabHandler()

        self.commentTabHandler = CommentTabHandler()
        
        self.userDataTabHandler = UserDataTabHandler()

        self.rootView = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        // remember to call super func
        super.viewWillAppear(animated)

        print("SwitchViewController, viewID: " , self.viewID)
        
        print("SwitchViewController, self.nextViewID: " , self.nextViewID)
        
        if (self.nextViewID != "-null-" && self.nextViewID != self.viewID) {
            print("SwitchViewController: will show \(self.nextViewID) ...")
            self.nextView = self.getSubView(viewID: self.nextViewID)
            if (self.nextView == nil) {
                self.alertOK(currentView: self, title: "Internal Error", message: "viewID: \(self.nextViewID) not found in sub view list")
                self.nextViewID = "-null-"
                self.nextView = nil
            }
        } else {
            self.nextViewID = "-null-"
            self.nextView = nil
            
            print("SwitchViewController, stay in SwitchViewController: " , self.viewID)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // remember to call super func
        super.viewDidAppear(animated)

        if (self.envCheck() == false){
            self.errCount += 1
            let title = "fatal error on CoreData operation"
            let message = "\(String(describing: self.restorationIdentifier)), core data appTabHandler.initTable() failed."
            self.ShowFatalError(viewID: self.viewID, title: title, message: message, caller:self)
            return
        }

        if (self.envAccountCheck() == false){
            self.errCount += 1
            let title = "fatal error on CoreData operation"
            let message = "\(String(describing: self.restorationIdentifier)), core data accountTabHandler.initTable() failed."
            self.ShowFatalError(viewID: self.viewID, title: title, message: message, caller:self)
            return
        }

        if (self.envCommentCheck() == false){
            self.errCount += 1
            let title = "fatal error on CoreData operation"
            let message = "\(String(describing: self.restorationIdentifier)), core data commentTabHandler.initTable() failed."
            self.ShowFatalError(viewID: self.viewID, title: title, message: message, caller:self)
            return
        }
        
        if (self.envUserDataCheck() == false){
            self.errCount += 1
            let title = "fatal error on CoreData operation"
            let message = "\(String(describing: self.restorationIdentifier)), core data UserDataTabHandler.initTable() failed."
            self.ShowFatalError(viewID: self.viewID, title: title, message: message, caller:self)
            return
        }

        if (self.nextView != nil){
            print("SwitchViewController: switch to \(self.nextViewID) ...")
                let nview = self.nextView!
                self.nextViewID = "-null-"
                self.nextView = nil
                self.present(nview, animated:true, completion:nil)
        } else {
            self.nextViewID = "-null-"
            self.nextView = nil
            print("SwitchViewController: stay in root view \(self.viewID) ...")
        }
        Toast.fresh()

        // print("\(String(describing: self.restorationIdentifier)), appTabHandler.initTable() OK, self.errCount = ", self.errCount)
        // print("intent to show SwitchViewController: \(self.restorationIdentifier ?? "unknowView")")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func envCheck() -> Bool {
        if (self.appCheckTab != nil){
            return true
        }
        if (self.appTabHandler.initTable() == false) {
            print("appTabHandler.initTable() false.")
            return false
        } else {
            // print("appTabHandler.initTable() OK.")
        }

        if (self.readConfig() == false) {
            print("SwitchViewController: readConfig() false.")
            return false
        } else {
            // print("SwitchViewController: readConfig() ok.")
        }

        // print("\(String(describing: self.restorationIdentifier)): envCheck: AppTab, doWelcome: \(String(describing: self.rootView.appTab.doWelcome)), savePassword: \(String(describing: self.rootView.appTab.savePassword)), username: \(String(describing: self.rootView.appTab.username)), password: \(String(describing: self.rootView.appTab.password))\n")

        return true
    }

    func readConfig() -> Bool{

        self.appCheckTab = self.appTabHandler.readConfig()

        if (self.appCheckTab == nil) {
            // print("SwitchViewController: readConfig() false.")
            return false
        }

        self.appTab = self.appCheckTab!
        // print("SwitchViewController: readConfig() ok.")
        return true
    }

    func envAccountCheck() -> Bool {
        if (self.accountCheckTab != nil){
            return true
        }
        if (self.accountTabHandler.initTable() == false) {
            print("accountTabHandler.initTable() false.")
            return false
        } else {
            // print("accountTabHandler.initTable() OK.")
        }

        if (self.readAccountConfig() == false) {
            print("SwitchViewController: readAccountConfig() false.")
            return false
        } else {
            // print("SwitchViewController: readAccountConfig() ok.")
        }

        // print("\(String(describing: self.restorationIdentifier)): envAccountCheck: AccountTab, username: \(String(describing: self.rootView.accountTab.username)), password: \(String(describing: self.rootView.accountTab.password))\n")

        return true
    }

    func readAccountConfig() -> Bool{

        self.accountCheckTab = self.accountTabHandler.readConfig()

        if (self.accountCheckTab == nil) {
            // print("SwitchViewController: readConfig() false.")
            return false
        }

        self.accountTab = self.accountCheckTab!
        // print("SwitchViewController: readAccountConfig() ok.")
        return true
    }


    func envCommentCheck() -> Bool {
        if (self.commentCheckTab != nil){
            return true
        }
        if (self.commentTabHandler.initTable() == false) {
            print("commentTabHandler.initTable() false.")
            return false
        } else {
            // print("commentTabHandler.initTable() OK.")
        }

        if (self.readCommentConfig() == false) {
            print("SwitchViewController: readCommentConfig() false.")
            return false
        } else {
            // print("SwitchViewController: readCommentConfig() ok.")
        }

        // print("\(String(describing: self.restorationIdentifier)): envCommentCheck: CommentTab, username: \(String(describing: self.rootView.commentTab.username)), comment: \(String(describing: self.rootView.commentTab.comment))\n")

        return true
    }
    
    func envUserDataCheck() -> Bool {
        if (self.userDataCheckTab != nil){
            return true
        }
        if (self.userDataTabHandler.initTable() == false) {
            print("userDataTabHandler.initTable() false.")
            return false
        } else {
            // print("userDataTabHandler.initTable() OK.")
        }
        
        if (self.readUserDataConfig() == false) {
            print("SwitchViewController: readuserDataConfig() false.")
            return false
        } else {
            // print("SwitchViewController: readuserDataConfig() ok.")
        }
        
        // print("\(String(describing: self.restorationIdentifier)): envuserDataCheck: userDataTab, username: \(String(describing: self.rootView.userDataTab.username)), userData: \(String(describing: self.rootView.userDataTab.userData))\n")
        
        return true
    }
    
    func readUserDataConfig() -> Bool{
        
        self.userDataCheckTab = self.userDataTabHandler.fetchObjects()
        
        if (self.userDataCheckTab == nil) {
            // print("SwitchViewController: readConfig() false.")
            self.userDataCheckTab = [UserDataTab]()
            self.userDataCheckTab!.append(self.userDataTabHandler.newObject())
            return true
        }
        
        self.userDataTab = self.userDataCheckTab!
        // print("SwitchViewController: readUserDataConfig() ok.")
        return true
    }


    func readCommentConfig() -> Bool{

        self.commentCheckTab = self.commentTabHandler.readConfig()

        if (self.commentCheckTab == nil) {
            // print("SwitchViewController: readConfig() false.")
            self.commentCheckTab = self.commentTabHandler.newObject()
            return true
        }

        self.commentTab = self.commentCheckTab!
        // print("SwitchViewController: readCommentConfig() ok.")
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    public func ShowFatalError(viewID: String, title: String, message: String, caller: RootViewController) {                    print("ShowFatalError:", title, ", ", message)
        self.nextViewID = "FatalViewController"
        let newView = self.getSubView(viewID: self.nextViewID) as? FatalViewController
        if (newView == nil) {
            self.rootView.alertOK(currentView: self, title: "Internal Error", message: "viewID: \(self.nextViewID) not found in sub view list")
            return
        }
        newView!.setFatalTitle(text: title)
        newView!.setFatalMessage(text: message)
        if (self == caller) {
            self.presentView(viewID: "FatalViewController")
        } else {
            self.goNextView(viewID: "FatalViewController", caller:caller)
        }
    }

    internal func presentView(viewID: String){
        // let msg = "leaving view: \(self.restorationIdentifier ?? "unknowView"), goto \(viewID)"
        self.nextViewID = viewID
        // print(msg)
        print("presentView to show \(self.nextViewID) ...")
        if (self.nextViewID == self.viewID) {
            Toast.fresh()
            self.nextViewID = "-null-"
            self.nextView = nil
            Toast.fresh()
            return
        }
        let newView = self.getSubView(viewID: self.nextViewID)
        if (newView == nil) {
            self.rootView.alertOK(currentView: self, title: "Internal Error", message: "viewID: \(self.nextViewID) not found in sub view list")
            self.nextViewID = "-null-"
            self.nextView = nil
            Toast.fresh()
            return
        }
        self.nextViewID = "-null-"
        self.nextView = nil
        self.present(newView!, animated:true, completion:nil)
        Toast.fresh()
        // Toast(text: "presentView: \(viewID)", duration: Delay.short).show()
        return
    }

    func goNextView(viewID: String, caller: RootViewController){
        // let msg = "leaving view: \(self.restorationIdentifier ?? "unknowView"), goto \(viewID)"
        if (caller.viewID == self.rootView.viewID){
            // call from root view
            self.presentView(viewID: viewID)
            return
        }
        self.nextViewID = viewID
        self.nextView = nil
        // print(msg)
        caller.dismiss(animated: true, completion: nil)
        Toast.fresh()
    }

    func goRootView(caller: RootViewController){
        goNextView(viewID: self.viewID, caller: caller)
    }

    func setNextView(viewID: String){
        self.nextViewID = viewID
        self.nextView = nil
    }

    public func addSubView(viewID: String){
        if self.subViews[viewID] != nil {
            // already exist
            return
        }
        if (viewID == self.viewID) {
            return
        }
        let newView = storyBoard.instantiateViewController(withIdentifier: viewID) as? WorkViewController
        if (newView == nil) {
            self.rootView.alertOK(currentView: self, title: "Add Sub View Error", message: "viewID: \(viewID) not found in storyBoard: \(self.storyBoard.description)")
            return
        }
        newView!.setViewID(viewID: viewID)
        newView!.rootView = self
        self.subViews[viewID] = newView!
    }

    public func getSubView(viewID: String) -> WorkViewController? {
        if let view = self.subViews[viewID] {
            return view
        } else {
            return nil
        }
    }

}
