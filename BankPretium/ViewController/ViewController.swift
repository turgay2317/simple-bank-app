//
//  ViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 1.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var customerNumberInput: UITextField!
    
    @IBOutlet weak var customerPasswordInput: UITextField!
    
    @IBOutlet weak var rememberMeSwitch: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        rememberCheck()
    }
    
    @IBAction func loginClick(_ sender: Any) {
        let db = Firestore.firestore()
        db.collection("customers")
            .whereField("customerNumber", isEqualTo: customerNumberInput.text!)
            .whereField("customerPassword", isEqualTo: customerPasswordInput.text!)
            .getDocuments { snapshots, error in
                if snapshots?.count == 1 {
                    snapshots?.documents.forEach({ snapshot in
                        Auth.auth().signIn(withEmail: snapshot.get("customerEmail") as! String, password: snapshot.get("customerPassword") as! String) { [self] dataResult, error in
                            if error != nil {
                                getAlert(title: "Unexpected error", message: "You had an account but now it's not exist")
                            }else{
                                var customerDetails: [String : Any] = [
                                    "id": snapshot.get("customerID") as! String,
                                    "nameSurname": snapshot.get("customerNameSurname") as! String,
                                    "number": snapshot.get("customerNumber") as! String,
                                    "password": snapshot.get("customerPassword") as! String,
                                    "phone": snapshot.get("customerPhoneNumber") as! String,
                                    "email": snapshot.get("customerEmail") as! String,
                                    "remember" : rememberMeSwitch.isOn
                                ]
                                
                                for customerDetail in customerDetails {
                                    UserDefaults.standard.set(customerDetail.value, forKey: customerDetail.key)
                                }
                                
                                self.performSegue(withIdentifier: "toUserPage", sender: nil)
                            }
                        }
                    })
                }else if snapshots?.count == 0{
                    self.getAlert(title: "Error", message: "We couldn't know you... Stranger!")
                }else{
                    self.getAlert(title: "Error", message: "We have an unexpected problem, please contact with your admin")
                }
            }
    }
    
    @IBAction func applicationFormClick(_ sender: Any) {
        performSegue(withIdentifier: "toApplicationForm", sender: nil)
    }
    
    func rememberCheck(){
        DispatchQueue.main.async { [self] in
            if hasUserLogged(){
                if let rem = UserDefaults.standard.value(forKey: "remember"){
                    if rem as! Bool == true {
                        self.performSegue(withIdentifier: "toUserPage", sender: nil)
                    }else{
                        do{
                            try Auth.auth().signOut()
                            removeAllUserData()
                        }catch{
                            print("Auth error, rem")
                        }
                    }
                }else{
                    do{
                        try Auth.auth().signOut()
                    }catch{
                        print("Auth error, rem")
                    }
                }
            }
        }
    }
}

