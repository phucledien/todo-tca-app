//
//  TCATodosTests.swift
//  TCATodosTests
//
//  Created by Oliver Le on 01/02/2023.
//
import ComposableArchitecture
import XCTest
@testable import TCATodos

final class TCATodosTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler
    
    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("Unimplemented") }
            )
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    }
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(todos: []),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! }
            )
        )
        
        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [
                    Todo(
                        id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                        description: "",
                        isComplete: false
                    )
                ]
            }
        )
    }
    
    func testTodoSorting() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    ),
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    ),
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("Unimplemented") }
            )
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted) {
                $0.todos = [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    ),
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: true
                    ),
                ]
            }
        )
    }
    
    func testTodoSorting_Cancellation() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    ),
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    ),
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("Unimplemented") }
            )
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 0.5)
            },
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = false
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    }
}
