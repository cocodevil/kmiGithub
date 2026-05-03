//
//  RepositoryDetailView.swift
//  KmiGithub
//
//  Created by Codex on 2026/5/3.
//

import SwiftUI

struct RepositoryDetailView: View {
    let repository: Repository

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        AvatarImageView(url: repository.owner.avatarUrl, size: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(repository.fullName)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(repository.owner.login)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let description = repository.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    if let url = URL(string: repository.htmlUrl) {
                        Link(destination: url) {
                            Label(NSLocalizedString("repo.detail.open.github", comment: ""), systemImage: "safari")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section(header: Text(NSLocalizedString("repo.detail.stats", comment: ""))) {
                StatRow(
                    icon: "star.fill",
                    title: NSLocalizedString("repo.detail.stars", comment: ""),
                    value: formatCount(repository.stargazersCount),
                    iconColor: .yellow
                )

                StatRow(
                    icon: "eye",
                    title: NSLocalizedString("repo.detail.watchers", comment: ""),
                    value: formatCount(repository.watchersCount),
                    iconColor: .blue
                )

                StatRow(
                    icon: "tuningfork",
                    title: NSLocalizedString("repo.detail.forks", comment: ""),
                    value: formatCount(repository.forksCount),
                    iconColor: .secondary
                )

                StatRow(
                    icon: "exclamationmark.circle",
                    title: NSLocalizedString("repo.detail.issues", comment: ""),
                    value: formatCount(repository.openIssuesCount),
                    iconColor: .orange
                )
            }

            Section(header: Text(NSLocalizedString("repo.detail.info", comment: ""))) {
                if let language = repository.language {
                    HStack {
                        Text(NSLocalizedString("repo.detail.language", comment: ""))
                        Spacer()
                        LanguageBadgeView(language: language)
                    }
                }

                if let defaultBranch = repository.defaultBranch {
                    InfoRow(
                        title: NSLocalizedString("repo.detail.default.branch", comment: ""),
                        value: defaultBranch
                    )
                }

                InfoRow(
                    title: NSLocalizedString("repo.detail.type", comment: ""),
                    value: repository.fork
                        ? NSLocalizedString("repo.detail.type.fork", comment: "")
                        : NSLocalizedString("repo.detail.type.source", comment: "")
                )

                if let updatedAt = formattedDate(repository.updatedAt) {
                    InfoRow(
                        title: NSLocalizedString("repo.detail.updated", comment: ""),
                        value: updatedAt
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(repository.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fm", Double(count) / 1_000_000.0)
        }

        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }

        return "\(count)"
    }

    private func formattedDate(_ value: String?) -> String? {
        guard let value else { return nil }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let date = isoFormatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
        guard let date else { return nil }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(iconColor)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(.secondary)
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
