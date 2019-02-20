//
//  YTBExtension.swift
//  Pods-YTB_Example
//
//  Created by Dmitry on 17/01/2019.
//

import Foundation

final public class YTBExtension<Target> {
    var target: Target
    
    init(target: Target) {
        self.target = target
    }
}

public protocol YTBExtensionAvailable {
    var ytb: YTBExtension<Self> { get }
}

public extension YTBExtensionAvailable {
    var ytb: YTBExtension<Self> {
        return YTBExtension(target: self)
    }
}
