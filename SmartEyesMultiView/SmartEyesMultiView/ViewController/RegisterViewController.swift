//
//  RegisterViewController.swift
//  SmartEyesMultiView
//
//  Created by david on 2/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox
import Vision
import AVFoundation

class RegisterViewController: WorkViewController {

    //@IBOutlet weak var usernameText: UITextField!
    var user: [NSManagedObject] = []
    
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var classText: UITextField!
    
    //@IBOutlet weak var btnSave: UIButton!

    var photoCounter: Int = 0

    var previewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var photoCounterLbl: UILabel!

    private var validator = PasswordValidator.standard

    override func viewDidLoad() {

        super.viewDidLoad()

        //usernameText.delegate = self

        //btnSave.isEnabled = false

        self.TapSwitchCamera = true
        self.tapEndEditing = true

        // disable classify
        self.classificationRequest = nil

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreview.layer.addSublayer(previewLayer)

        // https://stackoverflow.com/questions/25693130/move-textfield-when-keyboard-appears-swift

        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)


        self.viewID = "RegisterViewController"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -200 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraPreview.bounds;
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

        print("\(String(describing: self.restorationIdentifier)): enter register view")

        // useing front camera
        switchCamera(camMaxIndex)

        TapSwitchCamera = true

        Toast.fresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // https://stackoverflow.com/questions/49522773/how-to-hide-the-keyboard-using-done-button-swift-4
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("textFieldShouldReturn: ", textField.restorationIdentifier ?? "unknow-textField")
        if (textField.restorationIdentifier == nil) {
            return true
        }
        if (textField.restorationIdentifier == "registerUserNameText") {
            save(btnSave)
            return true
        }
        return true
    }

    var contexts = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func takePhoto(_ sender: UIButton)
    {
        AudioServicesPlaySystemSound(1108)
    }
    
    @IBAction func addNewCancel(_ sender: UIBarButtonItem)
    {
        AudioServicesPlaySystemSound(1104)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem)
    {
        AudioServicesPlaySystemSound(1104)
        if nameText.text != "" && classText.text != ""
        {
            if (self.rootView.userDataTabHandler.saveObject(username: nameText.text!, adminName: "-null-", room: classText.text!, status: "Attended", date: Date.init()))
            {
                DavidUitl.alertOK(currentView: self, title: "Notice", message: "Registration Successful!")
            }
            else
            {
                DavidUitl.alertOK(currentView: self, title: "Error", message: "Core data error!")
            }
        }
        else
        {
            DavidUitl.alertOK(currentView: self, title: "Notice", message: "Please Fill in All Blanks")
        }
    }
}
