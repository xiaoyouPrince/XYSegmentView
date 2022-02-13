//
//  XYSegmentViewConfig.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/7.
//

/// 一个负责配置 Segment View 的类
/// Segment View 样式、内容、一些代理的展示

import UIKit

public enum ScrollLineType {
    case `default`
    case line
    case dot
}

open class XYSegmentViewConfig: NSObject {
    
    /// 设置XYSegmentView整体的 frame
    ///
    /// - 子视图的 frame 设置应匹配整体  frame
    var frame: CGRect = CGRect(x: 0, y: kNavHeight, width: kScreenW, height: kScreenH - kNavHeight - kTabSafeH)
    
    /// container 容器内容是否可以横向滑动切换 content
    var contentScrollEnable: Bool = true
    
    // MARK: - title 相关
    
    /// titleView 高度
    var titleViewFrame: CGRect = CGRect(x: 0, y: 0, width: kScreenW, height: 44)
    
    /// 快速设置 titleItem 为简单标题的 item
    var titles: [String] = ["没有","设置","分页","!"]
    
    /// 两个 title 之间间距, 则以某个 title 为参考单边为 10.
    var titleMargin: CGFloat = 20
    
    /// 设置 title 在 titleView 中布局是否为均分宽度，默认 false
    var isTitleAverageLayout: Bool = false
    
    
    // MARK: - title 底部滑块 相关
    var scrollLineType: ScrollLineType = .default
    
    /// 设置滑块的内边距，以 TitleItem 为准，设置其左右两侧边距
    var scrollLineInnerMargin: CGFloat = 0
    
    /// 设置滑块是否跟随滑动，即滑动过程是否有中间状态
    var scrollLineFollowSliding: Bool = true
    
    // MARK: - content 相关
    
    /// 默认的内容容器的 frame
    var containerViewFrame: CGRect = CGRect(x: 0, y: 44, width: kScreenW, height: kScreenH - 44)
    
    /// 内容VCs， 数组个数必须和 titles.count 相同
    var contentVCs: [UIViewController] = [vc(),vc(),vc(),vc()]
    
    /// segmentView 要加载到的 VC。
    ///
    /// - 当前版本必须要赋值
    var superVC: UIViewController!
    
    /// 用户自定义的扩展信息
    ///
    /// - 比如一些 XYSegmentView 组件内全局通用的数据信息
    /// - 比如埋点时候。最顶层 view 要埋一些基础配置的参数
    var userInfo: [String: Any] = [:]
}

class vc: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randomColor()
    }
}
