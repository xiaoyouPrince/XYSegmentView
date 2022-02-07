//
//  XYSegmentView.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/6.
//

import UIKit

let titleViewH: CGFloat = 44

class XYSegmentView: UIView {
    // MARK: - 懒加载pagetitleView
    lazy var pageTitleView : XYSegmentTitleView = { [weak self] in
        
        let titleFrame = CGRect(x: 0, y: 0, width: kScreenW, height: titleViewH)
        let titles = ["推荐","游戏","娱乐","趣玩"];
        
        // 创建对应的titleView
        let titleView = XYSegmentTitleView.init(frame: titleFrame, titles: titles)
        titleView.backgroundColor = UIColor.clear
        
        // 成为代理
        titleView.delegate = self  //因为在titleView中已经进行 ？ 处理了，所以这里不写 ？ 否则代理设置不成功
        
        return titleView
        
    }()
    
    // MARK:-懒加载一个pageContentView
    lazy var pageContentView : XYSegmentContainerView = { [weak self] in
        
        // 1.确定frame
        let contentY : CGFloat = titleViewH
        let contentH = (self?.bounds.height ?? kScreenH) - contentY
        let contentW = (self?.bounds.width ?? kScreenW)
        let contentFrame = CGRect(x: 0, y: contentY, width: contentW, height: contentH)
        
        // 2.创建对应的contentView
        var contentVcs = [UIViewController]()
        
        // 2.1 第一个是推荐
        contentVcs.append(CommonViewController())
        contentVcs.append(CommonViewController())
        contentVcs.append(CommonViewController())
        contentVcs.append(CommonViewController())
        
        let contentView = XYSegmentContainerView(frame: contentFrame, childVcs:contentVcs , parentVc: theVC)
        contentView.backgroundColor = UIColor.red
        contentView.delegate = self
        
        return contentView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .groupTableViewBackground
        addSubview(pageTitleView)
        addSubview(pageContentView)
    }
    
    required init?(coder: NSCoder) {
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
