//
//  TCATodosApp.swift
//  TCATodos
//
//  Created by Oliver Le on 01/02/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCATodosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: AppState(
                        todos: [
                            Todo(
                                id: UUID(),
                                description: "Milk",
                                isComplete: false
                            ),
                            Todo(
                                id: UUID(),
                                description: "Eggs",
                                isComplete: false
                            ),
                            Todo(
                                id: UUID(),
                                description: "Hand Soap",
                                isComplete: true
                            ),
                        ]
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
