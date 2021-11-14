//
//  DiceViewModel.swift
//  Dice game example
//
//  Created by Ievgen Petrovskiy on 14.11.2021.
//

import Combine
import UIKit

enum DiceError: Error {
    case rollOffTable
}

class DiceViewModel {
    private static var unknownDiceImage: UIImage = UIImage(systemName: "dice")!
    
    @Published
    var isRolling: Bool = false
    
    @Published
    var diceImage: UIImage = unknownDiceImage
    
    @Published
    private var diceValue: Int?
    
    @Published
    var error: DiceError?
    
    private var rollSubject = PassthroughSubject<Void, Never>()
    
    init() {
        rollSubject
            .flatMap { [unowned self] _ in
                roll()
                    .handleEvents(receiveSubscription: { _ in
                        error = nil
                        isRolling = true
                    }, receiveOutput: { _ in
                        isRolling = false
                    }, receiveCompletion: { _ in
                        isRolling = false
                    }, receiveCancel: {
                        isRolling = false
                    })
                    .map { $0 as Int? }
                    .catch { error -> Just<Int?> in
                        print(error)
                        self.error = error
                        return Just(nil)
                    }
            }
            .assign(to: &$diceValue)
        
        $diceValue
            .map { [unowned self] in diceImage(for: $0) }
            .assign(to: &$diceImage)
            
    }
    
    func rollDice() {
        rollSubject.send()
    }
    
    private func roll() -> AnyPublisher<Int, DiceError> {
        Future { promise in
            if Int.random(in: 1...4) == 1 {
                promise(.failure(DiceError.rollOffTable))
            } else {
                let value = Int.random(in: 1...6)
                promise(.success(value))
            }
        }
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
     
    func diceImage(for value: Int?) -> UIImage {
        guard let value = value else { return DiceViewModel.unknownDiceImage }
        switch value {
        case 1...6: return UIImage(systemName: "dice.fill")!
        default: return DiceViewModel.unknownDiceImage
        }
    }
}
