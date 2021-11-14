import Combine
import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

let session = URLSession.shared

let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
// http.bin

func example() {
    var cancellable: AnyCancellable?
    cancellable = session.dataTaskPublisher(for: url)
    // OUTPUT = (data: Data, response: URLResponse)
    // FAILURE = URLError
        .print()
        .map { $0.data }
        .replaceError(with: Data())
        .map { String(data: $0, encoding: .utf8) }
        .sink { response in
            print("Response: \(response ?? "<no_body>")")
            cancellable = nil
            _ = cancellable
        }
}

enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case networkingError(URLError)
    
    var description: String {
        switch self {
        case .nonHTTPResponse: return "Wrong response"
        case .requestFailed(let status):
            return "Received HTTP status: \(status)"
        case .networkingError(let error):
            return "Received Networking error: \(error.localizedDescription)"
        }
    }
}

func fetchData() -> AnyPublisher<String?, HTTPError> {
    let url = URL(string: "https://httpbin.org/status/422")!
    return session.dataTaskPublisher(for: url)
        .mapError({ HTTPError.networkingError($0) })
        .print()
        .tryMap {
            guard let http = $0.response as? HTTPURLResponse else {
                throw HTTPError.nonHTTPResponse
            }
            guard http.statusCode == 200 else {
                throw HTTPError.requestFailed(http.statusCode)
            }
            return $0.data
        }
        .mapError { $0 as! HTTPError }
        .map { String(data: $0, encoding: .utf8) }
        .eraseToAnyPublisher()
}

//example()

print("Getting publisher...")

var cancellable = fetchData()
    .catch { (error: HTTPError) -> Just<String?> in
        print("😤 Error: \(error.description)")
        return Just(nil)
    }
    .sink {
        if let body = $0 {
            print(body)
        }
    }

