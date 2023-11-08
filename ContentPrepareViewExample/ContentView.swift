//
//  ContentView.swift
//  ContentPrepareViewExample
//
//  Created by Toomas Vahter on 08.11.2023.
//

import SwiftUI

struct ContentView: View {
  // Demo: first load leads to an error
  @State private var showsError = true

  var body: some View {
    ContentPrepareView {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Hello, world!")
      }
      .padding()
    } task: {
      try await Task.sleep(nanoseconds: 2_000_000_000)
      // Demo: Retrying a task leads to success
      guard showsError else { return }
      showsError = false
      throw LoadingError.example
    }
  }
}

enum LoadingError: LocalizedError {
  case example

  var errorDescription: String? {
    "The connection to Internet is unavailable"
  }
}

#Preview {
  ContentView()
}
