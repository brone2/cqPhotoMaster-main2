//
//  newAudit.swift
//  cqidk2
//
//  Created by Neil Bronfin on 1/13/22.
//

import UIKit

class newAudit: UIViewController, UITextFieldDelegate  {
    
    
    @IBOutlet weak var storeAuditHeader: UILabel!
    
    @IBOutlet weak var branchAddressLabel: UITextField!
    
    @IBOutlet weak var branchIdLabel: UITextField!
    
    @IBOutlet weak var auditNameLabel: UITextField!
    
    @IBOutlet weak var grayView: UIView!
    
    @IBOutlet weak var catalogManagerNameLabel: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        self.grayView.layer.cornerRadius = 5
        self.grayView.layer.masksToBounds = true
        
        self.storeAuditHeader.text = "\(myCurrentStore) Audit"
        
    }
    
    
    @IBAction func didTapBeginAudit(_ sender: Any) {
        
        let key = databaseRef.child("photos").childByAutoId().key!
        
        let auditStorePath = "/audit/\(key)/auditStore"
        let auditStoreValue = myCurrentStore
        
        let auditCodePath = "/audit/\(key)/auditCode"
        let auditCodeValue = myCurrentStore + "-" + self.branchIdLabel.text! + "-" + todayDate
        
        let auditDatePath = "/audit/\(key)/auditDate"
        let auditDateValue = todayDate
        
        let myIdPath = "/audit/\(key)/myId"
        let myIdValue = loggedInUserId
        
        let countryPath = "/audit/\(key)/country"
        let countryValue = myCountry
        
        let auditTimestampPath = "/audit/\(key)/timestamp"
        
        let myNamePath = "/audit/\(key)/myName"
        let myNameValue = myName
        
        let auditBranchAddressPath = "/audit/\(key)/auditBranchAddress"
        let auditBranchAddressValue = self.branchAddressLabel.text!
        
        let auditBranchIdPath = "/audit/\(key)/auditBranchId"
        let auditBranchIdValue = self.branchIdLabel.text!
        
        let auditNamePath = "/audit/\(key)/auditName"
        let auditNameValue = self.auditNameLabel.text!
        
        let auditCatalogManagerNamePath = "/audit/\(key)/auditCatalogManagerName"
        let auditCatalogManagerNameValue = self.catalogManagerNameLabel.text!
        
        let auditKeyPath = "/audit/\(key)/auditKey"
        let auditKeyValue = key
        
        
        
        let childUpdates:Dictionary<String, Any> = [auditTimestampPath:[".sv": "timestamp"],auditStorePath:auditStoreValue,auditDatePath:auditDateValue,myIdPath:myIdValue,countryPath:countryValue,auditCodePath:auditCodeValue, auditBranchIdPath:auditBranchIdValue,myNamePath:myNameValue,auditNamePath:auditNameValue,auditCatalogManagerNamePath:auditCatalogManagerNameValue,auditKeyPath:auditKeyValue,auditBranchAddressPath:auditBranchAddressValue]
        
        databaseRef.updateChildValues(childUpdates)
        
        //Set values relating to audit
        isInAudit = true
        currentAuditId = key
        currentAuditName = self.auditNameLabel.text!
        currentAuditAddress = auditBranchAddressValue
        currentAuditBranchId = self.branchIdLabel.text!
        auditCode = auditCodeValue
        currentAuditStore = myCurrentStore
        
        
        let alert = UIAlertController(title: "Audit Begun", message: "The audit has begun. When you are finished select End Audit in Settings.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "startAuditToMain", sender: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        

        
        
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "startAuditToMain", sender: nil)
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            //resignfirstresponder is saying get rid of the textfiled mentioned
            textField.resignFirstResponder()
            return true
        }

    
    

}
