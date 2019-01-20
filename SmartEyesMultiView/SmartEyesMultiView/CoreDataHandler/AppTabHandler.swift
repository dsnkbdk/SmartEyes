//
//  AppTabHandler.swift
//  SmartEyesMultiView
//
//  Created by david on 4/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit
import CoreData

class AppTabHandler: NSObject {

    private var ctx: NSManagedObjectContext!

    private var entity: NSEntityDescription!

    override init() {
        super.init()
        self.ctx = getContext()
        self.entity = NSEntityDescription.entity(forEntityName: "AppTab", in: self.ctx!)
    }

    private  func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    public func newObject() -> AppTab {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "AppTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        
        manageObject.setValue("-null-", forKey: "username")
        manageObject.setValue("-null-", forKey: "adminName")
        manageObject.setValue("-null-", forKey: "password")
        manageObject.setValue(true, forKey: "doWelcome")
        manageObject.setValue(true, forKey: "savePassword")
        
        let obj:AppTab = manageObject as! AppTab
        
        return obj
        
    }
    
    public func initTable() -> Bool{
        
        let appTabs: [AppTab]? = fetchObject()

        if (appTabs == nil || appTabs?.count == 0){
            // print("info: initial AppTab record for empty table ...");
            let appTab = newObject()
            if (saveConfig(appTab: appTab) == false) {
                print("error: initial AppTab record failed.");
                return false
            }
        }
        return true
    }
    
    func fetchObject() -> [AppTab]? {
        let context = self.ctx // let context= getContext()
        var user:[AppTab]? = nil
        do {
            user = try context!.fetch(AppTab.fetchRequest())
            return user
        }catch {
            print("Unexpected fetchObject error: \(error).")
            return user
        }
    }
    
    public  func readConfig() -> AppTab? {
        
        var lastAppTab: AppTab? = nil
        
        if (initTable() == false){
            return nil
        }
        
        let appTab: [AppTab]? = fetchObject()
        if (appTab == nil || appTab?.count == 0){
            // record not exist
            // print("AppTab: is empty, return nil\n")
            return nil;
        }
        
        for (_, rec) in (appTab!.enumerated()) {
            // print("AppTab/fetchLastObject#\(idx), doWelcome: \(rec.doWelcome), savePassword: \(rec.savePassword), username: \(String(describing: rec.username)), password: \(String(describing: rec.password))\n")
            lastAppTab = rec
        }
        return lastAppTab
    }
    
    
    //
    public  func getDoWelcome(doWelcome:Bool) -> Bool {
        
        let lastAppTab: AppTab? = readConfig()
        if (lastAppTab == nil){
            return true
        }
        
        return lastAppTab!.doWelcome
    }
    
    func saveObject(adminName:String, username:String, password:String, doWelcome: Bool, savePassword: Bool) -> Bool {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "AppTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        
        manageObject.setValue(username, forKey: "username")
        manageObject.setValue(adminName, forKey: "adminName")
        manageObject.setValue(password, forKey: "password")
        manageObject.setValue(doWelcome, forKey: "doWelcome")
        manageObject.setValue(savePassword, forKey: "savePassword")
        
        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected saveObject error: \(error).")
            return false
        }
    }
    
    public  func saveConfig(appTab: AppTab?) -> Bool {
        if (appTab == nil){
            // print("AppTab/saveConfig: nil record")
            return false
        }

        // print("AppTab/saveConfig: input, doWelcome: \(appTab!.doWelcome), savePassword: \(appTab!.savePassword), username: \(appTab!.username ?? "-"), password: \(appTab!.password ?? "-")\n")

        let doWelcome: Bool = appTab!.doWelcome;
        let savePassword: Bool = appTab!.savePassword

        var adminName: String? = appTab!.adminName
        if (adminName == nil || adminName == ""){
            adminName = "-null-"
        }
        var username: String? = appTab!.username
        if (username == nil || username == ""){
            username = "-null-"
        }
        var password: String? = appTab!.password
        if (password == nil || password == ""){
            password = "-null-"
        }

        // print("AppTab/saveConfig: copy, doWelcome: \(doWelcome), savePassword: \(savePassword), username: \(username ?? "-"), password: \(password ?? "-")\n")
        // NOTE: only one record for this table, remove old data first
        if (cleanDelete() == false) {
            print("clean AppTab for Save failed")
            return false
        }

        // print("AppTab/saveConfig: save, doWelcome: \(doWelcome), savePassword: \(savePassword), username: \(username ?? "-"), password: \(password ?? "-")\n")

        if (saveObject(adminName: adminName!, username: username!, password: password!, doWelcome: doWelcome,savePassword: savePassword) == false){
            print("save AppTab/saveConfig failed")
            return false
        }
        return true
    }
    
    public  func setDoWelcome(doWelcome:Bool) -> Bool {
        
        let lastAppTab = readConfig()
        
        lastAppTab?.doWelcome = doWelcome

        return saveConfig(appTab: lastAppTab!)
    }
    
    func deleteObject(user: AppTab) -> Bool {
        let context = self.ctx // let context= getContext()
        context!.delete(user)
        
        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected deleteObject error: \(error).")
            return false
        }
        
    }
    
    func cleanDelete() -> Bool {
        var appTab: [AppTab]?
        let context = self.ctx // let context= getContext()
        do {
            appTab = try context!.fetch(AppTab.fetchRequest())
        }catch {
            print("Unexpected cleanDelete/fetchObject error: \(error).")
            return false
        }
        if (appTab == nil || appTab?.count == 0){
            // record not exist
            // print("AppTab: is empty, clear ok\n")
            return true;
        }

        for (_, rec) in (appTab!.enumerated()) {
            // print("AppTab/cleanDelete#\(idx), doWelcome: \(rec.doWelcome), savePassword: \(rec.savePassword), username: \(String(describing: rec.username)), password: \(String(describing: rec.password))\n")
            context!.delete(rec)
            do {
                try context!.save()
            }catch {
                print("Unexpected cleanDelete/deleteObject error: \(error).")
                return false
            }
        }
        return true
    }

    func filterUsername(username: String) -> [AppTab]? {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<AppTab> = AppTab.fetchRequest()
        var appTab:[AppTab]? = nil

        let predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = predicate

        do {
            appTab = try context!.fetch(fetchRequest)
            return appTab
        }catch {
            print("Unexpected filterUsername error: \(error).")
            return appTab
        }
    }

    func filterAdminName(adminName: String) -> [AppTab]? {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<AppTab> = AppTab.fetchRequest()
        var appTab:[AppTab]? = nil

        let predicate = NSPredicate(format: "adminName == %@", adminName)
        fetchRequest.predicate = predicate

        do {
            appTab = try context!.fetch(fetchRequest)
            return appTab
        }catch {
            print("Unexpected filterAdminName error: \(error).")
            return appTab
        }
    }
    
    func filterPassword(password: String) -> [AppTab]? {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<AppTab> = AppTab.fetchRequest()
        var appTab:[AppTab]? = nil
        
        let predicate = NSPredicate(format: "password == %@", password)
        fetchRequest.predicate = predicate
        
        do {
            appTab = try context!.fetch(fetchRequest)
            return appTab
        }catch {
            print("Unexpected filterPassword error: \(error).")
            return appTab
        }
    }
    
    func filterUsernamePassword(username: String, password: String) -> [AppTab]? {
        var filtedData:[AppTab]? = nil
        
        let user:[AppTab]? = filterUsername(username: username)
        let pass:[AppTab]? = filterPassword(password: password)
        
        for (_, u) in (user?.enumerated())! {
            // print("user-user#\(idx), doWelcome: \(u.doWelcome), savePassword: \(u.savePassword), username: \(String(describing: u.username)), password: \(String(describing: u.password))\n")
            for (_, p) in (pass?.enumerated())! {
                // print("user-password#\(idx), doWelcome: \(p.doWelcome), savePassword: \(p.savePassword), username: \(String(describing: p.username)), password: \(String(describing: p.password))\n")
                if (u.username == p.username && u.password == p.password){
                    filtedData?.append(u)
                }
            }
        }
        return filtedData
    }
}

