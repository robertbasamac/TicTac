//
//  TimerModel.swift
//  TicTac
//
//  Created by Robert Basamac on 28.09.2022.
//

import Foundation
import Combine

struct TimerModel: Identifiable {
    var id: String = UUID().uuidString
    var order: Int = 0
    var title: String
    var alarmMessage: String
    var duration: Double
    var category: CategoryModel?
    var isRunning: Bool = false
    var isPaused: Bool = false
    
    var startTime: Date? = nil
    var pauseTime: Date? = nil
    var alarmTime: Date? = nil
    
    var elapsedTime: Double = 0 {
        didSet {
            remainingPercentage = 1 - elapsedTime / duration
            displayedTime = (duration - elapsedTime).asHoursMinutesSeconds
        }
    }
    var remainingPercentage: Double = 1
    var displayedTime: String = 0.asHoursMinutesSeconds
    
    init(title: String = "Timer", message: String = "", duration: Double = 0, category: CategoryModel? = nil) {
        self.duration = duration
        self.title = title
        self.alarmMessage = message
        self.category = category
    }
}
