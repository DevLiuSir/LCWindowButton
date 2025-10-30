//
//  LCWindowButton.swift
//  
//
//  Created by DevLiuSir on 2020/12/11.
//

import Foundation
import Cocoa


/// 窗口按钮
class LCWindowButton: NSControl {
    
    // MARK: - Properties
    
    /// 按钮的类型，用于表示窗口按钮的功能（关闭、最小化、全屏等）。
    public var buttonType: LCWindowButtonType = .close {
        didSet {
            isHover = false  // 当按钮类型变化时，取消鼠标悬停效果。
            needsDisplay = true  // 标记需要重新绘制视图。
        }
    }
    
    /// 按钮的`激活状态`，用于指示按钮是否处于激活状态（例如，与当前窗口相关）。
    public var isActive: Bool = false {
        didSet {
            needsDisplay = true  // 标记需要重新绘制视图。
        }
    }
    
    /// 忽略自己的鼠标滑入, default = false
    public var ignoreMouseHover: Bool = false {
        didSet {
            updateTrackingAreas()
        }
    }
    
    /// 是否选中状态
    public var isHover: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    /// 是否禁用全屏按钮，设置 true 时按钮灰色且不可点击
    public var isFullScreenButtonDisabled: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    /// 窗口是否处于`全屏状态`的标志。
    private(set) var isWindowFullScreen: Bool = false {
        didSet {
            needsDisplay = true  // 标记需要重新绘制视图。
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
        trackingAreas.forEach { removeTrackingArea($0) }
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
        if buttonType == .mini {
            isEnabled = false
        }
    }
    
    @objc private func windowDidExitFullScreen() {
        isWindowFullScreen = false
        if buttonType == .mini {
            isEnabled = true
        }
    }
    
    // MARK: - Mouse Tracking
    
    
    /// 更新追踪区域以响应鼠标进入和退出事件
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        // 移除所有现有的追踪区域
        trackingAreas.forEach(removeTrackingArea)
        guard !ignoreMouseHover else { return }
        // 添加新的追踪区域
        let trackingArea = NSTrackingArea( rect: bounds,
                                           options: [.activeAlways, .mouseEnteredAndExited],
                                           owner: self,
                                           userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    /*** 光标进入跟踪区域 ***/
    override func mouseEntered(with event: NSEvent) {
        if let superView = superview, superView.isKind(of: LCWindowOperateView.self) {
            super.mouseEntered(with: event)
        } else {
            isHover = true    // 更新记录值
        }
    }
    
    /*** 光标已退出跟踪区域 ***/
    override func mouseExited(with event: NSEvent) {
        if let superView = superview, superView.isKind(of: LCWindowOperateView.self) {
            super.mouseEntered(with: event)
        } else {
            isHover = false  // 更新记录值
        }
    }
    
    // MARK: - Mouse Events
    
    /// 处理鼠标按下事件
    override func mouseDown(with event: NSEvent) {
        // 如果全屏按钮被禁用，直接忽略点击
        if (buttonType == .fullScreen || buttonType == .exitFullScreen),
           isFullScreenButtonDisabled {
            return
        }
        
        if isEnabled {
            // 设置窗口的第一响应者为当前控件
            window?.makeFirstResponder(self)
        }
        super.mouseDown(with: event)
    }
    
    /// 处理鼠标抬起事件
    override func mouseUp(with event: NSEvent) {
        // 如果全屏按钮被禁用，直接忽略点击
        if (buttonType == .fullScreen || buttonType == .exitFullScreen),
           isFullScreenButtonDisabled {
            return
        }
        if isEnabled, let action = action {
            // 发送指定的动作到目标对象
            NSApp.sendAction(action, to: target, from: self)
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
        
        /// 按钮背景渐变，用于绘制圆形按钮的光影层次效
        var bgGradient: NSGradient?
        /// 背景色
        var strokeColor: NSColor = .clear
        /// 前景色
        var symbolColor: NSColor = .clear
        
        switch buttonType {
        case .close:
            bgGradient = NSGradient(starting: .rgba(255, 95, 86, 1), ending: .rgba(255, 99, 91, 1))
            strokeColor = .rgba(226, 62, 55, 1)
            symbolColor = .rgba(154, 18, 0, 1)
        case .mini:
            bgGradient = NSGradient(starting: .rgba(255, 189, 46, 1), ending: .rgba(255, 197, 47, 1))
            strokeColor = .rgba(223, 157, 24, 1)
            symbolColor = .rgba(153, 88, 1, 1)
        case .fullScreen, .exitFullScreen:
            // 如果全屏按钮被禁用，则绘制 灰色背景 并跳过 符号图形 绘制
            if isFullScreenButtonDisabled {
                bgGradient = NSGradient(starting: .gray, ending: .lightGray)
                strokeColor = .darkGray
                symbolColor = NSColor.white.withAlphaComponent(0.5) // 或其他灰色符号
            } else {
                bgGradient = NSGradient(starting: .rgba(39, 201, 63, 1), ending: .rgba(39, 208, 65, 1))
                strokeColor = .rgba(46, 176, 60, 1)
                symbolColor = .rgba(1, 100, 0, 1)
            }
        }
        
        if !isActive && !isHover {
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
        
        // 如果是最小化按钮，并且窗口处于全屏状态，则不绘制符号
        if buttonType == .mini && isWindowFullScreen { return }
        
        // 如果鼠标没有悬停，则不绘制符号
        guard isHover else { return }
        
        // 如果全屏按钮被禁用，则不绘制全屏/退出全屏符号
        if isFullScreenButtonDisabled && (buttonType == .fullScreen || buttonType == .exitFullScreen) {
            return
        }
        
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
            path.lineWidth = 1.5
            path.lineCapStyle = .round      // 让线条两端呈圆弧状，更加圆润自然
            color.setStroke()
            path.stroke()
        case .mini:
            // shouldAntialia = true 表示开启抗锯齿，系统会对线条边缘进行平滑处理，使得线条看起来更加自然、柔和
            // shouldAntialias = false 表示关闭抗锯齿，绘制出的线条会更加锐利、像素感强。
            NSGraphicsContext.current?.shouldAntialias = true
            let path = NSBezierPath()
            path.move(to: NSPoint(x: width * 0.2, y: height * 0.5))
            path.line(to: NSPoint(x: width * 0.8, y: height * 0.5))
            path.lineWidth = 1.5
            path.lineCapStyle = .round          // 让线条两端呈圆弧状，更加圆润自然
            color.setStroke()
            path.stroke()
            NSGraphicsContext.current?.shouldAntialias = true
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
