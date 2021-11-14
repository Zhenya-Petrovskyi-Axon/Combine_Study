//
//  ViewController.swift
//  KeyboardNotificationDemo
//
//  Created by Ben Scheirman on 10/26/20.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var chatBar: UIView!
    @IBOutlet weak var safeAreaConstraint: NSLayoutConstraint!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        
        let willShow = nc.publisher(for: UIApplication.keyboardWillShowNotification)
            .extractKeyBoardInfo()
        
        let willHide = nc.publisher(for: UIApplication.keyboardWillHideNotification).extractKeyBoardInfo()
        
        willShow
            .map {
                (offSet: -$0.bounds.height, duration: $0.duration, curve: $0.animationCurve)
            }
            .merge(with: willHide.map {
                (offSet: 0, duration: $0.duration, curve: $0.animationCurve)
                
            })
            .sink { [weak self] parameters in
                let animator = UIViewPropertyAnimator(duration: parameters.duration, curve: parameters.curve) {
                    
                    self?.safeAreaConstraint.constant = parameters.offSet
                    self?.view.layoutIfNeeded()
                }
                animator.startAnimation()
            }
            .store(in: &cancellables)
        
    }

    @IBAction func sendTapped(_ sender: Any) {
        view.endEditing(true)
    }
}

struct KeyboardInfo {
    let bounds: CGRect
    let duration: TimeInterval
    let animationCurve: UIView.AnimationCurve
}

extension Publisher where Output == Notification, Failure == Never {
    func extractKeyBoardInfo() -> AnyPublisher<KeyboardInfo, Never> {
        map { notification in
            let bounds = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            
            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            let curve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber).flatMap { UIView.AnimationCurve(rawValue: Int(truncating: $0)) } ?? .easeInOut
            
            return KeyboardInfo(bounds: bounds, duration: duration, animationCurve: curve)
            
        }
        .eraseToAnyPublisher()
    }
}
