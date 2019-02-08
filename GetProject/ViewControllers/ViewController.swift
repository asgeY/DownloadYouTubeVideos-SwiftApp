//
//  ViewController.swift
//  GetProject
//
//  Created by BandarHelal on 19/01/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation
import Alamofire
import MediaPlayer
import FCFileManager
import Photos
import CoreVideo

class ViewController: UIViewController, URLSessionDelegate {
     let engine = YTB()
    @IBOutlet weak var Progress: UIProgressView!
    @IBOutlet weak var VideoURLTextField: UITextField!
    @IBOutlet weak var DownloadVideoButton: UIButton!
    let ExAlert = BHAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let TextFieldToolBar = UIToolbar()
        TextFieldToolBar.sizeToFit()
        
        let CloseTextFieldButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeTextField))
        TextFieldToolBar.setItems([CloseTextFieldButton], animated: true)
        
        VideoURLTextField.inputAccessoryView = TextFieldToolBar
        
    }
    
    @objc func closeTextField() {
        view.endEditing(true)
    }
    
    @IBAction func DownloadVideoAction() {
        engine.getYoutubeVideo(withVideoUrlString: self.VideoURLTextField.text!) { (result) in
            result.ifSuccess({ (video) in
                
                // HD
                print(video.links[0].url)
                self.download(VideoURL: video.links[0].url, VideoTitle: video.title)
                
                // medium
                // print(video.links[1].url)
                
                // small
                // print(video.links[2].url)
            }).ifError({ (error) in
                print(error.localizedDescription)
                self.ExAlert.ShowBHAlertController(Title: "hi", message: "Check the video URL and try agine", TitleButton: "ok", Target: self)
            })
        }
    }
    
    func download(VideoURL: URL, VideoTitle: String) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(VideoURL, to: destination).response {
            response in
            print(response.destinationURL!)
            FCFileManager.renameItem(atPath: response.destinationURL!.lastPathComponent, withName: "\(VideoTitle).mp4")
            self.Progress.setProgress(0, animated: true)
            
            }.downloadProgress { (Progress) in
                print("Download Progress: \(Progress.fractionCompleted)")
                let ProgressFloat = Float(Progress.fractionCompleted)
                self.Progress.setProgress(ProgressFloat, animated: true)
        }
    }
}
