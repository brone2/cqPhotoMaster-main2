//
//  ViewController.swift
//  cqidk2
//
//  Created by Neil Bronfin on 4/7/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit

var autoLoginHelp: Int = 0

//General User info
var myCurrentStore:String = "notSelected"
var myCurrentStoreId:String = "TBD"
var myCountry:String = "notSelected"
var todayDate:String = String(Date.getCurrentDate())
var myName:String = "TBD"
var loggedInUserId:String = "TBD"
var databaseRef = Database.database().reference()
var loggedInUserEmail:String = "TBD"
var myPhotoShootKey:String = "TBD"
var myEmail:String = "TBD"
var isX = true
var screenHeight:CGFloat = 25.0
var is_edit_store_id = false

//Audit Info
var isInAudit:Bool = false
var isScanOnly:Bool = false
var auditCode:String = "TBD" //This is the auto generated audit name with store, date, branch
var itemsScanned:Int = 0
var itemsScannedCreated:Int = 0
var auditHaveContentBarcodes:[String] = []
var auditMissingPhotoBarcodes:[String] = []
var isAllowDuplicateScan:Bool = false
var currentAuditId:String = "TBD"
var currentAuditName:String = "TBD"
var currentAuditAddress:String = "TBD"
var currentAuditBranchId:String = "TBD"
var currentAuditStore:String = "TBD"
var auditScanResults:String = "TBD"
var isShowNextPhotoMessage:Bool = false
var albertsonStoreIdList = ["11012","5553","8988","8987","11043","11009","5555","11044","11010","11011","5554","11186","12693","12855","13006"]
var isAlbertsonsStore = false


//Scanning barcode variables
var scannedBarcode:String = "TBD"
var rawBarcode:String = "TBD"
var isVariableWeight:Bool = false
var adjustedPluCode:String = "FALSE"
var pluCode:String = "FALSE"
var pluPrice:String = "0.00"
var photoNote:String = ""
var isDeliItem:Bool = false
var standardCreatedBcReference:[String] = ["https://sheet.best/api/sheets/4b104909-e4e6-4bbb-b375-c0df2b7e1f61","https://sheet.best/api/sheets/4b453c9b-21ec-4dd3-ad40-909f239a4540","https://sheet.best/api/sheets/9c7e2103-d75a-4b7c-89a3-20b0590fbe70"]
var variableCreatedBcReference = URL(string: "https://sheet.best/api/sheets/956ea209-12c3-46af-ba50-db0927679e62")!



//Uploading Photo variables
var downloadUrlAbsoluteStringPath:String = "TBD"
var downloadUrlAbsoluteStringValue = "TBD"

//segue helpers
var photoViewDismissHelper = 0
var isTapCancelPhoto:Bool = false

var is_iphone_12:Bool = false

class ViewController: UIViewController {

    var time = 0
    var timer = Timer()
    var loggedInUserData: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try! Auth.auth().signOut()
        
        self.checkModel()
        self.detectIphone()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.startTimer), userInfo: nil, repeats: true)
        
        print("Hello big dog!")
        
    //This is also an option to select in settings, so need to update there as well
        
//        //This is not needed because the barcodes will load fully when store is selected
//        let ref = loadAuditBarcodes()
//        var my_bc_created = ref.gather_have_content_barcodes_first_80()
//        var my_bc_created_80_160 = ref.gather_have_content_barcodes_80_160()
//        var my_bc_not_created = ref.gather_vw_items_have_content()
//        print(auditHaveContentBarcodes.count)
        
    }
    
    func checkModel()  {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        if modelCode != nil {
            if modelCode!.contains("iPhone12") {
                is_iphone_12 = true
            }
        }
        print(modelCode)
    }
    
    @objc func startTimer() {
        time += 1
        if time == 1 {
            //timer.invalidate()
            self.checkUser()
        }
        
        if time == 5 {
            print("gotto5")
            timer.invalidate()
            self.performSegue(withIdentifier: "introtoLogin", sender: nil)
        }
        
    }
    
    
    func checkUser()  {
        
        Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if autoLoginHelp == 0 {
                
            print(user)
     
            if user != nil {
                
                self.timer.invalidate()
                loggedInUserId = Auth.auth().currentUser!.uid
                
                //get user name
                databaseRef.child("users").child(loggedInUserId).observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
                    self.loggedInUserData = snapshot.value as? NSDictionary
                    
                    databaseRef.child("audit").observe(.childAdded) { (snapshot: DataSnapshot) in
                        //TEST HERE IF THIS WILL SPEED IT UP LATER
                    }
                    
                    if self.loggedInUserData?["myName"] as? String == nil  {
                        try! Auth.auth().signOut()
                        self.timer.invalidate()
                        self.performSegue(withIdentifier: "introtoLogin", sender: nil)
                        
                    } else {
                        
                        myName = (self.loggedInUserData?["myName"] as? String)!
                        myEmail = (self.loggedInUserData?["myEmail"] as? String)!
                        
                        if self.loggedInUserData?["myCountry"] as? String == nil  {
                            
                            myCountry = "USA"
                            
                        } else {
                            
                            myCountry = (self.loggedInUserData?["myCountry"] as? String)!
                            
                        }
                        self.performSegue(withIdentifier: "introToStore", sender: nil)
                    }
                } // end get uder info
            }
            
            }
        }) //Auth.auth()?.addStateDidChangeListener({ (auth, user) in
    }
    
   
    
    func detectIphone() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        screenHeight = screenSize.height
        print(screenHeight)
        
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
      // || UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        {
            isX = true
            print("isX!")
        }
        
        if #available(iOS 11.0, *) {
            if UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24 {
                isX = true
                print("isX!")
            }
        }
    }

        
}

extension Date {

 static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd/MM/yyyy"

        return dateFormatter.string(from: Date())

    }
}



