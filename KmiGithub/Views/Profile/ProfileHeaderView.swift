//
//  ProfileHeaderView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct ProfileHeaderView: View {
    let user: GitHubUser

    var body: some View {
        VStack(spacing: 16) {
            AvatarImageView(url: user.avatarUrl, size: 80)

            VStack(spacing: 4) {
                if let name = user.name {
                    Text(name)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Text(user.login)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            HStack(spacing: 32) {
                statItem(
                    count: user.publicRepos ?? 0,
                    label: NSLocalizedString("profile.repos.count", comment: "")
                )
                statItem(
                    count: user.followers ?? 0,
                    label: NSLocalizedString("profile.followers", comment: "")
                )
                statItem(
                    count: user.following ?? 0,
                    label: NSLocalizedString("profile.following", comment: "")
                )
            }

            if let location = user.location, !location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(location)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func statItem(count: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
