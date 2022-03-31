//
//  ViewController.swift
//  ExAVPlayerAudio
//
//  Created by Jake.K on 2022/03/31.
//

import UIKit
import AVFoundation
import SnapKit

class ViewController: UIViewController {
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "iOS 앱 개발 알아가기 - 오디오 재생 예제"
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(label)
    return label
  }()
  private lazy var elapsedTimeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(label)
    return label
  }()
  private lazy var totalTimeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(label)
    return label
  }()
  private lazy var playSlider: UISlider = {
    let slider = UISlider()
    slider.addTarget(self, action: #selector(didChangeSlide), for: .valueChanged)
    slider.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(slider)
    return slider
  }()
  private lazy var toggleButton: UIButton = {
    let button = UIButton()
    button.setTitle("재생", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.setTitleColor(.blue, for: .highlighted)
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(button)
    return button
  }()
  
  var player: AVPlayer = {
    guard let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") else { fatalError() }
    let player = AVPlayer()
    let playerItem = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: playerItem) // AVPlayer는 한번에 하나씩만 다룰 수 있음
    return player
  }()
  var buttonTitle: String? {
    didSet { self.toggleButton.setTitle(self.buttonTitle, for: .normal) }
  }
  var elapsedTimeSecondsFloat: Float64 = 0 {
    didSet {
      guard self.elapsedTimeSecondsFloat != oldValue else { return }
      let elapsedSecondsInt = Int(self.elapsedTimeSecondsFloat)
      let elapsedTimeText = String(format: "%02d:%02d", elapsedSecondsInt.miniuteDigitInt, elapsedSecondsInt.secondsDigitInt)
      self.elapsedTimeLabel.text = elapsedTimeText
    }
  }
  var totalTimeSecondsFloat: Float64 = 0 {
    didSet {
      guard self.totalTimeSecondsFloat != oldValue else { return }
      let totalSecondsInt = Int(self.totalTimeSecondsFloat)
      let totalTimeText = String(format: "%02d:%02d", totalSecondsInt.miniuteDigitInt, totalSecondsInt.secondsDigitInt)
      self.totalTimeLabel.text = totalTimeText
      self.progressValue = self.elapsedTimeSecondsFloat / self.totalTimeSecondsFloat
    }
  }
  var progressValue: Float64? {
    didSet { self.playSlider.value = Float(self.progressValue ?? 0.0) }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.titleLabel.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(16)
      $0.centerX.equalToSuperview()
    }
    self.playSlider.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(56)
      $0.left.right.equalToSuperview().inset(16)
    }
    self.elapsedTimeLabel.snp.makeConstraints {
      $0.top.equalTo(self.playSlider.snp.bottom).offset(8)
      $0.left.equalTo(self.playSlider)
    }
    self.totalTimeLabel.snp.makeConstraints {
      $0.top.equalTo(self.playSlider.snp.bottom).offset(8)
      $0.right.equalTo(self.playSlider)
    }
    self.toggleButton.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    self.addPeriodicTimeObserver()
  }
  
  private func addPeriodicTimeObserver() {
    let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
    self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] elapsedTime in
      self?.elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedTime)
      self?.totalTimeSecondsFloat = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    }
  }
  
  @objc private func didTapButton() {
    switch self.player.timeControlStatus {
    case .paused:
      self.player.play()
      self.buttonTitle = "일시정지"
    case .playing:
      self.player.pause()
      self.buttonTitle = "재생"
    default:
      break
    }
  }
  @objc private func didChangeSlide() {
    self.elapsedTimeSecondsFloat = Float64(self.playSlider.value) * self.totalTimeSecondsFloat
    self.player.seek(to: CMTimeMakeWithSeconds(self.elapsedTimeSecondsFloat, preferredTimescale: Int32(NSEC_PER_SEC)))
  }
}

extension Int {
  var secondsDigitInt: Int {
    self % 60
  }
  var miniuteDigitInt: Int {
    self / 60
  }
}
