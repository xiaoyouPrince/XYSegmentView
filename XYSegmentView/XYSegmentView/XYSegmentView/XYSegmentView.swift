//
//  XYSegmentView.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/6.
//

import UIKit

open class XYSegmentView: UIView {
    
    var config: XYSegmentViewConfig = XYSegmentViewConfig()
    
    // MARK: - 懒加载pagetitleView
    lazy var pageTitleView : XYSegmentTitleView = { [weak self] in
        
        let titleFrame = config.titleViewFrame
        let titles = config.titles
        
        // 创建对应的titleView
        let titleView = XYSegmentTitleView.init(frame: titleFrame, titles: titles)
        titleView.backgroundColor = UIColor.clear
        
        // 成为代理
        titleView.delegate = self
        
        return titleView
        
    }()
    
    // MARK:-懒加载一个pageContentView
    lazy var pageContentView : XYSegmentContainerView = { [weak self] in
        
        let contentFrame = config.containerViewFrame
        let contentVcs = config.contentVCs
        let parentVC = config.superVC
        
        let contentView = XYSegmentContainerView(frame: contentFrame, childVcs:contentVcs , parentVc: parentVC!)
        contentView.backgroundColor = UIColor.red
        contentView.delegate = self
        
        return contentView
    }()
    
    /// 指定初始化器
    /// - Parameter config: 指定设置类
    init(config: XYSegmentViewConfig) {
        super.init(frame: config.frame)
        self.config = config
        
        self.backgroundColor = .groupTableViewBackground
        addSubview(pageTitleView)
        addSubview(pageContentView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension XYSegmentView: XYSegmentTitleViewDelegate{
    func pageTitleView(titleView: XYSegmentTitleView, selectIndex index: Int) {
        
        // 通知contentView修改对应的Index
        pageContentView.setCurrnetIndex(currentIndex: index)
    }
}


extension XYSegmentView: XYSegmentContainerViewDelegate{
    func pageContentView(_ contentView: XYSegmentContainerView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        // 接收到代理方法之后，通知titleView去处理对应的文字、滑块、颜色等变化

        pageTitleView.setTitleWithProgress(progress : progress, sourceIndex : sourceIndex, targetIndex : targetIndex)
    }
}
