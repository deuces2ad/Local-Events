//
//  BookmarksView.swift
//  Local Events
//

import SwiftUI
import Models
import Core

struct BookmarksView: View {

    @ObservedObject
    var viewModel: BookmarksViewModel
    @EnvironmentObject
    private var factory: ViewModelFactory

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.bookmarkedEvents.isEmpty {
                    emptyView
                } else {
                    bookmarkList
                }
            }
            .navigationTitle("Bookmarks")
            .onAppear {
                viewModel.loadBookmarks()
            }
        }
    }

    private var bookmarkList: some View {
        List {
            ForEach(viewModel.bookmarkedEvents) { event in
                NavigationLink {
                    EventDetailView(
                        viewModel: factory.createEventDetailViewModel(event: event)
                    )
                } label: {
                    EventRowView(
                        event: event,
                        distance: viewModel.formattedDistance(to: event),
                        onBookmarkTapped: {
                            viewModel.removeBookmark(for: event)
                        }
                    )
                }
            }
            .onDelete { offsets in
                let eventsToRemove = offsets.map { viewModel.bookmarkedEvents[$0] }
                for event in eventsToRemove {
                    viewModel.removeBookmark(for: event)
                }
            }
        }
        .listStyle(.plain)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Bookmarks Yet",
            systemImage: "bookmark",
            description: Text("Events you bookmark will appear here.")
        )
    }
}
