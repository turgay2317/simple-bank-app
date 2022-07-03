//
//  UIViewController+Extensions.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

extension UIViewController{
    
    func getAlert(title : String, message : String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOkButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertOkButton)
        self.present(alert, animated: true)
    }
    
    func goLogin() {
        let sb = UIStoryboard(name: "Main", bundle: nil) // current Storyboard
        let loginVC = sb.instantiateViewController(withIdentifier: "ViewController") // instantiate Login page
        self.present(loginVC, animated: true, completion: nil) // present instantiated ViewController
    }
    
    func authenticationCheck(){
        if hasUserLogged() == false {
            goLogin()
        }
    }
}
