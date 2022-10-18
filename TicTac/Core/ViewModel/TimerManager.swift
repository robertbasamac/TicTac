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
    
    let coreDataManager = CoreDataManager.shared
    
    @Published var timerEntities: [TimerEntity] = []
    @Published var categoryEntities: [CategoryEntity] = []
    
    @Published var timers: [TimerModel] = []
    @Published var categories: [CategoryModel] = []

    @Published var isActive: Bool = true
    
    @Published private var clock: AnyCancellable?
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    // MARK: - Init
    init() {
        addSubscribers()
        getTimers()
        getCategories()
        
        startClock()
        stopClock()
    }
    
    // MARK: - Timers Handling
    func createTimer(_ timer: TimerModel) {
        let entity = TimerEntity(context: coreDataManager.context)
        
        entity.id = timer.id
        entity.order = (timerEntities.last?.order ?? 0) + 1
        entity.title = timer.title == "" ? "Timer" : timer.title
        entity.duration = timer.duration
        entity.isRunning = timer.isRunning
        entity.isPaused = timer.isPaused
        
        if let category = timer.category {
            let categoryEntities: [CategoryEntity] = fetchCategoryEntities(forId: category.id)
            
            guard !categoryEntities.isEmpty, let categoryEntity = categoryEntities.first else {
                print("No Category with id = \(timer.id) found.")
                return
            }
            
            entity.category = categoryEntity
        }
                
        startTimer(timer)
    }
    
    func editTimer(_ timer: TimerModel) {
        let entities: [TimerEntity] = fetchTimerEntities(forId: timer.id)
        
        guard !entities.isEmpty, let entity = entities.first else {
            print("No Timer with id = \(timer.id) found.")
            return
        }
        
        entity.id = timer.id
        entity.order = (timerEntities.last?.order ?? 0) + 1
        entity.title = timer.title
        entity.duration = timer.duration
        entity.isRunning = timer.isRunning
        entity.isPaused = timer.isPaused
        
        if let category = timer.category {
            let categoryEntities: [CategoryEntity] = fetchCategoryEntities(forId: category.id)
            
            guard !categoryEntities.isEmpty, let categoryEntity = categoryEntities.first else {
                print("No Category with id = \(timer.id) found.")
                return
            }
            
            entity.category = categoryEntity
        }
        
        startTimer(timer)
    }
    
    func startTimer(_ timer: TimerModel) {
        startClock()
        
        let entities: [TimerEntity] = fetchTimerEntities(forId: timer.id)
        
        guard !entities.isEmpty, let entity = entities.first else {
            print("No Timer with id = \(timer.id) found.")
            return
        }
        
        entity.startTime = Date()
        entity.alarmTime = Date(timeInterval: entity.duration, since: entity.startTime ?? Date())
        entity.isRunning = true
        
        NotificationManager.instance.scheduleNotification(
                        title: entity.title,
                        message: entity.message,
                        alarmTime: entity.alarmTime ?? Date())
        
        save()
    }
    
    func pauseTimer(_ timer: TimerModel) {
        let entities: [TimerEntity] = fetchTimerEntities(forId: timer.id)
        
        guard !entities.isEmpty, let entity = entities.first else {
            print("No Timer with id = \(timer.id) found.")
            return
        }
        
        entity.isPaused = true
        entity.pauseTime = Date()
        entity.elapsedTime = timer.elapsedTime

        save()
        
        stopClock()
    }
    
    func resumeTimer(_ timer: TimerModel) {
        startClock()
        
        let entities: [TimerEntity] = fetchTimerEntities(forId: timer.id)
        
        guard !entities.isEmpty, let entity = entities.first else {
            print("No Timer with id = \(timer.id) found.")
            return
        }
        
        let elapsedTimeWhilePaused = Date().timeIntervalSince(entity.pauseTime ?? Date())

        entity.startTime = Date(timeInterval: elapsedTimeWhilePaused, since: entity.startTime ?? Date())
        entity.alarmTime = Date(timeInterval: entity.duration, since: entity.startTime ?? Date())
        entity.isPaused = false
        
        save()
    }
    
    func stopTimer(_ timer: TimerModel) {
        let entities: [TimerEntity] = fetchTimerEntities(forId: timer.id)
        
        guard !entities.isEmpty, let entity = entities.first else {
            print("No Timer with id = \(timer.id) found.")
            return
        }
        
        entity.startTime = nil
        entity.alarmTime = nil
        entity.pauseTime = nil
        entity.isRunning = false
        entity.isPaused = false
        entity.elapsedTime = 0
        
        save()
        
        stopClock()
    }
    
    func deleteTimer(_ timer: TimerModel) {
        let entities: [TimerEntity] = fetchTimerEntities(forId: timer.id)
        
        guard !entities.isEmpty, let entity = entities.first else {
            print("No Timer with id = \(timer.id) found.")
            return
        }
        
        coreDataManager.context.delete(entity)
        save()
    }
    
    func deleteTimer(indexSet: IndexSet) {
        indexSet.map { timerEntities[$0] }.forEach(coreDataManager.context.delete)
        
        save()
                
        stopClock()
    }
    
    func moveTimer(fromOffsets: IndexSet, toOffset: Int) {
        let itemToMove = fromOffsets.first!
        
        if itemToMove < toOffset {
            var startIndex = itemToMove + 1
            let endIndex = toOffset - 1
            var startOrder = timerEntities[itemToMove].order
            
            while startIndex <= endIndex {
                timerEntities[startIndex].order = startOrder
                
                startOrder += 1
                startIndex += 1
            }
            
            timerEntities[itemToMove].order = startOrder
        } else if toOffset < itemToMove {
            var startIndex = toOffset
            let endIndex = itemToMove - 1
            var startOrder = timerEntities[toOffset].order + 1
            let newOrder = timerEntities[toOffset].order
            
            while startIndex <= endIndex {
                timerEntities[startIndex].order = startOrder
                startOrder += 1
                startIndex += 1
            }
            
            timerEntities[itemToMove].order = newOrder
        }
        
        save()
    }
    
    // MARK: - Categories Handling
    func createCategory(_ category: CategoryModel) {
        let entity = CategoryEntity(context: coreDataManager.context)
        
        entity.id = category.id
        entity.title = category.title
        entity.color = UIColor(category.color)
        
        save()
    }
    
    func deleteCategory(indexSet: IndexSet) {
        indexSet.map { categoryEntities[$0] }.forEach(coreDataManager.context.delete)
        
        save()
    }


// MARK: - Private
    
    private func addSubscribers() {
        $timerEntities
            .map(mapTimerEntitiesToTimerModels)
            .sink { [weak self] returnedTimers in
                guard let self = self else { return }
                
                self.timers = returnedTimers
            }
            .store(in: &cancellables)
        
        $categoryEntities
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
    
    // MARK: Clock Handling
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
    
    // MARK: - Update Timer
    private func updateTimer(forIndex index: Int) {
        if isActive {
            if timers[index].isRunning && !timers[index].isPaused {
                timers[index].elapsedTime = Date().timeIntervalSince(timers[index].startTime ?? Date())
                
                //                timers[index].remainingPercentage = 1 - timers[index].elapsedTime / timers[index].duration
                
                if timers[index].elapsedTime < timers[index].duration {
                    //                    let remainingTime = timers[index].duration - timers[index].elapsedTime
                    //                    timers[index].displayedTime = remainingTime.asHoursMinutesSeconds
                } else {
                    stopTimer(timers[index])
                }
            }
        }
    }
    
    // MARK: - Fetch Core Data Entities
    private func getTimers() {
        // one way to create the fetch request
//        let request: NSFetchRequest<TimerEntity> = TimerEntity.fetchRequest()
        
        // the other way to create the fetch request
        let request = NSFetchRequest<TimerEntity>(entityName: "TimerEntity")
        
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            timerEntities = try coreDataManager.context.fetch(request)
        } catch let error {
            print("Error fetching Timers, \(error.localizedDescription)")
        }
    }
    
    private func getCategories() {
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        
        do {
            categoryEntities = try coreDataManager.context.fetch(request)
        } catch let error {
            print("Error fetching Categories, \(error.localizedDescription)")
        }
    }
    
    private func fetchTimerEntities(forId id: String) -> [TimerEntity] {
        var entities: [TimerEntity] = []
        
        let request = NSFetchRequest<TimerEntity>(entityName: "TimerEntity")
        
        let filter = NSPredicate(format: "id == %@", id)
        request.predicate = filter
        
        do {
            entities = try coreDataManager.context.fetch(request)
        } catch let error {
            print("Error fetching Timer for id = \(id), \(error.localizedDescription)")
        }
        
        return entities
    }
    
    private func fetchCategoryEntities(forId id: String) -> [CategoryEntity] {
        var entities: [CategoryEntity] = []
        
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        
        let filter = NSPredicate(format: "id == %@", id)
        request.predicate = filter
        
        do {
            entities = try coreDataManager.context.fetch(request)
        } catch let error {
            print("Error fetching Category for id = \(id), \(error.localizedDescription)")
        }
        
        return entities
    }
    
    private func save() {
        coreDataManager.save()
        getTimers()
        getCategories()
    }
}
