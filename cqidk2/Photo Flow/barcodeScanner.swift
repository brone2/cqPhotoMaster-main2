//
//  barcodeScanner.swift
//  cqidk2
//
//  Created by Neil Bronfin on 4/10/21.
//

// Code from youtube https://docs.google.com/document/d/126OAOeagyNQROroOqcED3ux8fiBkQWDu0tP1nVYWuUo/edit?usp=sharing

//Note on this page reset all values for the photoshoot to defaults
//  TODO add note of scan to barcode
import UIKit
import AVFoundation
 
//Need to set photoViewDismissHelper = 1 here to begin next view on the camera picker
//Scan the barcode and then do all reformatting
class barcodeScanner: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    var buildingNameEntered:String?
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "barcodeScanToMain", sender: nil)
    }
    
    @IBOutlet weak var backButtonView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
     
        //Helper associated with segue from selecting Cancel on photo picker
        isTapCancelPhoto = false
        //Set all barcode values back to default
        downloadUrlAbsoluteStringValue = ""
        scannedBarcode = "TBD"
        rawBarcode = "TBD"
        isVariableWeight = false
        adjustedPluCode = ""
        pluCode = ""
        pluPrice = ""
        photoNote = ""
        isDeliItem = false
        
    }
    
    func scanningScript () {
        
        downloadUrlAbsoluteStringValue = ""
        avCaptureSession = AVCaptureSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
     
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video)
            
            else {
                self.failed()
                return
            }
            let avVideoInput: AVCaptureDeviceInput
            
            do {
                avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                self.failed()
                return
            }
            
            if (self.avCaptureSession.canAddInput(avVideoInput)) {
                self.avCaptureSession.addInput(avVideoInput)
            } else {
                self.failed()
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                self.avCaptureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13]
//                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr] REMOVE OTHER CODES FROM BEING SCANNED
                
            } else {
                self.failed()
                return
            }
            
            self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
            self.avPreviewLayer.frame = self.view.layer.bounds
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.avPreviewLayer)
            self.view.bringSubviewToFront(self.backButtonView)
            
            //Add text to say proceed to next item if in audit mode and last item was found
            if isShowNextPhotoMessage {
                
                let textlayer = CATextLayer()
                textlayer.frame = CGRect(x: self.view.bounds.midX - 280/2  , y: self.view.bounds.midY - 40, width: 280, height: 60)
                textlayer.fontSize = 28
                textlayer.font = "Helvetica-Bold" as CFTypeRef
                textlayer.alignmentMode = .center
                textlayer.string = "Proceed to Next Item"
                textlayer.isWrapped = true
                textlayer.truncationMode = .end
                textlayer.backgroundColor = UIColor.clear.cgColor
                textlayer.foregroundColor = UIColor.systemPink.cgColor
                self.view.layer.addSublayer(textlayer) // caLayer is and instance of parent CALayer
                //End Add text to direct to scan the barcode
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { //hide after 2 seconds
                    textlayer.isHidden = true
                }
                isShowNextPhotoMessage = false
            }
            
            //Add text to direct to scan the barcode
            let textlayer = CATextLayer()
            textlayer.frame = CGRect(x: self.view.bounds.midX - 280/2  , y: 86, width: 280, height: 44)
            textlayer.fontSize = 42
            textlayer.alignmentMode = .center
            textlayer.string = "Scan Barcode"
            textlayer.isWrapped = true
            textlayer.truncationMode = .end
            textlayer.backgroundColor = UIColor.clear.cgColor
            textlayer.foregroundColor = UIColor.green.cgColor
            self.view.layer.addSublayer(textlayer) // caLayer is and instance of parent CALayer
            //End Add text to direct to scan the barcode
            
            //Add manually enter sku button
            let myButton = UIButton(type: .system)
            myButton.frame = CGRect(x: self.view.bounds.midX - 280/2  , y: screenHeight - 140, width: 280, height: 40)
            myButton.setTitle("Enter Custom SKU", for: .normal)
            myButton.addTarget(self, action: #selector(self.buttonAction(_:)), for: .touchUpInside)
            myButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
            myButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            //myButton.underlineText()
            self.view.addSubview(myButton)
            //End Add manually enter sku button
            self.avCaptureSession.startRunning()
        }
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanningScript()
    }
    
//CUSTOM SKU SELECTED TO BE ENTERED
    @objc func buttonAction(_ sender:UIButton!) {

        var buildingNameTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Enter Custom SKU",
            message: "If this item has a barcode, please select Cancel and scan the barcode. Do not manually type in a barcode.",
            preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel", style: UIAlertAction.Style.default) {
            (action) -> Void in
        }
        
        let completeAction = UIAlertAction(
            title: "Complete", style: UIAlertAction.Style.default) {
            (action) -> Void in
            if let buildingName = buildingNameTextField?.text {
                self.buildingNameEntered = buildingName.capitalizingFirstLetter()
                scannedBarcode = "CUSTOM - " + self.buildingNameEntered!
                rawBarcode = "CUSTOM - " + self.buildingNameEntered!
                isVariableWeight = false
                adjustedPluCode = ""
                pluCode = ""
                pluPrice = ""
            }
            
            photoViewDismissHelper = 1
            self.performSegue(withIdentifier: "barcodeScanningToTakePhoto", sender: nil)

        }
        
        alertController.addTextField {
            (bldName) -> Void in
            buildingNameTextField = bldName
            buildingNameTextField!.placeholder = "Ex: Roast Beef sold by 1/2 pound"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        avCaptureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (avCaptureSession?.isRunning == false) {
            avCaptureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (avCaptureSession?.isRunning == true) {
            avCaptureSession.stopRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}


extension barcodeScanner : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        avCaptureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

//        self.performSegue(withIdentifier: "barcodeScanningToTakePhoto", sender: nil) //HERE MOVING THIS TO THE FOUND FUNCTION
    }

    
//Save and reformat barcode info. 1. Remove leading
    func found(code: String) {
        
        print(code)
        let codeAsInt = Int(code)
        let codeFormatted =  "\(codeAsInt!)"
        scannedBarcode = codeFormatted
        rawBarcode = scannedBarcode
        print(scannedBarcode)
        
        //Check if is variable weight
        let leadingDigit = scannedBarcode[0]
        if ((scannedBarcode.count) == 12) && (leadingDigit == "2") {
            isVariableWeight = true
            adjustedPluCode = "a" + scannedBarcode.substring(toIndex: scannedBarcode.length - 6) + "00000"
            pluCode = "a" + scannedBarcode[1 ..< 6]
            pluPrice = "a" + scannedBarcode[7 ..< 11]
        } else {
            isVariableWeight = false
            adjustedPluCode = ""
            pluCode = ""
            pluPrice = ""
        }
        scannedBarcode = "a" + scannedBarcode
        
        //IN AUDIT HERE DO THE CHECK IF THE PRODUCT IS IN CATALOG
        
        print(isVariableWeight)
        print(adjustedPluCode)
        print(pluCode)
        print(pluPrice)
        print(scannedBarcode)
        photoViewDismissHelper = 1
        
        
        //Perform Audit Related Logic
        if isAllowDuplicateScan { //always move on to take photo stage
            self.performSegue(withIdentifier: "barcodeScanningToTakePhoto", sender: nil)
        }
        

        else { //If identifying duplicate items
        
            if auditHaveContentBarcodes.contains(scannedBarcode) || auditHaveContentBarcodes.contains(adjustedPluCode)  {
                print("Product in Integration Created")
                auditScanResults = "Already Has Photo"
                isShowNextPhotoMessage = true   //Prep Variable to show message to move to next item
                self.scanningScript() //Move on to scan next item
                
//        //Change this to the variable weight sheet. THINK WE CAN IGNORE THIS BECAUSE THIS IS JUST NOT SOMETHING WERE GOING TO TRACK!!!!
//            } else if auditMissingPhotoBarcodes.contains(scannedBarcode) || auditMissingPhotoBarcodes.contains(adjustedPluCode) { //set some value here to signify its in integratoin
//                print("Product in Integration Not Created")
//                auditScanResults = "In Integration - Did Not Have Photo"
//                self.performSegue(withIdentifier: "barcodeScanningToTakePhoto", sender: nil)
                
                
            } else { //set some value here to signify its not in integratoin
                print("Product not in Integration Not Created")
                auditScanResults = "Does Not Have Photo"
                
                if isScanOnly == false {
                    self.performSegue(withIdentifier: "barcodeScanningToTakePhoto", sender: nil)
                } else {
                    isShowNextPhotoMessage = true   //Prep Variable to show message to move to next item
                    self.scanningScript() //Move on to scan next item
                }
            }
            
        //Here save the audit values. Actually save them all doesn't matter if its an audit or not
        //Apparently it doesn't matter that the segue is above this it still loads i guess

                let key = databaseRef.child("auditScans").childByAutoId().key!
                
                let scanTimestamp = "/auditScans/\(key)/timestamp"
                let keyPath = "/auditScans/\(key)/key"
                let scannedBarcodePath = "/auditScans/\(key)/scannedBarcode"
                let auditScanResultsPath = "/auditScans/\(key)/auditScanResults"
                let auditIdPath = "/auditScans/\(key)/auditId"
                let auditStorePath = "/auditScans/\(key)/auditStore"
                let auditNamePath = "/auditScans/\(key)/auditCode"
                let countryPath = "/auditScans/\(key)/country"
                let scanDatePath = "/auditScans/\(key)/scanDate"
                let scanerUserNamePath = "/auditScans/\(key)/scanerUserName"
                let scanerUserIdPath = "/auditScans/\(key)/scanerUserId"
                let auditBranchIdPath = "/auditScans/\(key)/auditBranchId"
                let auditBranchAddressPath = "/auditScans/\(key)/auditBranchAddress"
                let adjustedPluCodePath = "/auditScans/\(key)/adjustedPluCode"
                let pluPricePath = "/auditScans/\(key)/pluPrice"
                let isVariableWeightPath = "/auditScans/\(key)/isVariableWeight"
                
                
                
                let childUpdates:Dictionary<String, Any> = [scanTimestamp:[".sv": "timestamp"],keyPath:key,scannedBarcodePath:scannedBarcode,auditScanResultsPath:auditScanResults,
                                                              auditIdPath:currentAuditId,auditStorePath:myCurrentStore,auditNamePath:currentAuditName,countryPath:myCountry,scanDatePath:todayDate,scanerUserNamePath:myName,
                                                         scanerUserIdPath:loggedInUserId,auditBranchIdPath:currentAuditBranchId,auditBranchAddressPath:currentAuditAddress,adjustedPluCodePath:adjustedPluCode,pluPricePath:pluPrice,isVariableWeightPath:isVariableWeight]
                
                databaseRef.updateChildValues(childUpdates)
                        

        
    }
    }
    
}




extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


extension UIButton {
  func underlineText() {
    guard let title = title(for: .normal) else { return }

    let titleString = NSMutableAttributedString(string: title)
    titleString.addAttribute(
      .underlineStyle,
      value: NSUnderlineStyle.single.rawValue,
      range: NSRange(location: 0, length: title.count)
    )
    setAttributedTitle(titleString, for: .normal)
  }
}
