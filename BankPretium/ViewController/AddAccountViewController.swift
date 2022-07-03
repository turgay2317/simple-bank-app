//
//  AddAccountViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddAccountViewController: UIViewController {

    /* Fields */
    @IBOutlet weak var accountTitleInput: UITextField!
    @IBOutlet weak var currencyTypeInput: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authenticationCheck()
    }
    
    
    @IBAction func createButton(_ sender: Any) {
        let randomCustomerNumber : String = String(Int.random(in: 11111...99999))
        let randomIDNumber : String = String(Int.random(in: 11111111...99999999))
        let db = Firestore.firestore()
        var startingAmount : Int = 0
        
        if currencyTypeInput.selectedSegmentIndex == 0 {
            startingAmount = Int.random(in: 1000...4000)
        }else{
            startingAmount = Int.random(in: 75...200)
        }
        
        /* Create an account */
        db.collection("accounts").addDocument(data:
            [
                "accountTitle" : accountTitleInput.text,
                "accountCurrencyType" : currencyTypeInput.selectedSegmentIndex,
                "accountCustomerID" : sessionVal(key: "id"),
                "accountIBAN" : randomCustomerNumber,
                "accountAmount" : startingAmount,
                "accountID" : randomIDNumber
            ]
        ) { error in
            if error != nil {
                self.getAlert(title: "Account creation error", message: error!.localizedDescription)
            }else{
                /* Create first notification for account */
                db.collection("notifications").addDocument(data: [
                    "notificationDate" : getDateWithFormat(),
                    "notificationText" : "Account created",
                    "notificationID" : String(Int.random(in: 111111111...999999999)) as! String,
                    "accountID" : randomIDNumber
                ]) { [self] error in
                    if error != nil {
                        getAlert(title: "Notification creation error", message: error!.localizedDescription)
                    }else{
                        resetAll()
                        getAlert(title: "Succes!", message: "Your account created successfully, account iban number is "+randomCustomerNumber)
                    }
                }
                
                
            }
        }
    }
    
    func resetAll(){
        resetAccountTitle()
        resetCurrencyType()
    }

    func resetCurrencyType(){
        currencyTypeInput.selectedSegmentIndex = 0
    }

    func resetAccountTitle(){
        accountTitleInput.text = ""
    }

}

