//
//  ViewController.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/6.
//

import UIKit

var theVC = UIViewController()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        theVC = self
        
        let seg = XYSegmentView(frame: CGRect(x: 0, y: kNavBarH + 44, width: kScreenW, height: 500))
        view.addSubview(seg)
    }


}

