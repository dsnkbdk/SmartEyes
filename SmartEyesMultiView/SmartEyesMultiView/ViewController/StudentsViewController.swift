//
//  StudentsViewController.swift
//  SmartEyesMultiView
//
//  Created by david on 2/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

// for tableView: http://www.thomashanning.com/uitableview-tutorial-for-beginners/

class StudentsViewController: WorkViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var userDataTabs:[UserDataTab] = []
   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewID = "StudentsViewController"

        // provide data to tableVIew
        tableView.dataSource = self

        // receive event from tableVIew
        tableView.delegate = self
        
        btnSave.isEnabled = false
        
//        self.rootView.userDataTabHandler.cleanDelete()

//        if (self.rootView.userDataTabHandler.saveObject(username: "Jaime", adminName: "David", room: "2104", status: "Attented", date: Date.init())){
//            // dummy data inserted
//        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
       // print("func numberOfSections: 1")
        return 1 //
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("func tableView: numberOfRowsInSection: ", userDataTabs.count)
        return userDataTabs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        
        let rowidx = indexPath.row
        let username = self.userDataTabs[rowidx].username //2.
                
        let status = self.userDataTabs[rowidx].status //2.
        let date = self.userDataTabs[rowidx].date
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString = formatter.string(from:date!)
        
        cell.textLabel?.text = username! + " : " + status! + " : " + dateString //3.
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        if (status == "Unattended") {
            cell.textLabel?.textColor = .red
        }
        
        return cell //4.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("section: \(indexPath.section)")
        // print("row: \(indexPath.row)")
        
        let rowidx = indexPath.row
        _ = self.userDataTabs[rowidx].username //2.
        let status = self.userDataTabs[rowidx].status //2.
        _ = self.userDataTabs[rowidx].date
        if (status == "Unattended") {
            self.userDataTabs[rowidx].status = "Attended"
        } else {
            self.userDataTabs[rowidx].status = "Unattended"
        }
        
        tableView.reloadData()
        
        btnSave.isEnabled = true;
    }

    override func viewWillAppear(_ animated: Bool) {
        // remember to call super func
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        // remember to call super func
        super.viewDidAppear(animated)

        // NOTE: view/alert task should run in this stage
        // otherwise: whose view is not in the window hierarchy

        // for debug
        // self.rootView.commentTabHandler.cleanDelete()

      updateStudents()

        print("\(String(describing: self.restorationIdentifier)): enter comment view")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStudents() {
        self.userDataTabs = self.rootView.userDataTabHandler!.fetchObjects()
        
        tableView.reloadData()
    }
    
    @IBOutlet weak var btnSave: UIButton!
    
    @IBAction func clickBtnSave(_ sender: UIButton) {
        if (self.rootView.userDataTabHandler.updateUsernameStatus(changeList: self.userDataTabs)){
            DavidUitl.alertOK(currentView: self, title: "Saved", message: "All changes saved!")
            btnSave.isEnabled = false;
            updateStudents()
        } else {
            DavidUitl.alertOK(currentView: self, title: "Save failed", message: "Core data error, can not save!")
        }
    }
    
    @IBAction func clickCancel(_ sender: UIButton) {
        print("\(String(describing: self.restorationIdentifier)): goto MainView by button click")
        self.rootView!.goNextView(viewID: "MainViewController", caller: self)
    }
    
    // subclass may override this method
    override func onTappedAround() {
     
    }
    
    // subclass may override this method
    override func onDoubleTappedAround() {
      
    }
}
