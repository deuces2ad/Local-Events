//
//  EventRepository.swift
//  Core
//

import Foundation
import CoreData.NSManagedObjectContext
import Models
import Networking

// MARK: - Protocol

public protocol EventRepository {
    func getEvents(forceRefresh: Bool) async throws -> [Event]
    func getBookmarkedEvents() -> [Event]
    func addBookmark(eventId: String) -> Bool
    func removeBookmark(eventId: String) -> Bool
}


public final class EventRepositoryImplementation: EventRepository {

    // Core data instance to be init here
    private let remoteDataSource: RemoteDataSourceProtocol

    /// In-memory cache (temporary until Core Data is implemented)
    private var cachedEvents: [Event] = []
    private let cacheTTL: TimeInterval
    private var lastFetchDate: Date?

    public init(
        remoteDataSource: RemoteDataSourceProtocol,
        cacheTTL: TimeInterval = 10 * 60
    ) {
        self.remoteDataSource = remoteDataSource
        self.cacheTTL = cacheTTL
    }

    public func getEvents(forceRefresh: Bool = false) async throws -> [Event] {

        // Check in-memory cache
        let cacheIsValid: Bool = {
            guard !forceRefresh else { return false }
            guard !cachedEvents.isEmpty else { return false }
            guard let lastFetchDate else { return false }
            return Date().timeIntervalSince(lastFetchDate) < self.cacheTTL
        }()

        if cacheIsValid {
            return cachedEvents
        }

        // Fetch from remote
        do {
            let remoteEvents = try await remoteDataSource.fetchEvents()

            // For now, just store in memory
            mergeAndCache(remoteEvents)
            lastFetchDate = Date()
            return cachedEvents
        } catch {
            // Offline fallback
            if !cachedEvents.isEmpty {
                return cachedEvents
            }
            throw error
        }
    }

    public func getBookmarkedEvents() -> [Event] {
        return cachedEvents.filter { $0.isBookmarked }
    }

    public func addBookmark(eventId: String) -> Bool {
        return updateBookmark(eventId: eventId, isBookmarked: true)
    }

    public func removeBookmark(eventId: String) -> Bool {
        return updateBookmark(eventId: eventId, isBookmarked: false)
    }

    // MARK: - Private Helpers

    private func updateBookmark(eventId: String, isBookmarked: Bool) -> Bool {
        guard let index = cachedEvents.firstIndex(where: { $0.id == eventId }) else {
            print("No event found with id \(eventId)")
            return false
        }
        cachedEvents[index].isBookmarked = isBookmarked
        return true
    }

    private func mergeAndCache(_ remoteEvents: [Event]) {
        // Preserve existing bookmark state when refreshing
        let bookmarkedIds = Set(cachedEvents.filter { $0.isBookmarked }.map { $0.id })
        cachedEvents = remoteEvents.map { event in
            var merged = event
            if bookmarkedIds.contains(event.id) {
                merged.isBookmarked = true
            }
            return merged
        }
    }

    // MARK: - Core Data Stubs (TODO)

     private func fetchEventsFromCoreData() -> [Event] {
         []
     }

     private func saveEventsToCoreData(_ events: [Event]) {
         //TODO: delete old events, insert new, preserve bookmarks, save context
     }

     private func getLastUpdated(forKey key: String) -> Date? {
        nil
     }

     private func setLastUpdated(_ date: Date, forKey key: String) {
        //
     }
}
