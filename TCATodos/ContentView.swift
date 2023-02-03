//
//  ContentView.swift
//  TCATodos
//
//  Created by Oliver Le on 01/02/2023.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct Todo: Equatable, Identifiable {
    let id: UUID
    var description = ""
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {
}

let todoReducer = AnyReducer<Todo, TodoAction, TodoEnvironment>{ state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable{
    var todos: [Todo]
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
    case todoDelayCompleted
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}


let appReducer = AnyReducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    AnyReducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
            
        case .todo(index: _, action: .checkboxTapped):
            struct CancelDelayId: Hashable {}
            
            return Effect(value: AppAction.todoDelayCompleted)
                .debounce(id: CancelDelayId(), for: .seconds(1), scheduler: environment.mainQueue)
            
        case .todo(index: let index, action: let action):
            return .none
        case .todoDelayCompleted:
            state.todos = state.todos
                .enumerated()
                .sorted { lhs, rhs in
                    (!lhs.element.isComplete && rhs.element.isComplete)
                    || lhs.offset < rhs.offset
                }
                .map(\.element)
            return .none
        }
    }
)
.debug()


struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
                        content: TodoView.init(store:)
                    )
                }
                .navigationTitle(Text("Todos"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            viewStore.send(.addButtonTapped)
                        }
                    }
                }
            }
        }
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square": "square")
                }
                .buttonStyle(.plain)
                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
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
