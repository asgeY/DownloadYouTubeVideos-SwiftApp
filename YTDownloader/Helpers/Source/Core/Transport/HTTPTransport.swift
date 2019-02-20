//
//  HTTPTransport.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public final class HTTPTransport: IHTTPTransport {
    
    // MARK: - Private properties
    private let session = URLSession.shared
    
    // MARK: - Public methods
    public init() {}
    
    public func execute(request: URLRequest,
                        completion: @escaping (Result<Data, HTTPTransportError>) -> Void) {
        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    completion(.success(data))
                } else {
                    let resolvedError = (error != nil) ? HTTPTransportError.networkError(error!) : HTTPTransportError.unknown
                    
                    completion(.error(resolvedError))
                }
            }
        }.resume()
    }
}
