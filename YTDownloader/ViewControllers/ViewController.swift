//
//  ViewController.swift
//  YTDownloader
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

class ViewController: UIViewController {
     let engine = YTB()
    @IBOutlet weak var Progress            : UIProgressView!
    @IBOutlet weak var VideoURLTextField   : UITextField!
    @IBOutlet weak var DownloadVideoButton : BHButtonView!
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
                
                
                print(video)
                let FormatMP4  = "mp4"
                let FormatWEB  = "webm"
                let Format3GPP = "3gpp"
                
                
                let DownloadAlertSheet = UIAlertController(title: "hi", message: "Select video quality", preferredStyle: .actionSheet)
                
                if video.links.count == 1 {
                    
                    if video.links[0].quality == .hd {
                        print("HD:", video.links)
                        
                        let HDAction = UIAlertAction(title: "HD", style: .default, handler: { (action) in
                            if "\(video.links[0].url)".contains(FormatMP4) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatMP4)
                            } else if "\(video.links[0].url)".contains(FormatWEB) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatWEB)
                            } else if "\(video.links[0].url)".contains(Format3GPP) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: Format3GPP)
                            }
                        })
                        
                        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        DownloadAlertSheet.addAction(HDAction)
                        DownloadAlertSheet.addAction(Cancel)
                        
                        self.present(DownloadAlertSheet, animated: true, completion: nil)
                        
                    } else if video.links[0].quality == .medium {
                        print("Medium:", video.links)
                        
                        let MediumAction = UIAlertAction(title: "Medium", style: .default, handler: { (action) in
                            if "\(video.links[0].url)".contains(FormatMP4) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatMP4)
                            } else if "\(video.links[0].url)".contains(FormatWEB) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatWEB)
                            } else if "\(video.links[0].url)".contains(Format3GPP) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: Format3GPP)
                            }
                        })
                        
                        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        DownloadAlertSheet.addAction(MediumAction)
                        DownloadAlertSheet.addAction(Cancel)
                        
                        self.present(DownloadAlertSheet, animated: true, completion: nil)
                        
                        
                    } else if video.links[0].quality == .small {
                        print("Small:", video.links)
                        
                        let SmallAction = UIAlertAction(title: "Small", style: .default, handler: { (action) in
                            if "\(video.links[0].url)".contains(FormatMP4) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatMP4)
                            } else if "\(video.links[0].url)".contains(FormatWEB) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatWEB)
                            } else if "\(video.links[0].url)".contains(Format3GPP) {
                                self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: Format3GPP)
                            }
                        })
                        
                        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        DownloadAlertSheet.addAction(SmallAction)
                        DownloadAlertSheet.addAction(Cancel)
                        
                        self.present(DownloadAlertSheet, animated: true, completion: nil)
                    }
                    
                } else  if video.links.count == 2 {
                    print("count 2:", video.links)
                    
                    let HDAction = UIAlertAction(title: "HD", style: .default, handler: { (action) in
                        if "\(video.links[0].url)".contains(FormatMP4) {
                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatMP4)
                        } else if "\(video.links[0].url)".contains(FormatWEB) {
                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatWEB)
                        } else if "\(video.links[0].url)".contains(Format3GPP) {
                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: Format3GPP)
                        }
                    })
                    
                    let MediumAction = UIAlertAction(title: "Medium", style: .default, handler: { (action) in
                        if "\(video.links[1].url)".contains(FormatMP4) {
                            self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: FormatMP4)
                        } else if "\(video.links[1].url)".contains(FormatWEB) {
                            self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: FormatWEB)
                        } else if "\(video.links[1].url)".contains(Format3GPP) {
                            self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: Format3GPP)
                        }
                    })
                    
                    let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    DownloadAlertSheet.addAction(HDAction)
                    DownloadAlertSheet.addAction(MediumAction)
                    DownloadAlertSheet.addAction(Cancel)
                    
                    self.present(DownloadAlertSheet, animated: true, completion: nil)
                    
                    
                } else if video.links.count == 3 {
                    print("count 3:",video.links)
                    
                    let HDAction = UIAlertAction(title: "HD", style: .default, handler: { (action) in
                        if "\(video.links[0].url)".contains(FormatMP4) {
                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatMP4)
                        } else if "\(video.links[0].url)".contains(FormatWEB) {
                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: FormatWEB)
                        } else if "\(video.links[0].url)".contains(Format3GPP) {
                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: Format3GPP)
                        }
                    })
                    
                    let MediumAction = UIAlertAction(title: "Medium", style: .default, handler: { (action) in
                        if "\(video.links[1].url)".contains(FormatMP4) {
                            self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: FormatMP4)
                        } else if "\(video.links[1].url)".contains(FormatWEB) {
                            self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: FormatWEB)
                        } else if "\(video.links[1].url)".contains(Format3GPP) {
                            self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: Format3GPP)
                        }
                    })
                    
                    let SmallAction = UIAlertAction(title: "Small", style: .default, handler: { (action) in
                        if "\(video.links[2].url)".contains(FormatMP4) {
                            self.download(VideoURL: video.links[2].url, VideoTitle: video.title, format: FormatMP4)
                        } else if "\(video.links[2].url)".contains(FormatWEB) {
                            self.download(VideoURL: video.links[2].url, VideoTitle: video.title, format: FormatWEB)
                        } else if "\(video.links[2].url)".contains(Format3GPP) {
                            self.download(VideoURL: video.links[2].url, VideoTitle: video.title, format: Format3GPP)
                        }
                    })
                    
                    let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    DownloadAlertSheet.addAction(HDAction)
                    DownloadAlertSheet.addAction(MediumAction)
                    DownloadAlertSheet.addAction(SmallAction)
                    DownloadAlertSheet.addAction(Cancel)
                    
                    self.present(DownloadAlertSheet, animated: true, completion: nil)
                    
                } else {
                    print(video.links)
                }
                
            }).ifError({ (error) in
                print(error.localizedDescription)
                self.ExAlert.ShowBHAlertController(Title: "hi", message: "Check the video URL and try agine: \(error.localizedDescription)", TitleButton: "ok", Target: self)
            })
        }
    }
    
    func download(VideoURL: URL, VideoTitle: String, format: String) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(VideoURL, to: destination).response {
            response in
            //print(response.destinationURL!)
            FCFileManager.renameItem(atPath: response.destinationURL!.lastPathComponent, withName: "\(VideoTitle).\(format)")
            self.Progress.setProgress(0, animated: true)
            
            }.downloadProgress { (Progress) in
                print(String(format: "%.2f", Progress.fractionCompleted))
                let ProgressFloat = Float(Progress.fractionCompleted)
                self.Progress.setProgress(ProgressFloat, animated: true)
        }
    }
}
