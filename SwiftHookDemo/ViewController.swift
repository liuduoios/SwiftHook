//
//  ViewController.swift
//  SwiftHookDemo
//
//  Created by liuduo on 2022/10/7.
//

import UIKit
import SwiftHook

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        SwiftHook.hook(class: ViewController.self,
//                       fromSelector: #selector(viewWillAppear(_:)),
//                       toSelector: #selector(def))
        
        SwiftHook.hook(class: Self.self,
                       selector: #selector(viewWillAppear(_:)),
                       mode: .before) {
            print("closure")
        }
        
//        let value = ViewController.self
//        let c = object_getClass(value)
        SwiftHook.hook(class: ViewController.self, classSelector: #selector(ViewController.classMethod), mode: .before) {
            print("class method before hook")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        abc()
        Self.classMethod()
    }
    
    @objc dynamic static func classMethod() {
        print("classMethod")
    }

    @objc func abc() {
        print("abc")
    }
    
    @objc dynamic func def() {
        print("def")
        def()
    }
}

