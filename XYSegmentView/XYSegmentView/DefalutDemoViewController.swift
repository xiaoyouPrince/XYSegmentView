//
//  DefalutDemoViewController.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/11.
//

/// 本页面示例了一些默认效果
/// 所有效果仅仅需要修改 config 即可，无需修改

import UIKit

let demoViewHeight: CGFloat = 200
class DemoView: UIView {
    
    let label: UILabel = UILabel()
    let segmentView: XYSegmentView!
    
    init(title: String, config: XYSegmentViewConfig) {
        
        label.text = title
        label.frame = CGRect(x: 20, y: 10, width: kScreenW-40, height: 20)
        segmentView = XYSegmentView(config: config)
        
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: demoViewHeight))
        
        addSubview(label)
        addSubview(segmentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DefalutDemoViewController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - kNavHeight))
        self.view.addSubview(scrollView)
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let demoTitles: [String] = [
            "默认效果/一行代码",
            "header 数据较少平分宽度",
            "header 数据较少依次排开",
            "header 数据较少依次排开 - 自定间距",
            "header 多数据自适应宽度",
            "滑块 为条状且与 title 等宽度,跟随滑动",
            "滑块 为条状,与 title 不等宽度,跟随滑动",
            "滑块 为条状且与 title 等宽度,不跟随滑动",
            "滑块 为圆点状且切换有粘连效果",
            "滑块 为圆点点状且切换无粘连效果，不跟随滑动",
            "滑块 指定宽高, 跟随滑动",
            "滑块 指定宽高, 跟随滑动, 有粘连效果",
            "内容禁用左右滑动，只保留title点击切换",
        ]
        
        for (index,title) in demoTitles.enumerated() {
            
            let config = XYSegmentViewConfig()
            config.frame = CGRect(x: 20, y: 40, width: kScreenW - 40, height: demoViewHeight - 50)
            config.titleViewFrame = CGRect(x: 0, y: 0, width: config.frame.width, height: 44)
            
            
            config.containerViewFrame = CGRect(x: 0, y: 44, width: config.frame.width, height: config.frame.height - 44)
            config.superVC = self
            
            if index == 1 {
                config.titles = ["推荐","游戏","娱乐","趣玩"]
                config.isTitleAverageLayout = true
            }
            
            if index == 2 {
                config.titles = ["推荐","游戏","娱乐","趣玩"]
            }
            
            if index == 3 {
                config.titles = ["推荐","游戏","娱乐","趣玩"]
                config.titleMargin = 50
            }
            
            if index != 0 {
                config.titles = ["推荐","游戏","娱乐","趣玩"]
            }
            
            if index == 4 {
                config.titles = ["推荐","游戏","娱乐","趣玩","推荐333","游戏333游戏哈哈","娱乐0","趣玩1","推荐2313","游戏993js","娱乐jjddz","趣玩qnmb"]
                var vcs: [UIViewController] = []
                for _ in config.titles {
                    vcs.append(vc())
                }
                config.contentVCs = vcs
            }
            
            if index == 5 {
                config.scrollLineType = .default
            }
            
            if index == 6 {
                config.scrollLineInnerMargin = 20
            }
            
            if index == 7 {
                config.scrollLineInnerMargin = 10
                config.scrollLineFollowSliding = false
            }
            
            if index == 8 {
                config.scrollLineType = .dot
            }
            
            if index == 9 {
                config.scrollLineType = .dot
                config.scrollLineFollowSliding = false
            }
            
            if index == 10 {
                config.scrollLineType = .default
                config.scrollLineInnerMargin = 5
            }
            
            if index == 11 {
                config.scrollLineType = .default
                
            }
            
            if index == 12 {
                config.contentScrollEnable = false
            }
            
            
            let demo = DemoView(title: title, config: config)
            demo.frame.origin.y = CGFloat(index) * demoViewHeight
            addNewDemo(demo: demo)
        }
        scrollView.contentSize = CGSize(width: 0, height: Int(demoViewHeight) * demoTitles.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

extension DefalutDemoViewController {
    
    func addNewDemo(demo: DemoView) {
        scrollView.addSubview(demo)
    }
    
}
