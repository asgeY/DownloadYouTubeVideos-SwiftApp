//
//  DocumentsViewController.swift
//  YTDownloader
//
//  Created by BandarHelal on 05/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import SUBLicenseViewController
import FRPreferences
import Photos
import FCFileManager
import GoogleMobileAds
import LocalAuthentication

class DocumentsViewController: UIViewController {
    
    
    var selectedPath            : URL?
    var files                   : [URL]!
    var documentsDirectoryPath  : String?
    var bannerView              : GADBannerView!
    let infoPlistPath           = Bundle.main.infoDictionary
    var profileimage            = URL(string: "https://twitter.com/BandarHL/profile_image?size=bigger")
    var profileimage2           = URL(string: "https://twitter.com/AmeerDesgin/profile_image?size=bigger")
    let bhalert                 = BHAlert()
    let BHConvertSwift          = BHConverting()
    let BHConvertObjC           = BHConvertingObjc()
    var Player                  = AVPlayer()
    
    @IBOutlet weak var EmptyLabel: UILabel!
    @IBOutlet weak var DocumentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmptyLabel.isHidden = true
        DocumentsTableView.delegate   = self
        DocumentsTableView.dataSource = self
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-2502501640180711/8760771556"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        addBannerViewToView(bannerView)
        SetupDocumentsDirectoryPath()
        setupRemoteTransportControlsForVideoPlayer()
        EmptyTableView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        SetupDocumentsDirectoryPath()
        EmptyTableView()
    }
    
    fileprivate func EmptyTableView() {
        if files.count == 0 {
            self.EmptyLabel.isHidden = false
        } else {
            self.EmptyLabel.isHidden = true
        }
    }
    
    fileprivate func SetupDocumentsDirectoryPath() {
        documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        files = [URL]()
        let fileManager = FileManager.default
        let documentsURL = URL(string: documentsDirectoryPath!)
        
        do {
            try files = fileManager.contentsOfDirectory(at: documentsURL!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        } catch {
            print("error wtih \(error)")
        }
        
        DispatchQueue.main.async {
            self.DocumentsTableView.reloadData()
            self.DocumentsTableView.beginUpdates()
            self.DocumentsTableView.reloadRows(at: self.DocumentsTableView.indexPathsForVisibleRows!, with: UITableView.RowAnimation.automatic)
            self.DocumentsTableView.endUpdates();
        }
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func setupRemoteTransportControlsForVideoPlayer() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.Player.rate == 0.0 {
                self.Player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.Player.rate == 1.0 {
                self.Player.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
    }
    
    @IBAction func ShowAppInfo(_ sender: Any) {
        let section1 = FRPSection(title: nil, footer: nil)
        
        let AppVersionCell = FRPValueCell(title: "App Version", detail: infoPlistPath!["CFBundleShortVersionString"] as? String)
        
        let AppBundleCell = FRPValueCell(title: "Bundle", detail: infoPlistPath!["CFBundleIdentifier"] as? String)
        
        let LinkCell = FRPLinkCell(title: "Legal notes") { (TableViewCell) in
            let SUB = SUBLicenseViewController()
            self.navigationController?.pushViewController(SUB, animated: true)
        }
        
        let section2 = FRPSection(title: "Developer", footer: nil)
        let section3 = FRPSection(title: "Designer", footer: nil)
        
        
        if Reachability.isConnectedToNetwork() {
            let DataImage = try? Data(contentsOf: profileimage! as URL)
            let BandarHL = FRPDeveloperCell(title: "BandarHelal", detail: "@BandarHL", image: UIImage(data: DataImage!), url: "https://twitter.com/BandarHL")
            
            let DataImage2 = try? Data(contentsOf: profileimage2! as URL)
            let Ameer = FRPDeveloperCell(title: "Ameer 👨‍🎨", detail: "@AmeerDesgin", image: UIImage(data: DataImage2!), url: "https://twitter.com/AmeerDesgin")
            section2?.addCells([BandarHL!])
            section3?.addCells([Ameer!])
        } else {
            let BandarHL = FRPDeveloperCell(title: "BandarHelal", detail: "@BandarHL", image: UIImage(named: "BandarHL.png"), url: "https://twitter.com/BandarHL")
            let Ameer = FRPDeveloperCell(title: "Ameer 👨‍🎨", detail: "@AmeerDesgin", image: UIImage(named: "ameer.png"), url: "https://twitter.com/AmeerDesgin")
            section2?.addCells([BandarHL!])
            section3?.addCells([Ameer!])
        }
        
        
        section1?.addCells([AppVersionCell!, AppBundleCell!, LinkCell!])
        let table = FRPreferences.table(withSections: [section1!, section2!, section3!], title: "App information", tintColor: nil)
        self.navigationController?.pushViewController(table!, animated: true)
    }
    
    func generateThumbnail(VideoAsset: AVAsset) -> UIImage? {
        do {
            let imgGenerator = AVAssetImageGenerator(asset: VideoAsset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}

extension DocumentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let Cell = DocumentsTableView.dequeueReusableCell(withIdentifier: "DocCell") as? DocumentsTableViewCell else {
            return UITableViewCell()
        }
        
        let filePath = (files?[(indexPath as NSIndexPath).row])!
        let FileName = filePath.lastPathComponent
        let asset = AVAsset(url: self.files[indexPath.row].absoluteURL)
        let secs = Int(asset.duration.seconds)
        
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        
        if FileName.lowercased().contains(".mp4") {
            
            Cell.FileNameLabel.text = FileName.replacingOccurrences(of: ".mp4", with: "")
            Cell.SizeandDurVideo.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = self.generateThumbnail(VideoAsset: asset)
            
        } else if FileName.lowercased().contains(".m4a") {
            
            Cell.FileNameLabel.text = FileName.replacingOccurrences(of: ".m4a", with: "")
            Cell.SizeandDurVideo.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = UIImage(named: "musical-note")
        } else if FileName.lowercased().contains(".webm") {
            
            Cell.FileNameLabel.text = FileName.replacingOccurrences(of: ".webm", with: "")
            Cell.SizeandDurVideo.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = UIImage(named: "video-player")
            
        } else if FileName.lowercased().contains(".3gpp") {
            
            Cell.FileNameLabel.text = FileName.replacingOccurrences(of: ".3gpp", with: "")
            Cell.SizeandDurVideo.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = UIImage(named: "video-player")
        }
        
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let AlertController = UIAlertController(title: "hi", message: "select your option", preferredStyle: .actionSheet)
        
        
        print("File size:\(self.files[indexPath.row].absoluteURL.fileSizeString)")
        
        if String(self.files[indexPath.row].lastPathComponent.suffix(4)) == ".mp4" {
            print("file is MP4")
            
            
            let PlayButtonAction = UIAlertAction(title: "Play video", style: .default) { (action) in
                
                do {
                    let PlayerItem = AVPlayerItem(url: URL(string: self.files[indexPath.row].absoluteString)!)
                    self.Player = AVPlayer(playerItem: PlayerItem)
                    let PlayerController = AVPlayerViewController()
                    PlayerController.player = self.Player
                    
                    self.present(PlayerController, animated: true)
                    self.Player.play()
                }
            }
            let ExtractSoundAction = UIAlertAction(title: "Extract the sound from video", style: .default) { (action) in
                
                var documentsFolders = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                self.BHConvertObjC.convertVideo(toAudio: self.files[indexPath.row].absoluteURL, documentsPath: URL(fileURLWithPath: (documentsFolders[0])).appendingPathComponent("\(self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".mp4", with: "", options: .literal)).m4a").absoluteURL)
                self.SetupDocumentsDirectoryPath()
            }
            
            let SaveVideoAction = UIAlertAction(title: "Save to camera roll", style: .default) { (action) in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.files[indexPath.row].absoluteURL)
                }, completionHandler: { (pass, error) in
                    
                    if error != nil {
                        print("ERROR Save Video To Camera Roll")
                        self.bhalert.ShowBHAlertController(Title: "hi", message: "ERROR Save Video To Camera Roll", TitleButton: "ok", Target: self)
                    } else {
                        print("Success Save Video To Camera Roll")
                        self.bhalert.ShowBHAlertController(Title: "hi", message: "Success Save Video To Camera Roll", TitleButton: "ok", Target: self)
                    }
                })
            }
            
            
            let ShareItem = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareVC = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareVC, animated: true, completion: nil)
            }
            
            
            let RenameItemAction = UIAlertAction(title: "Rename video", style: .default) { (action) in
                
                let TextFieldAlertController = UIAlertController(title: "Add new name", message: "", preferredStyle: .alert)
                TextFieldAlertController.addTextField(configurationHandler: { (TextField) in
                    print(TextField.text!)
                    TextField.text = self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".mp4", with: "", options: .literal)
                })
                
                let RenameAction = UIAlertAction(title: "Rename!", style: .default, handler: { (action) in
                    FCFileManager.renameItem(atPath: self.files[indexPath.row].lastPathComponent, withName: "\(TextFieldAlertController.textFields![0].text!).mp4")
                    self.SetupDocumentsDirectoryPath()
                })
                
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                TextFieldAlertController.addAction(RenameAction)
                TextFieldAlertController.addAction(Cancel)
                
                self.present(TextFieldAlertController, animated: true, completion: nil)
            }
            
            
            let RemoveItem = UIAlertAction(title: "Remove Item", style: .default) { (action) in
                FCFileManager.removeItem(atPath: self.files[indexPath.row].lastPathComponent)
                self.SetupDocumentsDirectoryPath()
            }
            
            
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            AlertController.addAction(PlayButtonAction)
            AlertController.addAction(ExtractSoundAction)
            AlertController.addAction(SaveVideoAction)
            AlertController.addAction(ShareItem)
            AlertController.addAction(RenameItemAction)
            AlertController.addAction(RemoveItem)
            AlertController.addAction(CancelAction)
            self.present(AlertController, animated: true, completion: nil)
            
        } else if String(self.files[indexPath.row].lastPathComponent.suffix(5)) == ".webm" {
            print("file is webm")
            
            let BHAlertController = UIAlertController(title: "hi", message: "video format is not support iOS player \n please share the video with another app like VLC or Document by readdle", preferredStyle: .alert)
            
            let ShareAction = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareViewController = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareViewController, animated: true, completion: nil)
            }
            
            let removeitemAction = UIAlertAction(title: "Remove item", style: .default) { (action) in
                FCFileManager.removeItem(atPath: self.files[indexPath.row].lastPathComponent)
                self.SetupDocumentsDirectoryPath()
            }
            
            let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            BHAlertController.addAction(ShareAction)
            BHAlertController.addAction(removeitemAction)
            BHAlertController.addAction(Cancel)
            self.present(BHAlertController, animated: true, completion: nil)
            
            
        } else if String(self.files[indexPath.row].lastPathComponent.suffix(5)) == ".3gpp" {
            print("file is 3gpp")
            
            let BHAlertController = UIAlertController(title: "hi", message: "video format is not support iOS player \n please share the video with another app like VLC or Document by readdle", preferredStyle: .alert)
            
            let ShareAction = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareViewController = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareViewController, animated: true, completion: nil)
            }
            
            let removeitemAction = UIAlertAction(title: "Remove item", style: .default) { (action) in
                FCFileManager.removeItem(atPath: self.files[indexPath.row].lastPathComponent)
                self.SetupDocumentsDirectoryPath()
            }
            
            let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            BHAlertController.addAction(ShareAction)
            BHAlertController.addAction(removeitemAction)
            BHAlertController.addAction(Cancel)
            self.present(BHAlertController, animated: true, completion: nil)
            
        } else {
            print("file is sound")
            
            let PlayButtonAction = UIAlertAction(title: "Play Sound", style: .default) { (action) in
                
                do {
                    let PlayerItem = AVPlayerItem(url: URL(string: self.files[indexPath.row].absoluteString)!)
                    self.Player = AVPlayer(playerItem: PlayerItem)
                    let PlayerController = AVPlayerViewController()
                    PlayerController.player = self.Player
                    
                    self.present(PlayerController, animated: true)
                    self.Player.play()
                }
            }
            
            let ConvertToVideoAction = UIAlertAction(title: "Convert to video", style: .default) { (action) in
                
                var documentsFolders = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                
                self.BHConvertSwift.ConvertAudioToVideo(audioURL: self.files[indexPath.row].absoluteURL, destination: URL(fileURLWithPath: (documentsFolders[0])).appendingPathComponent("\(self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".m4a", with: "", options: .literal)).mp4").absoluteURL)
                self.SetupDocumentsDirectoryPath()
                
            }
            
            let ShareItem = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareVC = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareVC, animated: true, completion: nil)
            }
            
            let RenameItemAction = UIAlertAction(title: "Rename sound", style: .default) { (action) in
                
                let TextFieldAlertController = UIAlertController(title: "Add new name", message: "", preferredStyle: .alert)
                TextFieldAlertController.addTextField(configurationHandler: { (TextField) in
                    print(TextField.text!)
                    TextField.text = self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".m4a", with: "", options: .literal)
                })
                
                let RenameAction = UIAlertAction(title: "Rename!", style: .default, handler: { (action) in
                    FCFileManager.renameItem(atPath: self.files[indexPath.row].lastPathComponent, withName: "\(TextFieldAlertController.textFields![0].text!).m4a")
                    self.SetupDocumentsDirectoryPath()
                })
                
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                TextFieldAlertController.addAction(RenameAction)
                TextFieldAlertController.addAction(Cancel)
                
                self.present(TextFieldAlertController, animated: true, completion: nil)
            }
            
            
            let RemoveItem = UIAlertAction(title: "Remove Item", style: .default) { (action) in
                FCFileManager.removeItem(atPath: self.files[indexPath.row].lastPathComponent)
                self.SetupDocumentsDirectoryPath()
            }
            
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            AlertController.addAction(PlayButtonAction)
            AlertController.addAction(ConvertToVideoAction)
            AlertController.addAction(ShareItem)
            AlertController.addAction(RenameItemAction)
            AlertController.addAction(RemoveItem)
            AlertController.addAction(CancelAction)
            self.present(AlertController, animated: true, completion: nil)
        }
    }
}

extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

extension DocumentsViewController: GADBannerViewDelegate {
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
