//
//  EventRowView.swift
//  Local Events
//

import SwiftUI
import Models
import Core

struct EventRowView: View {

    let event: Event
    let distance: String
    let onBookmarkTapped: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            CachedAsyncImage(urlString: event.imageUrl)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: event.category.systemImage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(event.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Label(Formatters.relativeTime(from: event.time), systemImage: "clock")
                    Label(distance, systemImage: "location")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Bookmark button
            Button(action: onBookmarkTapped) {
                Image(systemName: event.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundStyle(event.isBookmarked ? .orange : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
