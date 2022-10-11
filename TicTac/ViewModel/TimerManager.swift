//
//  TimerManager.swift
//  TicTac
//
//  Created by Robert Basamac on 28.09.2022.
//

import Foundation
import Combine
import SwiftUI

class TimerManager: ObservableObject {
    
    @Published var timers: [TimerModel] = []

    @Published var isActive: Bool = true
    
    @Published private var clock: AnyCancellable?
    
    private func startClock() {
        clock?.cancel()
        
        clock = Timer
            .publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                for index in self.timers.indices {
                    self.updateTimer(forIndex: index)
                }
            }
    }
    
    private func stopClock() {
        let shouldStopClock: Bool = true
        
        for timer in timers {
            if timer.isRunning && !timer.isPaused {
                return
            }
        }
        
        if shouldStopClock {
            clock?.cancel()
        }
    }
    
    private func updateTimer(forIndex index: Int) {
        if isActive {
            if timers[index].isRunning && !timers[index].isPaused {
                timers[index].timeElapsed = Date().timeIntervalSince(timers[index].startTime ?? Date())
                
                timers[index].remainingPercentage = 1 - timers[index].timeElapsed / timers[index].duration
                
                if timers[index].timeElapsed < timers[index].duration {
                    let remainingTime = timers[index].duration - timers[index].timeElapsed
                    timers[index].displayedTime = remainingTime.asHoursMinutesSeconds
                } else {
                    stopTimer(timers[index])
                }
            }
        }
    }
    
    func createTimer(title: String, message: String, duration: Double) {
        let timer = TimerModel(title: title, message: message, duration: duration)
        
        timers.append(timer)
        
        startTimer(timer)
    }
    
    func startTimer(_ timer: TimerModel) {
        startClock()
        
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].startTime = Date()
            timers[index].isRunning = true
            
            NotificationManager.instance.scheduleNotification(
                title: timers[index].title,
                message: timers[index].message,
                alarmTime: timers[index].alarmTime ?? Date())
        }
    }
    
    func pauseTimer(_ timer: TimerModel) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].pauseTime = Date()
            timers[index].isPaused = true
        }
        
        stopClock()
    }
    
    func resumeTimer(_ timer: TimerModel) {
        startClock()
        
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].timeElapsedOnPause = Date().timeIntervalSince(self.timers[index].pauseTime ?? Date())
            timers[index].startTime = Date(timeInterval: timers[index].timeElapsedOnPause, since: timers[index].startTime ?? Date())
            timers[index].isPaused = false
        }
    }
    
    func stopTimer(_ timer: TimerModel) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].startTime = nil
            timers[index].alarmTime = nil
            timers[index].isRunning = false
            timers[index].isPaused = false
            timers[index].timeElapsed = 0
            timers[index].timeElapsedOnPause = 0
            timers[index].remainingPercentage = 1
            timers[index].displayedTime = timers[index].duration.asHoursMinutesSeconds
        }
        
        stopClock()
    }
    
    func deleteTimer(_ timer: TimerModel) {
        timers.removeAll(where: { $0.id == timer.id })
        
        stopClock()
    }
    
    func deleteTimer(indexSet: IndexSet) {
        timers.remove(atOffsets: indexSet)
        
        stopClock()
    }
    
    func moveTimer(fromOffsets: IndexSet, toOffset: Int) {
        timers.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
