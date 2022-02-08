//
//  XYSegmentViewConfig.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/7.
//

/// 一个负责配置 Segment View 的类
/// Segment View 样式、内容、一些代理的展示

import UIKit

open class XYSegmentViewConfig: NSObject {
    
    var frame: CGRect = CGRect(x: 0, y: kNavHeight, width: kScreenW, height: kScreenH - kNavHeight - kTabSafeH)
    
    // MARK: - title 相关
    
    /// titleView 高度
    var titleViewFrame: CGRect = CGRect(x: 0, y: 0, width: kScreenW, height: 44)
    /// 快速设置 titleItem 为简单标题的 item
    var titles: [String] = ["没有","设置","分页","!"]
    /// 两个 title 之间间距, 则以某个 title 为参考单边为 10.
    var titleMargin: CGFloat = 20
    /// 设置 title 在 titleView 中布局是否为均分宽度，默认 false
    var isTitleAverageLayout: Bool = false
    
    
    // MARK: - content 相关
    
    /// 默认的内容容器的 frame
    var containerViewFrame: CGRect = CGRect(x: 0, y: 44, width: kScreenW, height: kScreenH - 44)
    var contentVCs: [UIViewController] = [vc(),vc(),vc(),vc()]
    /// segmentView 要加载到的 VC。
    ///
    /// - 当前版本必须要赋值
    var superVC: UIViewController!
}

class vc: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randomColor()
    }
}
