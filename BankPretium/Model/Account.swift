//
//  Account.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import Foundation

class Account{
    var accountTitle : String
    var accountIBAN : String
    var accountAmount : Int
    var accountCurrencyType : Int8
    var accountID : String
    
    init(id : String,title : String, iban : String, amount : Int, currency : Int8) {
        accountID = id
        accountTitle = title
        accountIBAN = iban
        accountAmount = amount
        accountCurrencyType = currency
    }
    
    func getTitle() -> String{
        return self.accountTitle
    }
    
    func getIBAN() -> String {
        return self.accountIBAN
    }
    
    func getID() -> String{
        return self.accountID
    }
    
    func getAmount() -> Int {
        return self.accountAmount
    }
    
    func getCurrencyType() -> Int8{
        return self.accountCurrencyType
    }
    
    func getCurrencyAsStr() -> String{
        switch (self.accountCurrencyType){
            case 0 : return "TL"
            case 1 : return "$"
            case 2 : return "€" 
            default : return "TL"
        }
        return "TL"
    }
}
