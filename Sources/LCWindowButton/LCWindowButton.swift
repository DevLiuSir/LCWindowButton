// The Swift Programming Language
// https://docs.swift.org/swift-book

//
//  LCWindowButton.swift
//  WindowButton
//
//  Created by DevLiuSir on 2020/12/11.
//

import Foundation
import Cocoa


/// 窗口按钮
class LCWindowButton: NSControl {
    
    // MARK: - Properties
    
    /// 按钮的类型，用于表示窗口按钮的功能（关闭、最小化、全屏等）。
    var buttonType: LCWindowButtonType = .close {
        didSet {
            hover = false  // 当按钮类型变化时，取消鼠标悬停效果。
            needsDisplay = true  // 标记需要重新绘制视图。
        }
    }
    
    /// 按钮的`激活状态`，用于指示按钮是否处于激活状态（例如，与当前窗口相关）。
    var isActive: Bool = false {
        didSet {
            needsDisplay = true  // 标记需要重新绘制视图。
        }
    }
    
    /// 窗口是否处于`全屏状态`的标志。
    private var isWindowFullScreen: Bool = false {
        didSet {
            needsDisplay = true  // 标记需要重新绘制视图。
        }
    }
    
    /// 忽略自己的鼠标滑入, default = false
    var ignoreMouseHover: Bool = false {
        didSet {
            updateTrackingAreas()
        }
    }
    /// 是否选中状态
    var hover: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    // MARK: - Initializers
    
    /// 根据`指定的按钮类型`创建一个窗口按钮实例。
    /// - Parameter buttonType: 按钮的类型，例如关闭、最小化、全屏等。
    /// - Returns: 配置好的 `LCWindowButton` 实例。
    static func button(withType buttonType: LCWindowButtonType) -> LCWindowButton {
        return LCWindowButton(type: buttonType)
    }
    
    /// 使用`指定的按钮类型`初始化`窗口按钮`。
    /// - Parameter type: 按钮的类型，例如关闭、最小化、全屏等。
    init(type: LCWindowButtonType) {
        self.buttonType = type  // 设置按钮的类型。
        super.init(frame: .zero)  // 调用父类的初始化方法，设置默认的 frame。
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Window State Listeners
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeActive), name: NSWindow.didBecomeKeyNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignActive), name: NSWindow.didResignKeyNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidFullScreen), name: NSWindow.didEnterFullScreenNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidExitFullScreen), name: NSWindow.didExitFullScreenNotification, object: window)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Handle notification
    
    @objc private func windowDidBecomeActive() {
        isActive = true
    }
    
    @objc private func windowDidResignActive() {
        isActive = false
    }
    
    @objc private func windowDidFullScreen() {
        isWindowFullScreen = true
    }
    
    @objc private func windowDidExitFullScreen() {
        isWindowFullScreen = false
    }
    
    // MARK: - Mouse Tracking
    
    
    /// 更新追踪区域以响应鼠标进入和退出事件
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        // 移除所有现有的追踪区域
        trackingAreas.forEach(removeTrackingArea)
        guard !ignoreMouseHover else { return }
        // 添加新的追踪区域
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    /*** 光标进入跟踪区域 ***/
    override func mouseEntered(with event: NSEvent) {
        hover = true    // 更新记录值
    }
    
    /*** 光标已退出跟踪区域 ***/
    override func mouseExited(with event: NSEvent) {
        hover = false  // 更新记录值
    }
    
    // MARK: - Mouse Events
    
    /// 处理鼠标按下事件
    override func mouseDown(with event: NSEvent) {
        if isEnabled {
            // 设置窗口的第一响应者为当前控件
            window?.makeFirstResponder(self)
        }
        super.mouseDown(with: event)
    }
    
    /// 处理鼠标抬起事件
    override func mouseUp(with event: NSEvent) {
        if isEnabled {
            if let action = action {
                // 发送指定的动作到目标对象
                NSApp.sendAction(action, to: target, from: self)
            }
        }
        super.mouseUp(with: event)
    }
    
    /// 控件是否接受第一响应者状态
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    /// 成为第一响应者时的处理
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    
    
    // MARK: - Drawing
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let width = bounds.width
        let height = bounds.height
        
        var bgGradient: NSGradient?
        var strokeColor: NSColor = .clear
        var symbolColor: NSColor = .clear
        
        switch buttonType {
        case .close:
            bgGradient = NSGradient(starting: .rgba(255, 95, 86, 1), ending: .rgba(255, 99, 91, 1))
            strokeColor = .rgba(226, 62, 55, 1)
            symbolColor = .rgba(77, 0, 0, 1)
        case .mini:
            bgGradient = NSGradient(starting: .rgba(255, 189, 46, 1), ending: .rgba(255, 197, 47, 1))
            strokeColor = .rgba(223, 157, 24, 1)
            symbolColor = .rgba(153, 88, 1, 1)
        case .fullScreen, .exitFullScreen:
            bgGradient = NSGradient(starting: .rgba(39, 201, 63, 1), ending: .rgba(39, 208, 65, 1))
            strokeColor = .rgba(46, 176, 60, 1)
            symbolColor = .rgba(1, 100, 0, 1)
        }
        
        if !isActive && !hover {
            bgGradient = NSGradient(starting: .rgba(79, 83, 79, 1), ending: .rgba(75, 79, 75, 1))
            strokeColor = .rgba(65, 65, 65, 1)
        }
        
        if buttonType == .mini && isWindowFullScreen {
            bgGradient = NSGradient(starting: .rgba(94, 98, 94, 1), ending: .rgba(90, 94, 90, 1))
            strokeColor = .rgba(80, 80, 80, 1)
        }
        
        let path = NSBezierPath(ovalIn: NSRect(x: 0.5, y: 0.5, width: width - 1, height: height - 1))
        bgGradient?.draw(in: path, relativeCenterPosition: .zero)
        strokeColor.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        
        if buttonType == .mini && isWindowFullScreen { return }
        
        guard hover else { return }
        
        drawSymbol(for: buttonType, in: NSRect(x: 0, y: 0, width: width, height: height), with: symbolColor)
    }
    
    
    /// 绘制按钮符号（如关闭、最小化、全屏等）
    /// - Parameters:
    ///   - buttonType: 按钮类型，用于决定绘制的符号类型
    ///   - rect: 绘制区域的矩形框
    ///   - color: 符号的颜色
    private func drawSymbol(for buttonType: LCWindowButtonType, in rect: NSRect, with color: NSColor) {
        let width = rect.width
        let height = rect.height
        
        switch buttonType {
        case .close:
            let path = NSBezierPath()
            path.move(to: NSPoint(x: width * 0.3, y: height * 0.3))
            path.line(to: NSPoint(x: width * 0.7, y: height * 0.7))
            path.move(to: NSPoint(x: width * 0.7, y: height * 0.3))
            path.line(to: NSPoint(x: width * 0.3, y: height * 0.7))
            path.lineWidth = 1
            color.setStroke()
            path.stroke()
        case .mini:
            let path = NSBezierPath()
            path.move(to: NSPoint(x: width * 0.2, y: height * 0.5))
            path.line(to: NSPoint(x: width * 0.8, y: height * 0.5))
            path.lineWidth = 2
            color.setStroke()
            path.stroke()
        case .fullScreen:
            let path = NSBezierPath()
            path.move(to: NSPoint(x: width * 0.25, y: height * 0.75))
            path.line(to: NSPoint(x: width * 0.25, y: height / 3))
            path.line(to: NSPoint(x: width * 2 / 3, y: height * 0.75))
            path.close()
            color.setFill()
            path.fill()
            
            path.move(to: NSPoint(x: width * 0.75, y: height * 0.25))
            path.line(to: NSPoint(x: width * 0.75, y: height * 2 / 3))
            path.line(to: NSPoint(x: width / 3, y: height * 0.25))
            path.close()
            color.setFill()
            path.fill()
        case .exitFullScreen:
            let path = NSBezierPath()
            path.move(to: NSPoint(x: width * 0.1, y: height * 0.52))
            path.line(to: NSPoint(x: width * 0.48, y: height * 0.52))
            path.line(to: NSPoint(x: width * 0.48, y: height * 0.9))
            path.close()
            color.setFill()
            path.fill()
            
            path.move(to: NSPoint(x: width * 0.9, y: height * 0.48))
            path.line(to: NSPoint(x: width * 0.52, y: height * 0.48))
            path.line(to: NSPoint(x: width * 0.52, y: height * 0.1))
            path.close()
            color.setFill()
            path.fill()
        }
    }
    
   
}
