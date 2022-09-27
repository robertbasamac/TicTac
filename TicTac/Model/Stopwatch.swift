//
//  Stopwatch.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import Foundation
import Combine

class Stopwatch: ObservableObject {
    @Published private(set) var message = ""
    
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isPaused: Bool = false
    
    @Published private(set) var remainingPercentage: Double = 1
    
    @Published private(set) var alarmTime: Date? = nil

    private var startTime: Date? {
        didSet {
            saveStartTime()
            
            alarmTime = Date(timeInterval: duration, since: startTime ?? Date())
        }
    }
    
    private var pauseTime: Date?

    private var duration: Double
    
    private var elapsed: Double = 0
    
    private var elapsedOnPause: Double = 0
    
    private var timer: AnyCancellable?

    init(duration: Double) {
        self.duration = duration
        self.message = self.duration.asHoursMinutesSeconds

        startTime = fetchStartTime()
        
        if startTime != nil {
            start()
        }
    }
}

// MARK: - Public Interface
extension Stopwatch {
    
    func start() {
        timer?.cancel()

        if startTime == nil {
            startTime = Date()
        }
                
        timer = Timer
            .publish(every: 0.001, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                guard
                    let self = self,
                    let startTime = self.startTime
                else { return }

                if self.isRunning && !self.isPaused {
                    self.elapsed = value.timeIntervalSince(startTime)
                    self.remainingPercentage = 1 - self.elapsed / self.duration
                                        
                    guard self.elapsed < self.duration else {
                        self.stop()
                        return
                    }
                    
                    let remainingTime = self.duration - self.elapsed
                    self.message = remainingTime.asHoursMinutesSeconds
                } else {
                    self.elapsedOnPause = value.timeIntervalSince(self.pauseTime ?? Date())
                }
            }

        isRunning = true
    }
    
    func pause() {
        pauseTime = Date()
        isPaused = true
    }
    
    func resume() {
        startTime = Date(timeInterval: elapsedOnPause, since: startTime ?? Date())
        isPaused = false
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        startTime = nil
        alarmTime = nil
        isRunning = false
        isPaused = false
        elapsed = 0
        elapsedOnPause = 0
        remainingPercentage = 1
        message = duration.asHoursMinutesSeconds
    }
}

// MARK: - Private implementation
private extension Stopwatch {
    
    func saveStartTime() {
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "startTime")
        }
    }

    func fetchStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "startTime") as? Date
    }
}
