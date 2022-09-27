//
//  String.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import Foundation

extension Date {
    
    var asHoursAndMinutes: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: self)
    }
}
