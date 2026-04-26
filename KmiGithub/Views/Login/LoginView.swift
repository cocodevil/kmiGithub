//
//  LoginView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            headerSection

            Spacer()

            buttonSection

            Spacer()
                .frame(height: 60)
        }
        .padding(.horizontal, 32)
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.store = store
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 64))
                .foregroundColor(.primary)

            Text("KmiGithub")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(NSLocalizedString("login.subtitle", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 16) {
            Button {
                viewModel.loginWithGitHub()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                    Text(NSLocalizedString("login.github", comment: ""))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.label))
                .foregroundColor(Color(.systemBackground))
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)

            if viewModel.canUseBiometric {
                Button {
                    viewModel.loginWithBiometric()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: biometricIcon)
                        Text(String(format: NSLocalizedString("login.biometric", comment: ""), viewModel.biometricName))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundColor(Color.accentColor)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
            }

            Button {
                viewModel.skipLogin()
            } label: {
                Text(NSLocalizedString("login.skip", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)

            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 8)
            }
        }
    }

    private var biometricIcon: String {
        BiometricService.biometricType == .faceID ? "faceid" : "touchid"
    }
}
