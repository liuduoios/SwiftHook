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
        
        SwiftHook.hook(class: ViewController.self,
                       selector: #selector(viewWillAppear(_:)),
                       mode: .before) {
            print("closure")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        abc()
    }

    @objc func abc() {
        print("abc")
    }
    
    @objc dynamic func def() {
        print("def")
        def()
    }
}

