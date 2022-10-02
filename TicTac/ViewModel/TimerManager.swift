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
            .publish(every: 0.001, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                guard let self = self else { return }
                
                for index in self.timers.indices {
                    if self.timers[index].isRunning && !self.timers[index].isPaused {
                        self.timers[index].timeElapsed = value.timeIntervalSince(self.timers[index].startTime ?? Date())
                        self.timers[index].remainingPercentage = 1 - self.timers[index].timeElapsed / self.timers[index].duration
                        
                        if self.timers[index].timeElapsed < self.timers[index].duration {
                            let remainingTime = self.timers[index].duration - self.timers[index].timeElapsed
                            self.timers[index].message = remainingTime.asHoursMinutesSeconds
                        } else {
                            self.stopTimer(self.timers[index])
                        }
                    }
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
    
    func createTimer(title: String, duration: Double) {
        let timer = TimerModel(title: title, duration: 10)
        
        timers.append(timer)
        
        startTimer(timer)
    }
    
    func startTimer(_ timer: TimerModel) {
        startClock()
        
//        print("\nstartTimer called: \(timer.id)")
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
//            print("startTimer: before isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")

            timers[index].startTime = Date()
            timers[index].isRunning = true
            
//            print("startTimer: before isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")
        }
    }
    
    func pauseTimer(_ timer: TimerModel) {
//        print("\npauseTimer called: \(timer.id)")
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
//            print("pauseTimer: before isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")

            timers[index].pauseTime = Date()
            timers[index].isPaused = true
            
//            print("pauseTimer: after isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")
        }
        
        stopClock()
    }
    
    func resumeTimer(_ timer: TimerModel) {
        startClock()
//        print("\nresumeTimer called: \(timer.id)")
        
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
//            print("resumeTimer: before isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")
            
            timers[index].timeElapsedOnPause = Date().timeIntervalSince(self.timers[index].pauseTime ?? Date())
            timers[index].startTime = Date(timeInterval: timers[index].timeElapsedOnPause, since: timers[index].startTime ?? Date())
            timers[index].isPaused = false
            
//            print("resumeTimer: after isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")
        }
    }
    
    func stopTimer(_ timer: TimerModel) {
//        print("\nstopTimer called: \(timer.id)")

        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
//            print("stopTimer: before isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")

            timers[index].startTime = nil
            timers[index].alarmTime = nil
            timers[index].isRunning = false
            timers[index].isPaused = false
            timers[index].timeElapsed = 0
            timers[index].timeElapsedOnPause = 0
            timers[index].remainingPercentage = 1
            timers[index].message = timers[index].duration.asHoursMinutesSeconds
            
//            print("stopTimer: after isRunning(\(timers[index].isRunning)), isPaused(\(timers[index].isPaused))")
        }
        
        stopClock()
    }
    
    func deleteTimer(_ timer: TimerModel) {
        timers.removeAll(where: { $0.id == timer.id })
        
        stopClock()
    }
}
