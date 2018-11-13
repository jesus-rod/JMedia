//
//  VideoViewController.swift
//  JMedia
//
//  Created by Jesus Rodriguez on 09.11.18.
//  Copyright © 2018 com.jesusrod. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {




    override func viewDidLoad() {
        super.viewDidLoad()
        setupLauncher()
    }

    private func setupLauncher() {
        guard let urlPath = Bundle.main.url(forResource: "7secsVideo", withExtension: "mp4") else {
            print("URL NOT FOUND")
            return
        }
        let videoLauncher = VideoLauncher(url: urlPath)
        videoLauncher.title = "Short vid"
        videoLauncher.subTitle = "Just testing"
//        videoLauncher.minimizeVideoButton.addTarget(self, action: #selector(minimizeVideo), for: .touchUpInside)

        videoLauncher.showVideoPlayer()

        videoLauncher.videoPlayerView.player?.play()
        videoLauncher.videoPlayerView.pausePlayButton.isHidden = true
        videoLauncher.videoPlayerView.pausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_pause").withRenderingMode(.alwaysOriginal), for: .normal)
    }

}
