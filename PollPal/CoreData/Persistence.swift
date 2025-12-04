//
//  Persistence.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    // Container untuk database
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // GANTI "NamaProjectAnda" DENGAN NAMA FILE .xcdatamodeld ANDA
        container = NSPersistentContainer(name: "PollpalDataModel")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }

        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // Opsional: Agar update UI otomatis lebih mulus
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        DataSeeder.seed(viewContext: container.viewContext)
    }

}
