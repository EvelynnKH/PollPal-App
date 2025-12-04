//
//  PollPalApp.swift
//  PollPal
//
//  Created by student on 27/11/25.
//

import SwiftUI

@main
struct PollPalApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
