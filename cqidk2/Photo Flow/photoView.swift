//
//  photoView.swift
//  cqidk2
//
//  Created by Neil Bronfin on 4/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit

class photoView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//LOOK INTO SWIFT SPINNER
// Use photoViewDismissHelper to segue after photo is taken (1 is show camera 2 is segue)
    
//    https://stackoverflow.com/questions/28419336/uiimagepickercontroller-camera-overlay-that-matches-the-default-cropping
    var storageRef = Storage.storage().reference()
    
//FOR HELPING ALIGN THE DASH ON THE CAMERA
    var textLabel = UILabel()
    var dashLabel = UILabel()
    var hw:CGFloat = 0
    var yText:CGFloat = 460
    var yDash:CGFloat = 440
    var yAdjust:CGFloat = 0
    
// THE SPINNER WHILE WAITING
    var spinner: UIActivityIndicatorView?

//END FOR HELPING ALIGN THE DASH ON THE CAMERA
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //helper to segue back to barcode scanner on picker dismiss
        if isTapCancelPhoto {
            self.performSegue(withIdentifier: "photoViewToBarcodeView", sender: nil)
        }
        
        print(photoViewDismissHelper)
        if photoViewDismissHelper == 1 {
            
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
            
            
//TRY JUST ADD DOTTED LINE FOR GUIDANCE
            let font = UIFont.boldSystemFont(ofSize: 20)
            let fontSize: CGFloat = font.pointSize
            let componentWidth: CGFloat = self.view.frame.width

            if screenHeight >= 1.0 {
                yAdjust = yAdjust + 16
            }
            if screenHeight >= 844.0 {
                yAdjust = yAdjust - 2
            }
            if screenHeight >= 926.0 {
                yAdjust = yAdjust - 24
            }
            
            if is_iphone_12  { //TESTING IPHONE 12
                yAdjust = yAdjust - 24 - yTestValue
             }
            
            textLabel = UILabel(frame: CGRect(x: 0, y: yText - yAdjust, width: self.view.frame.width, height: 100))
            self.textLabel.font = font
            self.textLabel.textAlignment = .center
            self.textLabel.text = "Align Botton of Item"
            self.textLabel.textColor = UIColor.green
            picker.view.addSubview(self.textLabel)
            
           
            dashLabel = UILabel(frame: CGRect(x: 0, y: yDash - yAdjust, width: self.view.frame.width, height: 100))
            self.dashLabel.font = UIFont.boldSystemFont(ofSize: 20)
            self.dashLabel.textAlignment = .center
            self.dashLabel.text = "-------------------------------"
            self.dashLabel.textColor = UIColor.green
            picker.view.addSubview(self.dashLabel)
            
            //Detect photo was taken but not accepted
             NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"), object:nil, queue:nil, using: { note in
                 self.textLabel.isHidden = true
                 self.dashLabel.isHidden = true
             })
           //Detect photo retake
             NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem"), object:nil, queue:nil, using: { note in
                self.textLabel.isHidden = false
                self.dashLabel.isHidden = false
              })
            
            //Try to find how to add spinny thing
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidSelectItem"), object:nil, queue:nil, using: { note in
             print("PHOTO BEING USED!")
             })
            
            //END //Try to find how to add spinny thing
            
//THIS IS FOR CAMERA OVERLAY: EXCLUDING IPHONE12 UNTIL CAN FIGURE OUT THE COORDINATES
////        if is_iphone_12 == false {
//            picker.cameraOverlayView = guideForCameraOverlay()
//            picker.view.layer.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
//        }
//END THIS IS FOR CAMERA OVERLAY
        
        self.present(picker, animated: true)
            
        }
        
        if photoViewDismissHelper == 2 { //Helper for when camera is dismissed to segue
            self.performSegue(withIdentifier: "photoViewToFinishPhoto", sender: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //BRING OUT THE SPINNER!
        let screenSize: CGRect = UIScreen.main.bounds
        spinner = UIActivityIndicatorView(frame: CGRect(x: screenSize.width/2 - 50, y: screenSize.height/2 - 50, width: 100, height: 100))
        spinner?.isHidden = false
        spinner?.startAnimating()
        spinner?.color = UIColor.green
        spinner?.style = UIActivityIndicatorView.Style.large
        picker.view.addSubview(spinner!)

        photoViewDismissHelper = 2
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        let key = databaseRef.child("photos").childByAutoId().key
        
        storageRef.child("photos/\(key)/file.png").putData(imageData, metadata: nil) { (_, error) in
            guard error == nil else {
                print("failed to upload")
                return
            }
            
            self.storageRef.child("photos/\(key)/file.png").downloadURL(completion: {url,error in guard let url = url, error == nil else {
                return
            }
           
            downloadUrlAbsoluteStringValue = url.absoluteString
            print(downloadUrlAbsoluteStringValue)
            
            //Dismissing the alert spinny thing first
            self.spinner?.stopAnimating()
            self.spinner?.removeFromSuperview()
            self.spinner  = nil
            
            //Dismissing the camera
            self.dismiss(animated: false, completion: self.testSegue)
//            self.performSegue(withIdentifier: "photoViewToFinishPhoto", sender: nil)
            //        PUT THIS BACK
//            self.dismiss(animated: false, completion: nil)
            
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        //set the helper isTapCancelPhoto to TRUE so it segs when the initial view appears
        isTapCancelPhoto = true
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func testSegue(){
        self.performSegue(withIdentifier: "photoViewToFinishPhoto", sender: nil)
    }
    
    

//////THIS IS FOR CAMERA OVERLAY
//    func guideForCameraOverlay() -> UIView {
//        let guide = UIView(frame: UIScreen.main.fullScreenSquare())
//        guide.backgroundColor = UIColor.clear
//        guide.layer.borderWidth = 20
//        guide.layer.borderColor = UIColor.green.cgColor
//        guide.isUserInteractionEnabled = false
//        return guide
//    }
////    //END THIS IS FOR CAMERA OVERLAY
    
    
    
}

//////THIS IS FOR CAMERA OVERLAY
//
//extension UIScreen {
//    func fullScreenSquare() -> CGRect {
//        var hw:CGFloat = 0
//        var isLandscape = false
//        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
//        hw = UIScreen.main.bounds.size.width
//    }
//    else {
//        isLandscape = true
//        hw = UIScreen.main.bounds.size.height
//    }
//
//    var x:CGFloat = 0
//    var y:CGFloat = 0
//
//        if isLandscape {
//            x = (UIScreen.main.bounds.size.width / 2) - (hw / 2)
//        } else {
//
//        let window = UIApplication.shared.windows[0]
//        let topPadding = window.safeAreaInsets.top
//        let bottomPadding = window.safeAreaInsets.bottom
//        let padding_height = topPadding + bottomPadding
//
//        y = (UIScreen.main.bounds.size.height / 2) - (hw / 2) //Original
//
//
////PHONE SIZES ADJUST Y *********************
//
//        if isX && screenHeight >= 667.0 { //VALIDATED
//
//            y = ((UIScreen.main.bounds.size.height - padding_height - 28 + 12) / 2) - (hw / 2)
//
//        }
//
//        if isX && screenHeight >= 736.0 { //VALIDATED iPhone8+
//            //CURRENTLY SHOWING UP TOO LOW
//
//            y = ((UIScreen.main.bounds.size.height - padding_height - 28 - 2) / 2) - (hw / 2)
//
//        }
//
//
//        if isX && screenHeight >= 812.0 { //VALIDATED iPhoneX, iPhone11 Pro MY PHONE
//
//            print(y)
//            y = ((UIScreen.main.bounds.size.height - padding_height - 28) / 2) - (hw / 2)
//
//        }
//
//        if isX && screenHeight == 844.0 { //NOT VALIDATED**** iPhone12, iPhone12 Pro PROBLEM!!!!!
//
//        //*****TRYING THIS BECAUSE APPARENTLY THERE IS NO SAFE AREA ON IPHONE 12, STRAIGHT FORMULA COPY
//            let size_adjust = (844 - 812)/2 //=16
////            y = ((UIScreen.main.bounds.size.height - padding_height - 28 - 42 / 2) - (hw / 2))
//            y = ((UIScreen.main.bounds.size.height / 2) - (hw / 2))
//
//        }
//
//        if isX && screenHeight >= 896.0 { //iPhone11, iPhone11 ProMax, VALIDATED IPHONE11
//
//            let size_adjust = (896 - 812)/2 //=42
//            y = ((UIScreen.main.bounds.size.height - padding_height - 28 - 42 / 2) - (hw / 2))
//
//        }
//
//        if isX && screenHeight == 926.0 { //NOT VALIDATED**** iPhone12 ProMax,
//
//            //*****TRYING THIS BECAUSE APPARENTLY THERE IS NO SAFE AREA ON IPHONE 12, STRAIGHT FORMULA COPY
//                let size_adjust = (844 - 812)/2 //=16
//    //          y = ((UIScreen.main.bounds.size.height - padding_height - 28 - 42 / 2) - (hw / 2))
//                y = ((UIScreen.main.bounds.size.height / 2) - (hw / 2))
//
//        }
//
//
//    //TEST IPHONE 12*******************
//        if is_iphone_12  { //TESTING IPHONE 12
//
//            y = yTestValue
//
//        }
//    //END TEST IPHONE 12
//
//    }
//        return CGRect(x: x, y: y, width: hw, height: hw)
//    }
//    func isLandscape() -> Bool {
//        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
//    }
//}
//
//////END THIS IS FOR CAMERA OVERLAY


//EXTENSION ALLOWS YOU TO MOVE ZOOM IN OR WHATEVER
extension UIImagePickerController {
    open override var childForStatusBarHidden: UIViewController? {
        return nil
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fixCannotMoveEditingBox()
    }
    
    func fixCannotMoveEditingBox() {
            if let cropView = cropView,
               let scrollView = scrollView,
               scrollView.contentOffset.y == 0 {
                
                var top: CGFloat = 0.0
                if #available(iOS 11.0, *) {
                    top = cropView.frame.minY + self.view.safeAreaInsets.top
                } else {
                    // Fallback on earlier versions
                    top = cropView.frame.minY
                }
                let bottom = scrollView.frame.height - cropView.frame.height - top
                scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
                
                var offset: CGFloat = 0
                if scrollView.contentSize.height > scrollView.contentSize.width {
                    offset = 0.5 * (scrollView.contentSize.height - scrollView.contentSize.width)
                }
                scrollView.contentOffset = CGPoint(x: 0, y: -top + offset)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.fixCannotMoveEditingBox()
            }
        }
        
        var cropView: UIView? {
            return findCropView(from: self.view)
        }
        
        var scrollView: UIScrollView? {
            return findScrollView(from: self.view)
        }
        
        func findCropView(from view: UIView) -> UIView? {
            let width = UIScreen.main.bounds.width
            let size = view.bounds.size
            if width == size.height, width == size.height {
                return view
            }
            for view in view.subviews {
                if let cropView = findCropView(from: view) {
                    return cropView
                }
            }
            return nil
        }
        
        func findScrollView(from view: UIView) -> UIScrollView? {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
            for view in view.subviews {
                if let scrollView = findScrollView(from: view) {
                    return scrollView
                }
            }
            return nil
        }
}
