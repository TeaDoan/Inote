//
//  CoreDataStack.swift
//  Note.V2
//
//  Created by Thao Doan on 1/2/18.
//  Copyright © 2018 Thao Doan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "NoteModel")
        container.loadPersistentStores(completionHandler: {(storeDescription,error) in
            
            if let error = error as NSError? {
                fatalError("error has occured")
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func saveIfNeeded() {
        if context.hasChanges {
            try! context.save()
        }
    }
}
