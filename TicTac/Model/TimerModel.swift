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
    var title: String
    var startTime: Date? {
        didSet {
            alarmTime = Date(timeInterval: duration, since: startTime ?? Date())
        }
    }
    var pauseTime: Date? = nil
    var alarmTime: Date? = nil
    var duration: Double
    var timeElapsed: Double = 0 {
        didSet {
            message = (duration - timeElapsed).asHoursMinutesSeconds
        }
    }
    var timeElapsedOnPause: Double = 0
    var remainingPercentage: Double = 1
    var isRunning: Bool = false
    var isPaused: Bool = false
    var message: String = ""
    
    init(title: String, duration: Double) {
        self.duration = duration
        self.title = title
        self.message = self.duration.asHoursMinutesSeconds
    }
}
