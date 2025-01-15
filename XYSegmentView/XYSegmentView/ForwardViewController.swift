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
    public var isUp: Bool?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        panGestureRecognizer.addTarget(self, action: #selector(panMonitor(_:)))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
//        if gestureRecognizer == panGestureRecognizer {
//            print("gestureRecognizer == panGestureRecognizer")
//        }
//        
//        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self), let pan = gestureRecognizer as? UIPanGestureRecognizer {
//            let trans = pan.translation(in: pan.view)
//            print("trans -- \(trans)")
//        }
        
        
        if let gestureDelegate = gestureDelegate {
            return gestureDelegate.scrollViewGestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith:otherGestureRecognizer)
        } else {
            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        }
    }
    
    private var transBegin: CGPoint = .zero
    @objc func panMonitor(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .possible:
            break
        case .began:
            let trans = pan.translation(in: pan.view)
            //print("pan 开始滚动 -- trans = \(trans)")
            transBegin = trans
            isUp = nil
            print("    ", #line, "isUp = nil,  (begin gesture)")
            break
        case .changed:
            let trans = pan.translation(in: pan.view)
            //print("pan 滚动change -- trans = \(trans)")
            
            if (trans.y == transBegin.y && trans.y == 0) {
                isUp = nil
                transBegin = trans
                print("    ", #line, "isUp = nil,  (trans.y == transBegin.y && trans.y == 0)")
                return
            }
            
            if trans == transBegin {
                isUp = nil
                transBegin = trans
                print("    ", #line, "isUp = nil,  (trans == transBegin, trans = \(trans)")
                return
            }
            
            isUp = trans.y < transBegin.y
            
            transBegin = trans
            break
        case .ended:
            let trans = pan.translation(in: pan.view)
//            print("pan 滚动end -- trans = \(trans)")
//            isUp = nil
            break
        case .cancelled, .failed, .recognized:
            break
        @unknown default:
            break
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
    
//    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        let trans = (scrollView.gestureRecognizers?.filter({ $0.isKind(of: UIPanGestureRecognizer.self)}).first as! UIPanGestureRecognizer).translation(in: scrollView.gestureRecognizers?.filter({ $0.isKind(of: UIPanGestureRecognizer.self)}).first?.view)
//        let isUp = trans.y < lastTrans.y
//        
//        print("\n\n\nscrollViewWillBeginDragging--------------------")
//        print("isUp = \(isUp), trans = \(trans)， lastTrans: \(lastTrans)")
//    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let isUp: Bool = scrollView.contentOffset.y > CGFloat(Int(lastOffsetY))
        
        
        let trans = (scrollView.gestureRecognizers?.filter({ $0.isKind(of: UIPanGestureRecognizer.self)}).first as! UIPanGestureRecognizer).translation(in: scrollView.gestureRecognizers?.filter({ $0.isKind(of: UIPanGestureRecognizer.self)}).first?.view)
        guard let listView = currentScrollingListView else { return }
        if scrollView.contentOffset.y >= listViewMaxContentOffsetY {
            scrollView.contentOffset = CGPoint(x: 0, y: listViewMaxContentOffsetY)
        }
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
        
        guard let isUp = contentScrollView.isUp else {
            
            
            
            
            
            print("isUp = nil,  - return")
            return
        }
        
        //print("isUp = \(isUp), trans = \(trans)")
        print("isUp = \(isUp)", "scrollY = \(scrollView.contentOffset.y)", "listY = \(listView.contentOffset.y)")
        
        
//        if trans.y == 0 { return }
//        let isUp = trans.y < 0//lastTrans.y
//        
//        print("isUp = \(isUp), trans = \(trans)， lastTrans: \(lastTrans)")
//        
//        lastTrans = trans
        
        
        
        
//        if listView.contentOffset.y > 0 {
//            if scrollView.contentOffset.y <= 0 {
//                scrollView.contentOffset = .zero
//            }
//        }
//
//        if scrollView.contentOffset.y < 0 {
//            scrollView.contentOffset = .zero
//        }
        
        
        /*
         状态分析：(以scrollView 为基准)
         scrollView
            初始状态 -- contentOffset = .zero
                向上滑动 --
                    scrollView 正常滑动，
                    listView.contentOffset = .zero
                向下滑动 --
                    scrollView.contentOffset = .zero，
                    listView 正常滑动
            中间状态 -- contentOffset = .zero <--> contentOffset = .max
                向上滑动 --
                    scrollView 正常滑动，
                    listView.contentOffset = .zero
                向下滑动 --
                    scrollView 正常滑动，
                    listView.contentOffset = .zero
            最大状态 -- contentOffset = .max, listView.contentOffset = .zero
                向上滑动 --
                    scrollView.contentOffset = .max，
                    listView 正常滑动
                向下滑动 --
                    scrollView 正常滑动
                    listView.contentOffset = .zero
            最大状态 -- contentOffset = .max, listView.contentOffset.y > .zero
                向上滑动 --
                    scrollView.contentOffset = .max，
                    listView 正常滑动
                向下滑动 --
                    scrollView.contentOffset = .max，
                    listView 正常滑动
         */
        
        
        var scrollOffsetY: CGFloat = scrollView.contentOffset.y.rounded(.down)
        var listOffsetY: CGFloat = listView.contentOffset.y.rounded(.down)
        
        if isUp {
            scrollOffsetY = scrollView.contentOffset.y.rounded(.up)
            listOffsetY = listView.contentOffset.y.rounded(.up)
        }
        
        let maxOffsetY = listViewMaxContentOffsetY
        if scrollOffsetY == .zero {
            if isUp {
                listView.contentOffset = .zero
                print(#line)
            } else {
                scrollView.contentOffset = .zero
                print(#line)
            }
        }
        else
        if (scrollOffsetY > 0) && (scrollOffsetY < maxOffsetY) {
            if isUp {
                listView.contentOffset = .zero
                print(#line)
            } else {
                if listView.contentOffset.y > 0 {
                    scrollView.contentOffset = CGPoint(x: 0, y: maxOffsetY)
                    print(#line)
                } else {
                    listView.contentOffset = .zero
                    print(#line)
                }
            }
        }
        else
        if (scrollOffsetY == maxOffsetY) && listOffsetY == .zero {
            if isUp {
                scrollView.contentOffset = CGPoint(x: 0, y: maxOffsetY)
                print(#line)
            } else {
                listView.contentOffset = .zero
                print(#line)
            }
        }
        else
        if (scrollOffsetY == maxOffsetY) && listOffsetY > .zero {
            if isUp {
                scrollView.contentOffset = CGPoint(x: 0, y: maxOffsetY)
                print(#line)
            } else {
                scrollView.contentOffset = CGPoint(x: 0, y: maxOffsetY)
                print(#line)
            }
        }
       
        /*
        
        if isUp { // 往上滚动
            if scrollView.contentOffset.y < listViewMaxContentOffsetY {
                listView.contentOffset = .zero
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
         */
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
