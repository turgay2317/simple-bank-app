//
//  TransfersViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TransfersViewController: UIViewController {

    /* Fields */
    @IBOutlet weak var sourceAccountNumber: UITextField!
    @IBOutlet weak var sourceAccountMessage: UILabel!
    @IBOutlet weak var targetAccountNumber: UITextField!
    @IBOutlet weak var targetAccountMessage: UILabel!
    @IBOutlet weak var sendAmount: UITextField!
    @IBOutlet weak var lastMessage: UILabel!
    
    /* Variables */
    var areSourceAccountNumberCorrect : Bool = false
    var areTargetAccountNumberCorrect : Bool = false
    var curType : String = ""
    var sourceAmount : Int = 0
    var sourceCurType : Int = 0
    var targetCurType : Int = 0
    var targetAmount : Int = 0
    var sourceDocID : String = ""
    var targetDocID : String = ""
    var sourceAccountID : String = ""
    var targetAccountID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLastMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authenticationCheck()
    }
    
    func resetLastMessage(){
        lastMessage.text = ""
    }
    
    
    @IBAction func sourceNumberChange(_ sender: Any) {
        if sourceAccountNumber.text != targetAccountNumber.text {
            validateIBANSource(target: sourceAccountNumber, message: sourceAccountMessage)
        }else{
            sourceAccountMessage.text = "Same IBANS!"
            areSourceAccountNumberCorrect = false
        }
    }
    
    @IBAction func targetNumberChange(_ sender: Any) {
        if sourceAccountNumber.text != targetAccountNumber.text {
            validateIBANTarget(target: targetAccountNumber, message: targetAccountMessage)
        }else{
            targetAccountMessage.text = "Same IBANS!"
            areTargetAccountNumberCorrect = false
        }
    }
    
    
    @IBAction func amountEveryChange(_ sender: Any) {
        tryProccess()
    }
    
    func tryProccess(){
        if sendAmount.text != "" {
            if validateIBANs() && validateCurs() {
                if validateAmount(){
                    let money = Int(sendAmount.text!) as! Int
                    lastMessage.text = "You will send " + String(money) + curType
                }else{
                    lastMessage.text = "You have not enough money to send"
                }
            }else{
                lastMessage.text = "IBANS or Currency type has an error"
            }
            
        }else{
            resetLastMessage()
        }
    }
    
    func validateIBANs() -> Bool{
        return areSourceAccountNumberCorrect == true && areTargetAccountNumberCorrect == true
    }
    
    func validateAmount() -> Bool {
        return sourceAmount >= Int(sendAmount.text!) as! Int
    }
    
    func validateCurs() -> Bool {
        return self.targetCurType == self.sourceCurType
    }
    
    func validateIBANSource(target : UITextField, message : UILabel){
        let nText = target.text
        Firestore.firestore().collection("accounts")
            .whereField("accountCustomerID", isEqualTo: sessionVal(key: "id"))
            .whereField("accountIBAN", isEqualTo: nText)
            .addSnapshotListener { [self] snapshot, error in
                if error != nil {
                    getAlert(title: "Unexpected error", message: error!.localizedDescription)
                }else{
                    if snapshot?.isEmpty == false {
                        for document in snapshot!.documents {
                            curType = selectedStr(selectedType: document.get("accountCurrencyType") as! Int)
                            message.text = String(document.get("accountAmount") as! Int) as! String + curType
                            areSourceAccountNumberCorrect = true
                            sourceAmount = document.get("accountAmount") as! Int
                            sourceCurType = document.get("accountCurrencyType") as! Int
                            sourceDocID = document.documentID
                            sourceAccountID = document.get("accountID") as! String
                            tryProccess()
                        }
                    }else{
                        message.text = "IBAN number is wrong"
                        areSourceAccountNumberCorrect = false
                        tryProccess()
                    }
                }
            }
    }
    
    func validateIBANTarget(target : UITextField, message : UILabel){
        let nText = target.text
        Firestore.firestore().collection("accounts")
            .whereField("accountCustomerID", isNotEqualTo: sessionVal(key: "id"))
            .whereField("accountIBAN", isEqualTo: nText)
            .addSnapshotListener { [self] snapshot, error in
                if error != nil {
                    getAlert(title: "Unexpected error", message: error!.localizedDescription)
                }else{
                    if snapshot?.isEmpty == false {
                        for document in snapshot!.documents {
                            message.text = "OK"
                            areTargetAccountNumberCorrect = true
                            targetAmount = document.get("accountAmount") as! Int
                            targetCurType = document.get("accountCurrencyType") as! Int
                            targetDocID = document.documentID
                            targetAccountID = document.get("accountID") as! String
                            tryProccess()
                        }
                    }else{
                        message.text = "IBAN number is wrong"
                        areTargetAccountNumberCorrect = false
                        tryProccess()
                    }
                }
            }
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        if validateCurs() && validateIBANs() && validateAmount(){
            
            let db = Firestore.firestore()
            
            /* source account */
            var newAmount = sourceAmount - Int(sendAmount.text!)! as! Int
            var amountStore = ["accountAmount" : newAmount] as [String : Any]
            db.collection("accounts").document(sourceDocID).updateData(amountStore)
            
            /* source notification */
            var str = "Transfer : - \(sendAmount.text!) \(curType)"
            db.collection("notifications").addDocument(data: [
                "notificationDate" : getDateWithFormat(),
                "notificationText" : str,
                "notificationID" : String(Int.random(in: 111111111...999999999)) as! String,
                "accountID" : sourceAccountID
            ])
            
            /* target account */
            let added = Int(sendAmount.text!)
            newAmount = targetAmount + added!
            amountStore = ["accountAmount" : newAmount] as [String : Any]
            db.collection("accounts").document(targetDocID).updateData(amountStore)
            
            
            /* target notification */
            let addedStr = String(added!)
            str = "Transfer : + \(addedStr) \(curType)"
            db.collection("notifications").addDocument(data: [
                "notificationDate" : getDateWithFormat(),
                "notificationText" : str,
                "notificationID" : String(Int.random(in: 111111111...999999999)) as! String,
                "accountID" : targetAccountID
            ])
            
            resetAll()
            getAlert(title: "Transfer Successful", message: "You may go check your accounts!")
        }
    }
    
    func resetAll(){
        sourceAccountNumber.text = ""
        targetAccountNumber.text = ""
        sourceAccountMessage.text = ""
        targetAccountMessage.text = ""
        sendAmount.text = ""
    }
    
}
