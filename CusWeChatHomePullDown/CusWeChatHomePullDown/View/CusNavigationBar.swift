//
//  CusNavigationBar.swift
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/10/29.
//

import Foundation
import UIKit

//MARK: - Open API
extension CusNavigationBar {
    
    func toBottom(_ toBottom: Bool = true) {
        if toBottom {
            self.barBottomLayout.constant = -(UITool.safeBottom)
            self.bgColor = rgba(185, 185, 185, 0.1)
            self.isUserInteractionEnabled = true
            self.bar.titleTextAttributes = [
                .foregroundColor: rgba(185, 185, 185, 0.5)
            ]
            return
        }
        
        self.barBottomLayout.constant = 0
        self.bgColor = mainColor
        self.isUserInteractionEnabled = false
        self.bar.titleTextAttributes = [
            .foregroundColor: rgba(53, 53, 53)
        ]
    }
    
    func setTapActionHandler(_ handler: @escaping ()->Void) {
        self.tapActionHandler = handler
    }
    
    func setPanActionHandler(_ handler: @escaping (UIGestureRecognizer.State, CGFloat)->Void) {
        self.panActionhandler = handler
    }
}


class CusNavigationBar: UIView {
    
    var bgColor: UIColor? {
        
        set {
            self.backgroundColor = newValue
        }
        
        get {
            return self.backgroundColor
        }
    }
    
    fileprivate var barBottomLayout: NSLayoutConstraint!
    
    fileprivate var tapActionHandler: (()->Void)?
    
    fileprivate var panActionhandler: ((UIGestureRecognizer.State, CGFloat)->Void)?
    
    fileprivate lazy var bar: UINavigationBar = {
        let bar = UINavigationBar.init(frame: UINavigationController().navigationBar.bounds)
            .cc
            .content
        bar.setBackgroundImage(UIImage(), for: .default)
        bar.shadowImage = UIImage()
        return bar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bar.setItems([UINavigationItem.init(title: "微信")], animated: false)
        let map: [String: UIView] = ["bar": self.bar]
        map.addToSuperView(self)
        self.withVFL("V:[bar(\(self.bar.frame.height))]", views: map)
        self.withVFL("H:|[bar]|", views: map)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.barBottomLayout = self.bar.bottomAnchor.constraint(equalTo: self.bottomAnchor).set.isActive(true).get
        self.heightAnchor.constraint(equalToConstant: self.bar.frame.height + UITool.statusBarHeight).isActive = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(_:)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func tapAction() {
        self.tapActionHandler?()
    }
    
    @objc fileprivate func panAction(_ pan: UIPanGestureRecognizer) {
        let state = pan.state
        let point = pan.translation(in: pan.view)
        self.panActionhandler?(state, point.y * -1)
        pan.setTranslation(CGPoint.zero, in: pan.view)
    }
}
