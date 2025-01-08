//
//  ScrollViewController.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/3/26.
//

import UIKit


let headerHeight = 100
var superScroll = UIScrollView()

class ScrollViewController: UIViewController {
    
    private lazy var conetntView: ForwordContentView = .init(frame: .zero, dataSource: self)
    
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavHeight - titleViewH))
        scrollView.backgroundColor = .red
        view.addSubview(scrollView)
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return scrollView
    }()
    
    lazy var headerView: UIView = {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Int(kScreenW), height: headerHeight))
        header.backgroundColor = .green
//        scrollView.addSubview(header)
        return header
    }()
    
    lazy var segmentView: XYSegmentView = {
        // segmentView
        let segHeight = kScreenH - (navigationController?.navigationBar.frame.maxY ?? kNavHeight) - titleViewH - (forwordViewHeight - forwordHoverHeight)
        let segFrame = CGRect(x: 0, y: 0, width: kScreenW, height: segHeight)
        
        // title
        let titleFrame = CGRect(x: 0, y: 0, width: segFrame.width, height: titleViewH)
        let titles = ["默认效果","仿写","tableHeder","趣玩"];
        
        // content
        let contentY : CGFloat = titleViewH
        let contentH = segFrame.height - contentY
        let contentW = segFrame.width
        let contentFrame = CGRect(x: 0, y: contentY, width: contentW, height: contentH)
        
        // 2.创建对应的contentView
        var contentVcs = [UIViewController]()
        for (index, _) in titles.enumerated() {
            if index == 0 {
                let d = DefalutDemoViewController()
                d.abc = true
                contentVcs.append(d)
            }else{
                
                if index == 2 {
                    contentVcs.append(TableViewController())
                }else if index == 3 {
                    contentVcs.append(UIViewController())
                }else{
                    contentVcs.append(CommonViewController())
                }
            }
        }
        
        let config = XYSegmentViewConfig()
        config.frame = segFrame
        //config.contentScrollEnable = false
        
        config.titleViewFrame = titleFrame
        config.titles = titles
        if titles.count <= 4 {
            config.isTitleAverageLayout = true
        }
        config.titleMargin = 30
        
        config.containerViewFrame = contentFrame
        config.contentVCs = contentVcs
        config.superVC = self
        
        config.userInfo = ["type": "demo"] // 自定义一个用户指定信息
        
        let seg = XYSegmentView(config: config)
        scrollView.addSubview(seg)
        return seg
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        superScroll = scrollView
        _ = headerView
        _ = segmentView
        scrollView.contentSize = CGSize(width: kScreenW, height: CGFloat(headerHeight) + segmentView.bounds.height)
        
        conetntView.frame = view.bounds //CGRect(x: 0, y: 0, width: kScreenW, height: CGFloat(headerHeight) + segmentView.bounds.height)
        view.addSubview(conetntView)
        
        conetntView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            conetntView.topAnchor.constraint(equalTo: view.topAnchor),
            conetntView.leftAnchor.constraint(equalTo: view.leftAnchor),
            conetntView.rightAnchor.constraint(equalTo: view.rightAnchor),
            conetntView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        print(scrollView.frame, headerView.frame, segmentView.frame)
        
        print(scrollView.contentSize)
         
    }

}

extension ScrollViewController: ForwordDataSource {
    
    public var forwordView: UIView { headerView }
    public var forwordViewHeight: CGFloat { CGFloat(headerHeight) } //100
    public var forwordHoverHeight: CGFloat { 60 } // 60
    
    public var listView: UIScrollView { scrollView }
    
    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
//        self.callback = callback
        print("------------")
    }
}

extension ScrollViewController: UIScrollViewDelegate { }
//{
//
//    func checkScrollViewScroll(){
//        if scrollView.contentOffset.y >= 0, scrollView.contentOffset.y <= CGFloat(headerHeight) {
//            scrollView.isScrollEnabled = true
//        }else{
//            scrollView.isScrollEnabled = false
//        }
//
////        topScroll.isScrollEnabled = !scrollView.isScrollEnabled
//    }
//    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        // 将要滚动 - 检测自己能否滚动
//        checkScrollViewScroll()
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y >= CGFloat(headerHeight) {
//            scrollView.contentOffset.y = CGFloat(headerHeight)
//            checkScrollViewScroll()
//        }
//        if scrollView.contentOffset.y <= 0 {
//            scrollView.contentOffset.y = 0
//            checkScrollViewScroll()
//        }
//    }
//}



