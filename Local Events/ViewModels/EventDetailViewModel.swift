//
//  EventDetailViewModel.swift
//  Local Events
//
//  Delegates bookmark operations to the EventRepository.
//

import Foundation
import Combine
import CoreLocation
import MapKit
import Models
import Core

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published
    var event: Event

    private let eventRepository: EventRepository
    private let locationService: LocationServiceProtocol

    init(
        event: Event,
        eventRepository: EventRepository,
        locationService: LocationServiceProtocol
    ) {
        self.event = event
        self.eventRepository = eventRepository
        self.locationService = locationService
    }

    func toggleBookmark() {
        let newState = !event.isBookmarked
        if newState {
            _ = eventRepository.addBookmark(eventId: event.id)
        } else {
            _ = eventRepository.removeBookmark(eventId: event.id)
        }
        event.isBookmarked = newState
    }

    var distance: CLLocationDistance? {
        locationService.distance(to: event.location.coordinate)
    }

    var formattedDistance: String {
        Formatters.formattedDistance(distance)
    }

    func openInMaps() {
        let coordinate = event.location.coordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = event.title
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ])
    }
}
