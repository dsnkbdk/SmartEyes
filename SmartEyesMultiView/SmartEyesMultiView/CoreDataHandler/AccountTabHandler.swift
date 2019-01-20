//
//  AccountTabHandler.swift
//  SmartEyesMultiView
//
//  Created by david on 10/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit
import CoreData

class AccountTabHandler: NSObject {

    private var ctx: NSManagedObjectContext!

    private var entity: NSEntityDescription!

    override init() {
        super.init()
        self.ctx = getContext()
        self.entity = NSEntityDescription.entity(forEntityName: "AccountTab", in: self.ctx!)
    }

    private  func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        return appDelegate.persistentContainer.viewContext
    }

    public func newObject() -> AccountTab {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "AccountTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue("-null-", forKey: "username")
        manageObject.setValue("-null-", forKey: "password")

        let obj:AccountTab = manageObject as! AccountTab

        return obj

    }

    public func initTable() -> Bool{

        let accountTabs: [AccountTab]? = fetchObject()

        if (accountTabs == nil || accountTabs?.count == 0){
            // print("info: initial AccountTab record for empty table ...");
            let accountTab = newObject()
            if (saveConfig(accountTab: accountTab) == false) {
                print("error: initial AccountTab record failed.");
                return false
            }
        }
        return true
    }

    func fetchObject() -> [AccountTab]? {
        let context = self.ctx // let context= getContext()
        var user:[AccountTab]? = nil
        do {
            user = try context!.fetch(AccountTab.fetchRequest())
            return user
        }catch {
            print("Unexpected fetchObject error: \(error).")
            return user
        }
    }

    public  func readConfig() -> AccountTab? {

        var lastAccountTab: AccountTab? = nil

        if (initTable() == false){
            return nil
        }

        let accountTab: [AccountTab]? = fetchObject()
        if (accountTab == nil || accountTab?.count == 0){
            // record not exist
            // print("AccountTab: is empty, return nil\n")
            return nil;
        }

        for (_, rec) in (accountTab!.enumerated()) {
            // print"AccountTab/fetchLastObject#\(idx), username: \(String(describing: rec.username)), password: \(String(describing: rec.password))\n")
            lastAccountTab = rec
        }
        return lastAccountTab
    }

    func saveObject(username:String, password:String, doWelcome: Bool, savePassword: Bool) -> Bool {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "AccountTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue(username, forKey: "username")
        manageObject.setValue(password, forKey: "password")

        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected saveObject error: \(error).")
            return false
        }
    }

    public  func saveConfig(accountTab: AccountTab?) -> Bool {
        if (accountTab == nil){
            // print"AccountTab/saveConfig: nil record")
            return false
        }

        // print"AccountTab/saveConfig: input, username: \(accountTab!.username ?? "-"), password: \(accountTab!.password ?? "-")\n")

        var username: String? = accountTab!.username
        if (username == nil || username == ""){
            username = "-null-"
        }
        var password: String? = accountTab!.password
        if (password == nil || password == ""){
            password = "-null-"
        }

        // print"AccountTab/saveConfig: copy, username: \(username ?? "-"), password: \(password ?? "-")\n")
        // NOTE: only one record for this table, remove old data first
        if (cleanDelete() == false) {
            print("clean AccountTab for Save failed")
            return false
        }

        // print"AccountTab/saveConfig: save, username: \(username ?? "-"), password: \(password ?? "-")\n")

        if (saveObject(username: username!, password: password!) == false){
            print("save AccountTab/saveConfig failed")
            return false
        }
        return true
    }

    func saveObject(username:String, password:String) -> Bool {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "AppTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue(username, forKey: "username")
        manageObject.setValue(password, forKey: "password")

        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected saveObject error: \(error).")
            return false
        }
    }

    func deleteObject(user: AccountTab) -> Bool {
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
        var accountTab: [AccountTab]?
        let context = self.ctx // let context= getContext()
        do {
            accountTab = try context!.fetch(AccountTab.fetchRequest())
        }catch {
            print("Unexpected cleanDelete/fetchObject error: \(error).")
            return false
        }
        if (accountTab == nil || accountTab?.count == 0){
            // record not exist
            // print"AccountTab: is empty, clear ok\n")
            return true;
        }

        for (_, rec) in (accountTab!.enumerated()) {
            // print"AccountTab/cleanDelete#\(idx), username: \(String(describing: rec.username)), password: \(String(describing: rec.password))\n")
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

    func filterUsername(username: String) -> [AccountTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<AccountTab> = AccountTab.fetchRequest()
        var accountTab:[AccountTab] = []

        let predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = predicate

        do {
            accountTab = try context!.fetch(fetchRequest)
            return accountTab
        }catch {
            print("Unexpected filterUsername error: \(error).")
            return accountTab
        }
    }

    func filterPassword(password: String) -> [AccountTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<AccountTab> = AccountTab.fetchRequest()
        var accountTab:[AccountTab] = []

        let predicate = NSPredicate(format: "password == %@", password)
        fetchRequest.predicate = predicate

        do {
            accountTab = try context!.fetch(fetchRequest)
            return accountTab
        }catch {
            print("Unexpected filterPassword error: \(error).")
            return accountTab
        }
    }

    func filterUsernamePassword(username: String, password: String) -> [AccountTab] {
        var filtedData:[AccountTab] = []

        let user:[AccountTab]? = filterUsername(username: username)
        let pass:[AccountTab]? = filterPassword(password: password)

        for (_, u) in (user?.enumerated())! {
            // print"user-user#\(idx), username: \(String(describing: u.username)), password: \(String(describing: u.password))\n")
            for (_, p) in (pass?.enumerated())! {
                // print("user-password#\(idx), username: \(String(describing: p.username)), password: \(String(describing: p.password))\n")
                if (u.username == p.username && u.password == p.password){
                    filtedData.append(u)
                }
            }
        }
        return filtedData
    }
    
}
