//
//  DocumentsViewController.swift
//  GetProject
//
//  Created by BandarHelal on 05/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation
import CoreVideo
import Photos

class DocumentsViewController: UIViewController {
    
    var selectedPath : URL?
    var files        : [URL]!
    var documentsDirectoryPath : String?
    let bhalert = BHAlert()

    @IBOutlet weak var DocumentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DocumentsTableView.delegate = self
        DocumentsTableView.dataSource = self
        SetupDocumentsDirectoryPath()
}
    
    override func viewWillAppear(_ animated: Bool) {
        SetupDocumentsDirectoryPath()
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
        
        Cell.FileNameLabel.text = FileName.replacingOccurrences(of: ".mp4", with: "")
        
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let AlertController = UIAlertController(title: "hi", message: "select your option", preferredStyle: .actionSheet)
        
        let PlayButtonAction = UIAlertAction(title: "Play video", style: .default) { (action) in
            let PlayerItem = AVPlayerItem(url: URL(string: self.files[indexPath.row].absoluteString)!)
            let Player = AVPlayer(playerItem: PlayerItem)
            let PlayerController = AVPlayerViewController()
            PlayerController.player = Player
            
            self.present(PlayerController, animated: true) {
                Player.play()
            }
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
        
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        AlertController.addAction(PlayButtonAction)
        AlertController.addAction(SaveVideoAction)
        AlertController.addAction(CancelAction)
        self.present(AlertController, animated: true, completion: nil)
    }
}
