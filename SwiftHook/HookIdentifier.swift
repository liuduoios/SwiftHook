//
//  HookIdentifier.swift
//  SwiftHook
//
//  Created by hj on 2022/10/11.
//

import Foundation

struct HookIdentifier: Hashable {
    private let identifier: String
    
    init(`class`: AnyClass, selector: Selector) {
        identifier = String(describing: ObjectIdentifier(`class`)) + NSStringFromSelector(selector)
    }
}
