//
//  XYSegmentFuncs.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/7.
//

/// TODO & FEATURES
/// 1. 提供一个 XYSegmentView 级别的公共存储。让 content 随时可以知道自己是哪个 item <最好是协议，默认实现的那种, 实现协议的部分可以直接使用>。 自定义的 title/ content 都可以直接基于协议实现，提供自定义说明指导
/// 2. 提供一个 XYSegmentView 级别的公共配置。外界使用者可以直接配置配置类即可轻松实现
/// 3. 代理的实现。针对页面跳转、滑动、跨页点击跳转都通过代理方便监听各种事件
/// 4. 丰富的自定义实现Demo: 微博、智联招聘、老虎证券、亲宝宝、咕咚运动

import UIKit

// MARK:-一些常量

func navHeight() -> CGFloat {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? UIApplication.shared.statusBarFrame.height
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

public let iPhoneX = isIPhoneX()
public let kStatusBarH = navHeight()
public let kNavBarH : CGFloat = 44
public let kNavHeight : CGFloat = kStatusBarH + kNavBarH
public let kTabbarH : CGFloat = 49
public let kTabSafeH : CGFloat = tabbarSafeHeight()

public let kScreenW : CGFloat = UIScreen.main.bounds.width
public let kScreenH : CGFloat = UIScreen.main.bounds.height

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
    
    // MARK: - 返回一个颜色的 RGB
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        return (fRed * 255, fGreen * 255, fBlue * 255)
    }
    
}
