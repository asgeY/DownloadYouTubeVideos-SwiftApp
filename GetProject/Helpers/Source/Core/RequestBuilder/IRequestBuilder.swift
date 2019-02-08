//
//  IRequestBuilder.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public enum RequestBuilderError: Error {
    case unableToBuildRequest
}

public protocol IRequestBuilder {
    func buildRequest(forVideoId videoId: String) -> Result<URLRequest, RequestBuilderError>
}
