//
//  URL+YouTube.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 17/01/2019.
//

import Foundation

extension URL: YTBExtensionAvailable {}

public extension YTBExtension where Target == URL {
    
    var isYoutubeVideoUrl: Bool {
        return target.absoluteString.ytb.isYoutubeVideoUrl
    }
    
    var youtubeVideoId: String? {
        return target.absoluteString.ytb.youtubeVideoId
    }
}
