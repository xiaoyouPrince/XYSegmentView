//
//  XYSegmentFuncs.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/7.
//

import UIKit

// MARK:-一些常量

func navHeight() -> CGFloat {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
    } else {
        return UIApplication.shared.statusBarFrame.height
    }
}

func tabbarSafeHeight() -> CGFloat {
    isIPhoneX() ? 34 : 0
}

func isIPhoneX() -> Bool {
    navHeight() == 20
}

let iPhoneX = isIPhoneX()
let kStatusBarH = navHeight()
let kNavBarH : CGFloat = 44
let kNavHeight : CGFloat = kStatusBarH + kNavBarH
let kTabbarH : CGFloat = 49
let kTabSafeH : CGFloat = tabbarSafeHeight()

let kScreenW : CGFloat = UIScreen.main.bounds.width
let kScreenH : CGFloat = UIScreen.main.bounds.height

// 重写一个UIColor的扩展，通过重写构造方法实现
extension UIColor{
    
    // MARK:-便利构造方法
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        // MARK:-必须通过self调用显式的构造方法
        self.init(red: r / 255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    // MARK: - 返回一个随机色
    class func randomColor() -> UIColor {
        return UIColor.init(r: CGFloat(arc4random_uniform(255)), g: CGFloat(arc4random_uniform(255)), b: CGFloat(arc4random_uniform(255)))
    }
    
}
