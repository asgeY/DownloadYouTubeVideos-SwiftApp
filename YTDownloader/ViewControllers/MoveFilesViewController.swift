//
//  MoveFilesViewController.swift
//  YTDownloader
//
//  Created by BandarHelal on 04/04/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit
import FCFileManager

class MoveFilesViewController: UIViewController {

    @IBOutlet weak var MoveFilesTableView: UITableView!
    var selectedPath            : URL?
    var files                   : [URL]!
    var documentsDirectoryPath  : String?
    var FileMovedName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileMovedName ?? "var is empty")
        self.navigationItem.title = "Select the folder to move file"
        MoveFilesTableView.delegate = self
        MoveFilesTableView.dataSource = self
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
            self.MoveFilesTableView.reloadData()
            self.MoveFilesTableView.beginUpdates()
            self.MoveFilesTableView.reloadRows(at: self.MoveFilesTableView.indexPathsForVisibleRows!, with: UITableView.RowAnimation.automatic)
            self.MoveFilesTableView.endUpdates();
        }
    }

}

extension MoveFilesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let Cell = MoveFilesTableView.dequeueReusableCell(withIdentifier: "MoveCell") as? MoveFilesTableViewCell else {
            return UITableViewCell()
        }
        
        let filePath = (files?[(indexPath as NSIndexPath).row])!
        let FileName = filePath.lastPathComponent
        
        if FCFileManager.isDirectoryItem(atPath: FileName) {
            Cell.FileNameLabel.text = FileName
        }
        return Cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print(files[indexPath.row].lastPathComponent)
        let FolderName = files[indexPath.row].lastPathComponent
        
        guard let FileMovedNameName = FileMovedName else {
            print("var is empty")
            return
        }
        FCFileManager.moveItem(atPath: FileMovedNameName, toPath: "\(FolderName)/\(FileMovedNameName)")
        self.dismiss(animated: true, completion: nil)
    }
}
