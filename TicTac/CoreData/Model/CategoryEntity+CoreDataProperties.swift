//
//  CategoryEntity+CoreDataProperties.swift
//  TicTac
//
//  Created by Robert Basamac on 13.10.2022.
//
//

import Foundation
import CoreData
import UIKit

extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var color: UIColor
    @NSManaged public var timers: NSSet?

}

// MARK: Generated accessors for timers
extension CategoryEntity {

    @objc(addTimersObject:)
    @NSManaged public func addToTimers(_ value: TimerEntity)

    @objc(removeTimersObject:)
    @NSManaged public func removeFromTimers(_ value: TimerEntity)

    @objc(addTimers:)
    @NSManaged public func addToTimers(_ values: NSSet)

    @objc(removeTimers:)
    @NSManaged public func removeFromTimers(_ values: NSSet)

}

extension CategoryEntity : Identifiable {

}
