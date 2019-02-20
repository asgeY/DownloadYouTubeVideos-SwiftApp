//
//  Result.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 17/01/2019.
//

import Foundation

public enum Result<T, E: Error> {
    case success(_ result: T)
    case error(_ error: E)
}

public extension Result {
    
    @discardableResult
    func ifSuccess(_ block: (T) -> Void) -> Result<T, E> {
        switch self {
        case .success(let result): block(result)
        default:
            break
        }
        
        return self
    }
    
    @discardableResult
    func ifError(_ block: (E) -> Void) -> Result<T, E> {
        switch self {
        case .error(let error): block(error)
        default:
            break
        }
        
        return self
    }
}
