//
//  TimeInterval.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import Foundation

extension TimeInterval {
    
    var asHoursMinutesSeconds: String {
        if self > 3600 {
            return String(format: "%0.0f:%02.0f:%02.0f",
                   (self / 3600).truncatingRemainder(dividingBy: 3600),
                   (self / 60).truncatingRemainder(dividingBy: 60).rounded(.down),
                   truncatingRemainder(dividingBy: 60).rounded(.down))
        } else {
            return String(format: "%02.0f:%02.0f",
                   (self / 60).truncatingRemainder(dividingBy: 60).rounded(.down),
                   truncatingRemainder(dividingBy: 60).rounded(.down))
        }
        
    }
}
