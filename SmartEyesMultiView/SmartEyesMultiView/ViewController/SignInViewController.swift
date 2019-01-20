//
//  SignInViewController.swift
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

class SignInViewController: WorkViewController {
    
    @IBOutlet weak var yesBtn: UIButton!
    
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var identifyName: UILabel!

    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var preMatchID: String = "Unknown"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreview.layer.addSublayer(previewLayer)

        // user admin model
        self.classificationRequest = self.userClassificationRequest

        // NOTE: FatalViewController should add in here

        self.viewID = "SignInViewController"

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

        // print("SignInViewController: before switch, doWelcome: \(self.rootView.appTab!.doWelcome), savePassword: \(self.rootView.appTab!.savePassword), username: \(self.rootView.appTab!.username ?? "-"), password: \(self.rootView.appTab!.password ?? "-")\n")

            // show welcome view
            print("\(String(describing: self.restorationIdentifier)): enter welcome view")

            // clear config for debug
            // self.appTabHandler.cleanDelete()
            if (camMaxIndex < 0) {
                self.rootView!.setNextView(viewID: "MainViewController")
                alertDismiss(currentView: self, title: "Camera initial error", message: "Camera not found in current device.")
                return
            }

            // useing front camera
            switchCamera(0)

            TapSwitchCamera = true
            
            Toast.fresh()
            // Toast(text: "Login or Register", duration: Delay.short).show()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    let confidence: Float = 0.90

    // MARK: Handle image classification results
    override public func handleUserClassification(request: VNRequest, error: Error?) {

        guard let observations = request.results as? [VNClassificationObservation]
            else { fatalError("unexpected result type from VNCoreMLRequest") }

        guard let best = observations.first else {
            fatalError("classification didn't return any results")
        }

        // Use results to update user interface (includes basic filtering)
        // print("\(best.identifier): \(best.confidence)")
        let matchid = best.identifier.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if matchid.starts(with: "Unknown") || matchid.starts(with: "other") || best.confidence < confidence {
            if self.unknownCounter < 3 { // a bit of a low-pass filter to avoid flickering
                self.unknownCounter += 1
            } else {
                self.unknownCounter = 0
                DispatchQueue.main.async {
                    if (self.identifyName.text != nil && self.identifyName.text!.count > 0) {
                        self.identifyName.text = ""
                    }
                    self.yesBtn.isEnabled = false
                    self.identifyName.text = matchid
                }
            }
        } else {
            // print(self.viewID, ", MATCH: \(matchid): \(best.confidence)")
            self.unknownCounter = 0
            DispatchQueue.main.async {
                        // Trimming labels because they sometimes have unexpected line endings which show up in the GUI
                if (self.preMatchID != matchid){
                        self.identifyName.text = matchid
                        self.matchID = matchid
                        self.preMatchID = matchid
                        self.pauseCaptureSession()
                        self.yesBtn.isEnabled = true
                        print(self.viewID, ", face matched: \(matchid): \(best.confidence)")
                        //self.alertOK(currentView: self, title: self.titleLabel.text! + " OK", message: "Administrator matched: \(matchid): \(best.confidence)")
                } else {
                    self.identifyName.text = matchid+"(done)"
                }
            }
        }
    }
    
    @IBAction func yes(_ sender: UIButton)
    {
        AudioServicesPlaySystemSound(1104)
        if (self.rootView.userDataTabHandler.saveObject(username: self.matchID, adminName: "-null-", room: "-null-", status: "Attended", date: Date.init()))
        {
            // DavidUitl.alertOK(currentView: self, title: "Success", message: self.matchID + " sign in successfully!")
            
            Toast(text: self.matchID + " sign in successfully!", duration: Delay.long).show()
        }
        else
        {
            DavidUitl.alertOK(currentView: self, title: "Error", message: "Core data error!")
        }
        self.startCaptureSession()
    }
    
    @IBAction func no(_ sender: UIButton)
    {
        AudioServicesPlaySystemSound(1104)
        if (self.rootView.userDataTabHandler.saveObject(username: identifyName.text!, adminName: "-null-", room: "-null-", status: "Unattended", date: Date.init()))
        {
//            DavidUitl.alertOK(currentView: self, title: "Manual Signin", message: "Click on records to Change attendance status")
            self.rootView.goNextView(viewID: "StudentsViewController", caller: self)
        }
        else
        {
            DavidUitl.alertOK(currentView: self, title: "Error", message: "Core data error!")
        }
    }
    
    @IBAction func signInCancel(_ sender: UIBarButtonItem)
    {
        AudioServicesPlaySystemSound(1104)
       self.rootView.goRootView(caller: self)
    }
    
    
    

    
    
    
    
    
    
}
