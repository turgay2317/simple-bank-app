//
//  ApplyViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 1.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ApplyViewController: UIViewController {

    /* Fields */
    @IBOutlet weak var nameAndSurnameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var termsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func applyClick(_ sender: Any) {
        if nameCheck() && passwordCheck() && phoneCheck() && emailCheck(){
            if termsCheck(){
                
                Auth.auth().createUser(withEmail: emailInput.text!, password: passwordInput.text!) { [self] result, error in
                    if error != nil {
                        getAlert(title: "Unexpected error", message: error!.localizedDescription)
                    }else{
                        let randomCustomerNumber : String = String(Int.random(in: 111111...999999))
                        let db = Firestore.firestore()
                        db.collection("customers").addDocument(data:
                            [
                                "customerNameSurname" : nameAndSurnameInput.text,
                                "customerPhoneNumber" : phoneNumberInput.text,
                                "customerEmail" : emailInput.text,
                                "customerPassword" : passwordInput.text,
                                "customerNumber" : randomCustomerNumber,
                                "customerID" : result!.user.uid
                            ]
                        ) { error in
                            if error != nil {
                                getAlert(title: "Save error", message: error!.localizedDescription)
                            }else{
                                getAlert(title: "Succes!", message: "Your customer number is "+randomCustomerNumber)
                            }
                        }
                        
                    }
                }
                
            }else { getAlert(title: "Accept the terms", message: "Accept the terms to apply please!") }
        }else{
            getAlert(title: "Fill all inputs", message: "Please fill all inputs to apply our bank")
        }
        
    }
    
    func nameCheck() -> Bool{
        return nameAndSurnameInput.text?.isEmpty == false
    }
    
    func emailCheck() -> Bool{
        return emailInput.text?.isEmpty == false
    }
    
    func passwordCheck() -> Bool{
        return passwordInput.text?.isEmpty == false
    }
    
    func phoneCheck() -> Bool{
        return phoneNumberInput.text?.isEmpty == false
    }
    
    func termsCheck() -> Bool{
        return termsSwitch.isOn == true
    }
    
    @IBAction func customerClick(_ sender: Any) {
        performSegue(withIdentifier: "toHomePage", sender: nil)
    }

}
