//
//  UITool.swift
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/10/28.
//

import CoreGraphics
import UIKit

//MARK: - UI常量和方法
/// rgb创建颜色
func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> UIColor {
    return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

/// 主题颜色
var mainColor: UIColor {
    return .groupTableViewBackground
}

/// 动画时间
let animationTimeinterval: TimeInterval = 0.35


//MARK: - 安全区的一些数据
struct UITool {
    
    /// 状态条高度
    static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            if let height = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.size.height {
                return height
            }
        }
        return  UIApplication.shared.statusBarFrame.size.height
    }
    
    /// 底部安全距离
    static var safeBottom: CGFloat {
        if #available(iOS 11.0, *) {
            if let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                return bottom
            }
        }
        return 0
    }
    
    /// 导航栏高度
    static var navBarHeight: CGFloat {
        let nav = UINavigationController()
        return nav.navigationBar.frame.height
    }
    
    /// 状态条 + 导航栏 的高度
    static var statusAndNavbarHeight: CGFloat {
        return self.statusBarHeight + self.navBarHeight
    }
    
}

//MARK: - VFL布局语法帮助扩展
extension UIView {
    
    func edgeTo(targetView: UIView) {
        self.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: targetView.leadingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: targetView.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: targetView.trailingAnchor).isActive = true
    }
    
    @discardableResult
    func withVFL(_ format: String , views: [String: UIView] , options: NSLayoutConstraint.FormatOptions = [] , metrics: [String : Any]? = nil) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views)
        self.addConstraints(constraints)
        return constraints
    }
    
    /// 找到View的父试图控制器
    func viewController() -> UIViewController? {
        var vc: UIResponder? = self.next
        while vc != nil {
            if vc?.isKind(of: UIViewController.self) == true {
                return vc as? UIViewController
            }
            vc = vc?.next
        }
        return nil
    }
}

extension Dictionary where Key == String , Value == UIView {
    
    func addToSuperView(_ superView: UIView) {
        let viewsArr = Array(self.values)
        if !viewsArr.contains(superView) {
            viewsArr.forEach { (subView) in
                if subView.translatesAutoresizingMaskIntoConstraints {
                    subView.translatesAutoresizingMaskIntoConstraints = false
                }
                superView.addSubview(subView)
            }
        }else {
            
        }
    }
    
}


//MARK: - 链式语法糖
protocol ChainCode {}

extension ChainCode {
    public var cc: Chainer<Self> {
        return Chainer(self)
    }
    public var set: Chainer<Self> {
        return Chainer(self)
    }
}

@dynamicMemberLookup
struct Chainer<Content> {
    
    public let content: Content
    
    var get: Content {
        return self.content
    }
    
    init(_ content: Content) {
        self.content = content
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> ((Value) -> Chainer<Content>) {
        var subject = self.content
        return { value in
            subject[keyPath: keyPath] = value
            return Chainer(subject)
        }
    }
}

extension UIView: ChainCode {}
extension NSLayoutConstraint: ChainCode {}
extension UIViewController: ChainCode {}
extension CALayer: ChainCode {}




