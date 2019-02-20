//
//  ResponseParser.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public final class ResponseParser: IResponseParser {
    
    public init() {}
    
    public func parse(_ input: Data) -> Result<Video, ResponseParserError> {
        
        guard let string = String(data: input, encoding: .utf8) else {
            return .error(.unableToParse)
        }
        
        let parts = string.dictionaryFromQueryStringComponents()
        
        guard let videoId = parts["video_id"] as? String else {
            return .error(.unableToParse)
        }
        
        guard let videoTitle = (parts["title"] as? String)?.removingPercentEncodingAndPlusses else {
            return .error(.unableToParse)
        }
        
        guard let duration = Double(parts["length_seconds"] as? String ?? String()) else {
            return .error(.unableToParse)
        }
        
        guard let author = (parts["author"] as? String)?.removingPercentEncodingAndPlusses else {
            return .error(.unableToParse)
        }
        
        guard let thumbnailUrlString = (parts["thumbnail_url"] as? String)?.removingPercentEncoding else {
            return .error(.unableToParse)
        }
        
        guard let fmtStreamMap = parts["url_encoded_fmt_stream_map"] as? String else {
            return .error(.unableToParse)
        }
        
        guard let decodedFmtStreamMap = fmtStreamMap.removingPercentEncoding else {
            return .error(.unableToParse)
        }
        
        let components = decodedFmtStreamMap.components(separatedBy: ",")
        
        var links = [PlaybackLink]()
        
        for component in components {
            let dict = component.dictionaryFromQueryStringComponents()
            // Getting quality of video
            guard let qualityString = dict["quality"] as? String else { continue }
            guard let quality = PlaybackLink.Quality(videoInfoQuality: qualityString) else { continue }
            // Receiving video URL
            guard let urlString = (dict["url"] as? String)?.removingPercentEncoding else { continue }
            guard let url = URL(string: urlString) else { continue }
            
            if links.first(where: {$0.quality == quality}) == nil {
                links.append(PlaybackLink(quality: quality, url: url))
            }
        }
        
        guard !links.isEmpty else {
            return .error(.unableToParse)
        }
        
        guard let smallThumbnailUrl = URL(string: thumbnailUrlString) else {
            return .error(.unableToParse)
        }
        
        guard let mediumThumbnailUrl = URL(string: thumbnailUrlString.replacingOccurrences(of: "default", with: "mqdefault")) else {
            return .error(.unableToParse)
        }
        
        guard let maximumThumbnailUrl = URL(string: thumbnailUrlString.replacingOccurrences(of: "default", with: "maxresdefault")) else {
            return .error(.unableToParse)
        }
        
        let thumbnail = Video.Thumbnail(small: smallThumbnailUrl,
                                        medium: mediumThumbnailUrl,
                                        maximum: maximumThumbnailUrl)
        
        let video = Video(id: videoId,
                          title: videoTitle,
                          author: author,
                          duration: duration,
                          thumbnail: thumbnail,
                          links: links)
        
        return .success(video)
    }
}

private extension String {
    
    var replacingPluses: String {
        return replacingOccurrences(of: "+", with: " ")
    }
    
    var removingPercentEncodingAndPlusses: String? {
        return removingPercentEncoding?.replacingPluses
    }
    
    func dictionaryFromQueryStringComponents() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        for keyValue in components(separatedBy: "&") {
            let keyValueArray = keyValue.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            let key = keyValueArray[0]
            let value = keyValueArray[1]
            parameters[key] = value as AnyObject
        }
        return parameters
    }
}

private extension PlaybackLink.Quality {
    
    init?(videoInfoQuality: String) {
        switch videoInfoQuality {
        case "small": self = .small
        case "medium": self = .medium
        case "hd720": self = .hd
        default: return nil
        }
    }
}
