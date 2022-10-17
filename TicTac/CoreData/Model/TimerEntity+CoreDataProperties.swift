//
//  TimerEntity+CoreDataProperties.swift
//  TicTac
//
//  Created by Robert Basamac on 13.10.2022.
//
//

import Foundation
import CoreData


extension TimerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerEntity> {
        return NSFetchRequest<TimerEntity>(entityName: "TimerEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var order: Int
    @NSManaged public var title: String
    @NSManaged public var message: String
    @NSManaged public var startTime: Date?
    @NSManaged public var pauseTime: Date?
    @NSManaged public var alarmTime: Date?
    @NSManaged public var duration: Double
    @NSManaged public var elapsedTime: Double
    @NSManaged public var isRunning: Bool
    @NSManaged public var isPaused: Bool
    @NSManaged public var category: CategoryEntity?

}

extension TimerEntity : Identifiable {

}
