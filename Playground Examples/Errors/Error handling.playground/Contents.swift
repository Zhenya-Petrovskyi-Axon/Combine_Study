import Combine

struct DummyError: Error {
    
}

let subject = PassthroughSubject<Int, DummyError>()

subject.sink { completion in
    print("Completion: \(completion)")
} receiveValue: { value in
    print("Value: \(value)")
}

// MARK: - Due to publisher life cycle we need to remember that publisher wont be producing any values after it received completion of any type

subject.send(1)
subject.send(completion: .failure(DummyError()))

subject.send(2)

// MARK: - Now we we learn how to catch an error and produce a new publisher out of it
let subject2 = PassthroughSubject<Int, DummyError>()

subject2
    .catch { error -> Just<Int> in
        print("Error: \(error)")
    return Just(-1)
}
    .sink { completion in
        print("Completion: \(completion)")
    } receiveValue: { value in
        print("Value: \(value)")
    }

subject2.send(1)
subject2.send(completion: .failure(DummyError()))
subject2.send(2)


let pub3 = [4, 5, 3, 8, 1, 9, 1, 2].publisher
let pub4 = pub3

pub3.tryMap { value throws -> Int in
    if value > 2 {
        throw DummyError()
    } else {
        return value
    }
}

print(type(of: pub3).Output)
print(type(of: pub3).Failure)

pub4
    .replaceError(with: 100)
    .sink (
        receiveCompletion: { completion in
        print("Completion: \(completion)")
    },
        receiveValue: { value in
        print("Value: \(value)")
    })













