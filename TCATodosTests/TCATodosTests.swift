//
//  TCATodosTests.swift
//  TCATodosTests
//
//  Created by Oliver Le on 01/02/2023.
//
import ComposableArchitecture
import XCTest
@testable import TCATodos

@MainActor
final class TCATodosTests: XCTestCase {
    let scheduler = DispatchQueue.test

    func testCompletingTodo() async {
        let store = TestStore(
            initialState: AppReducer.State(
                todos: [
                    Todo.State(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    )
                ]
            ),
            reducer: AppReducer(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("Unimplemented") }
            )
        )
        
        await store.send(.todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
        }
        await scheduler.advance(by: 1)
        await store.receive(.todoDelayCompleted)
    }

    func testAddTodo() async {
        let store = TestStore(
            initialState: AppReducer.State(todos: []),
            reducer: AppReducer(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! }
            )
        )
        
        await store.send(.addButtonTapped) {
            $0.todos = [
                Todo.State(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                    description: "",
                    isComplete: false
                )
            ]
        }
    }

    func testTodoSorting() async {
        let store = TestStore(
            initialState: AppReducer.State(
                todos: [
                    Todo.State(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    ),
                    Todo.State(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    ),
                ]
            ),
            reducer: AppReducer(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("Unimplemented") }
            )
        )
        
        await store.send(.todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
        }
        await scheduler.advance(by: 1)
        await store.receive(.todoDelayCompleted) {
            $0.todos = [
                Todo.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description: "Eggs",
                    isComplete: false
                ),
                Todo.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description: "Milk",
                    isComplete: true
                ),
            ]
        }
    }

    func testTodoSorting_Cancellation() async {
        let store = TestStore(
            initialState: AppReducer.State(
                todos: [
                    Todo.State(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    ),
                    Todo.State(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    ),
                ]
            ),
            reducer: AppReducer(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("Unimplemented") }
            )
        )

        await store.send(.todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
        }
        await scheduler.advance(by: 0.5)
        await store.send(.todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .checkboxTapped)) {
            $0.todos[0].isComplete = false
        }
        await self.scheduler.advance(by: 1)
        await store.receive(.todoDelayCompleted)
    }
}
