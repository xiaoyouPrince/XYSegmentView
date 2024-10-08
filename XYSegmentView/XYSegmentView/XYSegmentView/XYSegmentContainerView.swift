//
//  XYSegmentContainerView.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/7.
//

import UIKit

private let cellID : String = "CellID"

protocol XYSegmentContainerViewDelegate : XYSegmentConfigProtocol {
    
    var currentPage: Int { get }
    
    func pageContentView(_ contentView : XYSegmentContainerView, progress : CGFloat, sourceIndex : Int, targetIndex : Int)

}

// MARK:-类的声明
class XYSegmentContainerView: UIView {
    
    // MARK:-定义属性
    fileprivate var childVcs : [UIViewController]
    fileprivate weak var parentVc : UIViewController? //防止强引用导致循环引用
    fileprivate var startOffsetX : CGFloat = 0;
    weak var delegate : XYSegmentContainerViewDelegate?{
        didSet{
            collectionView.isScrollEnabled = delegate!.config.contentScrollEnable
            
            for vc in childVcs {
                if vc is XYSegmentConfigProtocol, let theVC = vc as? XYSegmentConfigProtocol {
                    theVC.config = delegate!.config
                }
            }
            
//            collectionView.reloadData()
            setupUI()
        }
    }
    fileprivate var isForbidScrollDelegate : Bool = false
    
    // MARK:-闭包加载collectionView -- 闭包内要对self进行弱化引用，防止循环引用
    fileprivate lazy var collectionView : UICollectionView = {[weak self] in
        
        // 1.创建layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = (self?.bounds.size)!
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: (self?.bounds)!, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        // 设置数据源代理-并注册
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)

        
        return collectionView
    }()
    
    // MARK:-自定义构造行数
    init(frame: CGRect, childVcs : [UIViewController] , parentVc : UIViewController) {
     
        self.childVcs = childVcs
        self.parentVc = parentVc
        
        // 自定义构造函数必须显式调用 父类的对应方法
        super.init(frame:frame)
        
        // MARK:-创建UI
//        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - 设置UI
extension XYSegmentContainerView{
    
    fileprivate func setupUI()
    {
        for childVc in childVcs {
            // 1.添加子控制器
            self.parentVc?.addChild(childVc)
        }
        // 2.设置内部的collectionview
        addSubview(collectionView)
    }
    
}


// MARK: - 遵守collectionVIew的DataSource代理
extension XYSegmentContainerView : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.childVcs.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        // 1.复用cell
        let cell : UICollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        // 2.设置cell内部view
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        let childVc = childVcs[indexPath.item]
        cell.contentView.addSubview(childVc.view)
        childVc.view.frame = cell.contentView.bounds
        
        return cell
    }
}


// MARK: - 遵守collectionView的Delegate方法
extension XYSegmentContainerView : UICollectionViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isForbidScrollDelegate = false
        
        startOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if isForbidScrollDelegate {
            return
        }
        
        // 1.定义需要获取的数据
        var progress : CGFloat = 0
        var sourceIndex : Int = 0
        var targetIndex : Int = 0
        
        // 2.判断是左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.width
        if currentOffsetX > startOffsetX { // 左滑
            // 1.计算progress
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW)
            
            // 2.计算sourceIndex
            sourceIndex = Int(currentOffsetX / scrollViewW)
            
            // 3.计算targetIndex
            targetIndex = sourceIndex + 1
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            
            // 4.如果完全划过去
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1
                targetIndex = sourceIndex
            }
        } else { // 右滑
            // 1.计算progress
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW))
            
            // 2.计算targetIndex
            targetIndex = Int(currentOffsetX / scrollViewW)
            
            // 3.计算sourceIndex
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVcs.count {
                sourceIndex = childVcs.count - 1
            }
        }
        
        // 3.将progress/sourceIndex/targetIndex传递给titleView
        delegate?.pageContentView(self, progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)

        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        let currentPage = delegate?.currentPage ?? 0
        if currentPage != page {
            // 滑动过快，直接从0 -> 2, 可能导致 scrollViewDidScroll 中偏移量计算精度不够，导致最后停止时候当前页面没有正确设置
            delegate?.pageContentView(self, progress: 1.0, sourceIndex: currentPage, targetIndex: page)
        }
    }
    
}


// MARK:-对外暴露的方法
extension XYSegmentContainerView{
    
    // 告知它滚到哪个控制器去
    func setCurrnetIndex(currentIndex : Int) {
        
        
        isForbidScrollDelegate = true // 当外界点击的时候禁用
        
        // 实际上修改collectionView的offsetx
        let positionX = CGFloat(currentIndex) * self.frame.width
        collectionView.setContentOffset(CGPoint(x:positionX,y:0), animated: false)
        
    }
    
}
