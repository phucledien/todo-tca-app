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
                    initialState: AppReducer.State(
                        todos: [
                            Todo.State(
                                id: UUID(),
                                description: "Milk",
                                isComplete: false
                            ),
                            Todo.State(
                                id: UUID(),
                                description: "Eggs",
                                isComplete: false
                            ),
                            Todo.State(
                                id: UUID(),
                                description: "Hand Soap",
                                isComplete: true
                            ),
                        ]
                    ),
                    reducer: AppReducer()
                ) {
                    $0.mainQueue = DispatchQueue.main.eraseToAnyScheduler()
                    $0.uuid = UUIDGenerator { UUID() }
                }
            )
        }
    }
}
