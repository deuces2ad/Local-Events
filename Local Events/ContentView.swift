//
//  ContentView.swift
//  Local Events
//
//

import SwiftUI
import Models
import Networking
import Core

struct ContentView: View {

    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var factory: ViewModelFactory

    var body: some View {
        TabView {
            EventListView(viewModel: factory.createEventListViewModel())
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            BookmarksView(viewModel: factory.createBookmarksViewModel())
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
        }
        .tint(.orange)
        .onAppear {
            container.locationService.requestPermission()
        }
    }
}

#Preview {
    let container = DependencyContainer()
    ContentView()
        .environmentObject(container)
        .environmentObject(ViewModelFactory(container: container))
}
