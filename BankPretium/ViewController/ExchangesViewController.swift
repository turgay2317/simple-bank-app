//
//  ExchangesViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ExchangesViewController: UIViewController {

    /* Fields */
    @IBOutlet weak var usdTryLabel: UILabel!
    @IBOutlet weak var usdEuroLabel: UILabel!
    @IBOutlet weak var sourceAccountNumber: UITextField!
    @IBOutlet weak var sourceAccountCurrencyType: UISegmentedControl!
    @IBOutlet weak var sourceAccountMessage: UILabel!
    @IBOutlet weak var targetAccountNumber: UITextField!
    @IBOutlet weak var targetAccountMessage: UILabel!
    @IBOutlet weak var targetAccountCurrencyType: UISegmentedControl!
    @IBOutlet weak var lastAmount: UITextField!
    @IBOutlet weak var gainText: UILabel!
    @IBOutlet weak var currencyAccountMessage: UILabel!
    
    /* Variables */
    var apiKey : String = ""
    var selectedSourceCurrency : String = "TRY"
    var selectedTargetCurrency : String = "USD"
    var areSourceAccountCurrencyTypeCorrect : Bool = false
    var areTargetAccountCurrencyTypeCorrect : Bool = false
    var areSourceAccountNumberCorrect : Bool = false
    var areTargetAccountNumberCorrect : Bool = false
    var sourceAmount : Int = 0
    var targetAmount : Int = 0
    var sourceDocID = ""
    var targetDocID = ""
    var sourceAccountID = ""
    var targetAccountID = ""
    var usdTryFloat : Double = 1.0
    var usdEuroFloat: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiKey = ""
        loadCurrencyRatios()
        gainText.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authenticationCheck()
    }
    
    
    @IBAction func sourceNumberChange(_ sender: Any) {
        if sourceAccountNumber.text != targetAccountNumber.text {
            validateIBAN(target: sourceAccountNumber, currencyInput: sourceAccountCurrencyType, message: sourceAccountMessage, cur: selectedSourceCurrency, type: "source")
        }else{
            sourceAccountMessage.text = "Same IBANS!"
            areSourceAccountNumberCorrect = false
        }
    }
    
    
    @IBAction func targetNumberChange(_ sender: Any) {
        if sourceAccountNumber.text != targetAccountNumber.text {
            validateIBAN(target: targetAccountNumber, currencyInput: targetAccountCurrencyType, message: targetAccountMessage, cur: selectedTargetCurrency, type: "target")
        }else{
            targetAccountMessage.text = "Same IBANS!"
            areTargetAccountNumberCorrect = false
        }
        
    }
    
    @IBAction func sourceCurrencyChanged(_ sender: Any) {
        if sourceAccountCurrencyType.selectedSegmentIndex == targetAccountCurrencyType.selectedSegmentIndex {
            sourceAccountMessage.text = "Currency types mustn't be same"
            areSourceAccountCurrencyTypeCorrect = false
        }else{
            selectedSourceCurrency = selectedStr(selectedType: sourceAccountCurrencyType.selectedSegmentIndex)
            validateIBAN(target: sourceAccountNumber, currencyInput: sourceAccountCurrencyType, message: sourceAccountMessage, cur: selectedSourceCurrency, type: "source")
        }
    }
    
    
    @IBAction func targetCurrencyChanged(_ sender: Any) {
        if sourceAccountCurrencyType.selectedSegmentIndex == targetAccountCurrencyType.selectedSegmentIndex {
            targetAccountMessage.text = "Currency types same!"
            areTargetAccountCurrencyTypeCorrect = false
        }else{
            selectedTargetCurrency = selectedStr(selectedType: targetAccountCurrencyType.selectedSegmentIndex)
            validateIBAN(target: targetAccountNumber, currencyInput: targetAccountCurrencyType, message: targetAccountMessage, cur: selectedTargetCurrency, type: "target")
        }
    }
    
    
    
    func validateIBAN(target : UITextField, currencyInput : UISegmentedControl, message : UILabel , cur : String, type : String){
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
                            if currencyInput.selectedSegmentIndex != document.get( "accountCurrencyType") as! Int{
                                message.text = "Currency types doesn't match!"
                                if type == "source"{ areSourceAccountCurrencyTypeCorrect = false }
                                else { areTargetAccountCurrencyTypeCorrect = false }
                                tryProccess()
                            }else{
                                let amount : Int = document.get("accountAmount") as! Int
                                
                                message.text = String(amount) + cur
                                if type == "source"{
                                    sourceAmount=amount;
                                    areSourceAccountNumberCorrect = true;
                                    areSourceAccountCurrencyTypeCorrect = true;
                                    sourceDocID = document.documentID;
                                    sourceAccountID = document.get("accountID") as! String;
                                }
                                else {
                                    targetAmount=amount;
                                    areTargetAccountNumberCorrect = true;
                                    areTargetAccountCurrencyTypeCorrect = true;
                                    targetDocID = document.documentID;
                                    targetAccountID = document.get("accountID") as! String;
                                }
                                tryProccess()
                            }
                        }
                    }else{
                        message.text = "IBAN number is wrong"
                        if type == "source"{
                            areSourceAccountNumberCorrect = false
                            
                        }
                        else {
                            areTargetAccountNumberCorrect = false
                            
                        }
                        tryProccess()
                    }
                }
            }
        
    }
    
    func calculateNowCurrency() -> Double{
        let source = sourceAccountCurrencyType.selectedSegmentIndex
        let target = targetAccountCurrencyType.selectedSegmentIndex
        var val : Double = 1
        if (source == 0 && target == 1){
            // try to usd
            val = 1/usdTryFloat
        }else if (source == 0 && target == 2){
            // try to eur
            val = 1/(usdTryFloat/usdEuroFloat)
        }else if (source == 1 && target == 0){
            // usd to try
            val = usdTryFloat
        }else if (source == 1 && target == 2){
            // usd to eur
            val = usdEuroFloat
        }else if (source == 2 && target == 0){
            // eur to try
            val = usdTryFloat/usdEuroFloat
        }else if(source == 2 && target == 1){
            // eur to usd
            val = 1/usdEuroFloat
        }
        return val
    }
 
    @IBAction func lastAmountChanged(_ sender: Any) {
        tryProccess()
    }
    
    func tryProccess(){
        if lastAmount.text != "" {
            if validateCurs() && validateIBANs() {
                if validateAmount(){
                    let money = Int(Double(Int(lastAmount.text!) as! Int) * calculateNowCurrency()) as! Int
                    gainText.text = "You will gain " + String(money) + selectedTargetCurrency
                }else{
                    gainText.text = "You have not enough money to exchange"
                }
            }else{
                gainText.text = "Please fix all inputs to calculate"
            }
            
        }else{
            gainText.text = ""
        }
    }
    
    func validateIBANs() -> Bool{
        return areSourceAccountNumberCorrect == true && areTargetAccountNumberCorrect == true
    }
    
    func validateCurs() -> Bool{
        return areTargetAccountCurrencyTypeCorrect == true && areSourceAccountCurrencyTypeCorrect == true
    }
    
    func validateAmount() -> Bool {
        return sourceAmount >= Int(lastAmount.text!) as! Int
    }
    
    @IBAction func convertButton(_ sender: Any) {
        if validateCurs() && validateIBANs() && validateAmount(){
            
            let db = Firestore.firestore()
            /* source account */
            var newAmount = sourceAmount - Int(lastAmount.text!)! as! Int
            var amountStore = ["accountAmount" : newAmount] as [String : Any]
            db.collection("accounts").document(sourceDocID).updateData(amountStore)
            
            /* source notification */
            var str = "Currency transaction : - \(lastAmount.text!) \(selectedSourceCurrency)"
            db.collection("notifications").addDocument(data: [
                "notificationDate" : getDateWithFormat(),
                "notificationText" : str,
                "notificationID" : String(Int.random(in: 111111111...999999999)) as! String,
                "accountID" : sourceAccountID
            ])
            
            /* target account */
            let added = Int(Double(Int(lastAmount.text!) as! Int) * calculateNowCurrency()) as! Int
            newAmount = targetAmount + added
            amountStore = ["accountAmount" : newAmount] as [String : Any]
            db.collection("accounts").document(targetDocID).updateData(amountStore)
            
            
            /* target notification */
            let addedStr = String(added)
            str = "Currency transaction : + \(addedStr) \(selectedTargetCurrency)"
            db.collection("notifications").addDocument(data: [
                "notificationDate" : getDateWithFormat(),
                "notificationText" : str,
                "notificationID" : String(Int.random(in: 111111111...999999999)) as! String,
                "accountID" : targetAccountID
            ])
            
            resetAll()
            
            getAlert(title: "Transaction Successful", message: "You may go check your accounts!")
            
            
        }
    }
    
    func resetAll(){
        sourceAccountNumber.text = ""
        targetAccountNumber.text = ""
        sourceAccountMessage.text = ""
        targetAccountMessage.text = ""
        sourceAccountCurrencyType.selectedSegmentIndex = 0
        targetAccountCurrencyType.selectedSegmentIndex = 1
        lastAmount.text = ""
    }
    
    func loadCurrencyRatios(){
        let url = URL(string: "https://api.apilayer.com/fixer/latest?symbols=TRY%2CEUR&base=USD&apikey="+apiKey)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { [self] (data, response, error) in
            if error != nil {
                getAlert(title: "Error", message: error!.localizedDescription)
            }else{
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, Any>
                    DispatchQueue.main.async { [self] in
                        if let rates = jsonResponse["rates"] as? [String:Any]{
                            let tryRatio : Double = rates["TRY"] as! Double
                            let euroRatio : Double = rates["EUR"] as! Double
                            usdTryLabel.text = formatPrice(total: tryRatio)
                            usdEuroLabel.text = formatPrice(total: euroRatio)
                            usdTryFloat = tryRatio
                            usdEuroFloat = euroRatio
                        }else{
                            print("Procces is not successful")
                        }
                    }
                }catch{
                    print("Data is not found")
                }
            }
        }
        task.resume()
    }
    
    func formatPrice(total : Double) -> String {
        return String(format:"%.2f",total)
    }

}
