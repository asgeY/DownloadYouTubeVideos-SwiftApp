//
//  YTB.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 17/01/2019.
//

import Foundation

public final class YTB {
    
    // MARK: - Private properties
    private let transport: IHTTPTransport
    private let requestBuilder: IRequestBuilder
    private let responseParser: IResponseParser
    
    public enum Error: Swift.Error {
        case unableToResolveVideoId
        case requestBuilderError(_ error: RequestBuilderError)
        case transportError(_ error: HTTPTransportError)
        case parserError(_ error: ResponseParserError)
    }
    
    public init(transport: IHTTPTransport = HTTPTransport(),
                requestBuilder: IRequestBuilder = RequestBuilder(),
                responseParser: IResponseParser = ResponseParser()) {
        
        self.transport = transport
        self.requestBuilder = requestBuilder
        self.responseParser = responseParser
    }
    
    public func getYoutubeVideo(withVideoUrl url: URL,
                                completion: @escaping (Result<Video, YTB.Error>) -> Void) {
        getYoutubeVideo(withVideoUrlString: url.absoluteString,
                        completion: completion)
    }
    
    public func getYoutubeVideo(withVideoUrlString urlString: String,
                                completion: @escaping (Result<Video, YTB.Error>) -> Void) {
        
        if let videoId = urlString.ytb.youtubeVideoId {
            getYoutubeVideo(withVideoId: videoId,
                            completion: completion)
        } else {
            completion(.error(.unableToResolveVideoId))
        }
    }
    
    public func getYoutubeVideo(withVideoId videoId: String,
                                completion: @escaping (Result<Video, YTB.Error>) -> Void) {
        requestBuilder.buildRequest(forVideoId: videoId).ifSuccess { (request) in
            transport.execute(request: request) { (result) in
                result.ifSuccess({ (data) in
                    // Parsing data to video object
                    self.responseParser.parse(data).ifSuccess({ (video) in
                        completion(.success(video))
                    }).ifError({ (error) in
                        completion(.error(.parserError(error)))
                    })
                }).ifError({ (error) in
                    completion(.error(.transportError(error)))
                })
            }
        }.ifError { (error) in
            completion(.error(.requestBuilderError(error)))
        }
    }
}
