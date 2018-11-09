//
//  AudioRecorder.swift
//  JMedia
//
//  Created by Jesus Adolfo on 15.10.17.
//  Copyright © 2017 jesus.rodriguez. All rights reserved.
//

import AVKit
import AVFoundation

open class AudioRecorderViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession!
    open weak var delegate: AVAudioRecorderDelegate?
    var isAudioRecordingGranted: Bool = false
    var isPlaying = false
    var meterTimer: Timer!

    let timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "00:00"
        label.textAlignment = .center
        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_lapp_close").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(finishRecordingTapped), for: .touchUpInside)
        return button
    }()

    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Siguiente", for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(finishRecordingTapped), for: .touchUpInside)
        return button
    }()

    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_lapp_play").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 40
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        return button
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        check_record_permission()

    }

    func setupViews() {

        let mainView: UIView = {
            let view = UIView()
            view.backgroundColor = BaseColors.mainBlue
            view.layer.cornerRadius = 8
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.white.cgColor
            return view
        }()

        view.addSubview(mainView)

        mainView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 250, heightConstant: 250)
        mainView.anchorCenterSuperview()
        mainView.addSubview(closeButton)
        mainView.addSubview(saveButton)
        mainView.addSubview(pausePlayButton)
        mainView.addSubview(timerLabel)


        closeButton.anchor(mainView.topAnchor, left: mainView.leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
        saveButton.anchor(mainView.topAnchor, left: nil, bottom: nil, right:  mainView.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 100, heightConstant: 44)

        pausePlayButton.anchorCenterSuperview()
        pausePlayButton.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)

        timerLabel.anchorCenterXToSuperview()
        timerLabel.anchor(nil, left: nil, bottom: mainView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 80, heightConstant: 30)

    }

    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            print("finish recording")
        }
    }

    @objc func playPauseRecording() {

        isPlaying = !isPlaying

        if isPlaying {
            handlePlay()
            pausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_play").withRenderingMode(.alwaysOriginal), for: .normal)
            saveButton.isHidden = false
        } else {
            handleStop()
            pausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_pause").withRenderingMode(.alwaysOriginal), for: .normal)
        }

    }

    func handlePlay() {
        audioRecorder?.pause()
        audioRecorder?.isMeteringEnabled = false
    }

    func handleStop() {
        audioRecorder?.record()
        audioRecorder?.isMeteringEnabled = false
    }

    func startRecording() {

        let audioFilename = getDocumentsDirectory().appendingPathComponent("audioRecording.aac")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            //Create audio file name URL
            //Create the audio recording, and assign ourselves as the delegate
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            //change target of button
            pausePlayButton.addTarget(self, action: #selector(playPauseRecording), for: .touchUpInside)
            pausePlayButton.setImage(#imageLiteral(resourceName: "ic_lapp_pause").withRenderingMode(.alwaysOriginal), for: .normal)
        } catch  let error {
            print("Error starting audio recording", error)
            finishRecording(success: false)
        }

    }


    func closeWithoutSaving() {
        finishRecording(success: false)
        dismiss(animated: true, completion: nil)
    }


    @objc func finishRecordingTapped() {
        finishRecording(success: true)
        dismiss(animated: true) {
            //maybe finish recording with success = false ?
        }
    }

    func finishRecording(success: Bool) {
        print("User finished recording")

        audioRecorder?.stop()
        audioRecorder = nil

        if success {
            //            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            //            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }

    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        if !flag {
            finishRecording(success: false)
        } else {
            delegate?.audioRecorderDidFinishRecording?(recorder, successfully: flag)
        }

    }



    @objc func updateAudioMeter(timer: Timer) {

        guard let recorder = audioRecorder else { return }
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            timerLabel.text = totalTimeString
            audioRecorder?.updateMeters()
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func check_record_permission() {

        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.spokenAudio, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //load recorder UI
                        self.setupViews()
                    } else {
                        print("failed to record")
                    }
                }
            }
        } catch {
            // failed to record!
            print("failed to record-")
        }
    }

}
