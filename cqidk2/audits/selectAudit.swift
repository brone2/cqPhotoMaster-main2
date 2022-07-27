//
//  selectAudit.swift
//  cqidk2
//
//  Created by Neil Bronfin on 1/13/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class selectAudit: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    @IBOutlet weak var auditTable: UITableView!
    
    var buildingsNearMe = [NSDictionary?]()
    
    
    @IBAction func didTapNewAudit(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "selectAuditToNewAudit", sender: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        

        if isX == false{
                for constraint in self.view.constraints {
                    if constraint.identifier == "toolBarConstraint" {
                        constraint.constant = 0
                    }
                }
        }
        
        
        
        databaseRef.child("audit").observe(.childAdded) { (snapshot: DataSnapshot) in

        let snapshot = snapshot.value as! NSDictionary
            
        let country = snapshot["country"] as? String
            
            if country == myCountry {
            
        print(snapshot)
            
        let requestDict = snapshot as! NSMutableDictionary
            
        self.buildingsNearMe.append(requestDict)
            
        self.buildingsNearMe.sort(by: { ($0?["timestamp"] as! Double) > ($1?["timestamp"] as! Double)}) //Sort by timestamp I think

//        self.buildingsNearMe.sort{($0?["timestamp"] as! String) < ($1?["timestamp"] as! String) }
        
        self.auditTable.reloadData()
        }
        }
    }
    
    //This method says how many rows will be in your table
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return self.buildingsNearMe.count
            
        }
       
    //This method will provide context for each cell
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    //define the cell as type cell to return
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            cell.textLabel?.text = self.buildingsNearMe[indexPath.row]?["auditName"] as? String
    
            return cell
   
            
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let selectedRowIndex = indexPath.row
        
        isInAudit = true
        currentAuditId = self.buildingsNearMe[indexPath.row]?["auditKey"] as! String
        auditCode = self.buildingsNearMe[indexPath.row]?["auditCode"] as! String
        currentAuditName = self.buildingsNearMe[indexPath.row]?["auditName"] as! String
        currentAuditAddress = self.buildingsNearMe[indexPath.row]?["auditBranchAddress"] as! String
        currentAuditBranchId = self.buildingsNearMe[indexPath.row]?["auditBranchId"] as! String
        currentAuditStore = self.buildingsNearMe[indexPath.row]?["auditStore"] as! String
        
        
        let alert = UIAlertController(title: "Audit Begun", message: "When you are finished select End Audit in Settings.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "selectAuditToMain", sender: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func toolBarReformat(){
        
        for constraint in self.view.constraints {
            if constraint.identifier == "toolBarConstraint" {
                constraint.constant = 0
            }
            
        }
        
    }
    

}
