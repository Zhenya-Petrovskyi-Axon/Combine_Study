import Combine
import Foundation

  // MARK: - Passthroughsubject

var subscribers: Set<AnyCancellable> = []

let subject = PassthroughSubject<String, Never>()

subject.sink {
    print("1) recieved value \($0)")
}

subject.send("First value")
subject.send("Second value")

print("---------------------------------------------------------------")

let subject2 = PassthroughSubject<String, Never>()

subject2.sink { completion in
    print("2) \(completion)")
} receiveValue: { value in
    print("2) \(value)")
}
// .store(in: &cancellables) in real project

subject2.send("Completing testing")
subject2.send(completion: .finished)

print("---------------------------------------------------------------")

// example of error usage

enum MyError: Error {
    case somethingWentWrong
}

let subject3 = PassthroughSubject<String, MyError>()

subject3.sink { completion in
    print("3) \(completion)")
} receiveValue: { value in
    print("3) \(value)")
}

subject3.send("Test Failure")
subject3.send(completion: .failure(MyError.somethingWentWrong))

print("---------------------------------------------------------------")

// MARK: Current value subject

// This one should have a value or values
let subject4 = CurrentValueSubject<String, Never>("Hello world")

subject4.sink { print("4) value is \($0)") }

subject4.send("Bye Bye World")

// Publishers could be subscribed many times, ex
subject4.value // <- current value and can be only one value at a time

subject4.sink { print("New subscriber recieved value \($0)") }

// Now if we will ad a value, this still will have a subscription, so it will change what we expected to be in privious lines
subject4.send("World Hello Again")


// MARK: - Now we will add not data oriented subject, ex
let buttonTappedSubject = PassthroughSubject<(Void, Never>()
buttonTappedSubject.send()
