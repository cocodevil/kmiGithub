//
//  View+Extensions.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
