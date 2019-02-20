//
//  IResponseParser.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 18/01/2019.
//

import Foundation

public enum ResponseParserError: Error {
    case unableToParse
}

public protocol IResponseParser {
    
    func parse(_ input: Data) -> Result<Video, ResponseParserError>
}
