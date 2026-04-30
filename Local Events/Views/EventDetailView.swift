//
//  EventDetailView.swift
//  Local Events
//

import SwiftUI
import MapKit
import Models
import Core

struct EventDetailView: View {

    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                detailContent
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                bookmarkButton
            }
        }
    }

    private var heroImage: some View {
        CachedAsyncImage(urlString: viewModel.event.imageUrl)
            .frame(height: 280)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    categoryBadge
                    Text(viewModel.event.title)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
                .padding()
            }
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Quick info row
            HStack(spacing: 20) {
                infoChip(icon: "clock", text: Formatters.relativeTime(from: viewModel.event.time))
                infoChip(icon: "location", text: viewModel.formattedDistance)
            }

            Divider()

            // Date & Time
            VStack(alignment: .leading, spacing: 6) {
                Text("Date & Time")
                    .font(.headline)
                Text(Formatters.fullDate(viewModel.event.time))
                    .foregroundStyle(.secondary)
            }

            // Address & Map
            VStack(alignment: .leading, spacing: 6) {
                Text("Location")
                    .font(.headline)
                Text(viewModel.event.location.address)
                    .foregroundStyle(.secondary)

                // Mini map
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: viewModel.event.location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ))) {
                    Marker(viewModel.event.title, coordinate: viewModel.event.location.coordinate)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(true)

                Button {
                    viewModel.openInMaps()
                } label: {
                    Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }

            Divider()

            // Description
            VStack(alignment: .leading, spacing: 6) {
                Text("About")
                    .font(.headline)
                Text(viewModel.event.description)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
    }

    // MARK: - Components

    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.event.category.systemImage)
            Text(viewModel.event.category.rawValue)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func infoChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
            Text(text)
                .font(.subheadline.weight(.medium))
        }
    }

    private var bookmarkButton: some View {
        Button {
            viewModel.toggleBookmark()
        } label: {
            Image(systemName: viewModel.event.isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundStyle(viewModel.event.isBookmarked ? .orange : .primary)
        }
    }
}
