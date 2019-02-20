//
//  DocumentsTableViewCell.swift
//  YTDownloader
//
//  Created by BandarHelal on 05/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import UIKit

class DocumentsTableViewCell: UITableViewCell {

    @IBOutlet weak var SizeandDurVideo   : UILabel!
    @IBOutlet weak var ImageFile         : UIImageView!
    @IBOutlet weak var FileNameLabel     : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
