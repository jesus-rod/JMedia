//
//  VideoPlayerView.swift
//  JMedia
//
//  Created by Jesus Adolfo on 15.10.17.
//  Copyright © 2017 jesus.rodriguez. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

public struct VideoTimes {
  public let seconds: String
  public let minutes: String
}

public protocol VideoPlayerViewDelegate: class {
  func currentVideoTimeChanged(withTime time: VideoTimes, seconds: Float64)
  func videoFinishedLoading(withTime time: VideoTimes, seconds: Float64)
}

open class VideoPlayerView: UIView {

  open var player: AVPlayer?
  open var playerLayer: AVPlayerLayer?
  var urlString: String?
  var isPlaying = false
  var firstTimeLoading = true

  open weak var delegate: VideoPlayerViewDelegate?

  open let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView(style: .whiteLarge)
    aiv.startAnimating()
    return aiv
  }()

  open let controlsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha :1)
    return view
  }()

 let videoLengthLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize : 13)
    label.textAlignment = .right
    return label
  }()

  let currentTimeLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize : 13)
    label.textAlignment = .left
    return label
  }()

  let videoSlider: UISlider = {
    let slider = UISlider()
    slider.isHidden = true
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumTrackTintColor = BaseColors.mainBlue
    slider.maximumTrackTintColor = .white
    slider.tintColor = BaseColors.mainBlue
    slider.setThumbImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysTemplate), for: .normal)
    slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    return slider
  }()

  open let pausePlayButton: UIButton = {
    let button = UIButton(type : .system)
    button.isHidden = true
    button.setImage(#imageLiteral(resourceName: "ic_lapp_play").withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
    return button
  }()

    @objc func handleSliderChange() {

    if let duration = player?.currentItem?.duration {
      let totalSeconds = CMTimeGetSeconds(duration)
      let value = Float64(videoSlider.value) * totalSeconds

      let seekTime = CMTime(value: Int64(value), timescale: 1)

      player?.seek(to: seekTime, completionHandler: { (_) in
        //do something after changing player/video position
      })
    }


  }

    @objc func handlePause() {

    if isPlaying {
      player?.pause()
      pausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_play").withRenderingMode(.alwaysOriginal), for: .normal)
    } else {
      player?.play()
      pausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_pause").withRenderingMode(.alwaysOriginal), for: .normal)
    }
    isPlaying = !isPlaying
  }


  deinit {
    print("deinit video launcher")
  }

  public init(frame: CGRect, urlString: String) {
    super.init(frame: frame)
    self.urlString = urlString
    setupPlayerView()


    controlsContainerView.frame = frame
    addSubview(controlsContainerView)

    controlsContainerView.addSubview(activityIndicatorView)
    activityIndicatorView.anchorCenterSuperview()


    addSubview(pausePlayButton)
    pausePlayButton.anchorCenterSuperview()
    pausePlayButton.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)

    controlsContainerView.addSubview(videoLengthLabel)
    videoLengthLabel.anchor(nil, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 50, heightConstant: 28)


    controlsContainerView.addSubview(currentTimeLabel)
    currentTimeLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 50, heightConstant: 28)

    controlsContainerView.addSubview(videoSlider)
    videoSlider.anchor(nil, left: currentTimeLabel.rightAnchor, bottom: bottomAnchor, right: videoLengthLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 28)

    //hides the playPauseButtton when the video is tapped
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(respondToVideoTap))
    self.addGestureRecognizer(tapRecognizer)

    backgroundColor = .black
  }


  @objc fileprivate func respondToVideoTap() {
    UIView.animate(withDuration: 1) {
      self.pausePlayButton.isHidden = self.pausePlayButton.isHidden == false ? true : false
    }
  }

  fileprivate  func setupPlayerView() {

    guard let urlString = urlString else { return }
    if let url = URL(string: urlString) {

      player = AVPlayer(url: url)
      playerLayer = AVPlayerLayer(player: player)

      guard let playerLayer = playerLayer else { return }

      self.layer.addSublayer(playerLayer)
      playerLayer.frame = self.frame

      player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
      player?.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty", options: .new, context: nil)
      player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .new, context: nil)
      player?.addObserver(self, forKeyPath: "currentItem.playbackBufferFull", options: .new, context: nil)


      //track progress

      let interval = CMTime(value: 1, timescale: 2)
      player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
        let seconds = CMTimeGetSeconds(progressTime)
        let secondsText = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
        let minutesText = String(format: "%02d", Int(seconds / 60))

        let videoTimes = VideoTimes(seconds: secondsText, minutes: minutesText)
        let currentTimesText = "\(minutesText):\(secondsText)"
        self.currentTimeLabel.text = currentTimesText
        self.delegate?.currentVideoTimeChanged(withTime: videoTimes, seconds: seconds)

        //lets move the slider thumb
        if let duration = self.player?.currentItem?.duration {
          let durationSeconds = CMTimeGetSeconds(duration)
          self.videoSlider.value = Float(seconds / durationSeconds)

        }
      })
    }

  }

  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

    //when the player is ready to play and rendering frames
    guard let thisPath = keyPath else { return }
    switch thisPath {
    case "currentItem.loadedTimeRanges":
      activityIndicatorView.stopAnimating()
      controlsContainerView.backgroundColor = .clear
      videoSlider.isHidden = false
      isPlaying = true

      if let duration = player?.currentItem?.duration {
        let seconds = CMTimeGetSeconds(duration)

        let secondsText = String(format: "%02d", Int(seconds) % 60)
        let minutesText = String(format: "%02d", Int(seconds) / 60)
        let videoTimes = VideoTimes(seconds: secondsText, minutes: minutesText)
        let videoLengthText = "\(minutesText):\(secondsText)"
        videoLengthLabel.text = videoLengthText

        if firstTimeLoading {
          firstTimeLoading = false
          delegate?.videoFinishedLoading(withTime: videoTimes, seconds: seconds)
        }

      }
    case "currentItem.playbackBufferEmpty":
      print("empty")
    case "currentItem.playbackLikelyToKeepUp":
      print("keep")
    case "currentItem.playbackBufferFull":
      print("full")
    default:
      print("defaulted key path")
    }

  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
