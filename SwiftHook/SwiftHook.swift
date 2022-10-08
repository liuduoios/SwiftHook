//
//  SwiftHook.swift
//  SwiftHook
//
//  Created by liuduo on 2022/10/7.
//

import Foundation

public enum HookMode {
    case before
    case after
    case instead
}

public class SwiftHook {
    public static func hook(`class`: AnyClass, fromSelector: Selector, toSelector: Selector) {
        guard let fromMethod = class_getInstanceMethod(`class`, fromSelector),
              let toMethod = class_getInstanceMethod(`class`, toSelector) else {
            return
        }
        // 为 fromSelector 添加 toMethod 的实现
        if (class_addMethod(`class`, fromSelector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
            // 添加成功，代表类之前没有 fromSelector 这个方法
            // 把 toSelector 方法的实现替换成 fromMethod 的实现
            class_replaceMethod(`class`, toSelector, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod))
        } else {
            // 添加失败，代表之前存在 fromSelector 这个方法
            method_exchangeImplementations(fromMethod, toMethod)
        }
    }
    
    static func hook(`class`: AnyClass, selector: Selector, mode: HookMode, closure: @convention(block) @escaping () -> Void) {
        let method = class_getInstanceMethod(`class`, selector)
        let imp = imp_implementationWithBlock(closure)
        let signature = blockSignature(closure)
        class_addMethod(`class`, selector, imp, signature)
    }
    
    static func hook(instance: AnyObject, selector: Selector, mode: HookMode, closure: () -> Void) {
        
    }
}
