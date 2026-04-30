//
//  Local_EventsApp.swift
//  Local Events
//
//

import SwiftUI
import Models
import Networking
import Core

@main
struct Local_EventsApp: App {

    @StateObject
    private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .environmentObject(ViewModelFactory(container: container))
        }
    }
}
