//
//  mainPage.swift
//  cqidk2
//
//  Created by Neil Bronfin on 4/9/21.
//

import UIKit

class mainPage: UIViewController {

    @IBOutlet weak var myCurrentStoreLabel: UILabel!
    @IBOutlet weak var photoShootIdLabel: UILabel!
    
    @IBOutlet weak var topTextLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        print("APPPEAR")
           
        if isInAudit == true {
            self.myCurrentStoreLabel.text = currentAuditName
        } else {
            self.myCurrentStoreLabel.text = myCurrentStore
        }
        
        if isInAudit == true {
            self.topTextLabel.text = "Current Audit"
        } else {
            self.topTextLabel.text = "Current Store"
        }
        
        self.photoShootIdLabel.text = myPhotoShootKey
        
        //Moving to didLoad because don't want to duplicate the append each time
        //load audit info
//        let ref = loadAuditBarcodes()
//        var my_bc_created = ref.gather_have_content_barcodes_first_80()
//        var my_bc_created_80_160 = ref.gather_have_content_barcodes_80_160()
//        var my_bc_not_created = ref.gather_missing_photos_barcodes()
        print(auditHaveContentBarcodes.count)
        
     
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 

    }
    
    @IBAction func didTapBeginPhotoshoot(_ sender: UIButton) {
        
        //Create the photoshoot, with id, date, store, photographer name
        //Create key let randomNum:UInt32 = arc4random_uniform(1000)
        let randomNum:UInt32 = arc4random_uniform(100)
        let someString:String = String(randomNum)
        let photoshootKey = myCurrentStore + "-" + someString
        myPhotoShootKey = photoshootKey
        
        make_alert(title: "Begin Photoshoot", message: "Please remember to connect to wifi before taking photos. Your photoshoot id is \(myPhotoShootKey)")
        let childUpdates = ["/photoshoots/\(photoshootKey)/photoshootKey":myPhotoShootKey,"/photoshoots/\(photoshootKey)/store":myCurrentStore,"/photoshoots/\(photoshootKey)/photographer":myName,"/photoshoots/\(photoshootKey)/startDate":todayDate,"/photoshoots/\(photoshootKey)/myId":loggedInUserId,"/photoshoots/\(photoshootKey)/startTimestamp":[".sv": "timestamp"]] as [String : Any]
        
        databaseRef.updateChildValues(childUpdates)
        self.photoShootIdLabel.text = myPhotoShootKey

        
    }
    
    
    @IBAction func didTapStartPhotos(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "mainToBarcodeScan", sender: nil)
        
    /*NOTIFICATION ABOUT WIFI AND DIRECTIONS
        let alertController = UIAlertController(
            title: "Validate Wifi Connection",
            message: "Are you currently connected to a strong Wifi network?",
            preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(
            title: "No", style: UIAlertAction.Style.default) {
            (action) -> Void in
            
            self.make_alert(title: "Wifi Connection Required", message: "Please connect to Wifi before beginning photoshoot.")
        }
        
        let completeAction = UIAlertAction(
            title: "Yes", style: UIAlertAction.Style.default) {
            (action) -> Void in
            
            self.performSegue(withIdentifier: "mainToBarcodeScan", sender: nil)
     
//            let alert2 = UIAlertController(title: "Instructions", message: "For each product, first scan the barcode. Once the barcode has been saved you will be prompted to photograph the item.", preferredStyle: UIAlertController.Style.alert)
//                
//                alert2.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
//                    //what happens when button is clicked
//                    self.performSegue(withIdentifier: "mainToBarcodeScan", sender: nil)
//                }))
//                
//            self.present(alert2, animated: true, completion: nil)

        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        self.present(alertController, animated: true, completion: nil)
        */
    }
    
    @IBAction func didTapContinuePhotoshoot(_ sender: UIButton) {
        
        
        
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
