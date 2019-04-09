//
//  MoveFilesTableViewCell.swift
//  YTDownloader
//
//  Created by BandarHelal on 04/04/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit

class MoveFilesTableViewCell: UITableViewCell {

    @IBOutlet weak var FileNameLabel: UILabel!
    @IBOutlet weak var FileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
