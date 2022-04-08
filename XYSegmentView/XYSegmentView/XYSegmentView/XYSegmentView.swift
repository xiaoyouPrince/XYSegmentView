//
//  XYSegmentView.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/6.
//

import UIKit

open class XYSegmentView: UIView {
    
    public var config: XYSegmentViewConfig = XYSegmentViewConfig()
    private(set) var currentIndex = 0 // 当前被选中的index
    
    // MARK: - 懒加载pagetitleView
    lazy var pageTitleView : XYSegmentTitleView = getTitleView()
    
    // MARK: -懒加载一个pageContentView
    lazy var pageContentView : XYSegmentContainerView = getContentView()
    
    /// 指定初始化器
    /// - Parameter config: 指定设置类
    public init(config: XYSegmentViewConfig) {
        super.init(frame: config.frame)
        self.config = config
        
        self.backgroundColor = .groupTableViewBackground
        _ = pageTitleView
        _ = pageContentView
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension XYSegmentView {
    
    private func getTitleView() -> XYSegmentTitleView {
        let titleFrame = config.titleViewFrame
        let titles = config.titles
        let titleView = XYSegmentTitleView.init(frame: titleFrame, titles: titles)
        titleView.backgroundColor = UIColor.clear
        addSubview(titleView)
        titleView.delegate = self
        return titleView
    }
    
    private func getContentView() -> XYSegmentContainerView {
        let contentFrame = config.containerViewFrame
        let contentVcs = config.contentVCs
        let parentVC = config.superVC
        let contentView = XYSegmentContainerView(frame: contentFrame, childVcs:contentVcs , parentVc: parentVC!)
        contentView.backgroundColor = UIColor.clear
        addSubview(contentView)
        contentView.delegate = self
        return contentView
    }
    
    /// 更新内容
    ///  - 此函数只会更新内容，不会更新 segmentView 本身的 frame
    func reloadData() {
        currentIndex = 0
        pageTitleView.removeFromSuperview()
        pageTitleView = getTitleView()
        pageContentView.removeFromSuperview()
        pageContentView = getContentView()
    }
    
    /// 选中指定Index.Item
    /// - Parameter index: index
    /// - 此函数不会回调 config.onSelectChangeBlcok . 入参即要选中的Index，调用者可行处理
    func selected(index: Int){
        guard index < config.titles.count else {return}
        guard currentIndex != index else {return}
        
        pageTitleView.setTitleWithProgress(progress: 1.0, sourceIndex: currentIndex, targetIndex: index)
        pageContentView.setCurrnetIndex(currentIndex: index)
        currentIndex = index
    }
}


extension XYSegmentView: XYSegmentTitleViewDelegate{
    func pageTitleView(titleView: XYSegmentTitleView, selectIndex index: Int) {
        
        // 通知contentView修改对应的Index
        pageContentView.setCurrnetIndex(currentIndex: index)
        currentIndex = index
        config.onSelectChangeBlock?(index)
    }
}


extension XYSegmentView: XYSegmentContainerViewDelegate{
    func pageContentView(_ contentView: XYSegmentContainerView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        // 接收到代理方法之后，通知titleView去处理对应的文字、滑块、颜色等变化

        pageTitleView.setTitleWithProgress(progress : progress, sourceIndex : sourceIndex, targetIndex : targetIndex)
        
        if progress == 1.0, currentIndex != targetIndex {
            currentIndex = targetIndex
            config.onSelectChangeBlock?(targetIndex)
        }
    }
}
