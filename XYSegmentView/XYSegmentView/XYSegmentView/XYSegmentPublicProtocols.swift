//
//  XYSegmentPublicProtocols.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/8.
//

import UIKit

fileprivate struct AssociatedKeys {
    static var configKey: String = String()
}

/// ContentView 协议，定义了 ContentView 的基本操作
public protocol XYSegmentConfigProtocol: AnyObject {
    var config: XYSegmentViewConfig {set get}
}

extension XYSegmentConfigProtocol {
    /// contentVC 可以实现此协议
    /// 快速获取一些配置参数
    
    var config: XYSegmentViewConfig {
        get {
            guard let config_ = objc_getAssociatedObject(self, &AssociatedKeys.configKey) as? XYSegmentViewConfig else {
                return XYSegmentViewConfig()
            }
            return config_
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.configKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 获取当前 contentVC 的 index。 返回值 -1 表示没有在数组内
    var currentSegmentIndex: Int {
        if self is UIViewController {
            return config.contentVCs.firstIndex(of: self as! UIViewController) ?? -1
        }
        return -1
    }
    
    /// 获取全局用户自定义扩展的信息
    var userInfo: [String: Any] {
        return config.userInfo
    }
}

/// TitleView 协议，定义了 TitleView 的基本操作
public protocol XYSegmentTitleViewProtocol: AnyObject {
    
}

extension XYSegmentTitleViewProtocol {
    
}

/// ContentView 协议，定义了 ContentView 的基本操作
public protocol XYSegmentContainerViewProtocol: AnyObject {
    
}

extension XYSegmentContainerViewProtocol {
    
}
