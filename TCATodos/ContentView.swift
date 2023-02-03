//
//  ContentView.swift
//  TCATodos
//
//  Created by Oliver Le on 01/02/2023.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct Todo: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var description = ""
        var isComplete = false
    }
    
    enum Action: Equatable {
        case checkboxTapped
        case textFieldChanged(String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .checkboxTapped:
            state.isComplete.toggle()
            return .none
        case .textFieldChanged(let text):
            state.description = text
            return .none
        }
    }
}


struct AppReducer: ReducerProtocol {
    struct State: Equatable{
        var todos: IdentifiedArrayOf<Todo.State>
    }
    
    enum Action: Equatable {
        case addButtonTapped
        case todo(id: Todo.State.ID, action: Todo.Action)
        case todoDelayCompleted
    }
   
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.todos.insert(Todo.State(id: uuid()), at: 0)
                return .none
                
            case .todo(id: _, action: .checkboxTapped):
                struct CancelDelayId: Hashable {}
                
                return EffectTask(value: .todoDelayCompleted)
                    .debounce(id: CancelDelayId(), for: .seconds(1), scheduler: mainQueue)
                
            case .todo(id: _, action: _):
                return .none
                
            case .todoDelayCompleted:
                state.todos
                    .sort { !$0.isComplete && $1.isComplete }
                return .none
            }
        }
        .forEach(\.todos, action: /Action.todo) {
            Todo()
        }
    }
}

struct ContentView: View {
    let store: StoreOf<AppReducer>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.todos, action: AppReducer.Action.todo(id:action:)),
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
    let store: StoreOf<Todo>
    
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
                        send: Todo.Action.textFieldChanged
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
