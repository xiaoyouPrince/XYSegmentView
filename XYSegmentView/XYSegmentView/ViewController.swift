//
//  ViewController.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/6.
//

import UIKit

var theVC = UIViewController()
let titleViewH: CGFloat = 44

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "XYSegmentView"
        theVC = self
        
        // segmentView
        let segFrame = CGRect(x: 0, y: kNavHeight, width: kScreenW, height: kScreenH - kNavHeight)
        
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
                contentVcs.append(DefalutDemoViewController())
            }else{
                
                if index == 2 {
                    contentVcs.append(TableViewController())
                }else if index == 3 {
                    contentVcs.append(ScrollViewController())
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
        view.addSubview(seg)
    }
}

