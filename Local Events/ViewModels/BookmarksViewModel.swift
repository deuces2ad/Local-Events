//
//  BookmarksViewModel.swift
//  Local Events
//
//  Delegates bookmark operations to the EventRepository.
//

import Foundation
import Combine
import CoreLocation
import Models
import Core

@MainActor
final class BookmarksViewModel: ObservableObject {

    @Published private(set) var bookmarkedEvents: [Event] = []
    @Published private(set) var isLoading = false

    private let eventRepository: EventRepository
    private let locationService: LocationServiceProtocol

    init(eventRepository: EventRepository, locationService: LocationServiceProtocol) {
        self.eventRepository = eventRepository
        self.locationService = locationService
    }

    func loadBookmarks() {
        isLoading = true
        bookmarkedEvents = eventRepository.getBookmarkedEvents()
        isLoading = false
    }

    func removeBookmark(for event: Event) {
        _ = eventRepository.removeBookmark(eventId: event.id)
        bookmarkedEvents.removeAll { $0.id == event.id }
    }

    func distance(to event: Event) -> CLLocationDistance? {
        locationService.distance(to: event.location.coordinate)
    }

    func formattedDistance(to event: Event) -> String {
        Formatters.formattedDistance(distance(to: event))
    }
}
