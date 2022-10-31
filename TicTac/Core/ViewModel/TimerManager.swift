//
//  TimerManager.swift
//  TicTac
//
//  Created by Robert Basamac on 28.09.2022.
//

import Foundation
import Combine
import SwiftUI
import CoreData

class TimerManager: ObservableObject {
    
    @Published var allTimers: [TimerModel] = []
    @Published var activeTimers: [TimerModel] = []
    @Published var otherTimers: [TimerModel] = []
    @Published var categories: [CategoryModel] = []
    
    @Published var searchText: String = ""
    @Published var allowUpdateTimers: Bool = true
    
    @Published private var clock: AnyCancellable?
    
    private let coreDataManager: CoreDataManager = CoreDataManager()
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    // MARK: - Init
    init() {
        addSubscribers()
        
        startClock()
        stopClock()
    }
    
    // MARK: - Timers Handling
    func updateTimer(_ timer: TimerModel) {
        coreDataManager.updateTimer(timer: timer)
        
        startTimer(timer)
    }
    
    func startTimer(_ timer: TimerModel) {
        startClock()
        
        var editableTimer = timer

        editableTimer.startTime = Date()
        editableTimer.alarmTime = Date(timeInterval: editableTimer.duration, since: editableTimer.startTime ?? Date())
        editableTimer.isRunning = true
        
        NotificationManager.instance.scheduleNotification(
                        title: editableTimer.title,
                        message: editableTimer.alarmMessage,
                        alarmTime: editableTimer.alarmTime ?? Date())
        
        coreDataManager.updateTimer(timer: editableTimer)
    }
    
    func pauseTimer(_ timer: TimerModel) {
        var editableTimer = timer

        editableTimer.isPaused = true
        editableTimer.pauseTime = Date()
        
        coreDataManager.updateTimer(timer: editableTimer)
        
        stopClock()
    }
    
    func resumeTimer(_ timer: TimerModel) {
        startClock()
        
        var editableTimer = timer
        
        let elapsedTimeWhilePaused = Date().timeIntervalSince(timer.pauseTime ?? Date())

        editableTimer.startTime = Date(timeInterval: elapsedTimeWhilePaused, since: editableTimer.startTime ?? Date())
        editableTimer.alarmTime = Date(timeInterval: editableTimer.duration, since: editableTimer.startTime ?? Date())
        editableTimer.isPaused = false
        
        coreDataManager.updateTimer(timer: editableTimer)
    }
    
    func stopTimer(_ timer: TimerModel) {
        var editableTimer = timer
        
        editableTimer.startTime = nil
        editableTimer.alarmTime = nil
        editableTimer.pauseTime = nil
        editableTimer.isRunning = false
        editableTimer.isPaused = false
        editableTimer.elapsedTime = 0
        
        coreDataManager.updateTimer(timer: editableTimer)
        
        stopClock()
    }
    
    func deleteTimer(_ timer: TimerModel) {
        coreDataManager.deleteTimer(timer: timer)
        
        stopClock()
    }
    
    func deleteTimer(indexSet: IndexSet) {
        indexSet.map { allTimers[$0] }.forEach(coreDataManager.deleteTimer)

        stopClock()
    }
    
    func moveTimer(fromOffsets: IndexSet, toOffset: Int) {
        let itemToMove = fromOffsets.first!

        if itemToMove < toOffset {
            var startIndex = itemToMove + 1
            let endIndex = toOffset - 1
            var startOrder = allTimers[itemToMove].order

            while startIndex <= endIndex {
                allTimers[startIndex].order = startOrder

                startOrder += 1
                startIndex += 1
            }
            allTimers[itemToMove].order = startOrder
        } else if toOffset < itemToMove {
            var startIndex = toOffset
            let endIndex = itemToMove - 1
            var startOrder = allTimers[toOffset].order + 1
            let newOrder = allTimers[toOffset].order

            while startIndex <= endIndex {
                allTimers[startIndex].order = startOrder
                startOrder += 1
                startIndex += 1
            }
            allTimers[itemToMove].order = newOrder
        }

        coreDataManager.updateAllTimers(timers: allTimers)
    }
    
    // MARK: - Categories Handling
    func createCategory(_ category: CategoryModel) {
        coreDataManager.updateCategory(category: category)
    }
    
    func deleteCategory(indexSet: IndexSet) {
        indexSet.map { categories[$0] }.forEach(coreDataManager.deleteCategory)
    }

// MARK: - Private
    
    private func addSubscribers() {
        coreDataManager.$timers
            .map(mapTimerEntitiesToTimerModels)
            .sink { [weak self] returnedTimers in
                guard let self = self else { return }
                
                self.allTimers = returnedTimers
            }
            .store(in: &cancellables)

        $allTimers
            .combineLatest($searchText)
            .map(mapAndFilterTimers)
            .sink { [weak self] (returnedActiveTimers, returnedOtherTimers) in
                guard let self = self else { return }
                
                self.activeTimers = returnedActiveTimers
                self.otherTimers = returnedOtherTimers
            }
            .store(in: &cancellables)
        
        coreDataManager.$categories
            .map(mapCategoryEntitiesToCategoryModels)
            .sink { [weak self] returnedCategories in
                guard let self = self else { return }
                
                self.categories = returnedCategories
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Map Core Data Entities to Models
    private func mapTimerEntitiesToTimerModels(timerEntities: [TimerEntity]) -> [TimerModel] {
        var timers: [TimerModel] = []
        
        for timerEntity in timerEntities {
            var timerModel: TimerModel = TimerModel()
            
            timerModel.id = timerEntity.id
            timerModel.order = timerEntity.order
            timerModel.title = timerEntity.title
            timerModel.alarmMessage = timerEntity.message
            timerModel.duration = timerEntity.duration
            timerModel.isRunning = timerEntity.isRunning
            timerModel.isPaused = timerEntity.isPaused
            timerModel.startTime = timerEntity.startTime
            timerModel.pauseTime = timerEntity.pauseTime
            timerModel.alarmTime = timerEntity.alarmTime
            timerModel.elapsedTime = timerEntity.elapsedTime
            
            if let categoryEntity = timerEntity.category {
                var categoryModel: CategoryModel = CategoryModel()
                categoryModel.id = categoryEntity.id
                categoryModel.title = categoryEntity.title
                categoryModel.color = Color(uiColor: categoryEntity.color)
                timerModel.category = categoryModel
            }
            
            timers.append(timerModel)
        }
        
        return timers
    }
    
    private func mapAndFilterTimers(timers: [TimerModel], text: String) -> ([TimerModel], [TimerModel]) {
        var activeTimers: [TimerModel] = []
        var otherTimers: [TimerModel] = []
        
        for timer in timers {
            if timer.isRunning {
                activeTimers.append(timer)
            } else {
                otherTimers.append(timer)
            }
        }
        
        otherTimers = filterTimers(timerModels: otherTimers, text: text)
        
        return (activeTimers, otherTimers)
    }
        
    private func mapCategoryEntitiesToCategoryModels(categoryEntities: [CategoryEntity]) -> [CategoryModel] {
        var categories: [CategoryModel] = []
        
        for categoryEntity in categoryEntities {
            var categoryModel: CategoryModel = CategoryModel()
            
            categoryModel.id = categoryEntity.id
            categoryModel.title = categoryEntity.title
            categoryModel.color = Color(uiColor: categoryEntity.color)
            
            categories.append(categoryModel)
        }
        
        return categories
    }
    
    private func filterTimers(timerModels: [TimerModel], text: String) -> [TimerModel] {
        guard !text.isEmpty else {
            return timerModels
        }
        
        let lowercasedText = text.lowercased()
         
        return timerModels.filter { (timer) -> Bool in
            if let category = timer.category {
                return (timer.title.lowercased().contains(lowercasedText) ||
                        timer.alarmMessage.lowercased().contains(lowercasedText) ||
                        category.title.lowercased().contains(lowercasedText))
            } else {
                return (timer.title.lowercased().contains(lowercasedText) ||
                        timer.alarmMessage.lowercased().contains(lowercasedText))
            }
        }
    }
    
    // MARK: Clock Handling
    private func startClock() {
        clock?.cancel()
        
        clock = Timer
            .publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.updateTimers()
            }
    }
    
    private func stopClock() {
        let shouldStopClock: Bool = true
        
        for timer in allTimers {
            if timer.isRunning && !timer.isPaused {
                return
            }
        }
        
        if shouldStopClock {
            clock?.cancel()
        }
    }
    
    // MARK: - Update Timer from Clock
    private func updateTimers() {
        if allowUpdateTimers {
            for timer in activeTimers {
                if !timer.isPaused {
                    if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
                        let elapsedTime = Date().timeIntervalSince(activeTimers[index].startTime ?? Date())
                        
                        if elapsedTime < activeTimers[index].duration {
                            activeTimers[index].elapsedTime = elapsedTime
                        } else {
                            stopTimer(activeTimers[index])
                        }
                    }
                }
            }
        }
    }
}
