//
//  ViewController.swift
//  LCWindowButtonDemo
//
//  Created by DevLiuSir on 2020/3/2.
//
    

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let windowButtonView = LCWindowOperateView(buttonTypes: [.close, .mini, .fullScreen])
        windowButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(windowButtonView)
        NSLayoutConstraint.activate([
            windowButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            windowButtonView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            windowButtonView.widthAnchor.constraint(equalToConstant: 55),
            windowButtonView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

