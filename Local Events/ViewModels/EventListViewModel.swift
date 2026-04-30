//
//  EventListViewModel.swift
//  Local Events
//
//  Delegates all data operations to the EventRepository.
//

import Foundation
import Combine
import CoreLocation
import Models
import Core

@MainActor
final class EventListViewModel: ObservableObject {

    @Published
    private(set) var events: [Event] = []
    @Published
    private(set) var isLoading = false
    @Published
    private(set) var errorMessage: String?
    @Published 
    var searchText = ""
    @Published
    var selectedCategory: EventCategory?

    // MARK: - Dependencies

    private let eventRepository: EventRepository
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    var filteredEvents: [Event] {
        var result = events

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.location.address.lowercased().contains(query) ||
                $0.category.rawValue.lowercased().contains(query)
            }
        }
        
        return result
    }

    init(eventRepository: EventRepository, locationService: LocationServiceProtocol) {
        self.eventRepository = eventRepository
        self.locationService = locationService
        observeLocation()
    }

    func loadEvents(forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await eventRepository.getEvents(forceRefresh: forceRefresh)
            events = sortedByDistance(fetched)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadEvents(forceRefresh: true)
    }

    // MARK: - Bookmarks

    func toggleBookmark(for event: Event) {
        if event.isBookmarked {
            _ = eventRepository.removeBookmark(eventId: event.id)
        } else {
            _ = eventRepository.addBookmark(eventId: event.id)
        }

        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].isBookmarked = !event.isBookmarked
        }
    }

    func distance(to event: Event) -> CLLocationDistance? {
        locationService.distance(to: event.location.coordinate)
    }

    func formattedDistance(to event: Event) -> String {
        Formatters.formattedDistance(distance(to: event))
    }

    private func sortedByDistance(_ events: [Event]) -> [Event] {
        guard locationService.currentLocation != nil else { return events }
        return events.sorted { a, b in
            let dA = distance(to: a) ?? .greatestFiniteMagnitude
            let dB = distance(to: b) ?? .greatestFiniteMagnitude
            return dA < dB
        }
    }

    private func observeLocation() {
        locationService.locationPublisher
            .compactMap { $0 }
            .removeDuplicates(by: { $0.distance(from: $1) < 50 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.events = self.sortedByDistance(self.events)
            }
            .store(in: &cancellables)
    }
}
