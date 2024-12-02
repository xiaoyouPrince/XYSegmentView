//
//  XYSegmentTitleView2.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/10.
//

import UIKit
#if canImport(SDWebImageWebPCoder)
import SDWebImage
import SDWebImageWebPCoder
#endif

// defaultScrollLineHeight = 8
// default kNormalColor = (85, 85, 85)
// default kSelectColor = (255, 128, 0)

class TitleItem: UIView, XYSegmentViewTitleItemProtocol {
    var widthConstraint: NSLayoutConstraint = .init()
    
    var titleView: XYSegmentTitleView {
        func findSuperXYSegmentTitleView(for view: UIView) -> XYSegmentTitleView? {
            if let rlt = view.superview as? XYSegmentTitleView {
                return rlt
            } else {
                if let superview = view.superview {
                    return findSuperXYSegmentTitleView(for: superview)
                } else {
                    return nil
                }
            }
        }
        
        if let titleView = findSuperXYSegmentTitleView(for: self) {
            return titleView
        }
        return XYSegmentTitleView(frame: .zero, titles: [])
    }
    
    var kNormalColor: (CGFloat, CGFloat, CGFloat) {
        return titleView.kNormalColor
    }
    var kSelectColor: (CGFloat, CGFloat, CGFloat) {
        return titleView.kSelectColor
    }
    
    func setNormalState() {
        if let label = subviews.first as? UILabel {
            label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
        }
    }
    
    func setSelectedState() {
        if let label = subviews.first as? UILabel {
            label.textColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2)
        }
    }
    
    func setState(with progress: CGFloat) {
        x_setProgress(progress: progress)
    }
    
    /// 从方法由于是分类中有实现，直接走的分类实现，这里走不到
    /// - Parameter progress: 进度
    func x_setProgress(progress: CGFloat) {
        
//        print("progress = \(progress)")
        
        if let label = subviews.first as? UILabel {
            
            let colorDelta = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1, kSelectColor.2 - kNormalColor.2)
            
            label.textColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        }
    }
}

//// MARK: - 定义自己代理
protocol XYSegmentTitleViewDelegate : XYSegmentConfigProtocol {
    
    // 这里只是方法的定义 --selectIndex index :分别是内部和外部属性
    func pageTitleView(titleView : XYSegmentTitleView , selectIndex index : Int)
    
}

class XYSegmentTitleView: UIView {
    
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
        scrollLine.backgroundColor = self?.scrollLineColor
        
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
    
    /// 重新刷新数据
    ///  - 只根据 delegate.config 数据刷新，不更新 frame
    func reloadData(){
        self.titles = delegate?.config.titles ?? []
        for (_, sv) in scrollView.subviews.enumerated() {
            if sv == scrollLine {
                continue
            }
            sv.removeFromSuperview()
        }
        titleItems.removeAll()
        setupUI()
    }

}

// MARK: - 设置UI
extension XYSegmentTitleView{
    
    
    fileprivate func setupUI(){
        
        backgroundColor = selfBgColor
        currentIndex = 0
        
        // 1.添加对应的scrollview
        addSubview(scrollView)
        scrollView.frame = self.bounds
        
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
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.heightAnchor.constraint(equalToConstant: labelH)
        ])
        
        var totoalWidth : CGFloat = 0
        for (index,title) in titles.enumerated(){
            
            let item = TitleItem()
            item.tag = index
            
            
            // 1.创建Label
            let label = UILabel()

            // 2.设置对应的属性
            label.text = title
            label.font = titleFont
            label.tag = index
            label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
            label.textAlignment = .center
            label.sizeToFit()
            label.layer.borderColor = UIColor.red.cgColor
            label.layer.borderWidth = 1
            
            /*
             1. 图片加载完成的布局， 图片本身（imageView, contentModeFit） + item 容器的宽度（高度是 config 中设置 titleViewFrame 固定的）
             先计算图片在确定高度的 Item 容器中真实的 fit 宽度， 加上 margin / 2 即 item 容器应该更新的 width
             */
            
//            SDAnimatedImageView
//            let image = /*UIImage(data: data)*/SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
            
            #if DEBUG
            print("debug")
            #else
            print("release")
            #endif
            
            if let url = URL(string: title), url.scheme != nil {
                DispatchQueue.global().async {
                    var url = url
                    if title.contains("apng"), let pngUrl = Bundle.main.url(forResource: "apng", withExtension: "png") {
                        url = pngUrl
                    }
                    SDWebImageDownloader.shared.downloadImage(with: url) { uiImage, imageData, error, finished in
                        if let image = uiImage, finished, let imageData = imageData {
                            DispatchQueue.main.async {
                                // webp / gif / apng
                                
                                var image = image
                                if let gifImage = SDImageGIFCoder.shared.decodedImage(with: imageData) {
                                    image = gifImage
                                } else if let apngIamge = SDImageAPNGCoder.shared.decodedImage(with: imageData) {
                                    image = apngIamge
                                } else if let webpImage = SDImageWebPCoder.shared.decodedImage(with: imageData, options: nil) {
                                    image = webpImage
                                }
                                let iv = SDAnimatedImageView(image: image)
                                
                                iv.contentMode = .scaleAspectFit
                                item.addSubview(iv)
                                item.backgroundColor = .green
                                iv.backgroundColor = .red
                                iv.translatesAutoresizingMaskIntoConstraints = false
                                
                                let orignalImageWidth = image.size.width
                                let heightScale = image.size.height / item.bounds.height
                                let fitWidth: CGFloat = orignalImageWidth / heightScale
                                let fitWidthWithMargin: CGFloat = fitWidth + titleMargin
                                
                                if !isAverageLayout {
                                    NSLayoutConstraint.deactivate([
                                        item.widthConstraint
                                    ])
                                    NSLayoutConstraint.activate([
                                        item.widthAnchor.constraint(equalToConstant: fitWidthWithMargin)
                                    ])
                                }
                                
                                NSLayoutConstraint.activate([
                                    iv.centerXAnchor.constraint(equalTo: item.centerXAnchor),
                                    iv.widthAnchor.constraint(equalToConstant: fitWidthWithMargin),
                                    iv.topAnchor.constraint(equalTo: item.topAnchor),
                                    iv.heightAnchor.constraint(equalToConstant: item.bounds.height)
                                ])
                            }
                            
                        }
                    }
                    
//                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data), false {
//                        DispatchQueue.main.async {
//                            let iv = UIImageView(image: image)
//                            iv.contentMode = .scaleAspectFit
//                            item.addSubview(iv)
//                            item.backgroundColor = .green
//                            iv.backgroundColor = .red
//                            iv.translatesAutoresizingMaskIntoConstraints = false
//                            
//                            let orignalImageWidth = image.size.width
//                            let heightScale = image.size.height / item.bounds.height
//                            let fitWidth: CGFloat = orignalImageWidth / heightScale
//                            let fitWidthWithMargin: CGFloat = fitWidth + titleMargin
//                            
//                            if !isAverageLayout {
//                                NSLayoutConstraint.deactivate([
//                                    item.widthConstraint
//                                ])
//                                NSLayoutConstraint.activate([
//                                    item.widthAnchor.constraint(equalToConstant: fitWidthWithMargin)
//                                ])
//                            }
//                            
//                            NSLayoutConstraint.activate([
//                                iv.centerXAnchor.constraint(equalTo: item.centerXAnchor),
//                                iv.widthAnchor.constraint(equalToConstant: fitWidthWithMargin),
//                                iv.topAnchor.constraint(equalTo: item.topAnchor),
//                                iv.heightAnchor.constraint(equalToConstant: item.bounds.height)
//                            ])
//                        }
//                    } else { // 图片加载失败, 默认图?
//                        
//                    }
                }
            } else {
                item.addSubview(label)
            }
            
            // 3.添加
            contentView.addSubview(item)
            
            // 4. 布局
            if isAverageLayout {
                let labelX : CGFloat = CGFloat(index) * labelW
                item.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
                label.frame = item.bounds
                
                item.translatesAutoresizingMaskIntoConstraints = false
                let widthConstraint = item.widthAnchor.constraint(equalToConstant: labelW)
                item.widthConstraint = widthConstraint
                if let lastItem = titleItems.last {
                    if index == titles.count - 1 {
                        NSLayoutConstraint.activate([
                            item.leadingAnchor.constraint(equalTo: lastItem.trailingAnchor),
                            item.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                            item.topAnchor.constraint(equalTo: contentView.topAnchor),
                            item.widthConstraint,
                            item.heightAnchor.constraint(equalToConstant: labelH)
                        ])
                    } else {
                        NSLayoutConstraint.activate([
                            item.leadingAnchor.constraint(equalTo: lastItem.trailingAnchor),
                            item.topAnchor.constraint(equalTo: contentView.topAnchor),
                            item.widthConstraint,
                            item.heightAnchor.constraint(equalToConstant: labelH)
                        ])
                    }
                } else {
                    NSLayoutConstraint.activate([
                        item.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        item.topAnchor.constraint(equalTo: contentView.topAnchor),
                        item.widthConstraint,
                        item.heightAnchor.constraint(equalToConstant: labelH)
                    ])
                }
            }else{
                let labelW : CGFloat = label.bounds.width + titleMargin
                let labelX : CGFloat = totoalWidth
                totoalWidth += labelW
                item.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
                label.frame = item.bounds
                
                item.translatesAutoresizingMaskIntoConstraints = false
                let widthConstraint = item.widthAnchor.constraint(equalToConstant: labelW)
                item.widthConstraint = widthConstraint
                if let lastItem = titleItems.last {
                    if index == titles.count - 1 {
                        NSLayoutConstraint.activate([
                            item.leadingAnchor.constraint(equalTo: lastItem.trailingAnchor),
                            item.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                            item.topAnchor.constraint(equalTo: contentView.topAnchor),
                            item.widthConstraint,
                            item.heightAnchor.constraint(equalToConstant: labelH)
                        ])
                    } else {
                        NSLayoutConstraint.activate([
                            item.leadingAnchor.constraint(equalTo: lastItem.trailingAnchor),
                            item.topAnchor.constraint(equalTo: contentView.topAnchor),
                            item.widthConstraint,
                            item.heightAnchor.constraint(equalToConstant: labelH)
                        ])
                    }
                } else {
                    NSLayoutConstraint.activate([
                        item.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        item.topAnchor.constraint(equalTo: contentView.topAnchor),
                        item.widthConstraint,
                        item.heightAnchor.constraint(equalToConstant: labelH)
                    ])
                }
            }

            // 5.添加到Label的数组中
            titleItems.append(item)
            item.setNormalState()

            // 6.给Label添加手势
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(tapGes:)))
            item.addGestureRecognizer(tapGes)
            
        }
        
        if isAverageLayout {
            scrollView.contentSize = CGSize(width: titleItems.last!.frame.maxX, height: 0)
        }
    }
    // MARK: - 设置底线 和 可以滚动的线
    private func setupBottomLineAndScrollLines(){
        
        let bottomLine = UIView()
        let bottomLineH : CGFloat = separatorHeight
        bottomLine.backgroundColor = separatorColor
        bottomLine.frame = CGRect(x: 0, y: frame.height - bottomLineH , width: frame.width, height: bottomLineH)
        addSubview(bottomLine)
        
        guard let label = titleItems.first else {return}
        label.setSelectedState()
        
        doSlider { type in
            switch type {
            case .default:
                scrollLine.frame = CGRect(x: label.bounds.origin.x + sliderInnerMargin, y: label.frame.origin.y+label.frame.height, width: label.frame.width - 2*sliderInnerMargin, height: kScrollLineH)
            case .line:
                fatalError("not implemented")
            case .dot:
                scrollLine.frame = CGRect(x: label.center.x, y: label.frame.origin.y+label.frame.height, width: kScrollLineH, height: kScrollLineH)
                scrollLine.layer.cornerRadius = kScrollLineH / 2
                scrollLine.clipsToBounds = true
            }
        }
        
        scrollView.addSubview(scrollLine)
    }
}

extension XYSegmentTitleView {
        
    var kScrollLineH: CGFloat {
        delegate?.config.scrollLineHeight ?? 2
    }
    
    var kNormalColor: (CGFloat, CGFloat, CGFloat) {
        
        if let normalColor = delegate?.config.titleItemNormalColor {
            return normalColor.getRGB()
        }
        
        return (85, 85, 85)
    }
    
    var kSelectColor : (CGFloat, CGFloat, CGFloat) {
        
        if let selectedColor = delegate?.config.titleItemSelectedColor {
            return selectedColor.getRGB()
        }
        
        return (255, 128, 0)
    }
    
    var selfBgColor: UIColor {
        delegate?.config.titleViewBackgroundColor ?? .clear
    }
    
    var separatorHeight: CGFloat {
        delegate?.config.separatorHeight ?? 0.5
    }
    
    var separatorColor: UIColor {
        delegate?.config.separatorColor ?? .lightGray
    }
    
    var scrollLineColor: UIColor {
        delegate?.config.scrollLineColor ?? .orange
    }
    
    var titleFont: UIFont {
        delegate?.config.titleFont ?? UIFont.systemFont(ofSize: 17)
    }
    
    var sliderInnerMargin: CGFloat {
        if let scrollLineInnerMargin = delegate?.config.scrollLineInnerMargin {
            return scrollLineInnerMargin
        }else{
            return 0
        }
    }
    
    var sliderFollowSliding: Bool {
        if let scrollLineFollowSliding = delegate?.config.scrollLineFollowSliding {
            return scrollLineFollowSliding
        }else{
            return true
        }
    }
    
    func doSlider(_ block: (ScrollLineType) -> ()) {
        if let lineType = delegate?.config.scrollLineType {
            block(lineType)
        }else{
            block(.default)
        }
    }
    
    func doSliderWithProgress( progress : CGFloat, sourceIndex : Int, targetIndex : Int) {
        
        // 1.取出sourceLabel/targetLabel
        let sourceLabel = titleItems[sourceIndex]
        let targetLabel = titleItems[targetIndex]
        let moveTotalX = abs(targetLabel.center.x - sourceLabel.center.x)
        if progress > 0.5 { // 后半段
            if targetIndex > sourceIndex { // 左滑
                let deltaX = moveTotalX * ((progress - 0.5) * 2)
                scrollLine.frame.origin.x = sourceLabel.center.x - kScrollLineH / 2 + deltaX
                
                var lineWidth = moveTotalX * (1 - (progress - 0.5) * 2)
                if lineWidth <= kScrollLineH {
                    lineWidth = kScrollLineH
                }
                scrollLine.frame.size.width = lineWidth
            }else{
                var lineWidth = moveTotalX * (1 - (progress - 0.5) * 2)
                if lineWidth <= kScrollLineH {
                    lineWidth = kScrollLineH
                }
                scrollLine.frame.size.width = lineWidth
                
                /// 处理滑动过快情景下，在前半段中
                /// 最后一帧位置没有同步到正确位置，就到下半段了
                /// 手动修改到正确位置
                if scrollLine.frame.origin.x != targetLabel.center.x - kScrollLineH / 2 {
                    scrollLine.frame.origin.x = targetLabel.center.x - kScrollLineH / 2
                }
            }
        }else{ // 前半段
            if targetIndex > sourceIndex { // 左滑
                var lineWidth = moveTotalX * progress * 2
                if lineWidth <= kScrollLineH {
                    lineWidth = kScrollLineH
                }
                scrollLine.frame.size.width = lineWidth
            }else{
                /// 在右滑动前半段，滑动过快会导致滑块.x 定位不准。
                /// 原因是scrollViewDidScroll 回调每个 Runloop 回调一次，如果滑动过快，相邻两次loop回调中间已经prosess > 0.5 了，此时不会走到修改 x 的回调中
                /// fix 在后半段中处理上半段位置 x 不对的情况
                let deltaX = moveTotalX * progress * 2
                scrollLine.frame.origin.x = sourceLabel.center.x - kScrollLineH / 2 - deltaX

                var lineWidth = moveTotalX * progress * 2
                if lineWidth <= kScrollLineH {
                    lineWidth = kScrollLineH
                }
                scrollLine.frame.size.width = lineWidth
            }
        }
    }
}


// MARK: - 监听Label的点击
extension XYSegmentTitleView{
    
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
        var scrollLinePosition : CGFloat = 0//currentLabel.frame.origin.x
        var scrollLineWidth : CGFloat = 0//currentLabel.frame.size.width
        doSlider { type in
            switch type {
            case .default:
                scrollLinePosition = currentLabel.frame.origin.x
                scrollLineWidth = currentLabel.frame.size.width
            case .line:
                fatalError("not implemented")
            case .dot:
                scrollLinePosition = currentLabel.center.x
                scrollLineWidth = kScrollLineH
            }
        }

        UIView.animate(withDuration: 0.15) {
            self.scrollLine.frame.origin.x = scrollLinePosition + self.sliderInnerMargin
            self.scrollLine.frame.size.width = scrollLineWidth - 2*self.sliderInnerMargin
        } completion: {_ in
            // 5.1 当前选中 title 滚动到中间位置
            self.scrollCurrentTitleCenter()
        }
        
        // 6.通知代理做事情
        delegate?.pageTitleView(titleView: self, selectIndex: currentIndex)
        
    }
    
    fileprivate func scrollCurrentTitleCenter() {
        
        if self.scrollView.bounds.width >= self.scrollView.contentSize.width {
            return
        }
        
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
extension XYSegmentTitleView {
    
    func setTitleWithProgress( progress : CGFloat, sourceIndex : Int, targetIndex : Int) {
        
        // 1.取出sourceLabel/targetLabel
        let sourceLabel = titleItems[sourceIndex]
        let targetLabel = titleItems[targetIndex]
        
        // 2. 滑块处理
        doSlider { type in
            if !self.sliderFollowSliding, 0 < progress , progress < 1  {
                return; // 闭包内部 return 返回的是这个闭包
            }
            switch type {
            case .default:
                let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
                let moveX = moveTotalX * progress + sliderInnerMargin
                scrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        
                let deltaWidth = (targetLabel.bounds.width - sourceLabel.bounds.width) * progress
                let lineWidth = deltaWidth + sourceLabel.bounds.width - 2*sliderInnerMargin
                scrollLine.frame.size.width = lineWidth
            case .line:
                fatalError("not implemented")
            case .dot:
                doSliderWithProgress(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
            }
        }
        
        
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
