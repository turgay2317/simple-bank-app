//
//  Notification.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import Foundation

class Notification{
    var notificationID : String
    var notificationText : String
    var notificationDate : String
    var accountID : String
    
    init(id : String, text : String, date : String, acid : String) {
        notificationID = id
        notificationText = text
        notificationDate = date
        accountID = acid
    }
    
    func getNotificationDate() -> String{
        return notificationDate
    }
    
    func getAccountID() -> String {
        return accountID
    }
    
    func getNotificationText() -> String{
        return notificationText
    }
    
    func getNotificationID() -> String{
        return notificationID
    }
    
}
