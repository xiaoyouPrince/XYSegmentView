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

var theRightSV: UIScrollView? = nil
var theRightSVOffset: CGPoint = .zero

public protocol XYHoverContainerDataSource: NSObjectProtocol {
    
    var topView: UIView { get }
    var topViewHeight: CGFloat { get }
    var hoverViewHeight: CGFloat { get }
    var listView: UIScrollView { get }
    var listViewBottomSafeHeight: CGFloat { get }
   
    func listViewDidScrollCallback(callback: @escaping (UIScrollView)->())
}
public typealias HoverViewDataSource = XYHoverContainerDataSource

public class XYHoverContainerView: UIView {
    
    private weak var dataSource: XYHoverContainerDataSource?
    
    public private(set) var currentScrollingScrollView: UIScrollView?
    
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
    
    private var lastOffsetY: CGFloat = .zero

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
    
    func setupUI() {
        addSubview(containerScrollView)
        containerScrollView.addSubview(topView)
        containerScrollView.addSubview(listContentView)
        
        
        dataSource?.listViewDidScrollCallback {[weak self] sv in
//            self?.listViewDidScroll(sv)
            theRightSV = sv
            theRightSVOffset = sv.contentOffset
        }
        
//        currentScrollingScrollView = dataSource?.listView
    }
    
//    /// 外部传入的listView，当其内部的scrollView滚动时，需要调用该方法
//    func listViewDidScroll(scrollView: UIScrollView) {
//        currentScrollingListView = scrollView
//        currentScrollingListView?.frame = listContentView.bounds
//        listContentView.reloadData()
//    }
}

class HoverConatainerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension XYHoverContainerView: UIScrollViewDelegate {
    
    var listViewMaxContentOffsetY: CGFloat {
        dataSource?.hoverViewHeight ?? 0
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        guard let listView = currentScrollingListView else { return }
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
            theRightSV?.contentOffset = theRightSVOffset
        }else{
            theRightSVOffset = theRightSV!.contentOffset
        }
        
        print("theRightSVOffset - \(theRightSVOffset)")
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        theRightSVOffset = theRightSV!.contentOffset
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 保存上一次
        theRightSVOffset = theRightSV!.contentOffset
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
