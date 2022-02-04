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
    // Key-value observing context
    private var playerItemContext = 0

    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8") else {
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

            print("time is \(time.value/(1000*1000*1000)).\(time.value%(1000*1000*1000)) seconds")
  
        }

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds //bounds of the view in which AVPlayer should be displayed
        playerLayer.videoGravity = .resizeAspect
        
        self.view.layer.addSublayer(playerLayer)
        player.play()
        

        // Do any additional setup after loading the view.
    }
    


//    func removePeriodicTimeObserver() {
//        if let timeObserverToken = timeObserverToken {
//            player.removeTimeObserver(timeObserverToken)
//            self.timeObserverToken = nil
//        }
//    }
    
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

