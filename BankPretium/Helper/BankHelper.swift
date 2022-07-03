//
//  BankHelper.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import Foundation
import UIKit
import FirebaseAuth

func removeAllUserData(){
    UserDefaults.standard.removeObject(forKey: "id")
    UserDefaults.standard.removeObject(forKey: "nameSurname")
    UserDefaults.standard.removeObject(forKey: "number")
    UserDefaults.standard.removeObject(forKey: "password")
    UserDefaults.standard.removeObject(forKey: "phone")
    UserDefaults.standard.removeObject(forKey: "email")
    UserDefaults.standard.removeObject(forKey: "remember")
}

func selectedStr(selectedType : Int) -> String{
    switch (selectedType){
    case 0 : return "TRY"
    case 1 : return "USD"
    case 2 : return "EUR"
    default:
        return ""
    }
}

func sessionVal(key : String) -> Any{
    if let value = UserDefaults.standard.value(forKey: key){
        return value
    }
    return ""
}

func hasUserLogged() -> Bool {
    return Auth.auth().currentUser != nil
}

func getDateWithFormat() -> String{
    let date = Date()
    let format = date.getFormattedDate(format: "dd.MM.yyyy HH:mm")
    return format
}


