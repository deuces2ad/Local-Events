//
//  Event.swift
//  Models
//

import Foundation
import CoreLocation

// MARK: - Event Location

public struct EventLocation: Codable, Equatable, Hashable {
    public let latitude: Double
    public let longitude: Double
    public let address: String

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    public init(latitude: Double, longitude: Double, address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}

// MARK: - Event

public struct Event: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let location: EventLocation
    public let time: Date
    public let imageUrl: String
    public let category: EventCategory
    public var isBookmarked: Bool

    public init(
        id: String,
        title: String,
        description: String,
        location: EventLocation,
        time: Date,
        imageUrl: String,
        category: EventCategory,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
        self.time = time
        self.imageUrl = imageUrl
        self.category = category
        self.isBookmarked = isBookmarked
    }
}

// MARK: - Event Category

public enum EventCategory: String, Codable, CaseIterable {
    case music = "Music"
    case food = "Food & Drink"
    case arts = "Arts & Culture"
    case sports = "Sports"
    case technology = "Technology"
    case community = "Community"
    case outdoor = "Outdoor"
    case nightlife = "Nightlife"

    public var systemImage: String {
        switch self {
        case .music: return "music.note"
        case .food: return "fork.knife"
        case .arts: return "paintpalette"
        case .sports: return "sportscourt"
        case .technology: return "laptopcomputer"
        case .community: return "person.3"
        case .outdoor: return "leaf"
        case .nightlife: return "moon.stars"
        }
    }
}
