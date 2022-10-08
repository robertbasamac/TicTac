//
//  TimeInterval.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import Foundation

extension TimeInterval {
    
    var asHoursMinutesSeconds: String {
        let formatter = DateComponentsFormatter()
        
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        
        if self > 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
    
        return formatter.string(from: self) ?? "00:00:00"
    }
}
