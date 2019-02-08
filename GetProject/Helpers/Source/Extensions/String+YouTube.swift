//
//  String+YouTube.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 17/01/2019.
//

import Foundation

extension String: YTBExtensionAvailable {}

public extension YTBExtension where Target == String {
    
    var isYoutubeVideoUrl: Bool {
        return youtubeVideoId != nil
    }
    
    var youtubeVideoId: String? {
        do {
            let regex = try NSRegularExpression(pattern: .youtubeVideoIdRegex)
            
            let matches = regex.matches(in: target,
                                        range: NSRange(location: 0, length: target.count))
            
            return matches.compactMap({
                return (target as NSString).substring(with: $0.range)
            }).first
        } catch { }
        
        return nil
    }
}

private extension String {
    static let youtubeVideoIdRegex = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
}
