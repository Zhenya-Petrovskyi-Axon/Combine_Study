import Combine
import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!

var cancellables: Set<AnyCancellable> = []

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

let publisher = session.dataTaskPublisher(for: url)
    .print("Datatask")
    .assumeHTTP()
    .responseData()
    .decoding(type: Post.self, decoder: JSONDecoder())
    .replaceError(with: Post(id: 2, title: "Hello world", body: "No Body", userId: 0))
    .share()
    .makeConnectable()

print("Assigning #1...")
publisher.sink { post in
    print("---------------------------------------------------------------------------------------------")
    print("1) Post: \(post)")
    print("---------------------------------------------------------------------------------------------")
}
.store(in: &cancellables)

DispatchQueue.main.async {
    print("Assigning #2...")
    publisher.sink { post in
        print("---------------------------------------------------------------------------------------------")
        print("2) Post: \(post)")
        print("---------------------------------------------------------------------------------------------")
    }
    .store(in: &cancellables)
    
    publisher.connect()
        .store(in: &cancellables)
}
