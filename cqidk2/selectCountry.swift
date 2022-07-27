//
//  selectCountry.swift
//  cqidk2
//
//  Created by Neil Bronfin on 5/4/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class selectCountry: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    var buildingsNearMe = [NSDictionary?]()
    
    var buildingNameEntered:String?
    
    override func viewDidAppear(_ animated: Bool) {
        
        if isX == false{
                for constraint in self.view.constraints {
                    if constraint.identifier == "toolBarConstraint" {
                        constraint.constant = 0
                    }
                }
        }
        
            print("begun pulling country")
        
            databaseRef.child("country").observe(.childAdded) { (snapshot: DataSnapshot) in
//            databaseRef.child("country").observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
            print("after snapshot taken")
            let snapshot = snapshot.value as! NSDictionary
                
            print(snapshot)
                
            let requestDict = snapshot as! NSMutableDictionary
                
            self.buildingsNearMe.append(requestDict)
            
            self.buildingsNearMe.sort{($0?["country"] as! String) < ($1?["country"] as! String) }
            
                print(self.buildingsNearMe)
            
            self.countryTable.reloadData()
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //This method says how many rows will be in your table
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return self.buildingsNearMe.count
            
        }
       
    //This method will provide context for each cell
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    //define the cell as type cell to return
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            cell.textLabel?.text = self.buildingsNearMe[indexPath.row]?["country"] as? String
            
            return cell
   
            
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let selectedRowIndex = indexPath.row
        
        myCountry = self.buildingsNearMe[indexPath.row]?["country"] as! String
        
        let childUpdates2 = ["/users/\(loggedInUserId)/myCountry":myCountry]
        //Update
        databaseRef.updateChildValues(childUpdates2)
        
        print(myCountry)
        
        self.performSegue(withIdentifier: "selectCountryToSelectStore", sender: nil)
    }

    
    @IBOutlet weak var storeTable: UITableView!
    
    @IBOutlet weak var countryTable: UITableView!
    
    @IBAction func didTapAddNewCountry(_ sender: UIBarButtonItem) {
        
        var buildingNameTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Add New Country",
            message: "Please add the name of the country.",
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
//                self.buildingNameEntered = self.buildingNameEntered?.replacingOccurrences(of: ".",with: "")
            }
            
            myCountry = self.buildingNameEntered!
            let key = databaseRef.child("country").childByAutoId().key!
            
            let childUpdates = ["/country/\(key)/country":self.buildingNameEntered!,"/country/\(key)/created_by_uid":loggedInUserId, "/country/\(key)/created_by_name":myName,"/country/\(key)/created_date":todayDate] as [String : Any]
  
            databaseRef.updateChildValues(childUpdates)
            
            let childUpdates2 = ["/users/\(loggedInUserId)/myCountry":myCountry]

            //Update
            databaseRef.updateChildValues(childUpdates2)
            
            self.segueOn()
 
        }
        
        alertController.addTextField {
            (bldName) -> Void in
            buildingNameTextField = bldName
            buildingNameTextField!.placeholder = "Indonesia"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    
    @IBAction func didTapAddNewStore(_ sender: UIBarButtonItem) {

    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
     // Pass the selected obje@objc ct to the new view controller.
    }
    */
    func segueOn() {
        
        print("NOTCED")
        let alert = UIAlertController(title: "Country Registered", message:  "\(self.buildingNameEntered!) has been registered!", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                print(myCountry)
                
                self.performSegue(withIdentifier: "selectCountryToSelectStore", sender: nil)
            }))
        present(alert, animated: true, completion: nil)
    }
    
    func toolBarReformat(){
        
        for constraint in self.view.constraints {
            if constraint.identifier == "toolBarConstraint" {
                constraint.constant = 0
            }
            
        }
        
    }
    

}

