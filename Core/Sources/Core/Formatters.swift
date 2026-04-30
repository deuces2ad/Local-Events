//
//  Formatters.swift
//  Core
//

import Foundation
import CoreLocation

public enum Formatters {

    // MARK: - Distance

    public static func formattedDistance(_ meters: CLLocationDistance?) -> String {
        guard let meters else { return "—" }
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.1f km", meters / 1000)
        }
    }

    // MARK: - Date / Time

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    private static let eventDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d 'at' h:mm a"
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .short
        return f
    }()

    public static func relativeTime(from date: Date) -> String {
        let now = Date()
        if date > now {
            return relativeDateFormatter.localizedString(for: date, relativeTo: now)
        } else {
            return "Now"
        }
    }

    public static func eventDate(_ date: Date) -> String {
        eventDateFormatter.string(from: date)
    }

    public static func fullDate(_ date: Date) -> String {
        fullDateFormatter.string(from: date)
    }
}
