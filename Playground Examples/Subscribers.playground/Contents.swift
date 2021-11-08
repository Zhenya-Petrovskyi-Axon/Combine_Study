import Combine

let intValues = [1, 3, 5, 8, 10, 11, 20]
let publisher = intValues.publisher
 
// MARK: - SINK
// How its done under the hood
func sinkExample() {
    let subscriber = Subscribers.Sink<Int, Never> { completion in
        // switch if you might have an error
        print(completion)
    } receiveValue: { value in
        print(value)
    }

    publisher.subscribe(subscriber)
}

sinkExample()

func sinkExampleShortVersion() {
    publisher.sink { completion in
        print(completion)
    } receiveValue: { value in
        print(value)
    }

}

sinkExampleShortVersion()

// MARK: - Assign
class Forum {
    var latestMessage: String = "" {
        didSet {
            print(latestMessage)
        }
    }
}

func assignExampleManualUnderTheHood() {
    let messages = ["Hey there", "I wanna eat"].publisher
    
    let forum = Forum()
    
    // Never produces an error
    let subscriber = Subscribers.Assign<Forum, String>(object: forum, keyPath: \.latestMessage)
    
    messages.subscribe(subscriber)
}

func assignExampleShortWay() {
    
    let messages = ["Hey there", "I wanna eat"].publisher
    
    let forum = Forum()
    
    messages.assign(to: \.latestMessage, on: forum)
}

assignExampleManualUnderTheHood()
assignExampleShortWay()
