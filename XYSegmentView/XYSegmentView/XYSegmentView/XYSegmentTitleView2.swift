//
//  XYSegmentTitleView2.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/10.
//

import UIKit


// MARK: - 定义常量
private let kScrollLineH : CGFloat = 2
private let kNormalColor : (CGFloat, CGFloat, CGFloat) = (85, 85, 85)
private let kSelectColor : (CGFloat, CGFloat, CGFloat) = (255, 128, 0)


class TitleItem: UIView, XYSegmentViewTitleItemProtocol {
    
    func setNormalState() {
        if let label = subviews.first as? UILabel {
            label.textColor = .red
        }
    }
    
    func setSelectedState() {
        if let label = subviews.first as? UILabel {
            label.textColor = .green
        }
    }
    
    func setState(with progress: CGFloat) {
        x_setProgress(progress: progress)
    }
    
    /// 从方法由于是分类中有实现，直接走的分类实现，这里走不到
    /// - Parameter progress: 进度
    func x_setProgress(progress: CGFloat) {
        
        print("progress = \(progress)")
        
        if let label = subviews.first as? UILabel {
            
            let colorDelta = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1, kSelectColor.2 - kNormalColor.2)
            
//            label.textColor = UIColor(r: kSelectColor.0 - colorDelta.0 * progress, g: kSelectColor.1 - colorDelta.1 * progress, b: kSelectColor.2 - colorDelta.2 * progress)
            
            label.textColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        }
    }
}

class XYSegmentTitleView2: UIView {
    
    // MARK: - 自定义属性
    fileprivate var titles : [String]
    fileprivate var titleItems : [XYSegmentViewTitleItemProtocol & UIView] = [TitleItem]()
    fileprivate var titleLabels : [UILabel] = [UILabel]()
    fileprivate var currentIndex : Int = 0 // 设置默认的当前下标为0
    weak var delegate : XYSegmentTitleViewDelegate?{
        didSet{
            // 创建UI
            setupUI()
        }
    }
    
    // MARK: - 懒加载属性
    fileprivate lazy var scrollView : UIScrollView = {[weak self] in
    
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        
        return scrollView
    }();
    
    fileprivate lazy var scrollLine : UIView = {[weak self] in
        
        let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor.orange
        
        return scrollLine
    }();
    
    init(frame: CGRect, titles: [String]){
        
        if titles.isEmpty {
            fatalError("the titles can not be empty")
        }
        
        // 1.给自己的titles赋值
        self.titles = titles
        
        // 2.通过frame构造实例变量
        super.init(frame:frame)
        
        
    }
    
    // 自定义构造方法必须重写initwithCoder方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - 设置UI
extension XYSegmentTitleView2{
    
    
    fileprivate func setupUI(){
        
        // 1.添加对应的scrollview
        addSubview(scrollView)
        scrollView.frame = self.bounds
//        scrollView.backgroundColor = UIColor.yellow
        
        // 2.添加lable
        setupTitleLabels()
        
        // 3.添加底边线和可滑动的线
        setupBottomLineAndScrollLines()
        
    }
    
    
    // MARK: - 添加label
    private func setupTitleLabels(){
        
        // 0.对于有些只需要设置一遍的东西，放到外面来
        let isAverageLayout = delegate?.config.isTitleAverageLayout ?? false
        var labelW: CGFloat = 0
        if isAverageLayout {
            labelW = frame.width / CGFloat(titles.count)
        }
        let titleMargin: CGFloat = delegate?.config.titleMargin ?? 20
        
        let labelH : CGFloat = frame.height - kScrollLineH
        let labelY : CGFloat = 0.0
        
        var totoalWidth : CGFloat = 0
        for (index,title) in titles.enumerated(){
            
            let item = TitleItem()
            item.tag = index
            
            
//            // 1.创建Label
            let label = UILabel()

            // 2.设置对应的属性
            label.text = title
            label.font = UIFont.systemFont(ofSize: 16.0)
            label.tag = index
            label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
            label.textAlignment = .center
            label.sizeToFit()
            
            item.addSubview(label)
            

            // 3. 设置frame
            if isAverageLayout {
                let labelX : CGFloat = CGFloat(index) * labelW
                item.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
                label.frame = item.bounds
            }else{
                let labelW : CGFloat = label.bounds.width + titleMargin
                let labelX : CGFloat = totoalWidth
                totoalWidth += labelW
                item.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
                label.frame = item.bounds
            }


            // 4.添加
            scrollView.addSubview(item)

            // 5.添加到Label的数组中
//            titleLabels.append(label)
            titleItems.append(item)
            item.setNormalState()

            // 6.给Label添加手势
//            label.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(tapGes:)))
            item.addGestureRecognizer(tapGes)
            
        }
        
        scrollView.contentSize = CGSize(width: titleItems.last!.frame.maxX, height: 0)
        
    }
    // MARK: - 设置底线 和 可以滚动的线
    private func setupBottomLineAndScrollLines(){
        
        let bottomLine = UIView()
        let bottomLineH : CGFloat = 0.5
        bottomLine.backgroundColor = UIColor.gray
        bottomLine.frame = CGRect(x: 0, y: frame.height - bottomLineH , width: frame.width, height: bottomLineH)
        addSubview(bottomLine)
        
        guard let label = titleItems.first else {return}
        label.setSelectedState()
        scrollLine.frame = CGRect(x: label.bounds.origin.x, y: label.frame.origin.y+label.frame.height, width: label.frame.width, height: kScrollLineH)
            scrollView.addSubview(scrollLine)

    }
}


// MARK: - 监听Label的点击 -- 必须使用@objc
extension XYSegmentTitleView2{
    
    @objc fileprivate func titleLabelClick(tapGes : UITapGestureRecognizer){
        
        // 1.取到当前的label
        guard let currentLabel = tapGes.view as? TitleItem else {
            return
        }
        
        // 对当前的Index和当前Label的tag值进行对比，如果当前label就是选中的label就不变了，如果是跳到其他的Label就执行后面，修改对应的颜色
        if currentLabel.tag == currentIndex { return }
        
        // 2.获取之前的label
        let oldLabel = titleItems[currentIndex]
        
        
        // 3.设置 source / target 状态
        currentLabel.setProgress(progress: 1.0)
        oldLabel.setProgress(progress: 0.0)

        // 4.保存新的当前下边值
        currentIndex = currentLabel.tag
        
        // 5.滚动条的滚动
        let scrollLinePosition : CGFloat =  currentLabel.frame.origin.x
        let scrollLineWidth : CGFloat =  currentLabel.frame.size.width
        UIView.animate(withDuration: 0.15) {
            self.scrollLine.frame.origin.x = scrollLinePosition
            self.scrollLine.frame.size.width = scrollLineWidth
        } completion: {_ in
            // 5.1 当前选中 title 滚动到中间位置
            self.scrollCurrentTitleCenter()
        }
        
        // 6.通知代理做事情
        delegate?.pageTitleView(titleView: XYSegmentTitleView(frame: .zero, titles: ["String"]), selectIndex: currentIndex)
        
    }
    
    fileprivate func scrollCurrentTitleCenter() {
        
        var offsetX: CGFloat = 0
        if self.scrollLine.center.x < self.scrollView.center.x {
            offsetX = 0
        }else
        if self.scrollLine.center.x > self.scrollView.center.x,
           self.scrollView.contentSize.width - self.scrollLine.center.x > self.scrollView.center.x
        {
            offsetX = self.scrollLine.center.x - self.scrollView.bounds.width / 2
            
        }else{
            offsetX = self.scrollView.contentSize.width - self.scrollView.bounds.width
        }
        
        self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
}

// MARK: - 暴露给外界的方法
extension XYSegmentTitleView2{
    
    func setTitleWithProgress( progress : CGFloat, sourceIndex : Int, targetIndex : Int) {
        
        // 1.取出sourceLabel/targetLabel
        let sourceLabel = titleItems[sourceIndex]
        let targetLabel = titleItems[targetIndex]
        
        // 2.处理滑块的逻辑
        let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveX = moveTotalX * progress
        scrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        
        let deltaWidth = (targetLabel.bounds.width - sourceLabel.bounds.width) * progress
        let lineWidth = deltaWidth + sourceLabel.bounds.width
        scrollLine.frame.size.width = lineWidth
        
        // 3. 处理 item 滑动进度
        sourceLabel.setProgress(progress: 1 - progress)
        targetLabel.setProgress(progress: progress)
        
        // 4.记录最新的index
        currentIndex = targetIndex
        
        if progress == 1.0 {
            // print("滑动完成------")
            scrollCurrentTitleCenter()
        }
    }
}
