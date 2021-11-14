import Combine
import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

// subscribe(on: )
// subscribe, request, cancel

print("___________________________Start______________________________")
let c = Just(1)
    .subscribe(on: DispatchQueue.global())
    .map { x in
        sleep(1)
        print("Map Thread: \(Thread.current)")
    }
    .subscribe(on: DispatchQueue.main)
    .sink { x in
        print("x: \(x), Thread: \(Thread.current)")
    }
print("___________________________Finish______________________________")
