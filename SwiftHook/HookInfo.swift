//
//  HookInfo.swift
//  SwiftHook
//
//  Created by hj on 2022/10/11.
//

import Foundation

internal var hookInfo: [HookIdentifier: HookInfo] = [:]

struct HookInfo {
    var beforeClosures: [(AnyObject) -> Void]
    var afterClosures: [(AnyObject) -> Void]
}
