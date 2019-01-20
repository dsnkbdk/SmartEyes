//
//  UserDataTabHandler.swift
//  SmartEyesMultiView
//
//  Created by david on 10/05/18.
//  Copyright © 2018 david. All rights reserved.
//


import UIKit
import CoreData

class UserDataTabHandler: NSObject {

    private var ctx: NSManagedObjectContext!

    private var entity: NSEntityDescription!

    override init() {
        super.init()
        self.ctx = getContext()
        self.entity = NSEntityDescription.entity(forEntityName: "UserDataTab", in: self.ctx!)
    }

    private  func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        return appDelegate.persistentContainer.viewContext
    }

    public func newObject() -> UserDataTab {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "UserDataTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue("-null-", forKey: "username")
        manageObject.setValue("-null-", forKey: "adminName")
        manageObject.setValue("-null-", forKey: "room")
        manageObject.setValue("-null-", forKey: "status")
        manageObject.setValue(Date.init(), forKey: "date")

        let obj:UserDataTab = manageObject as! UserDataTab

        return obj

    }

    public func initTable() -> Bool{

        let userDataTabs: [UserDataTab]? = fetchObjects()

        if (userDataTabs == nil || userDataTabs?.count == 0){
            // print"info: initial UserDataTab record for empty table ...");
            let userDataTab = newObject()
            if (saveConfig(userDataTab: userDataTab) == false) {
                print("error: initial UserDataTab record failed.");
                return false
            }
            // not default record
            if (cleanDelete() == false){
                print("error: clear temp UserDataTab record failed.");
                return false
            }
        }
        return true
    }

    func fetchObjects() -> [UserDataTab] {
        let context = self.ctx // let context= getContext()
        var user:[UserDataTab] = []
        do {
            let quser:[UserDataTab] = try context!.fetch(UserDataTab.fetchRequest())
            for (_, rec) in (quser.enumerated()) {
                if (rec.username == nil || rec.username == "" || rec.username == "-null-"){
                    continue
                }
                user.append(rec)
            }
            return user
        }catch {
            print("Unexpected fetchObjects error: \(error).")
            return user
        }
    }

    public  func readLastRow() -> UserDataTab? {

        var lastUserDataTab: UserDataTab? = nil

        if (initTable() == false){
            return nil
        }

        let userDataTab: [UserDataTab]? = fetchObjects()
        if (userDataTab == nil || userDataTab?.count == 0){
            // record not exist
            // print"UserDataTab: is empty, return nil\n")
            return nil;
        }

        for (_, rec) in (userDataTab!.enumerated()) {
            // print"UserDataTab/fetchLastObject#\(idx), username: \(String(describing: rec.username)), comment: \(String(describing: rec.comment))\n")
            lastUserDataTab = rec
        }
        return lastUserDataTab
    }

    func saveObject(username:String, adminName:String, room: String, status: String, date: Date) -> Bool {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "UserDataTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue(username, forKey: "username")
        manageObject.setValue(adminName, forKey: "adminName")
        manageObject.setValue(room, forKey: "room")
        manageObject.setValue(status, forKey: "status")
        manageObject.setValue(Date.init(), forKey: "date")

        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected saveObject error: \(error).")
            return false
        }
    }

    public  func saveConfig(userDataTab: UserDataTab?) -> Bool {
        return saveRecord(userDataTab: userDataTab, deleteAll: true)
    }
    
    public  func saveRecord(userDataTab: UserDataTab?, deleteAll: Bool) -> Bool {
        if (userDataTab == nil){
            // print("UserDataTab/saveConfig: nil record")
            return false
        }

        // print("UserDataTab/saveConfig: input, username: \(userDataTab!.username ?? "-"), comment: \(userDataTab!.comment ?? "-")\n")

        var username: String? = userDataTab!.username
        if (username == nil || username == ""){
            username = "-null-"
        }
        var adminName: String? = userDataTab!.adminName
        if (adminName == nil || adminName == ""){
            adminName = "-null-"
        }
        var room: String? = userDataTab!.room
        if (room == nil || room == ""){
            room = "-null-"
        }
        var status: String? = userDataTab!.status
        if (status == nil || status == ""){
            status = "-null-"
        }
        var date: Date? = userDataTab!.date
        if (date == nil){
            date = Date.init()
        }

        // print"UserDataTab/saveConfig: copy, username: \(username ?? "-"), comment: \(comment ?? "-")\n")
        
        if (deleteAll){
        // NOTE: only one record for this table, remove old data first
        if (cleanDelete() == false) {
            print("clean UserDataTab for Save failed")
            return false
        }
        }

        // print"UserDataTab/saveConfig: save, username: \(username ?? "-"), comment: \(comment ?? "-")\n")

        if (saveObject(username: username!, adminName: adminName!, room: room!, status: status!, date: date!) == false){
            print("save UserDataTab/saveConfig failed")
            return false
        }
        return true
    }

    func deleteObject(user: UserDataTab) -> Bool {
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
        var userDataTab: [UserDataTab]?
        let context = self.ctx // let context= getContext()
        do {
            userDataTab = try context!.fetch(UserDataTab.fetchRequest())
        }catch {
            print("Unexpected cleanDelete/fetchObjects error: \(error).")
            return false
        }
        if (userDataTab == nil || userDataTab?.count == 0){
            // record not exist
            // print"UserDataTab: is empty, clear ok\n")
            return true;
        }

        for (_, rec) in (userDataTab!.enumerated()) {
            // print"UserDataTab/cleanDelete#\(idx), username: \(String(describing: rec.username)), comment: \(String(describing: rec.comment))\n")
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

    func filterUsername(username: String) -> [UserDataTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<UserDataTab> = UserDataTab.fetchRequest()
        var userDataTab:[UserDataTab] = []

        let predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = predicate

        do {
            userDataTab = try context!.fetch(fetchRequest)
            return userDataTab
        }catch {
            print("Unexpected filterUsername error: \(error).")
            return userDataTab	
        }
    }
    
    func filterAdminName(adminName: String) -> [UserDataTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<UserDataTab> = UserDataTab.fetchRequest()
        var userDataTab:[UserDataTab] = []
        
        let predicate = NSPredicate(format: "adminName == %@", adminName)
        fetchRequest.predicate = predicate
        
        do {
            userDataTab = try context!.fetch(fetchRequest)
            return userDataTab
        }catch {
            print("Unexpected filterAdminName error: \(error).")
            return userDataTab
        }
    }
    
    func filterStatus(status: String) -> [UserDataTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<UserDataTab> = UserDataTab.fetchRequest()
        var userDataTab:[UserDataTab] = []
        
        let predicate = NSPredicate(format: "status == %@", status)
        fetchRequest.predicate = predicate
        
        do {
            userDataTab = try context!.fetch(fetchRequest)
            return userDataTab
        }catch {
            print("Unexpected filterStatus error: \(error).")
            return userDataTab
        }
    }


    func filterAdminNameUsername(adminName: String, username: String) -> [UserDataTab] {
        var filtedData:[UserDataTab] = []

        let user:[UserDataTab]? = filterUsername(username: username)
        let admin:[UserDataTab]? = filterAdminName(adminName: adminName)

        for (_, u) in (user?.enumerated())! {
            // print"user-user#\(idx), username: \(String(describing: u.username)), comment: \(String(describing: u.comment))\n")
            for (_, p) in (admin?.enumerated())! {
                // print("user-comment#\(idx), username: \(String(describing: p.username)), comment: \(String(describing: p.comment))\n")
                if (u.username == p.username && u.adminName == p.adminName){
                    filtedData.append(u)
                }
            }
        }
        return filtedData
    }
    
    func filterUsernameStatus(username: String, status: String) -> [UserDataTab] {
        var filtedData:[UserDataTab] = []
        
        let user:[UserDataTab]? = filterUsername(username: username)
        let statusList:[UserDataTab]? = filterStatus(status: status)
        
        for (_, u) in (user?.enumerated())! {
            // print"user-user#\(idx), username: \(String(describing: u.username)), comment: \(String(describing: u.comment))\n")
            for (_, p) in (statusList?.enumerated())! {
                // print("user-comment#\(idx), username: \(String(describing: p.username)), comment: \(String(describing: p.comment))\n")
                if (u.username == p.username && u.adminName == p.adminName){
                    filtedData.append(u)
                }
            }
        }
        return filtedData
    }
    
    
    func updateUsernameStatus(changeList: [UserDataTab]) -> Bool {
        
        var ok: Bool = true

        for (_, rec) in (changeList.enumerated()) {
            if (rec.username == nil || rec.status == nil) {
                continue
            }
            // insert new record
            if (saveRecord(userDataTab: rec, deleteAll: false) == false){
                ok = false
            }
        }
        
        var filtedData:[UserDataTab] = []
        for (_, rec) in (changeList.enumerated()) {
            if (rec.username == nil || rec.status == nil) {
                continue
            }
            filtedData = filterUsername(username: rec.username!)
            let lastidx = filtedData.count - 1
            for (idx, del) in (filtedData.enumerated()) {
                if (idx == lastidx) {
                    break
                }
                _ = deleteObject(user: del)
            }
        }
        return ok
    }

}
