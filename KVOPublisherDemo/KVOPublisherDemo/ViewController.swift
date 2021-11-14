//
//  ViewController.swift
//  KVOPublisherDemo
//
//  Created by Ben Scheirman on 10/23/20.
//

import UIKit
import AVKit
import Combine

class ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var logTextView: UITextView!
    
    private var playerController: AVPlayerViewController!
    
    private var playerItemCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayerController()
    }
    
    private func setupPlayerController() {
        playerController = AVPlayerViewController()
        addChild(playerController)
        
        videoContainer.addSubview(playerController.view)
        playerController.view.frame = videoContainer.bounds
        playerController.view.backgroundColor = UIColor.black
        playerController.didMove(toParent: self)
        
        let player = AVPlayer()
        player.volume = 0
        playerController.player = player
        
        player.publisher(for: \.timeControlStatus)
            .removeDuplicates()
            .withPriorValue()
            .sink { [weak self] tuple in
                self?.appendLog("\(tuple.prior?.stringValue) -> \(tuple.new.stringValue)")
            }
            .store(in: &cancellables)
        
        
        let isPlaying = player.publisher(for: \.rate)
            .map { $0 > 0 }
        
        player.publisher(for: \.currentItem)
            .sink { [weak self] item in
                let isOn = item == nil
                self?.playButton.isHidden = isOn
                self?.pauseButton.isHidden = isOn
            }
            .store(in: &cancellables)
        
        isPlaying
            .assign(to: \.isEnabled, on: pauseButton)
            .store(in: &cancellables)
        
        isPlaying
            .map { !$0 }
            .assign(to: \.isEnabled, on: pauseButton)
            .store(in: &cancellables)
    }

    // MARK: - Actions
    
    @IBAction func loadVideo(_ sender: Any) {
        playerController.player?.pause()
        
        let playerItem = AVPlayerItem(url: URL(string: "https://demo.unified-streaming.com/video/tears-of-steel/tears-of-steel.ism/.m3u8")!)
        playerController.player?.replaceCurrentItem(with: playerItem)
        
        playerItemCancellable = playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                self?.statusLabel.text = status.stringValue
            }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        playerController.player?.play()
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        playerController.player?.pause()
    }
    
    private func appendLog(_ text: String) {
        logTextView.text.append("\(text)\n")
    }
}

extension AVPlayer.TimeControlStatus {
    var stringValue: String {
        switch self {
        case .paused: return "Paused"
        case .playing: return "Playing"
        case .waitingToPlayAtSpecifiedRate: return "Buffering"
        @unknown default: return "?"
        }
    }
}

extension AVPlayerItem.Status {
    var stringValue: String {
        switch self {
        case .readyToPlay:
            return "Ready to play"
        case .failed:
            return "Player item failed"
        default:
            return "???"
        }
    }
}

extension Publisher {
    func withPriorValue() -> AnyPublisher<(prior: Output?, new: Output), Failure> {
        scan((prior: Output?.none, new: Output?.none)) { tuple, newValue in
            (prior: tuple.new, newValue: newValue)
        }
        .map { (prior: $0.prior, new: $0.new!) }
        .eraseToAnyPublisher()
    }
}
