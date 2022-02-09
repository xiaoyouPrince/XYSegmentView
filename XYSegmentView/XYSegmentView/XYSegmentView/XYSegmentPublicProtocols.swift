//
//  XYSegmentPublicProtocols.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/8.
//

import UIKit

/// ContentView 协议，定义了 ContentView 的基本操作
public protocol XYSegmentConfigProtocol: AnyObject {
    var config: XYSegmentViewConfig {set get}
}

/// TitleView 协议，定义了 TitleView 的基本操作
public protocol XYSegmentTitleViewProtocol: AnyObject {
    
}

extension XYSegmentTitleViewProtocol {
    
}

/// ContentView 协议，定义了 ContentView 的基本操作
public protocol XYSegmentContainerViewProtocol: AnyObject {
    
}

extension XYSegmentContainerViewProtocol {
    
}
