//
//  Storage.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/16.
//

import Foundation
import CoreData

// MARK: Core Data
class Storage {
    //Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores() { description, error in
            if let error = error as NSError? {
                fatalError()
            }
        }
        return container
    }()
    
    //Context
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
    
    
    func insertHistory(ofScore score: Int, atTime time: Date) {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as! History
        obj.score = Int32(score)
        obj.time = time
        saveContext()
    }
    
    func fetchHistories(withSortKey key: String, up: Bool) -> [History] {
        let fetchRequest = NSFetchRequest<History>(entityName: "History")
        fetchRequest.fetchOffset = 0
        let sortDescriptor = NSSortDescriptor(key: key, ascending: up)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            return fetchedObjects
        } catch {
            fatalError()
        }
    }
    
}

