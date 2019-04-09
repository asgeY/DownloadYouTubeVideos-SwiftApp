//
//  FolderTableViewCell.swift
//  YTDownloader
//
//  Created by BandarHelal on 02/04/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var ImageFile: UIImageView!
    @IBOutlet weak var NameFile: UILabel!
    @IBOutlet weak var SizeFile: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
