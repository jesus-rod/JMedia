//
//  AudioPlayerView.swift
//  JMedia
//
//  Created by Jesus Adolfo on 15.10.17.
//  Copyright © 2017 jesus.rodriguez. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

open class AudioPlayerView: UIView {

  open var audioPlayer: AVPlayer?
  var playerLayer: AVPlayerLayer?
  open var urlString: String?
  var isPlaying = false

  let audioBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = BaseColors.bgGray
    return view
  }()

  let audioPausePlayButton: UIButton = {
    let button = UIButton()
    button.addTarget(self, action: #selector(handleAudioPause), for: .touchUpInside)
    button.setImage(#imageLiteral(resourceName: "ic_lapp_play"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.contentHorizontalAlignment = .center
    button.contentVerticalAlignment = .center
    return button
  }()

  let audioSlider: UISlider = {
    let slider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumTrackTintColor = BaseColors.mainBlue
    slider.maximumTrackTintColor = .white
    slider.tintColor = BaseColors.mainBlue

    slider.setThumbImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysTemplate), for: .normal)
    slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)

    return slider
  }()

  let audioLengthLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize : 13)
    label.textAlignment = .right
    return label
  }()

  let audioCurrentTimeLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize : 13)
    label.textAlignment = .left
    return label
  }()

  public init(frame: CGRect, urlString: String) {
    self.urlString = urlString
    super.init(frame: frame)
    guard let audioUrl = URL(string: urlString) else { return }
    audioPlayer = AVPlayer(url: audioUrl)
    playerLayer = AVPlayerLayer(player: audioPlayer)
    guard let playerLayer = playerLayer else { return }
    self.layer.addSublayer(playerLayer)
    playerLayer.frame = self.frame
    setupAudioView()
    keepTrackOfAudio()
  }

  func keepTrackOfAudio() {
    audioPlayer?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)

    //track progress
    let interval = CMTime(value: 1, timescale: 2)
    audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
      let seconds = CMTimeGetSeconds(progressTime)
      let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
      let minutesString = String(format: "%02d", Int(seconds / 60))
      self.audioCurrentTimeLabel.text = "\(minutesString):\(secondsString)"

      //lets move the slider thumb
      if let duration = self.audioPlayer?.currentItem?.duration {
        let durationSeconds = CMTimeGetSeconds(duration)
        self.audioSlider.value = Float(seconds / durationSeconds)

      }
    })

  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

    //when the player is ready to play and rendering frames
    if keyPath == "currentItem.loadedTimeRanges" {
      isPlaying = true

      if let duration = audioPlayer?.currentItem?.duration {
        let seconds = CMTimeGetSeconds(duration)

        let secondsText = String(format: "%02d", Int(seconds) % 60)
        let minutesText = String(format: "%02d", Int(seconds) / 60)
        audioLengthLabel.text = "\(minutesText):\(secondsText)"
      }

    }
  }

  func setupAudioView() {
    addSubview(audioBackgroundView)
    audioBackgroundView.addSubview(audioPausePlayButton)
    audioBackgroundView.addSubview(audioCurrentTimeLabel)
    audioBackgroundView.addSubview(audioSlider)
    audioBackgroundView.addSubview(audioLengthLabel)

    audioBackgroundView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

    audioPausePlayButton.anchor(nil, left: audioBackgroundView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
    audioCurrentTimeLabel.anchor(nil, left: audioPausePlayButton.rightAnchor, bottom: nil, right: audioSlider.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 40, heightConstant: 44)
    audioSlider.anchor(nil, left: audioCurrentTimeLabel.rightAnchor, bottom: nil, right: audioLengthLabel.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 28)
    audioLengthLabel.anchor(nil, left: audioSlider.rightAnchor, bottom: nil, right: audioBackgroundView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 40, heightConstant: 44)
    audioPausePlayButton.anchorCenterYToSuperview()
    audioCurrentTimeLabel.anchorCenterYToSuperview()
    audioSlider.anchorCenterYToSuperview()
    audioLengthLabel.anchorCenterYToSuperview()



  }

    @objc func handleSliderChange() {

    if let duration = audioPlayer?.currentItem?.duration {
      let totalSeconds = CMTimeGetSeconds(duration)
      let value = Float64(audioSlider.value) * totalSeconds

      let seekTime = CMTime(value: Int64(value), timescale: 1)

      audioPlayer?.seek(to: seekTime, completionHandler: { (completedSeek) in
        //do something after changing player/video position
        print("audio completed seek:", completedSeek)
      })
    }

  }

    @objc func handleAudioPause() {

    if isPlaying {
      audioPlayer?.pause()
      audioPausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_play").withRenderingMode(.alwaysOriginal), for: .normal)
    } else {
      audioPlayer?.play()
      audioPausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_pause").withRenderingMode(.alwaysOriginal), for: .normal)
    }

    isPlaying = !isPlaying
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
