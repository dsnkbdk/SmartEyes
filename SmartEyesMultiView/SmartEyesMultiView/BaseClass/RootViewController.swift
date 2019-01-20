//
//  RootViewController.swift
//  SmartEyesMultiView
//
//  Created by david on 8/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import UIKit

import AVFoundation
import Vision

// https://medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a
class RootViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var storyBoard: UIStoryboard!

    var errCount: Int = 0

    var viewID: String = "RootViewController"

    var alertResult: Int = -1

    var tapEndEditing: Bool = false
    var TapSwitchCamera: Bool = false

    // controlling the pace of the machine vision analysis
    var lastAnalysis: TimeInterval = 0
    var pace: TimeInterval = 0.33 // in seconds, classification will not repeat faster than this value

    // performance tracking
    let trackPerformance = false // use "true" for performance logging
    var frameCount = 0
    let framesPerSample = 10
    var startDate = NSDate.timeIntervalSinceReferenceDate

    let targetImageSize = CGSize(width: 320, height: 320) // must match model data input

    let queue = DispatchQueue(label: "videoQueue")
    let videoOutput = AVCaptureVideoDataOutput()
    var unknownCounter = 0 // used to track how many unclassified images in a row

    var matchID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tapWaiting = false

        self.matchID = "Unknown"

        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.

        self.storyBoard  = UIStoryboard(name: "Main", bundle:nil)

        setupCamera()

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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setViewID(viewID: String) {
        self.viewID = viewID
        self.restorationIdentifier = viewID
    }

    func alertOK(currentView: UIViewController?, title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil)  {
        print("alertOK: enter TITLE: \(title), MESSAGE: \(message)\n")

        func alertHandler(action:  UIAlertAction!) {
            switch action.style{
            case .default:
                print("alertOK: default")
                self.alertResult = 0
                break
            case .cancel:
                print("alertOK: cancel")
                self.alertResult = 1
                break
            case .destructive:
                print("alertOK: destructive")
                self.alertResult = 3
                break
            }
            if (handler != nil){
                handler!(action)
            }

            Toast.fresh()
            // Toast(text: "alertOK: click on \(self.alertResult), TITLE: \(title), MESSAGE: \(message)\n", duration: Delay.short).show()

        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
        if (currentView == nil) {
            self.present(alert, animated: true, completion: nil)
        } else {
            currentView!.present(alert, animated: true, completion: nil)
        }

        print("alertOK: present, TITLE: \(title), MESSAGE: \(message)\n")

    }

    func alertDismiss(currentView: UIViewController?, title: String, message: String)  {
        print("alertDismiss: enter TITLE: \(title), MESSAGE: \(message)\n")

        func alertHandler(action:  UIAlertAction!) {
            switch action.style{
            case .default:
                print("alertOK: default")
                self.alertResult = 0
                break
            case .cancel:
                print("alertOK: cancel")
                self.alertResult = 1
                break
            case .destructive:
                print("alertOK: destructive")
                self.alertResult = 3
                break
            }
            currentView?.dismiss(animated: false, completion: nil)

            Toast.fresh()
            // Toast(text: "alertOK: click on \(self.alertResult), TITLE: \(title), MESSAGE: \(message)\n", duration: Delay.short).show()

        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
        if (currentView == nil) {
            self.present(alert, animated: true, completion: nil)
        } else {
            currentView!.present(alert, animated: true, completion: nil)
        }

        print("alertOK: present, TITLE: \(title), MESSAGE: \(message)\n")

    }

    // MARK: Handle user image classification results
    public func handleUserClassification(request: VNRequest, error: Error?) {
        fatalError("handleUserClassification must be implemented in subclass!")
    }

    // MARK: Handle admin image classification results
    public func handleAdminClassification(request: VNRequest, error: Error?) {
        fatalError("handleAdminClassification must be implemented in subclass!")
    }

    // MARK: Load the Model

    lazy var userClassificationRequest: [VNRequest] = {
        do {
            // Load the Custom Vision model.
            // To add a new model, drag it to the Xcode project browser making sure that the "Target Membership" is checked.
            // Then update the following line with the name of your new model.
            let model = try VNCoreMLModel(for: faces_user().model)
            let userClassificationRequest = VNCoreMLRequest(model: model, completionHandler: self.handleUserClassification)
            return [ userClassificationRequest ]
        } catch {
            fatalError("Can't load Vision ML model: \(error)")
        }
    }()

    lazy var adminClassificationRequest: [VNRequest] = {
        do {
            // Load the Custom Vision model.
            // To add a new model, drag it to the Xcode project browser making sure that the "Target Membership" is checked.
            // Then update the following line with the name of your new model.
            let model = try VNCoreMLModel(for: faces_admin().model)
            let adminClassificationRequest = VNCoreMLRequest(model: model, completionHandler: self.handleAdminClassification)
            return [ adminClassificationRequest ]
        } catch {
            fatalError("Can't load Vision ML model: \(error)")
        }
    }()

    var classificationRequest:[VNRequest]!

    let context = CIContext()
    var rotateTransform: CGAffineTransform?
    var scaleTransform: CGAffineTransform?
    var cropTransform: CGAffineTransform?
    var resultBuffer: CVPixelBuffer?

    func croppedSampleBuffer(_ sampleBuffer: CMSampleBuffer, targetSize: CGSize) -> CVPixelBuffer? {

        guard let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError("Can't convert to CVImageBuffer.")
        }

        // Only doing these calculations once for efficiency.
        // If the incoming images could change orientation or size during a session, this would need to be reset when that happens.
        if rotateTransform == nil {
            let imageSize = CVImageBufferGetEncodedSize(imageBuffer)
            let rotatedSize = CGSize(width: imageSize.height, height: imageSize.width)

            guard targetSize.width < rotatedSize.width, targetSize.height < rotatedSize.height else {
                fatalError("Captured image is smaller than image size for model.")
            }

            let shorterSize = (rotatedSize.width < rotatedSize.height) ? rotatedSize.width : rotatedSize.height
            rotateTransform = CGAffineTransform(translationX: imageSize.width / 2.0, y: imageSize.height / 2.0).rotated(by: -CGFloat.pi / 2.0).translatedBy(x: -imageSize.height / 2.0, y: -imageSize.width / 2.0)

            let scale = targetSize.width / shorterSize
            scaleTransform = CGAffineTransform(scaleX: scale, y: scale)

            // Crop input image to output size
            let xDiff = rotatedSize.width * scale - targetSize.width
            let yDiff = rotatedSize.height * scale - targetSize.height
            cropTransform = CGAffineTransform(translationX: xDiff/2.0, y: yDiff/2.0)
        }

        // Convert to CIImage because it is easier to manipulate
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let rotated = ciImage.transformed(by: rotateTransform!)
        let scaled = rotated.transformed(by: scaleTransform!)
        let cropped = scaled.transformed(by: cropTransform!)

        // Note that the above pipeline could be easily appended with other image manipulations.
        // For example, to change the image contrast. It would be most efficient to handle all of
        // the image manipulation in a single Core Image pipeline because it can be hardware optimized.

        // Only need to create this buffer one time and then we can reuse it for every frame
        if resultBuffer == nil {
            let result = CVPixelBufferCreate(kCFAllocatorDefault, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32BGRA, nil, &resultBuffer)

            guard result == kCVReturnSuccess else {
                fatalError("Can't allocate pixel buffer.")
            }
        }

        // Render the Core Image pipeline to the buffer
        context.render(cropped, to: resultBuffer!)

        //  For debugging
        //  let image = imageBufferToUIImage(resultBuffer!)
        //  print(image.size) // set breakpoint to see image being provided to CoreML

        return resultBuffer
    }

    // Only used for debugging.
    // Turns an image buffer into a UIImage that is easier to display in the UI or debugger.
    func imageBufferToUIImage(_ imageBuffer: CVImageBuffer) -> UIImage {

        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)

        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        let quartzImage = context!.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        let image = UIImage(cgImage: quartzImage!, scale: 1.0, orientation: .right)

        return image
    }


    // MARK: Camera handling

    var cameras: [AVCaptureDevice] = [AVCaptureDevice]()
    var camCurIndex: Int = 0
    var camMaxIndex: Int = -2

    var captureSession = AVCaptureSession()
    var isCaptureRunning: Bool = false

    func startCaptureSession () {
        self.captureSession.stopRunning()

        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            if (inputs.count > 0) {
                isCaptureRunning = true
                captureSession.startRunning()
                return
            }
        }
        if (camMaxIndex < 0) {
            return
        }
        switchCamera(camMaxIndex)
    }

    func pauseCaptureSession () {
        self.captureSession.stopRunning()
        isCaptureRunning = false
    }

    func stopCaptureSession () {
        self.pauseCaptureSession()

        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                print("captureSession, remove input: ", input.device.localizedName)
                self.captureSession.removeInput(input)
            }
        }
    }

    // https://github.com/meatspaces/meatspace-ios/blob/master/MeatChat/MCPostViewController.swift

    func switchCamera(_ index: Int) {
        if (camMaxIndex < 0) {
            alertOK(currentView: self, title: "Camera initial error", message: "Camera not found in current device.")
            return
        }
        var camIndex = index
        if (camIndex == -1) {
            if (isCaptureRunning == false) {
                startCaptureSession()
                return
            }
            camIndex = camCurIndex + 1
            if (camIndex > camMaxIndex) {
                camIndex = 0
            }
        }

        if (camIndex < 0 || camIndex > camMaxIndex) {
            let msg = String.init(format: "Invalid camera index %d, index range: 0 - %d", camIndex, camMaxIndex)
            alertOK(currentView: self, title: "Camera switch error", message: msg)
            return
        }
        camCurIndex = camIndex
        let currentDevice = cameras[camIndex]

        stopCaptureSession()
        do {

            let input = try AVCaptureDeviceInput(device: currentDevice)
            captureSession.addInput(input)

            captureSession.startRunning()
            print("switch to camera(\(currentDevice.localizedName)): ", camIndex, ", max: ", camMaxIndex)
            isCaptureRunning = true
        } catch {
            let msg = String.init(format: "Switch to camera %d: \(error)", camIndex)
            alertOK(currentView: self, title: "Camera initial error", message: msg)
        }
    }

    func setupCamera() {
        print("setup camera ...")
        let backDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)

        for onedev in backDevice.devices {
            cameras.append(onedev)
        }

        let frontDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)

        for onedev in frontDevice.devices {
            cameras.append(onedev)
        }
        camMaxIndex = cameras.count - 1

        if (camMaxIndex < 0) {
            return
        }
        videoOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : (NSNumber(value: kCVPixelFormatType_32BGRA) as! UInt32)]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)

        captureSession.sessionPreset = .photo // .hd1920x1080
        captureSession.addOutput(videoOutput)
                print("setup camera done")
    }


    // called for each frame of video
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        if (self.classificationRequest == nil) {
            // alertOK(currentView: self, title: "captureOutput error", message: "classificationRequest not initialed")
            return
        }

        let currentDate = NSDate.timeIntervalSinceReferenceDate

        // control the pace of the machine vision to protect battery life
        if currentDate - lastAnalysis >= pace {
            lastAnalysis = currentDate
        } else {
            return // don't run the classifier more often than we need
        }

        // keep track of performance and log the frame rate
        if trackPerformance {
            frameCount = frameCount + 1
            if frameCount % framesPerSample == 0 {
                let diff = currentDate - startDate
                if (diff > 0) {
                    if pace > 0.0 {
                        print("WARNING: Frame rate of image classification is being limited by \"pace\" setting. Set to 0.0 for fastest possible rate.")
                    }
                    print("\(String.localizedStringWithFormat("%0.2f", (diff/Double(framesPerSample))))s per frame (average)")
                }
                startDate = currentDate
            }
        }

        // Crop and resize the image data.
        // Note, this uses a Core Image pipeline that could be appended with other pre-processing.
        // If we don't want to do anything custom, we can remove this step and let the Vision framework handle
        // crop and resize as long as we are careful to pass the orientation properly.
        guard let croppedBuffer = croppedSampleBuffer(sampleBuffer, targetSize: targetImageSize) else {
            return
        }

        do {
            let classifierRequestHandler = VNImageRequestHandler(cvPixelBuffer: croppedBuffer, options: [:])
            try classifierRequestHandler.perform(self.classificationRequest)
        } catch {
            print(error)
        }
    }

    var tapWaiting: Bool = false;

    // subclass may override this method
    func onTappedAround() {
        if (self.tapEndEditing) {
            view.endEditing(true)
            // print("end editing by tap")
        }
        print("onTappedAround(default): ", self.restorationIdentifier as Any)
    }

    // subclass may override this method
    func onDoubleTappedAround() {
        if (self.TapSwitchCamera) {
            // print("switchCamera by tap")
            switchCamera(-1)
        }
        print("onDoubleTappedAround(default): ", self.restorationIdentifier as Any)
    }

} // end of class



// https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
// Put this piece of code anywhere you like

extension RootViewController {

    // note: put "self.hideKeyboardWhenTappedAround()" into viewDidLoad() to take effect
    func hideKeyboardWhenTappedAround() {

        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RootViewController.callDoubleTappedAround))
        doubleTap.cancelsTouchesInView = false
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RootViewController.callTappedAround))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1

        // button action will be disabled when use "tap.require(toFail: doubleTap"
        // tap.require(toFail: doubleTap)
        view.addGestureRecognizer(tap)
    }

    @objc func callTappedAround() {
        // print("callTappedAround: tapWaiting = ", self.tapWaiting )
        if (self.tapWaiting == false) {
            // wait for delay
            // print("callTappedAround: prepare ", self.restorationIdentifier as Any)
            self.tapWaiting = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if (self.tapWaiting) {
                    //print("callTappedAround: ", self.restorationIdentifier as Any)
                    self.onTappedAround()
                } else {
                    //print("callTappedAround: delay skipped ", self.restorationIdentifier as Any)
                }
                self.tapWaiting = false
            }
        } else {
            // fast tap
            self.callDoubleTappedAround()
        }
    }

    @objc func callDoubleTappedAround() {
        // print("callDoubleTappedAround: ", self.restorationIdentifier as Any)
        self.tapWaiting = false
        self.onDoubleTappedAround()
    }

} // end of class ext

