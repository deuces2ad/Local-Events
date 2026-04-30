//
//  CachedAsyncImage.swift
//  Local Events
//
//

import SwiftUI
import Core

struct CachedAsyncImage: View {

    let urlString: String
    @State
    private var image: UIImage?
    @State
    private var isLoading = true

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        ProgressView()
                    }
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .task(id: urlString) {
            isLoading = true
            image = await ImageCacheService.shared.image(for: urlString)
            isLoading = false
        }
    }
}
