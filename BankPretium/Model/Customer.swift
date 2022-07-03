//
//  Customer.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import Foundation

class Customer {
    private var id : String
    private var nameSurname : String
    private var email : String
    private var number : String
    private var password : String
    private var phone : String
    
    init(id : String,nameSurname : String, number : String, password : String, phone : String, email : String) {
        self.id = id
        self.nameSurname = nameSurname
        self.number = number
        self.email = email
        self.password = password
        self.phone = phone
    }
    
    func getBack() -> Customer{
        return self
    }
    
    func getEmail()->String{
        return self.email
    }
    
    func getID()->String{
        return self.id
    }
    
    func getNameSurname()->String{
        return self.nameSurname
    }
    
    func getNumber()->String{
        return self.number
    }
    
    func getPhone()->String{
        return self.phone
    }
    
}
