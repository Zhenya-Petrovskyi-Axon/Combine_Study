import Combine
import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!

struct Post: Codable {
    let id: Int?
    let title: String?
    let body: String?
    let userID: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, body
        case userID = "userId"
    }
}

var cancellables: Set<AnyCancellable> = []

session.dataTaskPublisher(for: url)
    .map { $0.data }
    .decode(type: Post.self, decoder: JSONDecoder())
    .sink { completion in
        print("Completion: \(completion)")
    } receiveValue: { data in
        print("Data: \(data.title)'")
    }
    .store(in: &cancellables)

// MARK: How it works under the hood in foundation
//extension Publisher where Output == Data {
//    func decode2<Item, Coder>(type: Item.Type, decoder: Coder) -> Publishers.Decode<Self, Item, Coder> where Item: Decodable, coder: TopLevelDecoder, Self.Output == Coder.Input
//}
