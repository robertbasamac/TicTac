//
//  CoreDataManager.swift
//  TicTac
//
//  Created by Robert Basamac on 13.10.2022.
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        ValueTransformer.setValueTransformer(UIColorTransformer(), forName: NSValueTransformerName("UIColorTransformer"))
        
        container = NSPersistentContainer(name: "CoreDataContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error).")
            } else {
                print("Succesfully laoded the core data.")
            }
        }

        context = container.viewContext
    }

    func save() {
        do {
            try context.save()
            print("Succesfully saved to core data.")
        } catch let error {
            print("Error saving Core Data: \(error.localizedDescription).")
        }
    }
}
