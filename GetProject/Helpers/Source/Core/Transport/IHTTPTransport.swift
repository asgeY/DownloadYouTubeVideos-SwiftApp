//
//  IHTTPTransport.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public enum HTTPTransportError: Error {
    case networkError(_ error: Error)
    case unknown
}

public protocol IHTTPTransport {
    
    func execute(request: URLRequest,
                 completion: @escaping (Result<Data, HTTPTransportError>) -> Void)
}
