//
//  ViewController.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 27.04.2021.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var videoPlayer : AVPlayer?
    var videoPlayerLayer : AVPlayerLayer?
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpVideo()
    }
    
    private func setUpElements() -> () {
        
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(registerLogin)
        
    }
    
    private func setUpVideo() {
        
        let bundlePath = Bundle.main.path(forResource: "Itachi edit(tiktok)", ofType: "mp4")
        
        guard bundlePath != nil else {return
        }
        
        let url = URL(fileURLWithPath: bundlePath!)
        
        let item = AVPlayerItem(url: url)
        
        videoPlayer = AVPlayer(playerItem: item)
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        //        videoPlayerLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        videoPlayer?.isMuted = true
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 1)
        
    }
    
}

