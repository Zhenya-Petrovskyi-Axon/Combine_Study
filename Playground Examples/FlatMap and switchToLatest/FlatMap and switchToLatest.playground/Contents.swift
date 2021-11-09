import Combine
import PlaygroundSupport
import Foundation

#warning("MARK: - faltMap and switchToLatest operates on streams that themselfs produce new publishers")

PlaygroundPage.current.needsIndefiniteExecution = true

let urls = [
    "https://combineswift.com",
    "https://apple.com",
    "https://twitter.com"
].compactMap { URL(string: $0) }

var cancellables: Set<AnyCancellable> = []

func exampleFlatMap() {
    urls.publisher
        .print("URL")
        .flatMap(maxPublishers: .max(2)) { // <-- So the flat  map takes urls and produce publishers form it and now we are taking 2 at a time as a max count parameter of netowrk calls data to receive, as soon as call gets callback, the slot will be available again and publisher will receive another URL and so on, untill it will be finished to receive URL's as they are out of stock in array.
            URLSession.shared.dataTaskPublisher(for: $0)
                .assertNoFailure() // <-- So dataTask wont produce any errors, in this case it will just crash
        }
        .print("Flat Map")
        .sink { data, response in
            print("Receives \(data.count) bytes from source \(response.url!)") // <-- it is ok for now to force unwrap
        }.store(in: &cancellables)
}

exampleFlatMap()

func exampleSwitchToLatest() {
    urls.publisher
        .print("URL")
        .map {
            URLSession.shared.dataTaskPublisher(for: $0)
                .assertNoFailure()// <-- So dataTask wont produce any errors, in this case it will just crash
                .print("Fetch: \($0)") // <-- Thios print is showing that as soon as publisher gets subscription it will cancel all the privious once, cause again switch to latest cares only about the last publisher
            /*
             example of using switch to latest is if user is touching a button, but that he is changing mind and taping another one -> what will happen with swutch to latest -> it will cancel subscription, cause a new publisher comes in place
             */
        }
        .switchToLatest() // <-- Cares aboyr only the last value received and subscribes on it
        .print("Switch to latest")
        .sink { data, response in
            print("Receives \(data.count) bytes from source \(response.url!)") // <-- it is ok for now to force unwrap
        }.store(in: &cancellables)
}
