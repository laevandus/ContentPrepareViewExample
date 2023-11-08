//
//  OnLoadViewModifier.swift
//  ContentPrepareViewExample
//
//  Created by Toomas Vahter on 08.11.2023.
//

import SwiftUI

struct OnLoadViewModifier: ViewModifier {
    @State var hasPrepared = false
    @State var task: Task<Void, Never>?
    let action: (() async -> Void)
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasPrepared else { return }
                guard task == nil else { return }
                task = Task {
                    await action()
                    hasPrepared = true
                }
            }
            .onDisappear {
                task?.cancel()
                task = nil
            }
    }
}

public extension View {
    func onLoad(perform action: @escaping () async -> Void) -> some View {
        modifier(OnLoadViewModifier(action: action))
    }
}
