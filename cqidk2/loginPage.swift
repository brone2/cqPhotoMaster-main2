//
//  loginPage.swift
//  cqidk2
//
//  Created by Neil Bronfin on 4/9/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit
import CoreLocation

class loginPage: UIViewController {

    var loggedInUserData: AnyObject?
    
    override func viewDidAppear(_ animated: Bool) {
        autoLoginHelp = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }


    
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        
        
        
        print(self.nameLabel.text)
        print(self.emailLabel.text)
        print(self.passwordLabel.text)
        
        if self.nameLabel.text == "" {
            make_alert(title: "Please Enter Name", message: "Please enter your full name to create an account")
        } else {
            
    //Create User, Log in User and save user to database
            Auth.auth().createUser(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
        
        if error != nil {
            self.errorLabel.text = error?.localizedDescription
        } else {
            
            self.errorLabel.text = "Successful registration!"
       
            Auth.auth().signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
                if error != nil {
                    
                }else{
                    
                    loggedInUserId = Auth.auth().currentUser!.uid
                    
//                    let childUpdates = ["/users/\(user!.uid)/name":self.nameLabel.text!,"/users/\(user!.uid)/cellPhoneNumber":"0","/users/\(user!.uid)/buildingName":"N/A", "/users/\(user!.uid)/email":self.emailLabel.text!,"/users/\(user!.uid)/userId":(user!.uid)] as [String : Any]
                    
                    let childUpdates = ["/users/\(loggedInUserId)/myName":self.nameLabel.text!,"/users/\(loggedInUserId)/cellPhoneNumber":"0","/users/\(loggedInUserId)/buildingName":"N/A", "/users/\(loggedInUserId)/myEmail":self.emailLabel.text!,"/users/\(loggedInUserId)/userId":(loggedInUserId),"/users/\(loggedInUserId)/myPhotoShootKey":(myPhotoShootKey)] as [String : Any]
                    
                    
                    myName = self.nameLabel.text!
                    
                    //Update
                    databaseRef.updateChildValues(childUpdates)
                    Analytics.setUserProperty(myName, forName: "fullName")
                    self.performSegue(withIdentifier: "loginToSelectCountry", sender: nil)}
            
        })
    }
})

} //End login block
    }

    @IBAction func didTapLogin(_ sender: UIButton) {
        
        if self.emailLabel.text == "" {
            make_alert(title: "Please Enter Email and Password to Sign in", message: "Please enter your email and password above to Sign In. You do not need to enter your name to login, just provide your email and password above and then select Sign In.")
        }  else {
        
        Auth.auth().signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
            if error != nil{
                self.errorLabel.text = error?.localizedDescription
                
            }else{
                
                Auth.auth()
                
                print("tuuuuuu")
                
                loggedInUserId = (Auth.auth().currentUser!.uid)
                
                //get user name
                databaseRef.child("users").child(loggedInUserId).observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
                    
                    self.loggedInUserData = snapshot.value as? NSDictionary
                    
                    myName = self.loggedInUserData?["myName"] as! String
                    myEmail = self.loggedInUserData?["myEmail"] as! String
                    myCountry = self.loggedInUserData?["myCountry"] as! String
                    print(myCountry)
                    self.performSegue(withIdentifier: "loginToSelectStore", sender: nil)
                    
         
                }
            }
        })

//        self.performSegue(withIdentifier: "loginToSelectStore", sender: nil)
        
    }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    func make_alert(title: String,message: String){
//            
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
//            
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                //what happens when button is clicked
////                self.dismiss(animated: true, completion: nil)
//            }))
//            
//            self.present(alert, animated: true, completion: nil)
//     
//        }//func make_alert(title: String,message: String){


    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
}

