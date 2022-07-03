//
//  AccountDetailsViewController.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AccountDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    /* Fields */
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyTypeLabel: UILabel!
    @IBOutlet weak var accountIDLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    /* Variables */
    var Notifications : [Notification] = [Notification]()
    var accountTitle : String = ""
    var accountAmount : Int = 0
    var accountCurrencyType : String = ""
    var accountID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAccountData()
        tableViewOptions()
        getNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authenticationCheck()
    }

    func getNotifications(){
        let fs = Firestore.firestore()
        fs.collection("notifications").whereField("accountID", isEqualTo: accountID).order(by: "notificationDate", descending: true).addSnapshotListener { [self] snapshot, error in
            if error != nil {
                getAlert(title: "Load error", message: error!.localizedDescription)
            }else{
                if snapshot?.isEmpty != true {
                    for document in snapshot!.documents {
                        Notifications.append(
                            Notification(
                                id: document.get("notificationID") as! String,
                                text: document.get("notificationText") as! String,
                                date: document.get("notificationDate") as! String,
                                acid: document.get("accountID") as! String
                            ))
                    }
                    
                }
                
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Notifications.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotCell", for: indexPath) as! NotificationsTableViewCell
        cell.tCell.text = Notifications[indexPath.row].getNotificationText()
        cell.dateLabel.text = Notifications[indexPath.row].getNotificationDate()
        return cell
    }
    
    func tableViewOptions(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadAccountData(){
        accountTitleLabel.text = accountTitle
        currencyTypeLabel.text = accountCurrencyType
        amountLabel.text = String(accountAmount) + accountCurrencyType
        accountIDLabel.text = accountID
    }

}

