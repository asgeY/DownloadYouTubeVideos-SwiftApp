//
//  RequestBuilder.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public final class RequestBuilder: IRequestBuilder {
    
    public init() {}
    
    public func buildRequest(forVideoId videoId: String) -> Result<URLRequest, RequestBuilderError> {
        guard let url = URL(string: .apiUrl + videoId) else {
            return .error(.unableToBuildRequest)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = .httpMethodGet
        request.addValue(.userAgent, forHTTPHeaderField: .httpHeaderFieldUserAgent)
        
        return .success(request)
    }
}

private extension String {
    static let apiUrl = "http://www.youtube.com/get_video_info?video_id="
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    
    static let httpHeaderFieldUserAgent = "User-Agent"
    static let httpMethodGet = "GET"
}
