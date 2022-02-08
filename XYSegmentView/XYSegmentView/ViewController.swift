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
        theVC = self
        
        // segmentView
        let segFrame = CGRect(x: 0, y: kNavHeight, width: kScreenW, height: kScreenH - kNavHeight)
        
        // title
        let titleFrame = CGRect(x: 0, y: 0, width: segFrame.width, height: titleViewH)
//        let titles = ["推荐","游戏","娱乐","趣玩"];
        let titles = ["推荐","游戏","娱乐","趣玩","推荐333","游戏333游戏哈哈","娱乐0","趣玩1","推荐2313","游戏993js","娱乐jjddz","趣玩qnmb"];
        
        // content
        let contentY : CGFloat = titleViewH
        let contentH = segFrame.height - contentY
        let contentW = segFrame.width
        let contentFrame = CGRect(x: 0, y: contentY, width: contentW, height: contentH)
        
        // 2.创建对应的contentView
        var contentVcs = [UIViewController]()
        for _ in titles {
            contentVcs.append(CommonViewController())
        }
        
        let config = XYSegmentViewConfig()
        config.frame = segFrame
        
        config.titleViewFrame = titleFrame
        config.titles = titles
        if titles.count <= 4 {
            config.isTitleAverageLayout = true
        }
        config.titleMargin = 30
        
        config.containerViewFrame = contentFrame
        config.contentVCs = contentVcs
        config.superVC = self
        
        let seg = XYSegmentView(config: config)
        view.addSubview(seg)
    }
}

