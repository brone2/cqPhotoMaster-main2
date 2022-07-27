//
//  settingsPage.swift
//  cqidk2
//
//  Created by Neil Bronfin on 4/11/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MessageUI



class settingsPage: UIViewController, MFMailComposeViewControllerDelegate {

    var buildingNameEntered:String?
    var myPastRecieve = [NSDictionary?]()
    var emailString = ""
    var orderHelper = 0
    
    @IBOutlet weak var existingPhotosButton: UIButton!
    @IBOutlet weak var scanOnlyButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInAudit {
            self.auditButton.setTitle("End Audit", for: .normal)
        }
        
        if isAllowDuplicateScan {
            self.existingPhotosButton.setTitle("Block Existing Photos", for: .normal)
        }
        
        if isScanOnly {
            self.scanOnlyButton.setTitle("End Scan Only", for: .normal)
        }
        
        
        
        
        

    }
    
    @IBOutlet weak var auditButton: UIButton!
    //All prompt function to input feedback
    @IBAction func didTapChangeEmail(_ sender: UIButton) { //THIS IS NOW AUDIT!!!!!!
  
        if isInAudit == true { //press to end the audit

            isInAudit = false
            self.make_alert(title: "Audit Ended", message: "The audit has now ended")
            self.auditButton.setTitle("Begin Audit", for: .normal)
            self.orderHelper = 1

        }

        if isInAudit == false  { // press to begin audit
            if self.orderHelper == 0 {
                isInAudit = true
                self.auditButton.setTitle("End Audit", for: .normal)
                self.performSegue(withIdentifier: "settingsToSelectAudit", sender: nil)
//                self.make_alert(title: "Audit Began", message: "You are now in audit mode, select end audit to end this audit")
                
            }

        }
                
        
    }
    
    @IBAction func didTapChangeName(_ sender: UIButton) { //Now this is the one for duplicate scan. ie even if it gets a match from the google sheet it still can take photo
        
        if isAllowDuplicateScan == true {
            isAllowDuplicateScan = false
            self.existingPhotosButton.setTitle("Allow Existing Photos", for: .normal)
            print("now can duplicate scan")
            self.make_alert(title: "Settings Changed", message: "You will now be able to photograph items which already have a photo in the catalog")
        } else {
            isAllowDuplicateScan = true
            self.existingPhotosButton.setTitle("Block Existing Photos", for: .normal)
            self.make_alert(title: "Settings Changed", message: "You will be blocked from taking photographs of items which already have a photo in the catalog")
            print("now cannot duplicate scan")
        }
       
        
        
    }
    
    //Actually ChangeCountry
    
    @IBAction func didTapSubmitFeedback(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "settingsToChangeCountry", sender: nil)
        
    }
    
    @IBAction func didTapReportAbuse(_ sender: UIButton) {
        
  
        
        self.settingsAlert(title: "Report Abuse", message: "Please provide specifics of the issue", placeHolder: "")
        
        
    }
    
    @IBAction func didTapOtherInquiries(_ sender: UIButton) {
        
//        self.updateInfo()
//
//        self.settingsAlert(title: "Other Inquiries", message: "Please describe your inquiry", placeHolder: "")
    
        is_edit_store_id = true
        self.performSegue(withIdentifier: "settingsToSelectStore", sender: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        databaseRef.child("photos").observe(.childAdded) { (snapshot2: DataSnapshot) in
              
              let snapshot2 = snapshot2.value as! NSDictionary
              let snapRecieveId = snapshot2["myId"] as? String
             // let snapComplete = snapshot2["isComplete"] as? Bool
              
              if(snapRecieveId == loggedInUserId){// && snapComplete == true){
                  self.myPastRecieve.append(snapshot2)
              }

          }
        
  
        
    }
    
    //Initially was to send photos, turning this into scan only, and will also reload barcodes which at one point this was
    @IBAction func didTapPhotoRequest(_ sender: UIButton) {
        
        if isScanOnly {
            isScanOnly = false
            self.scanOnlyButton.setTitle("Scan Only", for: .normal)
            self.make_alert(title: "Settings Changed", message: "You will now be prompted to take a photo when the item is not recognized")
        } else {
            isScanOnly = true
            self.scanOnlyButton.setTitle("End Scan Only", for: .normal)
            self.make_alert(title: "Settings Changed", message: "You will not be prompted to take a photo when the item is not recognized")
        }
        
        
        //Clear out all the barcodes because we need to reload the variable weight ones
        auditHaveContentBarcodes = []
        let ref = loadAuditBarcodes()
        var load_all_bc = ref.gather_all_have_content_barcodes()
        var my_vw_items_created = ref.gather_vw_items_have_content()
        

//        var my_bc_created = ref.gather_have_content_barcodes_first_80()
//        var my_bc_created_80_160 = ref.gather_have_content_barcodes_80_160()
            
//        databaseRef.child("photos").observe(.childAdded) { (snapshot2: DataSnapshot) in
//
//              let snapshot2 = snapshot2.value as! NSDictionary
//                print("HEEERE")
//                print(snapshot2)
//              let snapRecieveId = snapshot2["myId"] as? String
//             // let snapComplete = snapshot2["isComplete"] as? Bool
//
//              if(snapRecieveId == loggedInUserId){// && snapComplete == true){
//                  self.myPastRecieve.append(snapshot2)
//              }
//
//          }
//
//        print(self.myPastRecieve)
//
//        for v in self.myPastRecieve {
//            let photoUrl = v!["photoUrl"] as! String
//            let scannedBarcode = v!["scannedBarcode"] as! String
//            let photoNote = v!["photoNote"] as! String
//            let store = v!["store"] as! String
//
//            print(emailString + "," + photoUrl + "-" + scannedBarcode + "-" + photoNote)
//            emailString = emailString + "," + photoUrl + "-" + scannedBarcode + "-" + photoNote + "-" + store
//        }
//        print(emailString)
//
//
//
//        //Send Email
//        let composeVC = MFMailComposeViewController()
//        composeVC.mailComposeDelegate = self
//
//        // Configure the fields of the interface.
//        composeVC.setToRecipients([myEmail])
//        composeVC.setSubject("Photoshoot Results")
//        composeVC.setMessageBody(emailString, isHTML: false)
//
//        // Present the view controller modally.
//        self.present(composeVC, animated: true, completion: nil)
        
        
        
    }
    
 

    
    
func settingsAlert (title: String, message: String, placeHolder:String) {
    var buildingNameTextField: UITextField?
    
    let alertController = UIAlertController(
        title: title,
        message: message,
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
        }
        
        let randomNum:UInt32 = arc4random_uniform(10000)
        let someString:String = String(randomNum)
            
        let childUpdates = ["/inquiry/\(myName)/\(someString)":self.buildingNameEntered!] as [String : Any]
        databaseRef.updateChildValues(childUpdates)

    }
    
    alertController.addTextField {
        (bldName) -> Void in
        buildingNameTextField = bldName
        buildingNameTextField!.placeholder = "placeHolder"
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(completeAction)
    self.present(alertController, animated: true, completion: nil)

}
    
    
    
    
    
    func updateInfo () {
        
//    //Update Users Country all the same
//
//        databaseRef.child("users").observe(.childAdded) { (snapshot: DataSnapshot) in
//        let snapshot = snapshot.value as! NSDictionary
//        let userId = snapshot["userId"] as? String
//        let childUpdates = ["/users/\(userId!)/myCountry":"USA"]
//        databaseRef.updateChildValues(childUpdates)
//
//    //End Update Users Country all the same
            
    //Update Photo Country all the same
        
//        databaseRef.child("photos").observe(.childAdded) { (snapshot: DataSnapshot) in
//        let snapshot = snapshot.value as! NSDictionary
//        let userId = snapshot["photoKey"] as? String
//        let childUpdates = ["/photos/\(userId!)/country":"USA"]
//        databaseRef.updateChildValues(childUpdates)
            
    //End Update Photo Country all the same

// End Update Store Country all the same
        
    
            
            
            
            
            
            
//    }
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    

}



