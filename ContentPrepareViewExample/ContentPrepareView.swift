//
//  ContentPrepareView.swift
//  ContentPrepareViewExample
//
//  Created by Toomas Vahter on 08.11.2023.
//

import SwiftUI

struct ContentPrepareView<Content, Failure, Loading>: View where Content: View, Failure: View, Loading: View {
  @State private var viewContent: ViewContent = .loading

  @ViewBuilder let content: () -> Content
  @ViewBuilder let failure: (Error, @escaping () async -> Void) -> Failure
  @ViewBuilder let loading: () -> Loading
  let task: () async throws -> Void

  init(content: @escaping () -> Content,
       failure: @escaping (Error, @escaping () async -> Void) -> Failure = { FailureView(error: $0, retryTask: $1) },
       loading: @escaping () -> Loading = { ProgressView() },
       task: @escaping () async throws -> Void) {
    self.content = content
    self.failure = failure
    self.loading = loading
    self.task = task
  }

  var body: some View {
    Group {
      switch viewContent {
      case .content:
        content()
      case .failure(let error):
        failure(error, loadTask)
      case .loading:
        loading()
      }
    }
    .onLoad(perform: loadTask)
  }

  @MainActor func loadTask() async {
    do {
      viewContent = .loading
      try await task()
      viewContent = .content
    }
    catch {
      viewContent = .failure(error)
    }
  }
}

extension ContentPrepareView {
  enum ViewContent {
    case loading
    case content
    case failure(Error)
  }
}

struct FailureView: View {
  let error: Error
  let retryTask: () async -> Void

  var body: some View {
    ContentUnavailableView(label: {
      Label("Failed to load", systemImage: "exclamationmark.circle.fill")
    }, description: {
      Text(error.localizedDescription)
    }, actions: {
      Button(action: {
        Task { await retryTask() }
      }, label: {
        Text("Retry")
      })
    })
  }
}


#Preview {
  ContentPrepareView(content: {
    Text("Main Content")
  }, task: {
    // Simulate async loading
    try await Task.sleep(nanoseconds: 1_000_000_000)
  })
}
