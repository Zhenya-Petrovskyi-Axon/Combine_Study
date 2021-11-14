import Foundation
import Combine

class ToDo: Equatable, Hashable, CustomStringConvertible {
    var id = UUID()
    var text: String
    var completed = false
    
    init(text: String) {
        self.text = text
    }
    
    var description: String {
        text + (completed ? "👌" : "🖕")
    }
    
    static func ==(lhs: ToDo, rhs: ToDo) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class ToDoStore: ObservableObject {
    private(set) var todos: [ToDo] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    
    init() {
        // load from disk etc
    }
    
    func add(_ todo: ToDo) {
        todos.append(todo)
    }
    
    func remove(_ todo: ToDo) {
        guard let index = todos.firstIndex(of: todo) else { return }
        todos.remove(at: index)
    }
    
    func completeToDo() {
        todo.completed = true
        objectWillChange.send()
    }
}

class Today {
    let store: ToDoStore
    
    var cancellables: Set<AnyCancellable> = []
    
    init(store: ToDoStore) {
        self.store = store
        store.objectWillChange.sink { [unowned self] in printTodos(store.todos) }
        .store(in: &cancellables)
        
    }
    
    func printTodos(_ todos: [ToDo]) {
        print(todos)
    }
}

let store = ToDoStore()

let today = Today(store: store)

store.add(ToDo(text: "I wanna record a video"))
store.add(ToDo(text: "I need to visit a doctor"))
store.add(ToDo(text: "I need some beers"))

let todo = ToDo(text: "Buy some milk")
store.add(todo)
store.completeToDo()

