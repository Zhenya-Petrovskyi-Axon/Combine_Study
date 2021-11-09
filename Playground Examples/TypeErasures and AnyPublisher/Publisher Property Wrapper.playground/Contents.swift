import Combine

// @Published Property Wrapper

// Initial class to start with
class MockCar {
    private(set) var gasLevel = 1.0
    
    func drive() {
       if gasLevel > 0 {
            print("🚗💨")
           gasLevel -= 0.25
       } else {
           print("OUT OF GAS")
       }
    }
}

// MARK: - Example of usage
class Car {
    @Published
    private(set) var gasLevel = 1.0
    
    @Published
    private(set) var gasGauge = ""
    
    init() {
        $gasLevel
            .map { String(Int(100 * $0)) + "%" }
            .assign(to: &$gasGauge)
    }
    
    func drive() {
       if gasLevel > 0 {
            print("🚗💨")
           gasLevel -= 0.25
       } else {
           print("OUT OF GAS")
       }
    }
}

let car = Car()

car.$gasLevel
    .drop(while: { $0 > 0.4} )
    // filter <-- ALLWAYS EVAALUATE
    .sink { _ in print("WARNING, your gas level is low: \(car.gasGauge)")}



car.drive()
car.drive()
car.drive()
car.drive()
car.drive()
