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

public class XYSegmentViewTitleModel: NSObject {
    /// item 的标题，如果设置图片信息，优先展示图片信息，图片加载失败使用默认 title 标题
    var title: String
    /// 图片远程 url
    var imageUrlString: String?
    /// 图片本地文件名, 需要完整指定图片名和格式 如 a.png，从 mainBundle 中查找
    var imageName: String?
    ///  图片的占位图片, 如果设置了网络图片，在网络图片加载过程中展示的一个本地图片
    ///   - 尚未实现， 先观察使用情况再看
    var imagePlaceholder: String?
    
    init(title: String, imageUrlString: String? = nil, imageName: String? = nil, imagePlaceholder: String? = nil) {
        self.title = title
        self.imageUrlString = imageUrlString
        self.imageName = imageName
        self.imagePlaceholder = imagePlaceholder
    }
}

public class XYSegmentViewConfig: NSObject {
    
    /// 设置XYSegmentView整体的 frame
    ///
    /// - 子视图的 frame 设置应匹配整体  frame
    public var frame: CGRect = CGRect(x: 0, y: kNavHeight, width: kScreenW, height: kScreenH - kNavHeight - kTabSafeH)
    
    /// container 容器内容是否可以横向滑动切换 content
    public var contentScrollEnable: Bool = true
    
    /// 选中项目切换回调，入参为被选中的 Index，此参数为 config 共有，多次赋值以最后一次为准
    public var onSelectChangeBlock: ((Int)->())?
    
    // MARK: - title 相关
    
    /// titleView frame
    public var titleViewFrame: CGRect = CGRect(x: 0, y: 0, width: kScreenW, height: 44)
    
    /// 设置 titleView 的 edgeInsets，可用于 titleView 的左右边距
    public var titleViewEdgeInsets: UIEdgeInsets = .zero
    
    /// 快速设置 titleItem 为简单标题的 item，设置此属性仅支持展示普通文本
    ///  - note： 如果需要 title 支持展示图片，请使用 titleModels 属性
    public var titles: [String] = ["没有","设置","分页","!"]
    
    /// 设置 titleItem 数据源, 如果没有设置此属性则通过 titles 快捷生成
    /// - note： 设置此属性之后，titles 失效
    public var titleModels: [XYSegmentViewTitleModel] = []
    
    /// 两个 title 之间间距, 默认为 20pt，以某个 title 为参考单边为 10.
    public var titleMargin: CGFloat = 20
    
    /// 设置 title 在 titleView 中布局是否为均分宽度，默认 false
    public var isTitleAverageLayout: Bool = false
    
    /// titleItem 在默认未选中的颜色
    public var titleItemNormalColor: UIColor?
    
    /// titleItem 在默认未选中的颜色
    public var titleItemSelectedColor: UIColor?
    
    /// titleView 自己的背景色
    public var titleViewBackgroundColor: UIColor?
    
    /// titleView底部分割线的高度
    public var separatorHeight: CGFloat?
    
    /// titleView 底部分割线的颜色
    public var separatorColor: UIColor?
    
    /// 设置 title View 顶部只有普通文本时候的 font
    /// - 此属性在自定义 titleItem 时候可能无效
    public var titleFont: UIFont?
    
    /// 设置 title View 顶部只有普通文本被选中时候的 font
    /// - 此属性在自定义 titleItem 时候可能无效
    public var titleSelectedFont: UIFont?
    
    // MARK: - title 底部滑块 相关
    public var scrollLineType: ScrollLineType = .default
    
    /// 设置滑块的颜色
    public var scrollLineColor: UIColor?
    
    /// 设置滑块的高度，当滑块类型为 .dot 时候此值将作为滑块的直径
    public var scrollLineHeight: CGFloat?
    
    /// 设置滑块的内边距，以 TitleItem 为准，设置其左右两侧边距
    public var scrollLineInnerMargin: CGFloat = 0
    
    /// 设置滑块是否跟随滑动，即滑动过程是否有中间状态
    public var scrollLineFollowSliding: Bool = true
    
    // MARK: - content 相关
    
    /// 默认的内容容器的 frame
    public var containerViewFrame: CGRect = CGRect(x: 0, y: 44, width: kScreenW, height: kScreenH - 44)
    
    /// 内容VCs， 数组个数必须和 titles.count 相同
    public var contentVCs: [UIViewController] = [vc(),vc(),vc(),vc()]
    
    /// segmentView 要加载到的 VC。
    ///
    /// - 当前版本必须要赋值
    public var superVC: UIViewController!
    
    /// 用户自定义的扩展信息
    ///
    /// - 比如一些 XYSegmentView 组件内全局通用的数据信息
    /// - 比如埋点时候。最顶层 view 要埋一些基础配置的参数
    public var userInfo: [String: Any] = [:]
}

class vc: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randomColor()
    }
}
