import Combine
import PlaygroundSupport

func example(_ title: String, completion: () -> Void) {
    print("-------------------------[\(title)]------------------------")
    completion()
    print("----------------------------[End]--------------------------")
}

example("Merge") {
    let pub1 = CurrentValueSubject<Int, Never>(100)
    
    let pub2 = [1, 2, 5, 8, 13].publisher
    
    let merge = pub1.merge(with: pub2)
        .print()
        merge.sink { print($0) }
    
    pub1.send(101)
    
    // Merging will be still alive as pub1 was dealocated from upstream to downstream, that's why we need to tell merge that we finished
    pub1.send(completion: .finished)
}

// Only values with the same type
example("Merge multiple") {
    let pub1 = [1, 2, 3].publisher
    let pub2 = [4, 5, 6].publisher
    let pub3 = [7, 8, 9].publisher
    
    // Chose how many publishers you want to merge, in this case its 3, really handy
    Publishers.Merge3(pub1, pub2, pub3)
        .print()
        .sink { print($0) }
    
    /*
     Publishers.MergeMany([...])
     */
}

// Pairing different types, but only if it can have a pair, otherwise it will be ignored
example("Zip") {
    let int = [1, 2, 3].publisher
    let strings = ["a", "b", "c", "d"].publisher // <- "d" will be ignored
    
    // Publishers.Zip3
    int.zip(strings)
        .map { "\($0.0) -> \($0.1)"}
        .sink { print($0) } // <- will print new paired streams, if it has a pair
}

