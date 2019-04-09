//
//  FolderViewController.swift
//  YTDownloader
//
//  Created by BandarHelal on 02/04/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import FCFileManager

class FolderViewController: ViewController {
    
    @IBOutlet weak var FolderTableView: UITableView!
    @IBOutlet weak var EmptyFolder: UILabel!
    var selectedPath            : URL?
    var files                   : [URL]!
    var documentsDirectoryPath  : String?
    let bhalert                 = BHAlert()
    let BHConvertSwifty         = BHConverting()
    let BHConvertObjC           = BHUtilities()
    var Player                  = AVPlayer()
    var folderName : String?
    var FolderNameSelected2 : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = folderName!
        EmptyFolder.isHidden = true
        print(folderName!)
        SetupDocumentsDirectoryPath()
        FolderTableView.delegate = self
        FolderTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SetupDocumentsDirectoryPath()
        EmptyTableView()
    }
    
    fileprivate func SetupDocumentsDirectoryPath() {
        documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        files = [URL]()
        let fileManager = FileManager.default
        //let documentsURL = URL(string: documentsDirectoryPath!)
        
        do {
            try files = fileManager.contentsOfDirectory(at: URL(string: URL.urlInDocumentsDirectory(with: folderName!).path)!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        } catch {
            print("error wtih \(error)")
        }
        
        DispatchQueue.main.async {
            self.FolderTableView.reloadData()
            self.FolderTableView.reloadRows(at: self.FolderTableView.indexPathsForVisibleRows!, with: UITableView.RowAnimation.automatic)
        }
    }
    
    fileprivate func EmptyTableView() {
        if files.count == 0 {
            self.EmptyFolder.isHidden = false
        } else {
            self.EmptyFolder.isHidden = true
        }
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
    
    func RemoveFile(Path: String, FileName: String) {
        
        FCFileManager.removeItem(atPath: Path)
        bhalert.ShowBHAlertController(Title: "Hi", message: "Successful remove: \n \(FileName)", TitleButton: "ok", Target: self)
        self.SetupDocumentsDirectoryPath()
        self.viewWillAppear(true)
    }
    
}

extension FolderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let Cell = FolderTableView.dequeueReusableCell(withIdentifier: "FolderCell") as? FolderTableViewCell else {
            return UITableViewCell()
        }
        
        let filePath = (files?[(indexPath as NSIndexPath).row])!
        let FileName = filePath.lastPathComponent
        let asset = AVAsset(url: self.files[indexPath.row].absoluteURL)
        let secs = Int(asset.duration.seconds)
        
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        
        if FileName.lowercased().contains(".mp4") {
            
            Cell.NameFile.text = FileName.replacingOccurrences(of: ".mp4", with: "")
            Cell.SizeFile.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = self.generateThumbnail(VideoAsset: asset)
            
        } else if FileName.lowercased().contains(".m4a") {
            
            Cell.NameFile.text = FileName.replacingOccurrences(of: ".m4a", with: "")
            Cell.SizeFile.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = UIImage(named: "musical-note")
        } else if FileName.lowercased().contains(".webm") {
            
            Cell.NameFile.text = FileName.replacingOccurrences(of: ".webm", with: "")
            Cell.SizeFile.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = UIImage(named: "video-player")
            
        } else if FileName.lowercased().contains(".3gpp") {
            
            Cell.NameFile.text = FileName.replacingOccurrences(of: ".3gpp", with: "")
            Cell.SizeFile.text = "\(self.files[indexPath.row].absoluteURL.fileSizeString) | \(minutes):\(seconds)"
            Cell.ImageFile.image = UIImage(named: "video-player")
        } else {
            Cell.NameFile.text = FileName
            Cell.ImageFile.image = UIImage(named: "folder_icon_iPhone")
            Cell.SizeFile.text = ""
            
        }
        
        return Cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
            let DeleteRowAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, IndexPath) in
                
                if String(self.files[indexPath.row].lastPathComponent.suffix(4)) == ".mp4" {
                    
                    self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".mp4", with: ""))
                    
                } else if String(self.files[indexPath.row].lastPathComponent.suffix(4)) == ".MP4" {
                    
                    self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".MP4", with: ""))
                    
                } else if String(self.files[indexPath.row].lastPathComponent.suffix(5)) == ".webm" {
                    
                    self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".webm", with: ""))
                    
                } else if String(self.files[indexPath.row].lastPathComponent.suffix(5)) == ".3gpp" {
                    
                    self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".3gpp", with: ""))
                    
                } else {
                    
                    self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".m4a", with: ""))
                    
                }
            }
        
        let ReturnRowAction = UITableViewRowAction(style: .default, title: "return to doc") { (action, IndexPath) in
            FCFileManager.moveItem(atPath: "\(self.folderName!)/\(self.files[indexPath.row].lastPathComponent)", toPath: self.files[indexPath.row].lastPathComponent)
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        ReturnRowAction.backgroundColor = .blue
            
        return [DeleteRowAction, ReturnRowAction]
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
                print(URL(string: URL.urlInDocumentsDirectory(with: self.folderName!).path)!)
                self.BHConvertObjC.convertVideo(toAudio: self.files[indexPath.row].absoluteURL, documentsPath: URL(string: URL.urlInDocumentsDirectory(with: self.folderName!).path)!, completionHandler: {

                    DispatchQueue.main.async {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    self.SetupDocumentsDirectoryPath()

                })
            }

            let SaveVideoAction = UIAlertAction(title: "Save to camera roll", style: .default) { (action) in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.files[indexPath.row].absoluteURL)
                }, completionHandler: { (pass, error) in

                    if error != nil {
                        print("ERROR Save Video To Camera Roll")
                        self.bhalert.ShowBHAlertController(Title: "hi", message: "ERROR Save Video To Camera Roll", TitleButton: "ok", Target: self)
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        print("Success Save Video To Camera Roll")
                        self.bhalert.ShowBHAlertController(Title: "hi", message: "Success Save Video To Camera Roll", TitleButton: "ok", Target: self)
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                })
            }


            let ShareItem = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareVC = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareVC, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }


            let RenameItemAction = UIAlertAction(title: "Rename video", style: .default) { (action) in

                let TextFieldAlertController = UIAlertController(title: "Add new name", message: "", preferredStyle: .alert)
                TextFieldAlertController.addTextField(configurationHandler: { (TextField) in
                    print(TextField.text!)
                    TextField.text = self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".mp4", with: "", options: .literal)
                })

                let RenameAction = UIAlertAction(title: "Rename!", style: .default, handler: { (action) in
                    FCFileManager.renameItem(atPath: self.files[indexPath.row].lastPathComponent, withName: "\(TextFieldAlertController.textFields![0].text!).mp4")
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.SetupDocumentsDirectoryPath()
                })

                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                TextFieldAlertController.addAction(RenameAction)
                TextFieldAlertController.addAction(Cancel)

                self.present(TextFieldAlertController, animated: true, completion: nil)
            }


            let RemoveItem = UIAlertAction(title: "Remove Item", style: .default) { (action) in

                self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".mp4", with: ""))
                tableView.deselectRow(at: indexPath, animated: true)
            }


            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
            }

            AlertController.addAction(PlayButtonAction)
            AlertController.addAction(ExtractSoundAction)
            AlertController.addAction(SaveVideoAction)
            AlertController.addAction(ShareItem)
            AlertController.addAction(RenameItemAction)
            AlertController.addAction(RemoveItem)
            AlertController.addAction(CancelAction)
            self.present(AlertController, animated: true, completion: nil)

        } else if String(self.files[indexPath.row].lastPathComponent.suffix(4)) == ".MP4" {

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
                self.BHConvertObjC.convertVideo(toAudio: self.files[indexPath.row].absoluteURL, documentsPath: URL(fileURLWithPath: (documentsFolders[0])).appendingPathComponent("\(self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".MP4", with: "", options: .literal)).m4a").absoluteURL, completionHandler: {

                    DispatchQueue.main.async {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    self.SetupDocumentsDirectoryPath()
                })
            }

            let SaveVideoAction = UIAlertAction(title: "Save to camera roll", style: .default) { (action) in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.files[indexPath.row].absoluteURL)
                }, completionHandler: { (pass, error) in

                    if error != nil {
                        print("ERROR Save Video To Camera Roll")
                        self.bhalert.ShowBHAlertController(Title: "hi", message: "ERROR Save Video To Camera Roll", TitleButton: "ok", Target: self)
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        print("Success Save Video To Camera Roll")
                        self.bhalert.ShowBHAlertController(Title: "hi", message: "Success Save Video To Camera Roll", TitleButton: "ok", Target: self)
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                })
            }


            let ShareItem = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareVC = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareVC, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }


            let RenameItemAction = UIAlertAction(title: "Rename video", style: .default) { (action) in

                let TextFieldAlertController = UIAlertController(title: "Add new name", message: "", preferredStyle: .alert)
                TextFieldAlertController.addTextField(configurationHandler: { (TextField) in
                    print(TextField.text!)
                    TextField.text = self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".MP4", with: "", options: .literal)
                })

                let RenameAction = UIAlertAction(title: "Rename!", style: .default, handler: { (action) in
                    FCFileManager.renameItem(atPath: self.files[indexPath.row].lastPathComponent, withName: "\(TextFieldAlertController.textFields![0].text!).MP4")
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.SetupDocumentsDirectoryPath()
                })

                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                TextFieldAlertController.addAction(RenameAction)
                TextFieldAlertController.addAction(Cancel)

                self.present(TextFieldAlertController, animated: true, completion: nil)
            }


            let RemoveItem = UIAlertAction(title: "Remove Item", style: .default) { (action) in

                self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".MP4", with: ""))
                tableView.deselectRow(at: indexPath, animated: true)
            }


            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
            }

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
                tableView.deselectRow(at: indexPath, animated: true)
            }

            let removeitemAction = UIAlertAction(title: "Remove item", style: .default) { (action) in
                self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".webm", with: ""))
                tableView.deselectRow(at: indexPath, animated: true)
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
                tableView.deselectRow(at: indexPath, animated: true)
            }

            let removeitemAction = UIAlertAction(title: "Remove item", style: .default) { (action) in
                self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".3gpp", with: ""))
                tableView.deselectRow(at: indexPath, animated: true)
            }

            let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            BHAlertController.addAction(ShareAction)
            BHAlertController.addAction(removeitemAction)
            BHAlertController.addAction(Cancel)
            self.present(BHAlertController, animated: true, completion: nil)

        } else if String(self.files[indexPath.row].lastPathComponent.suffix(4)) == ".m4a" {
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

                self.BHConvertSwifty.ConvertAudioToVideo(audioURL: self.files[indexPath.row].absoluteURL, destination: URL(string: URL.urlInDocumentsDirectory(with: self.folderName!).path)!, completionHandler: {

                    DispatchQueue.main.async {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }

                    self.SetupDocumentsDirectoryPath()
                })
            }

            let ShareItem = UIAlertAction(title: "Share", style: .default) { (action) in
                let ShareVC = UIActivityViewController(activityItems: [self.files[indexPath.row]], applicationActivities: nil)
                self.present(ShareVC, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }

            let RenameItemAction = UIAlertAction(title: "Rename sound", style: .default) { (action) in

                let TextFieldAlertController = UIAlertController(title: "Add new name", message: "", preferredStyle: .alert)
                TextFieldAlertController.addTextField(configurationHandler: { (TextField) in
                    print(TextField.text!)
                    TextField.text = self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".m4a", with: "", options: .literal)
                })

                let RenameAction = UIAlertAction(title: "Rename!", style: .default, handler: { (action) in
                    FCFileManager.renameItem(atPath: self.files[indexPath.row].lastPathComponent, withName: "\(TextFieldAlertController.textFields![0].text!).m4a")
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.SetupDocumentsDirectoryPath()
                })

                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                TextFieldAlertController.addAction(RenameAction)
                TextFieldAlertController.addAction(Cancel)

                self.present(TextFieldAlertController, animated: true, completion: nil)
            }


            let RemoveItem = UIAlertAction(title: "Remove Item", style: .default) { (action) in
                self.RemoveFile(Path: self.files[indexPath.row].lastPathComponent, FileName: self.files[indexPath.row].lastPathComponent.replacingOccurrences(of: ".m4a", with: ""))
                tableView.deselectRow(at: indexPath, animated: true)
            }

            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
            }

            AlertController.addAction(PlayButtonAction)
            AlertController.addAction(ConvertToVideoAction)
            AlertController.addAction(ShareItem)
            AlertController.addAction(RenameItemAction)
            AlertController.addAction(RemoveItem)
            AlertController.addAction(CancelAction)
            self.present(AlertController, animated: true, completion: nil)
        } else {
            FolderNameSelected2 = files[indexPath.row].lastPathComponent
            print(FolderNameSelected2!)

            let folderVC = self.storyboard?.instantiateViewController(withIdentifier: "foldersVC") as! FolderViewController

            folderVC.folderName = "\(folderName!)/\(FolderNameSelected2!)"
            self.navigationController?.pushViewController(folderVC, animated: true)
        }
    }
}


extension String {
    
    static var DirectoryPath: String? {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsURL = URL(string: documentsDirectory)
        return documentsURL!.absoluteString
    }
}
