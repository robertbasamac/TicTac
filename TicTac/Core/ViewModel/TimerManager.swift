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
    
    //    @Published var allTimers: [TimerModel] = []
    @Published var activeTimers: [TimerModel] = []
    @Published var otherTimers: [TimerModel] = []
    @Published var categories: [CategoryModel] = []
    
    @Published var searchText: String = ""
    @Published var allowUpdateTimers: Bool = true
    
    @Published private var clock: Cancellable?
    
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
    }
    
    func handleTimer(_ timer: TimerModel) {
        timer.isRunning ?
            timer.isPaused ? resumeTimer(timer) : pauseTimer(timer)
            : startTimer(timer)
    }
    
    func startTimer(_ timer: TimerModel) {
        print("\nSTART")
        
        startClock()
        
        if let index = otherTimers.firstIndex(where: { $0.id == timer.id } ) {
            otherTimers[index].startTime = Date()
            otherTimers[index].alarmTime = Date(timeInterval: otherTimers[index].duration, since: otherTimers[index].startTime ?? Date())
            otherTimers[index].isRunning = true
            
            NotificationManager.instance.scheduleNotification(
                title: otherTimers[index].title,
                message: otherTimers[index].alarmMessage,
                alarmTime: otherTimers[index].alarmTime ?? Date())
        }
        
        let timers = activeTimers + otherTimers
        
        withAnimation {
            coreDataManager.updateAllTimers(timers: timers)
        }
    }
    
    func pauseTimer(_ timer: TimerModel) {
        print("\nPAUSE")
        
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id } ) {
            activeTimers[index].isPaused = true
            activeTimers[index].pauseTime = Date()
        }
        
        withAnimation {
            coreDataManager.updateAllTimers(timers: activeTimers)
        }
        
        stopClock()
    }
    
    func resumeTimer(_ timer: TimerModel) {
        print("\nRESUME")
        
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id } ) {
            let elapsedTimeWhilePaused = Date().timeIntervalSince(timer.pauseTime ?? Date())
            
            activeTimers[index].startTime = Date(timeInterval: elapsedTimeWhilePaused, since: activeTimers[index].startTime ?? Date())
            activeTimers[index].alarmTime = Date(timeInterval: activeTimers[index].duration, since: activeTimers[index].startTime ?? Date())
            activeTimers[index].isPaused = false
        }
        
        withAnimation {
            coreDataManager.updateAllTimers(timers: activeTimers)
        }
    }
    
    func stopTimer(_ timer: TimerModel) {
        print("\nSTOP")
        
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id } ) {
            activeTimers[index].startTime = nil
            activeTimers[index].alarmTime = nil
            activeTimers[index].pauseTime = nil
            activeTimers[index].isRunning = false
            activeTimers[index].isPaused = false
            activeTimers[index].elapsedTime = 0
        }
        
        withAnimation {
            coreDataManager.updateAllTimers(timers: activeTimers)
        }
        
        stopClock()
    }
    
    func deleteTimer(_ timer: TimerModel) {
        coreDataManager.deleteTimer(timer: timer)
        
        stopClock()
    }
    
    func deleteTimer(indexSet: IndexSet, active: Bool) {
        if active {
            indexSet.map { activeTimers[$0] }.forEach(coreDataManager.deleteTimer)
        } else {
            indexSet.map { otherTimers[$0] }.forEach(coreDataManager.deleteTimer)
        }
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
        
        coreDataManager.$activeTimers
            .map(mapTimerEntitiesToTimerModels)
            .sink { [weak self] returnedTimers in
                guard let self = self else { return }
                
                self.activeTimers = returnedTimers
                print("Publisher activeTimers")
            }
            .store(in: &cancellables)
        
        coreDataManager.$otherTimers
            .combineLatest($searchText)
            .map(mapTimerEntitiesToTimerModelsAndFilter)
            .sink { [weak self] returnedTimers in
                guard let self = self else { return }
                
                self.otherTimers = returnedTimers
                print("Publisher otherTimers")
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
        print("mapTimerEntitiesToTimerModels called")
        var timers: [TimerModel] = []
        
        for timerEntity in timerEntities {
            var timerModel: TimerModel = TimerModel()
            
            timerModel.id = timerEntity.id
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
    
    private func mapTimerEntitiesToTimerModelsAndFilter(timerEntities: [TimerEntity], text: String) -> [TimerModel] {
        print("mapTimerEntitiesToTimerModelsAndFilter called")
        var timers: [TimerModel] = mapTimerEntitiesToTimerModels(timerEntities: timerEntities)
        
        timers = filterTimers(timerModels: timers, text: text)
        
        return timers
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
        print("filterTimers called")
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
        
        clock = Timer.TimerPublisher(interval: 0.01, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.updateTimers()
            }
    }
    
    private func stopClock() {
        if activeTimers.isEmpty {
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
