//
//  loadAuditBarcodes.swift
//  cqidk2
//
//  Created by Neil Bronfin on 1/13/22.
//

import UIKit
import Foundation

//Metabase query https://metabase.internal.cornershop.io/question/30573-audit-query-help-1

class loadAuditBarcodes: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    //Roll up all standard barcode lookups into one, also loads the sheets for standard and variable
    func gather_all_have_content_barcodes () {
    
    //Set the country
    if myCountry.lowercased().range(of:"usa") != nil {
        print("is USA tru!")
                standardCreatedBcReference = ["https://sheet.best/api/sheets/4b104909-e4e6-4bbb-b375-c0df2b7e1f61","https://sheet.best/api/sheets/4b453c9b-21ec-4dd3-ad40-909f239a4540","https://sheet.best/api/sheets/9c7e2103-d75a-4b7c-89a3-20b0590fbe70"]
        
                variableCreatedBcReference = URL(string: "https://sheet.best/api/sheets/956ea209-12c3-46af-ba50-db0927679e62")!
    }
        
        
    if myCountry.lowercased().range(of:"canada") != nil {
        print("is canada")
                standardCreatedBcReference = ["https://sheet.best/api/sheets/867d77e7-ca04-4380-aa9a-76483b03f8e0","https://sheet.best/api/sheets/dc9f360d-51c7-4c86-b19a-1629cf6740eb","https://sheet.best/api/sheets/a98baff7-20b3-45c2-b61f-2b2a2cd84a65","https://sheet.best/api/sheets/43d6642c-c6c2-4be9-94f9-a8f0e352dd08"]
        
                variableCreatedBcReference = URL(string: "https://sheet.best/api/sheets/c0d2bd23-5872-4655-aa33-1ce4d43f90d1")!
    }
    
        
    //US barcodes
//        let google_sheet_url_strings = ["https://sheet.best/api/sheets/4b104909-e4e6-4bbb-b375-c0df2b7e1f61","https://sheet.best/api/sheets/4b453c9b-21ec-4dd3-ad40-909f239a4540","https://sheet.best/api/sheets/9c7e2103-d75a-4b7c-89a3-20b0590fbe70"]

        
        
        //Loop through each google sheet and store all barcodes
        for google_sheet_url in standardCreatedBcReference {
            
            print(google_sheet_url)
            
            let have_content_integration_url = URL(string: google_sheet_url)!
            
            let task = URLSession.shared.dataTask(with: have_content_integration_url) {(data, response, error) in
                guard let data = data else { return }
                let data2 = String(data: data, encoding: .utf8)!
//                print("CHECK HERE")
//                print(data2)
                let split_data2 = data2.components(separatedBy: ",")
                for str in split_data2 {
                    if let frontIndex = str.endIndex(of: "a") { // get after that character is found
                        if let backIndex = str.index(of: "}") {
                            let subString = str[frontIndex..<backIndex]
                            let upcValue = subString.replacingOccurrences(of: "\"", with: "")
                            let upcValueInt = Int(upcValue)
//                            print(upcValueInt)
                            let upcValueString = "a\(upcValueInt!)"
                            auditHaveContentBarcodes.append(upcValueString)
                        } //if let frontIndex = str.index(of: ":") {
                    } //let frontIndex = str.index(of: ":") {
                }
            }
            print("loaded")
            task.resume()
            
        }
    }
    
    //Take the type 2 barcodes for the selected store.
    func gather_vw_items_have_content (){
        
    //Add an if statement here that redirects to the albertsons sheet if store_id is Albertsons
        if isAlbertsonsStore {
            self.gather_albertsons_vw_items_have_content()
        } else {
            
    //US Variable weight items
//        let variable_weight_url = URL(string: "https://sheet.best/api/sheets/956ea209-12c3-46af-ba50-db0927679e62")!

        let task = URLSession.shared.dataTask(with: variableCreatedBcReference) {(data, response, error) in
            guard let data = data else { return }
            let data2 = String(data: data, encoding: .utf8)!
            let split_data2 = data2.components(separatedBy: ",")
            
            for str in split_data2 {
                let myCurrentStoreIdAssist = myCurrentStoreId + "a"
                if str.range(of: String(myCurrentStoreIdAssist)) != nil {
                    if let frontIndex = str.endIndex(of: "a") { // get after that character is found
                        if let backIndex = str.index(of: "}") {
                            let subString = str[frontIndex..<backIndex]
                            let upcValue = subString.replacingOccurrences(of: "\"", with: "")
                            let upcValueInt = Int(upcValue)
                            let upcValueString = "a\(upcValueInt!)"
                            auditHaveContentBarcodes.append(upcValueString)
                        } //if let frontIndex = str.index(of: ":") {
                    } //let frontIndex = str.index(of: ":") {
                }
            }
        }
        task.resume()
        }
            
    }
    
    
    ///ALBERTSONS VARIABLE WEIGHT ITEMS. FOR ANY ALBERTSONS STORE TAKE ALL THE VARIABLE WEIGHT ITEMS WITH CONTENT AND LOAD TO THE LIST OF BARCODES WITH CONTENT
    func gather_albertsons_vw_items_have_content (){
        
    //Add an if statement here that redirects to the albertsons sheet if store_id is Albertsons
        
    //US Variable weight items
        let variable_weight_url = URL(string: "https://sheet.best/api/sheets/cc6170ec-d194-471c-b1e4-fd766919b7fe")!
        
        let task = URLSession.shared.dataTask(with: variable_weight_url) {(data, response, error) in
            guard let data = data else { return }
            let data2 = String(data: data, encoding: .utf8)!
            let split_data2 = data2.components(separatedBy: ",")
            for str in split_data2 {
                
                if let frontIndex = str.endIndex(of: "a") { // get after that character is found
                    if let backIndex = str.index(of: "}") {
                        let subString = str[frontIndex..<backIndex]
                        let upcValue = subString.replacingOccurrences(of: "\"", with: "")
                        let upcValueInt = Int(upcValue)
//                            print(upcValueInt)
                        let upcValueString = "a\(upcValueInt!)"
//                        print(upcValueString)
                        auditHaveContentBarcodes.append(upcValueString)
                    } //if let frontIndex = str.index(of: ":") {
                } //let frontIndex = str.index(of: ":") {
            }
        }
        print("loaded")
        task.resume()
    }
    
    
    

    // Make this variable weight barcodes
    //ToDo Need to filter on store, so need to load this after store is selected
    //https://metabase.internal.cornershop.io/question/30838-vw-items-have-content
//    func gather_missing_photos_barcodes (){

    
    
    
}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
