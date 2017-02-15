//
//  CoreDataStack.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let managedObjectModelName: String
    
    required init(modelName: String) {
        managedObjectModelName = modelName
    }
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL =
            Bundle.main.url(forResource: self.managedObjectModelName,
                            withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return urls.first!
    }()
    
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        var coordinator =
            NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        let url =
            self.applicationDocumentsDirectory.appendingPathComponent(pathComponent)
        
        let store = try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                        configurationName: nil,
                                                        at: url,
                                                        options: nil)
        
        return coordinator
    }()
    
    lazy var mainQueueContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        moc.name = "Main Queue Context (UI Context)"
        
        return moc
    }()
    
    lazy var privateQueueContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.mainQueueContext
        moc.name = "Primary Private Queue Context"
        
        return moc
    }()
    
    func saveChanges() throws {
        var optionalError: Error?
        
        privateQueueContext.performAndWait { () -> Void in
            if self.privateQueueContext.hasChanges {
                do {
                    try self.privateQueueContext.save()
                }
                catch let saveError {
                    optionalError = saveError
                }
            }
        }
        
        if let error = optionalError {
            throw error
        }
        
        mainQueueContext.performAndWait { () -> Void in
            
            if self.mainQueueContext.hasChanges {
                do {
                    try self.mainQueueContext.save()
                }
                catch let saveError {
                    optionalError = saveError
                }
            }
        }
        if let error = optionalError {
            throw error
        }
    }
    
}
