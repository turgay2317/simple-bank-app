//
//  AccountsViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    /* Fields */
    @IBOutlet weak var nameSurnameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var Accounts : [Account] = [Account]()
    
    var selectedAccount : Account = Account(id: "" ,title: "", iban: "", amount: 0, currency: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if hasUserLogged() {
            nameSurnameLabel.text = sessionVal(key: "nameSurname") as! String
            tableView.delegate = self
            tableView.dataSource = self
            getAccounts()
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authenticationCheck()
    }

    func getAccounts(){
        let fs = Firestore.firestore()
        fs.collection("accounts")
            .whereField("accountCustomerID", isEqualTo: sessionVal(key: "id"))
            .addSnapshotListener { [self] snapshot, error in
                if error != nil {
                    getAlert(title: "Load error", message: error!.localizedDescription)
                }else{
                    if snapshot?.isEmpty != true {
                        Accounts.removeAll(keepingCapacity: false)
                        for document in snapshot!.documents {
                            Accounts.append(Account(
                                id: document.get("accountID") as! String,
                                title: document.get("accountTitle") as! String as! String,
                                iban: document.get("accountIBAN") as! String,
                                amount: document.get("accountAmount") as! Int,
                                currency: document.get("accountCurrencyType") as! Int8)
                            )
                        }
                        
                    }
                    
                }
            self.tableView.reloadData()
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAccountDetail"{
            let destinationVC = segue.destination as! AccountDetailsViewController
            destinationVC.accountTitle = selectedAccount.getTitle() as! String
            destinationVC.accountID = selectedAccount.getID() as! String
            destinationVC.accountAmount = selectedAccount.getAmount() as! Int
            destinationVC.accountCurrencyType = selectedAccount.getCurrencyAsStr()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedAccount = Accounts[indexPath.row]
        performSegue(withIdentifier: "viewAccountDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountsTableViewCell
        cell.accountNameLabel.text = Accounts[indexPath.row].getTitle()
        cell.ibanNumberLabel.text = Accounts[indexPath.row].getIBAN()
        cell.moneyLabel.text = String(Accounts[indexPath.row].getAmount()) as! String + " " + Accounts[indexPath.row].getCurrencyAsStr() as! String
        
        return cell
    }
    
    @IBAction func createAccount(_ sender: Any) {
        performSegue(withIdentifier: "addNewAccount", sender: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            removeAllUserData()
            performSegue(withIdentifier: "logoutVC", sender: nil)
        }catch{
            print("Logout error")
        }
    }
    
}
