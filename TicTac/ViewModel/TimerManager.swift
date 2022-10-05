//
//  TimerManager.swift
//  TicTac
//
//  Created by Robert Basamac on 28.09.2022.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    
    @Published var timers: [TimerModel] = []

    @Published private var clock: AnyCancellable?
    
    private func startClock() {
        clock?.cancel()
        
        clock = Timer
            .publish(every: 0.1, on: .main, in: .common)
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
        if self.timers[index].isRunning && !self.timers[index].isPaused {
            self.timers[index].timeElapsed = Date().timeIntervalSince(self.timers[index].startTime ?? Date())
            self.timers[index].remainingPercentage = 1 - self.timers[index].timeElapsed / self.timers[index].duration
            
            if self.timers[index].timeElapsed < self.timers[index].duration {
                let remainingTime = self.timers[index].duration - self.timers[index].timeElapsed
                self.timers[index].displayedTime = remainingTime.asHoursMinutesSeconds
            } else {
                self.stopTimer(self.timers[index])
            }
        }
    }
    
    func createTimer(title: String, duration: Double) {
        let timer = TimerModel(title: title, duration: duration)
        
        timers.append(timer)
        
        startTimer(timer)
    }
    
    func startTimer(_ timer: TimerModel) {
        startClock()
        
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].startTime = Date()
            timers[index].isRunning = true
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
}
