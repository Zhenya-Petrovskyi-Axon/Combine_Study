import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

print("_________________________START______________________")
let c = Just(1)
    .print()
    .delay(for: .seconds(1), scheduler: DispatchQueue.global())
    .receive(on: DispatchQueue.main)
    .sink { _ in
        print(Thread.current)
    }
print("_________________________FIN______________________")
