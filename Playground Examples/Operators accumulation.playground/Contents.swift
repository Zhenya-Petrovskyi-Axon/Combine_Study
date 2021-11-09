import Combine
import PlaygroundSupport

// MARK: ALL of this operators will sit and wait for completion to collect data and then produce curtain output

func example(_ title: String, completion: () -> Void) {
    print("-------------------------[\(title)]------------------------")
    completion()
    print("----------------------------[End]--------------------------")
}

example("Reduce") {
    let values = [1, 3, 5 ,8, 13]
    values.publisher
    // it will print value that is received
        .print()
    // reduce will wait for all values of publisher to pass through and than it will return the final value
        .reduce(0) { sum, value in
            sum + value
        }
        .sink { print($0) }
}

example("Count") {
    let values = [1, 3, 5 ,8, 13]
    values.publisher
        .print()
        .count()
        .sink { print($0) }
}

example("Last") {
    let values = [1, 3, 5 ,8, 13]
    values.publisher
        .print()
        .last()
        .sink { print($0) }
}

example("First") {
    let values = [1, 3, 5 ,8, 13]
    values.publisher
        .print()
    // will cancel when value is received
        .first()
        .sink { print($0) }
}

example("output(at: )") {
    let values = [1, 3, 5 ,8, 13]
    values.publisher
        .print()
    // will cancel when value is received at index, iterating synchronously
        .output(at: 3)
        .sink { print($0) }
}

// max min -> will wait for upstream publisher to finish first and than produces the value, data should be confirmed to protocol Equatable

example("Collect") {
    let values = [1, 3, 5 ,8, 13]
    values.publisher
        .print()
    // it will also wait until upstream publisher will finish and than produces a value and than pack it into an array
        .collect()
        .sink { print($0) }
}

