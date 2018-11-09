//
//  VideoLauncher.swift
//  JMedia
//
//  Created by Jesus Rodriguez on 09.11.18.
//  Copyright © 2018 com.jesusrod. All rights reserved.
//

import LBTAComponents
import AVKit
import AVFoundation
import JMedia

class VideoLauncher: NSObject {

    var url: String?
    var title: String?
    var subTitle: String?
    var mainView = UIView()
    var videoPlayerView = VideoPlayerView(frame: .zero, urlString: "")

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.blue
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()

    lazy var fullScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = false
        button.setImage(#imageLiteral(resourceName: "ic_fullscreen").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        button.addTarget(self, action: #selector(forceRotation), for: .touchUpInside)
        return button
    }()

    let minimizeVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = false
        button.setImage(#imageLiteral(resourceName: "ic_haip_back").withRenderingMode(.alwaysOriginal), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: (.pi * 1.5 ))
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()

    @objc func forceRotation() {
        let currentOrientation = UIDevice.current.orientation

        if  currentOrientation == UIDeviceOrientation.portrait || currentOrientation == UIDeviceOrientation.portraitUpsideDown {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")

        }
    }

    func minimizeVideo(withVideoSize videoSize: CGSize, withScreenSize screenSize: CGSize) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.subtitleLabel.isHidden = true
            self.nameLabel.isHidden = true


            self.mainView.frame = CGRect(x: screenSize.width, y: screenSize.height, width: 0, height: 0)
            let videoPlayerFrame = CGRect(x: screenSize.width, y: screenSize.height, width: 0, height: 0)


            self.videoPlayerView.frame = videoPlayerFrame
            self.videoPlayerView.playerLayer?.frame = videoPlayerFrame
            self.mainView.subviews.forEach { $0.removeFromSuperview() }


        }, completion: { (_) in

            //STOP THE PLAYER COMPLETELY
            self.mainView.removeFromSuperview()
            self.videoPlayerView.player?.replaceCurrentItem(with: nil)
            self.videoPlayerView.subviews.forEach { $0.removeFromSuperview() }

            //SHOW THE STATUS BAR AGAIN
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal

        })
    }

    func resizeVideo(withSize size: CGSize) {

        if let keyWindow = UIApplication.shared.keyWindow {

            subtitleLabel.isHidden = false
            nameLabel.isHidden = false

            //get the width and height
            let deviceWidth = size.width
            let deviceHeight = size.height + 50
            //calculate the height to make sure we keep the ratio
            let videoHeight = deviceWidth * 9 / 16


            keyWindow.backgroundColor = .red

            print("NEW deviceWidth IS:", deviceWidth)
            print("NEW deviceHeight IS:", deviceHeight)

            mainView.frame = CGRect(x: 0, y: 0, width: deviceWidth, height: deviceHeight)

            let videoPlayerFrame = CGRect(x: 0, y: 0, width: deviceWidth, height: videoHeight)

            print(deviceWidth)
            print(videoHeight)
            videoPlayerView.frame = videoPlayerFrame
            videoPlayerView.playerLayer?.frame = videoPlayerFrame
        }
    }

    func showVideoPlayer() {
        print("Showing video player animation...")

        if let keyWindow = UIApplication.shared.keyWindow {
            mainView = UIView(frame: keyWindow.frame)
            mainView.backgroundColor = .white
            mainView.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)

            let height = UIScreen.main.bounds.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)

            print("WIDTH IS:", keyWindow.frame.width)
            print("HEIGHT IS:", keyWindow.frame.height)

            guard let launcherUrl = url else { return }
            videoPlayerView = VideoPlayerView(frame: videoPlayerFrame, urlString: launcherUrl)
            mainView.addSubview(videoPlayerView)
            keyWindow.addSubview(mainView)

            //Minimize video button
            mainView.addSubview(minimizeVideoButton)
            minimizeVideoButton.anchor(videoPlayerView.topAnchor, left: videoPlayerView.leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)

            //Full screen button
            mainView.addSubview(fullScreenButton)
            fullScreenButton.anchor(videoPlayerView.topAnchor, left: nil, bottom: nil, right: videoPlayerView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 40, heightConstant: 40)

            //name label
            mainView.addSubview(nameLabel)
            nameLabel.anchor(videoPlayerView.bottomAnchor, left: keyWindow.leftAnchor, bottom: nil, right: keyWindow.rightAnchor, topConstant: 30, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
            nameLabel.text = title ?? ""

            //level label
            mainView.addSubview(subtitleLabel)
            subtitleLabel.anchor(nameLabel.bottomAnchor, left: keyWindow.leftAnchor, bottom: nil, right: keyWindow.rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 20)
            subtitleLabel.text = subTitle ?? ""



            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                self.mainView.frame = keyWindow.frame
                self.nameLabel.isHidden = false
                self.subtitleLabel.isHidden = false

            }, completion: { _ in
                UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar

            })
        }
    }
}
