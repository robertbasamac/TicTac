//
//  CoreDataManager.swift
//  TicTac
//
//  Created by Robert Basamac on 13.10.2022.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    
    let container: NSPersistentContainer
    
    @Published var timers: [TimerEntity] = []
    @Published var categories: [CategoryEntity] = []
    
    init() {
        ValueTransformer.setValueTransformer(UIColorTransformer(), forName: NSValueTransformerName("UIColorTransformer"))
        
        container = NSPersistentContainer(name: "CoreDataContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error).")
            }
            
            self.getTimers()
            self.getCategories()
        }
    }
    
    // MARK: - Public
    func updateTimer(timer: TimerModel) {
        if let entity = timers.first(where: { $0.id == timer.id }) {
            updateTimer(entity: entity, timer: timer)
        } else {
            addTimer(timer: timer)
        }
        
        applyChanges()
    }
    
    
    func updateCategory(category: CategoryModel) {
        if let entity = categories.first(where: { $0.id == category.id }) {
            updateCategory(entity: entity, category: category)
        } else {
            addCategory(category: category)
        }
        
        applyChanges()
    }
    
    func deleteTimer(timer: TimerModel) {
        if let entity = timers.first(where: { $0.id == timer.id }) {
            container.viewContext.delete(entity)
        }
        
        applyChanges()
    }
    
    func deleteCategory(category: CategoryModel) {
        if let entity = categories.first(where: { $0.id == category.id }) {
            container.viewContext.delete(entity)
        }
        
        applyChanges()
    }
    
    func updateAllTimers(timers: [TimerModel]) {
        for timer in timers {
            if let entity = self.timers.first(where: { $0.id == timer.id }) {
                updateTimer(entity: entity, timer: timer)
            }
        }
        
        applyChanges()
    }
    
    // MARK: - Private

    private func getTimers() {
        let request = NSFetchRequest<TimerEntity>(entityName: "TimerEntity")
                
        do {
            timers = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Timers, \(error.localizedDescription)")
        }
    }
    
    private func getCategories() {
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        
        do {
            categories = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Categories, \(error.localizedDescription)")
        }
    }
    
    private func addTimer(timer: TimerModel) {
        let entity = TimerEntity(context: container.viewContext)
        
        updateTimer(entity: entity, timer: timer)
    }
    
    private func addCategory(category: CategoryModel) {
        let entity = CategoryEntity(context: container.viewContext)
        
        updateCategory(entity: entity, category: category)
    }
    
    private func updateTimer(entity: TimerEntity, timer: TimerModel) {
        entity.id = timer.id
        entity.title = timer.title == "" ? "Timer" : timer.title
        entity.duration = timer.duration
        entity.message = timer.alarmMessage
        entity.isRunning = timer.isRunning
        entity.isPaused = timer.isPaused
        entity.startTime = timer.startTime
        entity.pauseTime = timer.pauseTime
        entity.alarmTime = timer.alarmTime
        entity.elapsedTime = timer.elapsedTime
        
        if let category = timer.category {
            entity.category = categories.first(where: { $0.id == category.id })
        } else {
            entity.category = nil
        }
    }
    
    private func updateCategory(entity: CategoryEntity, category: CategoryModel) {
        entity.id = category.id
        entity.title = category.title
        entity.color = UIColor(category.color)
    }
    
    private func applyChanges() {
        save()
        getTimers()
        getCategories()
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving Core Data: \(error.localizedDescription).")
        }
    }
}
