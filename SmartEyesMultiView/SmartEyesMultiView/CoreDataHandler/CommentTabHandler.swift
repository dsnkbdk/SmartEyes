//
//  CommentTabHandler.swift
//  SmartEyesMultiView
//
//  Created by david on 10/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit
import CoreData

class CommentTabHandler: NSObject {

    private var ctx: NSManagedObjectContext!

    private var entity: NSEntityDescription!

    override init() {
        super.init()
        self.ctx = getContext()
        self.entity = NSEntityDescription.entity(forEntityName: "CommentTab", in: self.ctx!)
    }

    private  func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        return appDelegate.persistentContainer.viewContext
    }

    public func newObject() -> CommentTab {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "CommentTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue("-null-", forKey: "username")
        manageObject.setValue("-null-", forKey: "comment")

        let obj:CommentTab = manageObject as! CommentTab

        return obj

    }

    public func initTable() -> Bool{

        let commentTabs: [CommentTab]? = fetchObjects()

        if (commentTabs == nil || commentTabs?.count == 0){
            // print"info: initial CommentTab record for empty table ...");
            let commentTab = newObject()
            if (saveConfig(commentTab: commentTab) == false) {
                print("error: initial CommentTab record failed.");
                return false
            }
            // not default record
            if (cleanDelete() == false){
                print("error: clear temp CommentTab record failed.");
                return false
            }
        }
        return true
    }

    func fetchObjects() -> [CommentTab]? {
        let context = self.ctx // let context= getContext()
        var user:[CommentTab]? = nil
        do {
            user = try context!.fetch(CommentTab.fetchRequest())
            return user
        }catch {
            print("Unexpected fetchObjects error: \(error).")
            return user
        }
    }

    public  func readConfig() -> CommentTab? {

        var lastCommentTab: CommentTab? = nil

        if (initTable() == false){
            return nil
        }

        let commentTab: [CommentTab]? = fetchObjects()
        if (commentTab == nil || commentTab?.count == 0){
            // record not exist
            // print"CommentTab: is empty, return nil\n")
            return nil;
        }

        for (_, rec) in (commentTab!.enumerated()) {
            // print"CommentTab/fetchLastObject#\(idx), username: \(String(describing: rec.username)), comment: \(String(describing: rec.comment))\n")
            lastCommentTab = rec
        }
        return lastCommentTab
    }

    func saveObject(username:String, comment:String, doWelcome: Bool, saveComment: Bool) -> Bool {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "CommentTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue(username, forKey: "username")
        manageObject.setValue(comment, forKey: "comment")

        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected saveObject error: \(error).")
            return false
        }
    }

    public  func saveConfig(commentTab: CommentTab?) -> Bool {
        if (commentTab == nil){
            // print("CommentTab/saveConfig: nil record")
            return false
        }

        // print("CommentTab/saveConfig: input, username: \(commentTab!.username ?? "-"), comment: \(commentTab!.comment ?? "-")\n")

        var username: String? = commentTab!.username
        if (username == nil || username == ""){
            username = "-null-"
        }
        var comment: String? = commentTab!.comment
        if (comment == nil || comment == ""){
            comment = "-null-"
        }

        // print"CommentTab/saveConfig: copy, username: \(username ?? "-"), comment: \(comment ?? "-")\n")
        // NOTE: only one record for this table, remove old data first
        if (cleanDelete() == false) {
            print("clean CommentTab for Save failed")
            return false
        }

        // print"CommentTab/saveConfig: save, username: \(username ?? "-"), comment: \(comment ?? "-")\n")

        if (saveObject(username: username!, comment: comment!) == false){
            print("save CommentTab/saveConfig failed")
            return false
        }
        return true
    }

    func saveObject(username:String, comment:String) -> Bool {
        let context = self.ctx // let context= getContext()
        //let entity= NSEntityDescription.entity(forEntityName: "AppTab", in: context!)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        manageObject.setValue(username, forKey: "username")
        manageObject.setValue(comment, forKey: "comment")

        do {
            try context!.save()
            return true
        }catch {
            print("Unexpected saveObject error: \(error).")
            return false
        }
    }

    func deleteObject(user: CommentTab) -> Bool {
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
        var commentTab: [CommentTab]?
        let context = self.ctx // let context= getContext()
        do {
            commentTab = try context!.fetch(CommentTab.fetchRequest())
        }catch {
            print("Unexpected cleanDelete/fetchObjects error: \(error).")
            return false
        }
        if (commentTab == nil || commentTab?.count == 0){
            // record not exist
            // print"CommentTab: is empty, clear ok\n")
            return true;
        }

        for (_, rec) in (commentTab!.enumerated()) {
            // print"CommentTab/cleanDelete#\(idx), username: \(String(describing: rec.username)), comment: \(String(describing: rec.comment))\n")
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

    func filterUsername(username: String) -> [CommentTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<CommentTab> = CommentTab.fetchRequest()
        var commentTab:[CommentTab] = []

        let predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = predicate

        do {
            commentTab = try context!.fetch(fetchRequest)
            return commentTab
        }catch {
            print("Unexpected filterUsername error: \(error).")
            return commentTab
        }
    }

    func filterComment(comment: String) -> [CommentTab] {
        let context = self.ctx // let context= getContext()
        let fetchRequest:NSFetchRequest<CommentTab> = CommentTab.fetchRequest()
        var commentTab:[CommentTab] = []

        let predicate = NSPredicate(format: "comment == %@", comment)
        fetchRequest.predicate = predicate

        do {
            commentTab = try context!.fetch(fetchRequest)
            return commentTab
        }catch {
            print("Unexpected filterComment error: \(error).")
            return commentTab
        }
    }

    func filterUsernameComment(username: String, comment: String) -> [CommentTab] {
        var filtedData:[CommentTab] = []

        let user:[CommentTab]? = filterUsername(username: username)
        let pass:[CommentTab]? = filterComment(comment: comment)

        for (_, u) in (user?.enumerated())! {
            // print"user-user#\(idx), username: \(String(describing: u.username)), comment: \(String(describing: u.comment))\n")
            for (_, p) in (pass?.enumerated())! {
                // print("user-comment#\(idx), username: \(String(describing: p.username)), comment: \(String(describing: p.comment))\n")
                if (u.username == p.username && u.comment == p.comment){
                    filtedData.append(u)
                }
            }
        }
        return filtedData
    }

}
