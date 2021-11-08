import Combine
import PlaygroundSupport
import Foundation
PlaygroundPage.current.needsIndefiniteExecution = true

class Tik {
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        // Publisher
       Timer.publish(every: 0.5, on: .main, in: .common)
        // MARK: With print you can have some sort of a debugging information
        // Operators
            .autoconnect()
            .print("Timer")
        //
        // Subscriber
            .sink { _ in
                print("Ticky")
            }.store(in: &cancellables)
    }
    
    /* retain cycle problem is here and is solved with [unowned self]
     Timer.publish(every: 0.5, on: .main, in: .common)
          .autoconnect()
          .sink { [unowned self] _ in
              self.tick() <- the problem occures when using self, instead use [unowned self]
           MARK: its really handy to use [weak self] if you sure class will be deallocated or it is not safe
              tick()
          }.store(in: &cancellables)
     
     func tick() {
     print("Tick')
     }
     
     */
}

// Optional to make it nil if needed
var example: Tik? = Tik()

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    example = nil
    print("Cleaning up timer")
}
