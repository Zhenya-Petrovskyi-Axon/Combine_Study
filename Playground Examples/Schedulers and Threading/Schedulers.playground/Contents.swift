import Combine
import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

/*
 Schedulers
 - Threads and Queues
 - GCD / DispatchQueue
 - Operations
 - RunLoop
 */

Timer.publish(every: 0.5, on: .main, in: .default)

Just(1).delay(for: .seconds(0.5), scheduler: OperationQueue.main)
Just(1).delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
Just(1).delay(for: .seconds(0.5), scheduler: RunLoop.main)

Just(1)
    .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)

Just(2)
    .sink { _ in
        print(Thread.current)
        print(Thread.isMainThread)
    }

DispatchQueue.global().async {
    Just(2)
        .sink { _ in
            print(Thread.current)
            print(Thread.isMainThread)
        }
}

let session = URLSession.shared

let c = session.dataTaskPublisher(for: URL(string: "https://httpbin.org")!)
    .assertNoFailure()
    .sink { _ in
        print(Thread.current)
        print(Thread.isMainThread)
    }
