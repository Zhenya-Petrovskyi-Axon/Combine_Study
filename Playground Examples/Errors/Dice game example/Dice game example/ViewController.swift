//
//  ViewController.swift
//  Dice game example
//
//  Created by Ievgen Petrovskiy on 14.11.2021.
//

import Combine
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var labelview: UILabel!
    @IBOutlet weak var rollDiceView: UIButton!
    @IBOutlet weak var rollDiceImageView: UIImageView!
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel = DiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Do any additional setup after loading the view.
        viewModel.$diceImage
            .map { $0 as UIImage? }
            .assign(to: \.image, on: rollDiceImageView)
            .store(in: &cancellables)
        
        viewModel.$isRolling
            .map { !$0 }
            .assign(to: \.isEnabled, on: rollDiceView)
            .store(in: &cancellables)
        
        viewModel.$isRolling
            .sink { [weak self] isRolling in
                UIView.animate(withDuration: 0.5) {
                    self?.rollDiceImageView.alpha = 0.5
                    self?.rollDiceImageView.transform = isRolling ? CGAffineTransform(scaleX: 0.5, y: 0.5) : CGAffineTransform.identity
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap({ $0 })
            .sink { [weak self] error in
                guard let self = self else { return }
                let alert = UIAlertController(title: "Allert", message: "\(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Roll Again", style: .default, handler: { _ in
                    self.rollDiceTapped()
                }))
                self.present(alert, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }
    
    private func configure() {
        rollDiceView.addTarget(self, action: #selector(rollDiceTapped), for: .touchUpInside)
    }
    
}

extension ViewController {
    @objc private func rollDiceTapped() {
        viewModel.rollDice()
    }
}

