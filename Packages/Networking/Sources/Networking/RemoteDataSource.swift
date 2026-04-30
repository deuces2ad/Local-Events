//
//  RemoteDataSource.swift
//  Networking
//

import Foundation
import Models

public protocol RemoteDataSourceProtocol {
    func fetchEvents() async throws -> [Event]
}

public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
    case serverError(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .decodingFailed(let error): return "Decoding failed: \(error.localizedDescription)"
        case .serverError(let code): return "Server error: \(code)"
        }
    }
}

// MARK: - Mock Implementation

public final class RemoteDataSource: RemoteDataSourceProtocol {

    public init() {}

    public func fetchEvents() async throws -> [Event] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return Self.mockEvents
    }

    private static let mockEvents: [Event] = {
        let now = Date()
        let cal = Calendar.current

        return [
            Event(id: "1", title: "Jazz in the Park", description: "Live jazz evening at the park",
                  location: EventLocation(latitude: 37.7749, longitude: -122.4194, address: "Golden Gate Park, SF"),
                  time: cal.date(byAdding: .hour, value: 3, to: now)!, imageUrl: "https://picsum.photos/seed/jazz/800/600", category: .music),

            Event(id: "2", title: "Street Food Festival", description: "50+ food trucks and live demos",
                  location: EventLocation(latitude: 37.7849, longitude: -122.4094, address: "Ferry Building, SF"),
                  time: cal.date(byAdding: .hour, value: 5, to: now)!, imageUrl: "https://picsum.photos/seed/food/800/600", category: .food),

            Event(id: "3", title: "Modern Art Exhibition", description: "Paintings and sculptures by local artists",
                  location: EventLocation(latitude: 37.7859, longitude: -122.4009, address: "SFMOMA, SF"),
                  time: cal.date(byAdding: .day, value: 1, to: now)!, imageUrl: "https://picsum.photos/seed/art/800/600", category: .arts),

            Event(id: "4", title: "5K Charity Run", description: "Waterfront run for youth programs",
                  location: EventLocation(latitude: 37.8070, longitude: -122.4190, address: "Crissy Field, SF"),
                  time: cal.date(byAdding: .hour, value: 18, to: now)!, imageUrl: "https://picsum.photos/seed/run/800/600", category: .sports),

            Event(id: "5", title: "SwiftUI Meetup", description: "Talks and workshops on SwiftUI",
                  location: EventLocation(latitude: 37.7879, longitude: -122.3964, address: "Moscone Center, SF"),
                  time: cal.date(byAdding: .day, value: 2, to: now)!, imageUrl: "https://picsum.photos/seed/tech/800/600", category: .technology),

            Event(id: "6", title: "Sunset Kayaking", description: "Guided coastal paddle at sunset",
                  location: EventLocation(latitude: 37.8085, longitude: -122.4776, address: "Aquatic Park, SF"),
                  time: cal.date(byAdding: .hour, value: 28, to: now)!, imageUrl: "https://picsum.photos/seed/kayak/800/600", category: .outdoor),
        ]
    }()
}
