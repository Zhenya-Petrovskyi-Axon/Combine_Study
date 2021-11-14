import Combine

struct DivideByZeroError: Error {}
struct ERROR_BAD_INPUT: Error {}

let dominators = [4, 3, 2, 0].publisher

dominators
    .tryMap { dom -> Double in
    guard dom != 0 else { throw ERROR_BAD_INPUT() }
    return 10.2 / Double(dom)
}
    .tryCatch({ error -> Just<Double> in
        if error is ERROR_BAD_INPUT {
            throw DivideByZeroError()
        } else {
            throw error
        }
    })
    .sink { completion in
        print("Completion: \(completion)")
    } receiveValue: { value in
        print("Value: \(value)")
    }

