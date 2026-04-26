//
//  LanguageBadgeView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct LanguageBadgeView: View {
    let language: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colorForLanguage(language))
                .frame(width: 10, height: 10)

            Text(language)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func colorForLanguage(_ language: String) -> Color {
        switch language.lowercased() {
        case "swift": return .orange
        case "objective-c": return Color(red: 0.26, green: 0.53, blue: 1.0)
        case "python": return Color(red: 0.21, green: 0.45, blue: 0.66)
        case "javascript": return .yellow
        case "typescript": return Color(red: 0.18, green: 0.46, blue: 0.82)
        case "java": return Color(red: 0.69, green: 0.44, blue: 0.07)
        case "kotlin": return Color(red: 0.66, green: 0.33, blue: 0.97)
        case "go": return Color(red: 0.0, green: 0.68, blue: 0.84)
        case "rust": return Color(red: 0.87, green: 0.42, blue: 0.21)
        case "c++", "cpp": return Color(red: 0.96, green: 0.29, blue: 0.57)
        case "c": return Color(red: 0.33, green: 0.33, blue: 0.33)
        case "c#": return Color(red: 0.1, green: 0.54, blue: 0.0)
        case "ruby": return .red
        case "php": return Color(red: 0.30, green: 0.37, blue: 0.62)
        case "html": return Color(red: 0.89, green: 0.30, blue: 0.15)
        case "css": return Color(red: 0.34, green: 0.24, blue: 0.77)
        case "shell", "bash": return .green
        case "dart": return Color(red: 0.0, green: 0.71, blue: 0.82)
        default: return .gray
        }
    }
}
