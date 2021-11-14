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

var simulatedErrors = 3

var cancellables: Set<AnyCancellable> = []

func fetchPosts() -> AnyPublisher<Post, HttpError> {
    session.dataTaskPublisher(for: url)
        .assumeHTTP() // OUTPUT is (DATA< HTTPURLRESPONSE)
    // Failure is HTTPError
        .simulateFakeRateLimit(when: {
            simulatedErrors -= 1
            return simulatedErrors > 0
        })
        .responseData()
        .decoding(type: Post.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

let publisher = fetchPosts()

publisher
    .print()
    .tryCatch({ error -> AnyPublisher<Post, HttpError> in
        if error.isRetriable {
            print("Retrying")
            return publisher.retry(2).eraseToAnyPublisher()
        } else {
            throw error
        }
    })
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0)}
    )
    .store(in: &cancellables)

extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HttpError {
    func simulateFakeRateLimit(when: @escaping () -> Bool) -> AnyPublisher<(data: Data, response: HTTPURLResponse), HttpError> {
        map { (data, response) in
            if when() {
                Swift.print("Simulating rate limit...")
                let newResponse = HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: nil)!
                return (data: data, response: newResponse)
            } else {
                Swift.print("No more Errors....")
                return (data: data, response: response)
            }
        }
        .eraseToAnyPublisher()
    }
}

