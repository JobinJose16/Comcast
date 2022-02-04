//
//  ViewController.swift
//  ComcastDemo
//
//  Created by Jobin Jose on 1/29/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var timeObserverToken: Any?
    private var playerItemContext = 0
    
    let videoUrl = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo();
    }

    func playVideo() {
        guard let url = URL(string: videoUrl) else {
            return;
        }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        let player = AVPlayer(playerItem: playerItem)
        let timeScale = CMTimeScale(10)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) { time in
            print("played duration is \(time.value/(1000*1000*1000)).\(time.value%(1000*1000*1000)) seconds")
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds //bounds of the view in which AVPlayer should be displayed
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Ended")
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
                
            } else {
                status = .unknown
            }
            
            // Switch over status value
            print("status = ")
            
            switch status {
            case .readyToPlay:
                print("readyToPlay")
                // Player item is ready to play.
            case .failed:
                print("failed")
                // Player item failed. See error.
            case .unknown:
                print("unknown")
                
                // Player item is not yet ready.
            default:
                fatalError()
            }
        }
    }
    
}

