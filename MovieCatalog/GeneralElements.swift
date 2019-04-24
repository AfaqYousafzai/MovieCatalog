//
//  GeneralElements.swift
//  MovieCatalog
//
//  Created by Afaq on 20/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Reachability


//Singleton class to hold globaly shared variables and some common methods
class GeneralElements {
    
    static let shared = GeneralElements() //Singleton object
    
    var internetConnectivity: Reachability.Connection = .none
    
    //MARK:- Private Initilizer
    //making initializer private because of singleton pattern
    private init() {
    }
    
    
    //MARK:- Static Common Methods
    static func showAlertWithMessage(_ message: String, sender: UIViewController?){
        let alert = UIAlertController(title: "Movie Catalog", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        if let sender = sender{
            sender.present(alert, animated: false, completion: nil)
        }
        else{
            topViewController()?.present(alert, animated: false, completion: nil)
        }
    }
    
    //returns top view controller
    static func topViewController() -> UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        while topViewController.presentedViewController != nil {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
    
    //Dismiss progressHUD (SVProgressHud is also implemented on singleton pattern)
    static func dismissHUD(){
        DispatchQueue.main.async {
            if SVProgressHUD.isVisible(){
                SVProgressHUD.dismiss()
            }
        }
    }
}
