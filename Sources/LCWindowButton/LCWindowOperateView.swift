//
//  LCWindowOperateView.swift
//  WindowButton
//
//  Created by DevLiuSir on 2020/12/11.
//

import Foundation
import Cocoa



/// 按钮的高度
let kLCWindowButtonWH: CGFloat = 13.0



/// 窗口操作视图
public class LCWindowOperateView: NSView {
    
    /// 按钮类型数组，用于确定窗口操作视图中包含哪些按钮
    var buttonTypes: [LCWindowButtonOperateType]
    
    /// 点击事件回调，返回被点击的按钮类型
    var clickHandler: ((LCWindowButtonType) -> Void)?
    

    // MARK: - Initializers

    /// 初始化 LCWindowOperateView
    /// - Parameter buttonTypes: 包含按钮类型的数组，用于确定需要显示的按钮
    public init(buttonTypes: [LCWindowButtonOperateType]) {
        self.buttonTypes = buttonTypes
        super.init(frame: .zero)
        setupButtons()  // 设置按钮
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 创建并返回一个 LCWindowOperateView 实例
    /// - Parameter buttonTypes: 包含按钮类型的数组
    /// - Returns: 配置了指定按钮类型的 LCWindowOperateView 实例
    static func operateView(buttonTypes: [LCWindowButtonOperateType]) -> LCWindowOperateView {
        return LCWindowOperateView(buttonTypes: buttonTypes)
    }
    
    
    // MARK: - Setup Buttons

    /// 设置按钮
    private func setupButtons() {
        for (_ , buttonType) in buttonTypes.enumerated() {
            guard let buttonType = LCWindowButtonType(rawValue: buttonType.rawValue) else { continue }
            if buttonType == .exitFullScreen {
                // 退出全屏
                continue
            }
            let button = LCWindowButton(type: buttonType)
            button.ignoreMouseHover = true
            button.target = self
            button.action = #selector(operateButtonClicked(_:))
            addSubview(button)
        }
        self.frame = NSRect(x: 0, y: 0, width: CGFloat(subviews.count) * (kLCWindowButtonWH + 7.5) - 7.5, height: 15)
    }

    
    // MARK: - Layout
    
    
    /// 指定视图的坐标系是否是翻转的
    /// 返回 `true` 表示原点位于左上角
    public override var isFlipped: Bool {
        return true
    }

    /// 布局子视图
    /// 根据视图宽度和子按钮的宽度动态排列子视图
    public override func layout() {
        super.layout()
        var left: CGFloat = 0 // 子视图的起始 x 坐标
        var frame = NSRect(x: 0, y: 0, width: kLCWindowButtonWH, height: kLCWindowButtonWH)
        
        // 设置子视图在垂直方向上的居中
        frame.origin.y = (bounds.height - kLCWindowButtonWH) / 2
        
        for subview in subviews {
            guard let button = subview as? LCWindowButton else { continue } // 忽略非 LCWindowButton 类型的子视图
            frame.origin.x = left   // 设置按钮的 x 坐标
            button.frame = frame    // 应用计算好的框架
            left = frame.maxX + 7.5 // 更新下一个按钮的起始 x 坐标
        }
    }
    
    

    // MARK: - Mouse Tracking
    // 更新鼠标跟踪区域， 用于监控鼠标进入和离开视图的事件
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) } // 移除已有的跟踪区域
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseEnteredAndExited], // 始终激活，监听鼠标进入和退出
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea) // 添加新的跟踪区域
    }

    /** 处理鼠标进入区域 **/
    public override func mouseEntered(with event: NSEvent) {
        // 设置所有子按钮的 hover 状态为 true
        subviews.forEach { (subview) in
            (subview as? LCWindowButton)?.hover = true
        }
    }

    /** 处理鼠标离开区域 **/
    public override func mouseExited(with event: NSEvent) {
        // 设置所有子按钮的 hover 状态为 false
        subviews.forEach { (subview) in
            (subview as? LCWindowButton)?.hover = false
        }
    }
    
    
    // MARK: - Button Actions

    /// 按钮点击事件的处理方法
    /// - Parameter sender: 被点击的按钮
    @objc private func operateButtonClicked(_ sender: LCWindowButton) {
        guard let window = self.window else { return }
        switch sender.buttonType {
        case .close:
            window.performClose(sender)
        case .mini:
            window.performMiniaturize(sender)
        case .fullScreen:
            window.toggleFullScreen(sender)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                sender.buttonType = .exitFullScreen
            }
        case .exitFullScreen:
            window.toggleFullScreen(sender)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                sender.buttonType = .fullScreen
            }
        }
        subviews.forEach { (subview) in
            (subview as? LCWindowButton)?.hover = false
        }
        clickHandler?(sender.buttonType)
    }

    // MARK: - Helper Method

    /// 查找`指定类型的按钮`
    /// - Parameter buttonType: 按钮的类型
    /// - Returns: 与指定类型匹配的按钮，如果未找到则返回 `nil`
    func button(withType buttonType: LCWindowButtonType) -> LCWindowButton? {
        return subviews.compactMap { $0 as? LCWindowButton }.first { $0.buttonType == buttonType }
    }
}
