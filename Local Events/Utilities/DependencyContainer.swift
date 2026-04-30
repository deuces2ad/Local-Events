//
//  DependencyContainer.swift
//  Local Events
//
//  Lightweight DI container. Creates and owns all shared services
//  and repositories used throughout the app.
//

import Foundation
import Combine
import Models
import Networking
import Core

@MainActor
final class DependencyContainer: ObservableObject {
    let locationService: LocationService
    let eventRepository: EventRepository

    init() {
        self.locationService = LocationService()
        self.eventRepository = EventRepositoryImplementation(
            remoteDataSource: RemoteDataSource())
    }
}

// MARK: - ViewModel Factory

@MainActor
final class ViewModelFactory: ObservableObject {

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func createEventListViewModel() -> EventListViewModel {
        return EventListViewModel(
            eventRepository: container.eventRepository,
            locationService: container.locationService
        )
    }

    func createEventDetailViewModel(event: Event) -> EventDetailViewModel {
        return EventDetailViewModel(
            event: event,
            eventRepository: container.eventRepository,
            locationService: container.locationService
        )
    }

    func createBookmarksViewModel() -> BookmarksViewModel {
        return BookmarksViewModel(
            eventRepository: container.eventRepository,
            locationService: container.locationService
        )
    }
}
