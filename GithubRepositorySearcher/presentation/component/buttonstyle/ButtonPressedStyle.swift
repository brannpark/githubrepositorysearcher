//
//  ButtonPressedStyle.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/02.
//

import SwiftUI

struct ButtonPressedStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .opacity(configuration.isPressed ? 0.65 : 1.0)
            .scaleEffect(configuration.isPressed ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
