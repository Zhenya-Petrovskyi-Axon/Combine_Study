import Combine
import Foundation

// MARK: Lets see first what problem can occure

func myNumberPublisherProblem() -> Publishers.Concatenate<Publishers.Sequence<[Int], Publishers.Drop<Publishers.MergeMany<Publishers.Sequence<[Int], Never>>>.Failure>, Publishers.Drop<Publishers.MergeMany<Publishers.Sequence<[Int], Never>>>> { // <-- You cant just return a Publisher, so if you returning something you need to specify it as a type and while type is changing all the time due to operators tha was used -> there is a need to change specified type to return
    let publisher = [1, 2, 3].publisher
        .merge(with: [4, 5, 6].publisher)
        .dropFirst()
        .prepend([1, 2, 3])
    /*
     so the problem is each operator changes a generic type of returning value, with holds as a generic parrameter initial value
     */
    return publisher
}

let publisher = myNumberPublisherProblem()
print(publisher)

// MARK: - Solving the problem

func myNumberPublisherFixed() -> AnyPublisher<Int, Never> {
    let publisher = [1, 2, 3].publisher
        .merge(with: [4, 5, 6].publisher)
        .dropFirst()
        .prepend([1, 2, 3])
    return publisher
        .eraseToAnyPublisher() // <-- that is some kind of casting, that will help you to return it as a AnyPublisher
}

let fixedPublisher = myNumberPublisherFixed()
print(fixedPublisher)
