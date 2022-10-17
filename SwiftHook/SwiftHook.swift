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
    
    /// Hook 类方法
    /// - Parameters:
    ///   - `class`: 类对象
    ///   - classSelector: 类方法 SEL
    ///   - mode: hook 模式
    ///   - closure: 要添加的代码
    public static func hook(`class`: AnyClass, classSelector: Selector, mode: HookMode, closure: @convention(block) @escaping (AnyObject) -> Void) {
        guard let method = class_getClassMethod(`class`, classSelector) else {
            return
        }
        hook(class: `class`, classMethod: method, mode: mode, closure: closure)
    }
    
    /// Hook 实例方法
    /// - Parameters:
    ///   - `class`: 类对象
    ///   - selector: 类方法 SEL
    ///   - mode: hook 模式
    ///   - closure: 要添加的代码
    public static func hook(`class`: AnyClass, selector: Selector, mode: HookMode, closure: @convention(block) @escaping (AnyObject) -> Void) {
        guard let method = class_getInstanceMethod(`class`, selector) else {
            return
        }
        hook(class: `class`, method: method, mode: mode, closure: closure)
    }
    
    private static func hook(`class`: AnyClass, classMethod method: Method, mode: HookMode, closure: @convention(block) @escaping (AnyObject) -> Void) {
        let selector = method_getName(method)
        let toSelector = NSSelectorFromString("SwiftHook_\(NSStringFromSelector(selector))")
        
        let identifier = HookIdentifier(class: `class`, selector: selector)
        let hasHooked = identifier.hasHooked()
        saveIdentifier(identifier, mode: mode, closure: closure)
        if hasHooked { return }
        
        let callClosure = finalClosure(identifier, toSelector: toSelector)
        let callClosureImp = imp_implementationWithBlock(callClosure)
        let callClosureSignature = blockSignature(callClosure)
        
        if (class_addMethod(object_getClass(`class`), selector, callClosureImp, callClosureSignature)) {
            class_replaceMethod(`class`, toSelector, method_getImplementation(method), method_getTypeEncoding(method))
        } else {
            // 把闭包添加成类的一个方法
            class_addMethod(object_getClass(`class`), toSelector, callClosureImp, callClosureSignature)
            guard let toMethod = class_getClassMethod(`class`, toSelector) else {
                return
            }
            // 交换新添加的方法和原方法
            method_exchangeImplementations(method, toMethod)
        }
    }
    
    private static func hook(`class`: AnyClass, method: Method, mode: HookMode, closure: @convention(block) @escaping (AnyObject) -> Void) {
        let selector = method_getName(method)
        let toSelector = NSSelectorFromString("SwiftHook_\(NSStringFromSelector(selector))")
        
        let identifier = HookIdentifier(class: `class`, selector: selector)
        let hasHooked = identifier.hasHooked()
        saveIdentifier(identifier, mode: mode, closure: closure)
        if hasHooked { return }
        
        let callClosure = finalClosure(identifier, toSelector: toSelector)
        let callClosureImp = imp_implementationWithBlock(callClosure)
        let callClosureSignature = blockSignature(callClosure)
        
        if (class_addMethod(`class`, selector, callClosureImp, callClosureSignature)) {
            class_replaceMethod(`class`, toSelector, method_getImplementation(method), method_getTypeEncoding(method))
        } else {
            // 把闭包添加成类的一个方法
            class_addMethod(`class`, toSelector, callClosureImp, callClosureSignature)
            guard let toMethod = class_getInstanceMethod(`class`, toSelector) else {
                return
            }
            // 交换新添加的方法和原方法
            method_exchangeImplementations(method, toMethod)
        }
    }
    
    private static func saveIdentifier(_ identifier: HookIdentifier, mode: HookMode, closure: @convention(block) @escaping (AnyObject) -> Void) {
        var info: HookInfo! = hookInfo[identifier]
        if info == nil {
            info = HookInfo(beforeClosures: [], afterClosures: [])
        }
        switch mode {
        case .before:
            info.beforeClosures.append(closure)
        case .after:
            info.afterClosures.append(closure)
        case .instead:
            break
        }
        hookInfo[identifier] = info
    }
    
    /// 生成最终要用来替换的闭包
    /// - Parameters:
    ///   - closure: 要被包装的闭包
    ///   - toSelector: 要替换成的 Selector，替换后代表原方法
    /// - Returns: 包装后的闭包
    private static func finalClosure(_ identifier: HookIdentifier, toSelector: Selector) -> @convention(block) (AnyObject) -> Void {
        let callClosure: @convention(block) (AnyObject) -> Void = { object in
            if let hookInfo = hookInfo[identifier] {
                for closure in hookInfo.beforeClosures {
                    closure(object)
                }
            }
            
            // 调用原函数
            _ = object.perform(toSelector)
            
            if let hookInfo = hookInfo[identifier] {
                for closure in hookInfo.afterClosures {
                    closure(object)
                }
            }
        }
        return callClosure
    }
    
    static func hook(instance: AnyObject, selector: Selector, mode: HookMode, closure: () -> Void) {
        
    }
}
