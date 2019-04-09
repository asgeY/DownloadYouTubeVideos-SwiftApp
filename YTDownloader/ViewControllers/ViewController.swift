//
//  ViewController.swift
//  YTDownloader
//
//  Created by BandarHelal on 19/01/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer
import FCFileManager
import KRProgressHUD
import GoogleMobileAds

class ViewController: UIViewController, UITextFieldDelegate {
    let engine = YTB()
    @IBOutlet weak var Progress            : UIProgressView!
    @IBOutlet weak var VideoURLTextField   : UITextField!
    @IBOutlet weak var DownloadVideoButton : BHButtonView!
    let BHObj = BHUtilities()
    let BHConvertSwift = BHConverting()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    let ExAlert = BHAlert()
    let FormatMP4  = "mp4"
    let FormatWEB  = "webm"
    let Format3GPP = "3gpp"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-2502501640180711/8760771556"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2502501640180711/2505019237")
        interstitial.load(GADRequest())
        interstitial.delegate = self
        
        
        addBannerViewToView(bannerView)
        dismisskeyBoardOnView()
        guard let VideoText = VideoURLTextField else {
            return
        }
        VideoText.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    fileprivate func dismisskeyBoardOnView() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hidekeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hidekeyBoard() {
        self.view.endEditing(true)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    @IBAction func DownloadVideoAction() {
        
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
            
            self.interstitial.present(fromRootViewController: self)
            
            
            let AlertController = UIAlertController(title: "Hi", message: "Select option", preferredStyle: .actionSheet)
            
            let AudioAction = UIAlertAction(title: "Sound", style: .default) { (action) in
                
                if self.VideoURLTextField.text!.lowercased().contains("youtu.be") {
                    
                    do {
                        let regex = try NSRegularExpression(pattern: .youtubeVideoIdRegex)
                        let matches = regex.matches(in: self.VideoURLTextField.text!,
                                                    range: NSRange(location: 0, length: self.VideoURLTextField.text!.count))
                        
                        print(matches.compactMap({ (self.VideoURLTextField.text! as NSString).substring(with: $0.range)
                        }).first!)
                        
                        DaiYoutubeParser.parse(matches.compactMap({ (self.VideoURLTextField.text! as NSString).substring(with: $0.range)
                        }).first!, screenSize: .zero, videoQuality: DaiYoutubeParserQualityHighres, completion: { (status, url, videoTitle, VideoDur) in
                            
                            if status == DaiYoutubeParserStatusSuccess {
                                self.downloadSound(VideoURL: URL(string: url!)!, VideoTitle: videoTitle!)
                                KRProgressHUD.show(withMessage: "Downloading...")
                            } else if status == DaiYoutubeParserStatusFail {
                                self.ExAlert.ShowBHAlertController(Title: "hi", message: "something wrong :)", TitleButton: "ok", Target: self)
                            }
                        })
                    } catch {
                        print(error)
                    }
                } else {
                    self.ExAlert.ShowBHAlertController(Title: "hi", message: "Text Field is empty \n صاحي انت؟ منت حاط رابط فيديو وتضغط زر التحميل", TitleButton: "ok", Target: self)
                }
                
            }
            
            let videoAction = UIAlertAction(title: "Video", style: .default) { (action) in
                
                // do action
                if self.VideoURLTextField.text!.lowercased().contains("youtu.be") {
                    self.engine.getYoutubeVideo(withVideoUrlString: self.VideoURLTextField.text!) { (result) in
                        result.ifSuccess({ (video) in
                            
                            print(video)
                            
                            
                            let DownloadAlertSheet = UIAlertController(title: "hi", message: video.title, preferredStyle: .actionSheet)
                            
                            if video.links.count == 1 {
                                
                                if video.links[0].quality == .hd {
                                    print("HD:", video.links)
                                    
                                    let HDAction = UIAlertAction(title: "HD", style: .default, handler: { (action) in
                                        if "\(video.links[0].url)".contains(self.FormatMP4) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatMP4)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if "\(video.links[0].url)".contains(self.FormatWEB) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatWEB)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if "\(video.links[0].url)".contains(self.Format3GPP) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.Format3GPP)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        }
                                    })
                                    
                                    let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                    
                                    DownloadAlertSheet.addAction(HDAction)
                                    DownloadAlertSheet.addAction(Cancel)
                                    
                                    self.present(DownloadAlertSheet, animated: true, completion: nil)
                                    
                                } else if video.links[0].quality == .medium {
                                    print("Medium:", video.links)
                                    
                                    let MediumAction = UIAlertAction(title: "Medium", style: .default, handler: { (action) in
                                        if "\(video.links[0].url)".contains(self.FormatMP4) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatMP4)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if "\(video.links[0].url)".contains(self.FormatWEB) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatWEB)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if "\(video.links[0].url)".contains(self.Format3GPP) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.Format3GPP)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        }
                                    })
                                    
                                    let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                    
                                    DownloadAlertSheet.addAction(MediumAction)
                                    DownloadAlertSheet.addAction(Cancel)
                                    
                                    self.present(DownloadAlertSheet, animated: true, completion: nil)
                                    
                                    
                                } else if video.links[0].quality == .small {
                                    print("Small:", video.links)
                                    
                                    let SmallAction = UIAlertAction(title: "Small", style: .default, handler: { (action) in
                                        if "\(video.links[0].url)".contains(self.FormatMP4) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatMP4)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if "\(video.links[0].url)".contains(self.FormatWEB) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatWEB)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if "\(video.links[0].url)".contains(self.Format3GPP) {
                                            self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.Format3GPP)
                                            KRProgressHUD.show(withMessage: "Downloading...")
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
                                    if "\(video.links[0].url)".contains(self.FormatMP4) {
                                        self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatMP4)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[0].url)".contains(self.FormatWEB) {
                                        self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatWEB)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[0].url)".contains(self.Format3GPP) {
                                        self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.Format3GPP)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    }
                                })
                                
                                let MediumAction = UIAlertAction(title: "Medium", style: .default, handler: { (action) in
                                    if "\(video.links[1].url)".contains(self.FormatMP4) {
                                        self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: self.FormatMP4)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[1].url)".contains(self.FormatWEB) {
                                        self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: self.FormatWEB)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[1].url)".contains(self.Format3GPP) {
                                        self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: self.Format3GPP)
                                        KRProgressHUD.show(withMessage: "Downloading...")
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
                                    if "\(video.links[0].url)".contains(self.FormatMP4) {
                                        self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatMP4)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[0].url)".contains(self.FormatWEB) {
                                        self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.FormatWEB)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[0].url)".contains(self.Format3GPP) {
                                        self.download(VideoURL: video.links[0].url, VideoTitle: video.title, format: self.Format3GPP)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    }
                                })
                                
                                let MediumAction = UIAlertAction(title: "Medium", style: .default, handler: { (action) in
                                    if "\(video.links[1].url)".contains(self.FormatMP4) {
                                        self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: self.FormatMP4)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[1].url)".contains(self.FormatWEB) {
                                        self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: self.FormatWEB)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[1].url)".contains(self.Format3GPP) {
                                        self.download(VideoURL: video.links[1].url, VideoTitle: video.title, format: self.Format3GPP)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    }
                                })
                                
                                let SmallAction = UIAlertAction(title: "Small", style: .default, handler: { (action) in
                                    if "\(video.links[2].url)".contains(self.FormatMP4) {
                                        self.download(VideoURL: video.links[2].url, VideoTitle: video.title, format: self.FormatMP4)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[2].url)".contains(self.FormatWEB) {
                                        self.download(VideoURL: video.links[2].url, VideoTitle: video.title, format: self.FormatWEB)
                                        KRProgressHUD.show(withMessage: "Downloading...")
                                    } else if "\(video.links[2].url)".contains(self.Format3GPP) {
                                        self.download(VideoURL: video.links[2].url, VideoTitle: video.title, format: self.Format3GPP)
                                        KRProgressHUD.show(withMessage: "Downloading...")
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
                            
                            do {
                                let regex = try NSRegularExpression(pattern: .youtubeVideoIdRegex)
                                let matches = regex.matches(in: self.VideoURLTextField.text!,
                                                            range: NSRange(location: 0, length: self.VideoURLTextField.text!.count))
                                
                                print(matches.compactMap({ (self.VideoURLTextField.text! as NSString).substring(with: $0.range)
                                }).first!)
                                
                                DaiYoutubeParser.parse(matches.compactMap({ (self.VideoURLTextField.text! as NSString).substring(with: $0.range)
                                }).first!, screenSize: CGSize.zero, videoQuality: DaiYoutubeParserQualityHighres, completion: { (status, url, videoTitle, VideoDur) in
                                    
                                    print(url!)
                                    if status == DaiYoutubeParserStatusSuccess {
                                        if url!.contains(self.FormatMP4) {
                                            self.download(VideoURL: URL(string: url!)!, VideoTitle: videoTitle!, format: self.FormatMP4)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if url!.contains(self.FormatWEB) {
                                            self.download(VideoURL: URL(string: url!)!, VideoTitle: videoTitle!, format: self.FormatWEB)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        } else if url!.contains(self.Format3GPP) {
                                            self.download(VideoURL: URL(string: url!)!, VideoTitle: videoTitle!, format: self.Format3GPP)
                                            KRProgressHUD.show(withMessage: "Downloading...")
                                        }
                                    } else {
                                        self.ExAlert.ShowBHAlertController(Title: "hi", message: "something wrong :)", TitleButton: "ok", Target: self)
                                    }
                                })
                            } catch {
                                print(error)
                            }
                        })
                    }
                } else {
                    self.ExAlert.ShowBHAlertController(Title: "hi", message: "Text Field is empty \n صاحي انت؟ منت حاط رابط فيديو وتضغط زر التحميل", TitleButton: "ok", Target: self)
                }
            }
            
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            AlertController.addAction(AudioAction)
            AlertController.addAction(videoAction)
            AlertController.addAction(CancelAction)
            self.present(AlertController, animated: true, completion: nil)
            
        } else {
            print("Internet Connection not Available!")
            self.ExAlert.ShowBHAlertController(Title: "hi", message: "Please check your internet connection \n ياليل مافي فايدة مافي فايدة رح شغل الانترنت", TitleButton: "ok", Target: self)
        }
    }
    
    func download(VideoURL: URL, VideoTitle: String, format: String) {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(VideoURL, to: destination).response {
            response in
            
            if FCFileManager.existsItem(atPath: "\(VideoTitle).\(format)") {
                FCFileManager.renameItem(atPath: response.destinationURL!.lastPathComponent, withName: "\(VideoTitle)2.\(format)")
            } else {
                FCFileManager.renameItem(atPath: response.destinationURL!.lastPathComponent, withName: "\(VideoTitle).\(format)")
            }
            self.Progress.setProgress(0, animated: true)
            DispatchQueue.main.async {
                KRProgressHUD.dismiss()
            }
            }.downloadProgress { (Progress) in
                print(String(format: "%.2f", Progress.fractionCompleted))
                let ProgressFloat = Float(Progress.fractionCompleted)
                self.Progress.setProgress(ProgressFloat, animated: true)
        }
    }
    
    func downloadSound(VideoURL: URL, VideoTitle: String) {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(VideoURL, to: destination).response {
            response in
            
            var documentsFolders = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            self.BHObj.convertVideo(toAudio: response.destinationURL!.absoluteURL, documentsPath: URL(fileURLWithPath: (documentsFolders[0])).appendingPathComponent("\(VideoTitle).m4a"), completionHandler: nil)
            FCFileManager.removeItem(atPath: response.destinationURL!.lastPathComponent)
            self.Progress.setProgress(0, animated: true)
            DispatchQueue.main.async {
                KRProgressHUD.dismiss()
            }
            }.downloadProgress { (Progress) in
                print(String(format: "%.2f", Progress.fractionCompleted))
                let ProgressFloat = Float(Progress.fractionCompleted)
                self.Progress.setProgress(ProgressFloat, animated: true)
        }
        
    }
}

extension ViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
}
extension ViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
