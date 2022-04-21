//
//  XYHoverContainerView.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/4/20.
//  Copyright © 2022 xiaoyou. All rights reserved.
//

/*      the layout of XYHoverContainerView
 
 topViewHeight = hoverViewHeight +
 
 ---------------------         -|
                                |
    top_content                 |
                                |----> topView(topViewHeight)
 ---------------------          |
    top_hover(hoverViewHeight)  |
 ---------------------         -|
                            
                            
                            
                            
                            
        listView
                            
                            
                            
                            
                            
 ---------------------
 
 */

import UIKit

public protocol XYHoverContainerDataSource: NSObjectProtocol {
    
    /// 设置 topView
    var topView: UIView { get }
    
    /// 指定 topView 的高度
    var topViewHeight: CGFloat { get }
    
    /// 指定要悬浮区域的高度
    var hoverViewHeight: CGFloat { get }
    
    /// 指定内部滚动视图
    var listView: UIScrollView { get }
    
    /// 指定内部滚动视图的底部安全区域高度。 默认高度 0
    ///  - 比如矩形屏幕和刘海屏可以指定34/0。 此值由数据源自行设置
    var listViewBottomSafeHeight: CGFloat { get }
    
    /// 设置当前滚动视图
    /// - 默认实现是 listView
    /// - 如果 listView 内部有多视图，可以在切换视图的时候自行指定
    var currentScrollingScrollView: UIScrollView { get }
}
public typealias HoverViewDataSource = XYHoverContainerDataSource
public extension HoverViewDataSource {
    var listViewBottomSafeHeight: CGFloat { 0 }
    var currentScrollingScrollView: UIScrollView { listView }
}

public class XYHoverContainerView: UIView {
    
    private weak var dataSource: XYHoverContainerDataSource?
    private var currentScrollingViewOffset: CGPoint = .zero
    
    private lazy var containerScrollView: HoverConatainerScrollView = {
        let scrollView = HoverConatainerScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var listContentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cvCell")
        return cv
    }()
    
    public init(frame: CGRect, dataSource: HoverViewDataSource) {
        super.init(frame: frame)
        self.dataSource = dataSource
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerScrollView.frame = bounds
        topView.frame = .init(x: 0, y: 0, width: bounds.width, height: topViewHeight)
        let height = topViewHeight + bounds.height
        containerScrollView.contentSize = .init(width: 0, height: height)
        listContentView.frame = .init(x: 0, y: topViewHeight, width: bounds.width, height: bounds.height - hoverViewHeight - bottomSafeHeight)
        listView.frame = listContentView.bounds
    }
}

extension XYHoverContainerView {
    
    var topView: UIView {
        dataSource?.topView ?? UIView()
    }
    
    var listView: UIScrollView {
        dataSource?.listView ?? UIScrollView()
    }
    
    var topViewHeight: CGFloat {
        dataSource?.topViewHeight ?? 0
    }
    
    var hoverViewHeight: CGFloat {
        dataSource?.hoverViewHeight ?? 0
    }
    
    var bottomSafeHeight: CGFloat {
        dataSource?.listViewBottomSafeHeight ?? 0
    }
    
    var currentScrollingScrollView: UIScrollView {
        dataSource?.currentScrollingScrollView ?? UIScrollView()
    }
    
    func setupUI() {
        addSubview(containerScrollView)
        containerScrollView.addSubview(topView)
        containerScrollView.addSubview(listContentView)
        currentScrollingViewOffset = currentScrollingScrollView.contentOffset
    }
}

class HoverConatainerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension XYHoverContainerView: UIScrollViewDelegate {
    
    var listViewMaxContentOffsetY: CGFloat {
        (dataSource?.topViewHeight ?? 0 ) - (dataSource?.hoverViewHeight ?? 0)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= listViewMaxContentOffsetY {
            scrollView.contentOffset = CGPoint(x: 0, y: listViewMaxContentOffsetY)
        }
        
        if listView.contentOffset.y > 0 {
            if scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset = .zero
            }
        }

        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
        }
        
        // 优化真实滚动的 listView，效果看起来要
        if scrollView.contentOffset.y < listViewMaxContentOffsetY, scrollView.contentOffset.y > 0 {
            currentScrollingScrollView.contentOffset = currentScrollingViewOffset
        }else{
            currentScrollingViewOffset = currentScrollingScrollView.contentOffset
        }
        
        #if DEBUG
        print("theRightSVOffset - \(currentScrollingViewOffset)")
        #endif
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentScrollingViewOffset = currentScrollingScrollView.contentOffset
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 保存上一次
        currentScrollingViewOffset = currentScrollingScrollView.contentOffset
    }
}

extension XYHoverContainerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath)
        cell.contentView.addSubview(listView)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  listContentView.frame.size
    }
}
