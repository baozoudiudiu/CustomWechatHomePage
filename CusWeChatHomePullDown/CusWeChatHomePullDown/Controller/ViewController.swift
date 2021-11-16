//
//  ViewController.swift
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/10/28.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    //MARK: - Lazy
    /// 消息列表
    lazy var messageView: MessageView = {
        let msgView = MessageView.init()
            .cc
            .delegate(self)
            .backgroundColor(mainColor)
            .content
        return msgView
    }()
    
    
    /// 小程序列表
    lazy var appletView: AppletMainView = {
        return AppletMainView.init(frame: CGRect.zero)
    }()
    
    //MARK: - Property
    var mainBgColor: UIColor {
        return mainColor
    }
    
    /// 消息列表顶部距离父视图的约束对象
    fileprivate var msgViewTopLayout: NSLayoutConstraint!
    
    //MARK: - Configure UI
    fileprivate func configureUI() {
        
        func setupNavgationItem() {
            self.navigationItem.title = "微信"
            if #available(iOS 13.0, *) {
                let bar = UINavigationBarAppearance()
                bar.backgroundColor = mainColor
                self.navigationController?.navigationBar.standardAppearance = bar
                self.navigationController?.navigationBar.scrollEdgeAppearance = bar
            } else {
                self.navigationController?.navigationBar.barTintColor = mainColor
            }
        }
        
        // 添加小程序列表视图
        func addAppletView() {
            let map: [String: UIView] = [
                "appletView": self.appletView
            ]
            map.addToSuperView(self.view)
            self.view.withVFL("H:|[appletView]|", views: map)
            self.view.withVFL("V:|[appletView]|", views: map)
        }
        
        // 添加消息列表视图
        func addMessageView() {
            let map: [String: UIView] = [
                "msgView": self.messageView
            ]
            map.addToSuperView(self.view)
            self.view.withVFL("H:|[msgView]|", views: map)
            self.messageView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
            self.msgViewTopLayout = self.messageView.topAnchor.constraint(equalTo: self.view.topAnchor)
                .set
                .isActive(true)
                .get
        }
        
        setupNavgationItem()
        addAppletView()
        addMessageView()
        self.view.backgroundColor = self.mainBgColor
    }
}

extension ViewController: MessageViewDelegate {
    
    func barChanged(_ isShow: Bool) {
        self.navigationController?.navigationBar.isHidden = isShow
    }
    
    func loadTopLayout() -> NSLayoutConstraint {
        return self.msgViewTopLayout
    }
        
    func beginToBottom(_ toBottom: Bool) {
        if toBottom == false {
            self.appletView.closeAnimation()
        }
    }
    
    func endToBottom(_ toBottom: Bool) {
        if toBottom == false {
            self.tabBarController?.tabBar.isHidden = toBottom
        }
    }
    
    func toBottom(_ toBottom: Bool) {
        if toBottom {
            self.tabBarController?.tabBar.isHidden = toBottom
        }
    }
    
    func navigationBarClick() {
        self.appletView.closeAnimation()
    }
    
    func upToDown(percent: CGFloat) {
        self.appletView.setUpdownPercent(percent)
    }
    
    func downToUp(_ distance: CGFloat) {
        self.appletView.setDownToUpDistance(distance)
    }
}

