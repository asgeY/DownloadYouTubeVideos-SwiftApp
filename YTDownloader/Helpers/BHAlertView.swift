//
//  BHAlertView.swift
//  YTDownloader
//
//  Created by BandarHelal on 30/11/2018.
//  Copyright © 2018 BandarHelal. All rights reserved.
//

import Foundation
import UIKit

open class BHAlert: UIAlertController {
    
    
    func ShowBHAlertController(Title: String, message: String,TitleButton: String, Target: UIViewController) {
        let BHVC = UIAlertController(title: Title, message: message, preferredStyle: .alert)
        let BHAction = UIAlertAction(title: TitleButton, style: .default, handler: nil)
        BHVC.addAction(BHAction)
        Target.present(BHVC, animated: true, completion: nil)
        
    }
}
