//
//  RepositoryRowView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct RepositoryRowView: View {
    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                AvatarImageView(url: repository.owner.avatarUrl, size: 24)

                Text(repository.fullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 16) {
                if let language = repository.language {
                    LanguageBadgeView(language: language)
                }

                Label {
                    Text(formatCount(repository.stargazersCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }

                Label {
                    Text(formatCount(repository.forksCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "tuningfork")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
}
