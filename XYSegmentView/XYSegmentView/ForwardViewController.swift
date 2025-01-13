//
//  ForwordContentView.swift
//  FowrdView
//
//  Created by ☆大强☆ on 2022/2/23.
//

import Foundation
import UIKit

public protocol ForwordDataSource: NSObjectProtocol {
    var listView: UIScrollView { get }
    var forwordViewHeight: CGFloat { get }
    var forwordHoverHeight: CGFloat { get }
    var forwordView: UIView { get }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView)->())
}

// MARK: - GesteureDelegate
@objc public protocol ScrollViewGestureDelegate {
    //如果headerView（或其他地方）有水平滚动的scrollView，当其正在左右滑动的时候，就不能让列表上下滑动，所以有此代理方法进行对应处理
    func scrollViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

open class ForwordScrollView: UIScrollView, UIGestureRecognizerDelegate {
    public weak var gestureDelegate: ScrollViewGestureDelegate?

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureDelegate = gestureDelegate {
            return gestureDelegate.scrollViewGestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith:otherGestureRecognizer)
        } else {
            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        }
    }
}

public class ForwordContentView: UIView {
    
    private weak var dataSource: ForwordDataSource?
    
    public private(set) var currentScrollingListView: UIScrollView?
    
    private var forwordViewHeight: CGFloat = 0
    
    public lazy var contentScrollView: ForwordScrollView = {
        let sv = ForwordScrollView(frame: .zero)
        sv.showsVerticalScrollIndicator = false
        sv.delegate = self
        return sv
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
    
    public init(frame: CGRect, dataSource: ForwordDataSource) {
        super.init(frame: frame)
        self.dataSource = dataSource
        
        forwordViewHeight = self.dataSource?.forwordViewHeight ?? 0
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func listViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y > lastOffsetY { // 往上滚动
            if scrollView.contentOffset.y <= 0 { // 此处为下拉刷新
                contentScrollView.contentOffset = .zero
                return
            }
            if contentScrollView.contentOffset.y < contentScrollView.contentSize.height - contentScrollView.bounds.height {
                scrollView.contentOffset = CGPoint(x: 0, y: lastOffsetY)
            }
        } else { // 往下滚动
            if contentScrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset = .zero
            }
            if scrollView.contentOffset.y > 0 {
                if contentScrollView.contentOffset.y <= 0 {
                    contentScrollView.contentOffset = .zero
                } else {
                    let isBottom = scrollView.contentSize.height <= (scrollView.contentOffset.y - scrollView.contentInset.bottom + scrollView.bounds.height)
                    if contentScrollView.contentOffset.y > 0 && !isBottom {
                        scrollView.contentOffset = CGPoint(x: 0, y: lastOffsetY)
                    }
                }
            }
        }
        lastOffsetY = scrollView.contentOffset.y
    }
    
    /*
     if up {
        if scrollView.offset.y < maxOffsetY {
            listView.contentOffset = .zero
        }
     } else { // down
        if listView.contentOffset.y >= .zero {
            scrollView.contentOffset = CGPoint(x: 0, y: listViewMaxContentOffsetY)
        }
     }
     */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let isUp: Bool = scrollView.contentOffset.y > CGFloat(Int(lastOffsetY))
        
        
        let trans = (scrollView.gestureRecognizers?.filter({ $0.isKind(of: UIPanGestureRecognizer.self)}).first as! UIPanGestureRecognizer).translation(in: scrollView.gestureRecognizers?.filter({ $0.isKind(of: UIPanGestureRecognizer.self)}).first?.view)
        let isUp = trans.y < lastTrans.y
        
        lastTrans = trans
        
        print("isUp = \(isUp), trans = \(trans)")
        
        
        guard let listView = currentScrollingListView else { return }
        if scrollView.contentOffset.y >= listViewMaxContentOffsetY {
            scrollView.contentOffset = CGPoint(x: 0, y: listViewMaxContentOffsetY)
        }
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
        
//        if listView.contentOffset.y > 0 {
//            if scrollView.contentOffset.y <= 0 {
//                scrollView.contentOffset = .zero
//            }
//        }
//
//        if scrollView.contentOffset.y < 0 {
//            scrollView.contentOffset = .zero
//        }
        
        if isUp { // 往上滚动
            if scrollView.contentOffset.y < listViewMaxContentOffsetY {
                listView.contentOffset = .zero
            } else {
                
            }
        } else { // 往下滚动
//            if listView.contentOffset.y >= .zero {
//                scrollView.contentOffset = CGPoint(x: 0, y: listViewMaxContentOffsetY)
//            }
//            if scrollView.contentOffset.y < listViewMaxContentOffsetY {
//                listView.contentOffset = .zero
//            }
            
            if listView.contentOffset.y > 0 {
                scrollView.contentOffset = CGPoint(x: 0, y: listViewMaxContentOffsetY)
            } else if scrollView.contentOffset.y > 0 {
                listView.contentOffset = .zero
            }
        }
        lastOffsetY = scrollView.contentOffset.y
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        contentScrollView.frame = bounds
//        dataSource?.forwordView.frame = .init(x: 0, y: 0, width: bounds.width, height: forwordViewHeight)
//        let height = forwordViewHeight + bounds.height
//        contentScrollView.contentSize = .init(width: 0, height: height)
//        listContentView.frame = .init(x: 0, y: dataSource?.forwordViewHeight ?? 0, width: bounds.width, height: bounds.height - 34)
//        dataSource?.listView.frame = listContentView.bounds
//        
//    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentScrollView.frame = bounds
        dataSource?.forwordView.frame = .init(x: 0, y: 0, width: bounds.width, height: forwordViewHeight)
        let height = forwordViewHeight - listViewMaxContentOffsetY + bounds.height
        contentScrollView.contentSize = .init(width: 0, height: height)
        listContentView.frame = .init(x: 0, y: dataSource?.forwordViewHeight ?? 0, width: bounds.width, height: bounds.height - (forwordViewHeight - listViewMaxContentOffsetY))
        currentScrollingListView?.frame = listContentView.bounds
        
    }
    
    private var lastOffsetY: CGFloat = .zero
    private var lastTrans: CGPoint = .zero
}

extension ForwordContentView {
    
    func setupUI() {
        addSubview(contentScrollView)
        
        contentScrollView.addSubview(listContentView)
        
        
        if let forwordView = dataSource?.forwordView {
            contentScrollView.addSubview(forwordView)
        }
        
        dataSource?.listViewDidScrollCallback {[weak self] sv in
            self?.listViewDidScroll(sv)
        }
        
        currentScrollingListView = dataSource?.listView
    }
    
    /// 外部传入的listView，当其内部的scrollView滚动时，需要调用该方法
    func listViewDidScroll(scrollView: UIScrollView) {
        currentScrollingListView = scrollView
        currentScrollingListView?.frame = listContentView.bounds
        listContentView.reloadData()
    }
}

extension ForwordContentView: UIScrollViewDelegate {
    var listViewMaxContentOffsetY: CGFloat {
        dataSource?.forwordHoverHeight ?? 0
    }
}

extension ForwordContentView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath)
        if let v = currentScrollingListView {
            cell.contentView.addSubview(v)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  listContentView.frame.size
    }
}
