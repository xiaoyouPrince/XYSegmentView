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
    var titles: [String] = ["没有","设置","分页","!"]
    
    
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
