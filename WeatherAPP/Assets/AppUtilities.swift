//
//  AppUtilities.swift
//  WeatherAPP
//
//  Created by Amit on 12/09/2019.
//  Copyright © 2018 Amit. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AppUtilities {
    
    fileprivate let TAG = "AppUtilities"
    
    internal func getHeightUILabel(label: UILabel, text: String) -> CGFloat {
        let uiLabel = UILabel(frame: CGRect(x: 0, y: 0, width: label.frame.width, height: 0))
        uiLabel.numberOfLines = label.numberOfLines
        uiLabel.text = text
        uiLabel.sizeToFit()
        return uiLabel.bounds.height
    }
    
    internal func getWindDirection(fromDegrees degrees: Float) -> String {
        let directions =  ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let i = Int((degrees + 11.25) / 22.5)
        return directions[i % 16]
    }
    
   
    
    internal func showStandardDialogOKEvent(viewController: UIViewController, title: String, message: String, event: @escaping() -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            event()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    internal func getDayName(timeInterval: Int) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat  = "EEEE"
        return dateFormatter.string(from: date as Date)
    }
    
    internal func getHour(timeInterval: Int) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = TimeZone.current
        let hour = dateFormatter.calendar.component(.hour, from: date as Date)
        return "\(hour)"
    }
    
    internal func getTime(timeInterval: Int) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = TimeZone.current
        let hour = dateFormatter.calendar.component(.hour, from: date as Date)
        let minute = dateFormatter.calendar.component(.minute, from: date as Date)
        return "\(hour).\(minute)"
    }
    
    internal func setBlurEffect(view: UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
   internal func getViewXBy(label: String, fromViews: [UIView]) -> UIView {
        var resultView: UIView!
        for view in fromViews {
            if view.accessibilityLabel == label {
                resultView = view
            }
        }
        return resultView
    }
    
    internal func addChildViewController(parentVC: UIViewController, containerView: UIView, childVC: UIViewController) {
        parentVC.addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.didMove(toParent: parentVC)
    }
    
    internal func launchXIB(window: UIWindow, viewController: UIViewController) {
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.rootViewController?.navigationController?.isNavigationBarHidden = true
        window.makeKeyAndVisible()
    }
    
    internal func delay(second: Double, completion: @escaping() -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + second) {
            completion()
        }
    }
    
    internal func getLocalFileDirectory(fileName: String) -> URL {
        if let urlFile =  Bundle.main.url(forResource: fileName, withExtension: "mp4") {
            return urlFile
        } else {
            print("\(TAG) file \(fileName) not found")
            return Bundle.main.url(forResource: "", withExtension: "mp4")!
        }
    }
    
    internal func videoAlwaysPlay(videoPlayer: AVPlayer) {
        videoPlayer.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                videoPlayer.seek(to: CMTime.zero)
                videoPlayer.play()
            }
        })
    }
    
    internal func changeVideoBackground(view: UIView, videoType: AssetManager.WEATHER_VIDEO) -> AVPlayer {
        let urlVideo = getLocalFileDirectory(fileName: videoType.rawValue)
        let videoPlayer = AVPlayer(url: urlVideo)
        videoPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        if let layers = view.layer.sublayers {
            let avLayer = layers.first as! AVPlayerLayer
            avLayer.player = videoPlayer
            return avLayer.player!
        } else {
            print("\(TAG) : AVVideoLayer doesn't exist in this view")
            return videoPlayer
        }
    }
    
    internal func setVideoUIView(view: UIView, videoType: AssetManager.WEATHER_VIDEO) -> AVPlayer {
        let urlVideo = getLocalFileDirectory(fileName: videoType.rawValue)
        let videoPlayer = AVPlayer(url: urlVideo)
        videoPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        let videoLayer: AVPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoLayer.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: getHeightScreen())
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        if let sublayers = view.layer.sublayers {
            var isExistVideo = false
            for layer in sublayers {
                if layer is AVPlayerLayer {
                    let layerPlayer = layer as! AVPlayerLayer
                    isExistVideo = true
                    return layerPlayer.player!
                }
            }
            if !isExistVideo {
                view.layer.insertSublayer(videoLayer, at: 0)
            }
        } else {
            view.layer.insertSublayer(videoLayer, at: 0)
        }
        return videoPlayer
    }
    
    internal func setParallaxEffect(view: UIView) {
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        view.addMotionEffect(group)
    }
    
    internal func blurView(view: UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
    func getXScreenPercent(percent: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.width - (UIScreen.main.bounds.width * ((100 - percent) / 100))
    }
    
    func getYScreenPercent(percent: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.height - (UIScreen.main.bounds.height * ((100 - percent) / 100))
    }
    
    func getWidthScreenPercent(percent: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.width * (percent / 100)
    }
    
    func getHeightScreenPercent(percent: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.height * (percent / 100)
    }
    
    func getWidthScreen() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    func getHeightScreen() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
