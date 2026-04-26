//
//  ThemeSelectorView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct ThemeSelectorView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HStack {
            Image(systemName: store.state.theme.iconName)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            Text(NSLocalizedString("settings.theme", comment: ""))

            Spacer()

            Menu {
                ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                    Button {
                        store.dispatch(.setTheme(theme))
                    } label: {
                        Label {
                            Text(theme.displayName)
                        } icon: {
                            if store.state.theme == theme {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(store.state.theme.displayName)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
