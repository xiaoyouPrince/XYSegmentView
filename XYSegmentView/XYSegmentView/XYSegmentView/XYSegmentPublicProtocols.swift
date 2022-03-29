//
//  XYSegmentPublicProtocols.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/8.
//

/// 滑块协议
/// 活动类型 【平滑(宽度同步对应的Item) / 圆点到另一个圆点，过程中‘会/不会’变长 / 背景滑块】

import UIKit

fileprivate struct AssociatedKeys {
    static var configKey: String = String()
}

/// ContentView 协议，定义了 ContentView 的基本操作
public protocol XYSegmentConfigProtocol: AnyObject {
    var config: XYSegmentViewConfig {set get}
}

public extension XYSegmentConfigProtocol {
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
        
        if self is UIView & XYSegmentViewTitleItemProtocol,
        let item = self as? UIView {
            return item.tag
        }
        return -1
    }
    
    /// 获取全局用户自定义扩展的信息
    var userInfo: [String: Any] {
        return config.userInfo
    }
}


/// TitleView 协议，定义了 TitleView 的基本操作
public protocol XYSegmentViewTitleItemProtocol: AnyObject {
    
    /// 获取 item 的标题
    var title: String { get }
    
    /// 设置其普通状态
    func setNormalState()
    
    /// 设置其完全被选中状态
    func setSelectedState()
    
    /// 设置状态进度，即 normalState 和 selectedState 之间的过程状态，
    /// - 不实现则只有两种状态
    func setState(with progress: CGFloat)
    
}

public extension XYSegmentViewTitleItemProtocol {
    var title: String { "" }
    func setNormalState() { }
    func setSelectedState() { }
    func setState(with progress: CGFloat) { /*不实现就直接使用两级状态*/}
    func setProgress(progress: CGFloat) {
        if progress <= 0.01 {
            setNormalState()
        }else if progress >= 0.99 {
            setSelectedState()
        }else{
            // 用户自己实现
            setState(with: progress)
        }
    }
}

/// TitleView 协议，定义了 TitleView 的基本操作
public protocol XYSegmentViewSliderProtocol: AnyObject {
    
}

public extension XYSegmentViewSliderProtocol {
    
}

/// TitleView 协议，定义了 TitleView 的基本操作
public protocol XYSegmentTitleViewProtocol: AnyObject {
    
}

public extension XYSegmentTitleViewProtocol {
    
}

/// ContentView 协议，定义了 ContentView 的基本操作
public protocol XYSegmentContainerViewProtocol: AnyObject {
    
}

public extension XYSegmentContainerViewProtocol {
    
}
