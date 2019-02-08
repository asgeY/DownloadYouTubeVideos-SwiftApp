//
//  Video.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public struct PlaybackLink {
    public enum Quality {
        /// 360p
        case small
        /// 480p
        case medium
        /// 720p
        case hd
    }
    
    let quality: Quality
    let url: URL
}

public struct Video {
    
    public struct Thumbnail {
        let small: URL
        let medium: URL
        let maximum: URL
    }
    
    let `id`: String
    let title: String
    let author: String
    let duration: TimeInterval
    let thumbnail: Thumbnail
    
    let links: [PlaybackLink]
}
