import Combine
import UIKit
import PlaygroundSupport

func example(_ title: String, completion: () -> Void) {
    print("--------------------\(title)----------------")
    completion()
    print("--------------------Completed \(title)----------------")
}

example("MAP") {
    [1, 2, 3, 5, 8, 13].publisher
        .map { $0 * 10 }
        .sink { value in
            print(value)
        }
}

example("Map") {
    [1, 2, 3].publisher
        .map { value in
            String("and-a \(value)")
        }
        .sink { print($0)}
}

example("Filter") {
    _ = [1, 2, 3, 5, 8, 13].publisher
        .map { $0 * 10 }
    // filter will work only with previous operator map with its values
        .filter { $0 < 60 }
        .sink { completion in
            print(completion)
        } receiveValue: { value in
            print(value)
        }
    
}

// Produces accumulated value over time
example("Scan") {
    _ = ["a", "b", "c"].publisher
        .scan("", { (accumulated, char) -> String in
            accumulated + char
        })
        .sink { print($0) }
}

example("Indepth Scan") {
    let grades: [Double] = [12, 34, 65, 99, 103, 1005]
    grades.publisher
        .scan((avg: 0.0, sum: 0.0, count: 0.0)) { (tuple, grade) in
            let newSum = tuple.sum + grade
            let count = tuple.count + 1
            let newAvg = newSum / Double(count)
            return (avg: newAvg, sum: newSum, count: count)
        }
        .map { $0.avg }
        .sink { print($0) }
}

example("Another Indepth Scan example") {
    PlaygroundPage.current.needsIndefiniteExecution = true
    var cancallable: AnyCancellable? =
    Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .scan(0) { count, _ in
            count + 1
        }
        .sink { print($0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        cancallable = nil
        PlaygroundPage.current.needsIndefiniteExecution = false
    }
}

example("[Remove Duplicates]") {
    // It is removing duplicates only in a last sequence char
    _ = [1,1,1,1,1,1,2,3,4,4,5,5,4,4,1,1].publisher
        .removeDuplicates()
        .sink { print($0) }
}

example("[Compact Map]") {
    let values: [Int?] = [1, nil, 3, nil, 8, nil, 10001]
    _ = values.publisher
    // if compact map can return a value -> it will return, otherwise it will just ignore
        .compactMap({ $0 })
        .sink { print($0) }
}

example("[Compact Map -> 2]") {
    let values: [String] = ["1", "grovie", "3", "4"]
    _ = values.publisher
        .compactMap { Int($0) }
        .sink { print($0) }
}
