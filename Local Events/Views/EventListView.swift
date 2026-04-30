//
//  EventListView.swift
//  Local Events
//

import SwiftUI
import Models
import Core

struct EventListView: View {

    @ObservedObject var viewModel: EventListViewModel
    @EnvironmentObject private var factory: ViewModelFactory

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.events.isEmpty {
                    errorView(error)
                } else {
                    eventList
                }
            }
            .navigationTitle("Nearby Events")
            .searchable(text: $viewModel.searchText, prompt: "Search events")
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    categoryMenu
                }
            }
            .task {
                if viewModel.events.isEmpty {
                    await viewModel.loadEvents()
                }
            }
        }
    }

    // MARK: - Event List

    private var eventList: some View {
        List {
            ForEach(viewModel.filteredEvents) { event in
                NavigationLink {
                    EventDetailView(
                        viewModel: factory.createEventDetailViewModel(event: event)
                    )
                } label: {
                    EventRowView(
                        event: event,
                        distance: viewModel.formattedDistance(to: event),
                        onBookmarkTapped: {
                            viewModel.toggleBookmark(for: event)
                        }
                    )
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.filteredEvents.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            }
        }
    }

    // MARK: - Category Filter

    private var categoryMenu: some View {
        Menu {
            Button("All Categories") {
                viewModel.selectedCategory = nil
            }
            Divider()
            ForEach(EventCategory.allCases, id: \.self) { category in
                Button {
                    viewModel.selectedCategory = category
                } label: {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        } label: {
            Image(systemName: viewModel.selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Finding events near you...")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Events", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.loadEvents(forceRefresh: true) }
            }
            .buttonStyle(.bordered)
        }
    }
}
