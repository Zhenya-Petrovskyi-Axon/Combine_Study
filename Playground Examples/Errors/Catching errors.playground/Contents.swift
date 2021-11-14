import Combine

struct DummyError: Error {}

let subject = PassthroughSubject<Int, DummyError>()


