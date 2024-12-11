//
//  NSColor+Extension.swift
//  WindowButton
//
//  Created by DevLiuSir on 2020/12/11.
//

import Cocoa

/// 扩展NSColor
extension NSColor {
    
    /// 创建一个指定 RGBA 值的颜色
    ///
    /// - Parameters:
    ///   - r: 红色通道的值（0~255）
    ///   - g: 绿色通道的值（0~255）
    ///   - b: 蓝色通道的值（0~255）
    ///   - a: 透明度通道的值（0~1.0）
    /// - Returns: 根据指定 RGBA 值生成的 `NSColor` 对象
    static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> NSColor {
        return NSColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}

