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
    
    var asHoursMinutesSecondsShorted: String {        
        if self >= 3600 {
            if self.truncatingRemainder(dividingBy: 3600) == 0 {
                let howManyHours = self / 3600
                return String(format: "%.0f \(howManyHours > 1 ? "HRS" : "HR")", howManyHours)
            }
        } else if self >= 60 {
            if self.truncatingRemainder(dividingBy: 60) == 0 {
                let howManyMinutes = self / 60
                return String(format: "%.0f MIN", howManyMinutes)
            }
        } else {
            return String(format: "%.0f SEC", self)
        }
        
        return self.asHoursMinutesSeconds
    }
}
