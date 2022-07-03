//
//  Date+Extensions.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import Foundation

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
