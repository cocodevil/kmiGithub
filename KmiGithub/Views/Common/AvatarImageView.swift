//
//  AvatarImageView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI
import Kingfisher

struct AvatarImageView: View {
    let url: String
    var size: CGFloat = 40

    var body: some View {
        KFImage(URL(string: url))
            .placeholder {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: size * 0.4))
                    )
            }
            .resizable()
            .fade(duration: 0.25)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
