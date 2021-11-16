//
//  MessageListView.swift
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/10/29.
//

import Foundation
import UIKit
import AudioToolbox

protocol MessageViewDelegate: AnyObject {
    
    /**
     状态条发生变化
     isShow - true: 展示, false: 隐藏
     */
    func barChanged(_ isShow: Bool) -> Void
    
    /**
     获取MessageView的顶部约束
     */
    func loadTopLayout() -> NSLayoutConstraint
    
    /**
     开始执行动画
     toBottom - true: 滚向底部, false: 滚向顶部
     */
    func beginToBottom(_ toBottom: Bool) -> Void
    
    /**
     动画中
     */
    func toBottom(_ toBottom: Bool) -> Void
    
    /**
     动画完成
     */
    func endToBottom(_ toBottom: Bool) -> Void
    
    /**
     naviBar点击事件回调
     */
    func navigationBarClick() -> Void
    
    /**
     从上往下拖动的进度
     */
    func upToDown(percent: CGFloat) -> Void
    
    /**
     从下往上拖的距离
     */
    func downToUp(_ distance: CGFloat) -> Void
}

class MessageView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    init() {
        super.init(frame: CGRect.zero)
        
        /// tableView
        var map:[String: UIView] = ["tb": self.tableView]
        map.addToSuperView(self)
        self.withVFL("H:|[tb]|", views: map)
        self.withVFL("V:|-(\(UITool.statusAndNavbarHeight))-[tb]|", views: map)
        
        /// bar && loading
        map = ["bar": self.navgationBar, "loading": self.loadingView]
        map.addToSuperView(self)
        self.withVFL("H:|[bar]|", views: map)
        self.withVFL("H:|[loading]|", views: map)
        self.withVFL("V:[loading(\(self.loadingViewHeight))][bar]", views: map)
        self.barTopLayout = self.navgationBar.topAnchor.constraint(equalTo: self.topAnchor)
            .set
            .isActive(true)
            .get
        
        self.bgColor = mainColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Lazy
    lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: CGRect.zero, style: .plain)
            .set
            .delegate(self)
            .dataSource(self)
            .backgroundColor(.clear)
            .get
        let view = UIView.init(frame: UIScreen.main.bounds)
            .set
            .backgroundColor(.clear)
            .get
        tb.backgroundView = view
        return tb
    }()
    
    lazy var navgationBar: CusNavigationBar = {
        return CusNavigationBar.init(frame: UINavigationController().navigationBar.frame)
            .set
            .isHidden(true)
            .get
    }()
    
    
    
    //MARK: - Property
    weak var delegate: MessageViewDelegate?
    
    /// 是否在执行动画中
    fileprivate var doAnimation: Bool = false {
        willSet {
            self.tableView.isScrollEnabled = !newValue
        }
    }
    
    fileprivate var bgColor: UIColor? {
        get {
            return self.backgroundColor
        }
        
        set {
            self.backgroundColor = newValue
        }
    }
    
    /// 状态导航栏顶部间距
    fileprivate var barTopLayout: NSLayoutConstraint!
    
    /// loadingView, 三个点
    fileprivate var loadingView = LoadingView(frame: CGRect.zero)
    
    /// loadingView的高度
    fileprivate let loadingViewHeight: CGFloat = 50
    
    //MARK: - TableViewDelegate, TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cell_id"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellId)
        }
        let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .cyan, .purple]
        cell?.contentView.backgroundColor = colors[indexPath.row % colors.count]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewController()?.navigationController?.pushViewController(NextController()
                                                                            .cc
                                                                            .hidesBottomBarWhenPushed(true)
                                                                            .content,
                                                                        animated: true)
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.doAnimation {
            return
        }
        
        let y = scrollView.contentOffset.y
        defer {self.moveBar(y)}
        self.showBar(y < 0) // 如果 y < 0, 则展示自定义导航栏, 否则隐藏
        
        if y <= 0 {
            // 实际的滑动距离
            let scrollDistance = abs(y)
            // 忽略多少距离后才开始计算进度
            let ignoreDist: CGFloat = self.loadingViewHeight * 0.5 + UITool.statusBarHeight
            // 参与计算的滑动距离
            let loadingDistance = scrollDistance > ignoreDist ? scrollDistance - ignoreDist : 0
            // 最大滑动距离
            let maxDist: CGFloat = 200
            // 计算动画百分比
            let percent = min(loadingDistance, maxDist) / maxDist
            self.loadingView.updatePercent(percent * 2)
            self.delegate?.upToDown(percent: percent / 5)
            
            let alpha = 1 - percent
            self.bgColor = mainColor.withAlphaComponent(alpha)
            self.navgationBar.bgColor = mainColor.withAlphaComponent(alpha < 1 ? 0 : 1)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let y = scrollView.contentOffset.y
        
        if y <= -120 {
            AudioServicesPlaySystemSound(1520)
            self.animationToBottom()
        }
    }
    
    //MARK: - Logic
    
    fileprivate func animationToBottom() {
        
        guard let layout = self.delegate?.loadTopLayout() else {
            return
        }
        
        self.doAnimation = true
        self.navgationBar.setTapActionHandler { [weak self] in
            self?.animationToTop()
            self?.delegate?.navigationBarClick()
        }
        var distance: CGFloat = 0
        self.navgationBar.setPanActionHandler { [weak self] (state, dis) in
            if state == .ended {
                self?.animationToTop()
                return
            }
            distance += dis
            self?.delegate?.downToUp(distance)
            layout.constant = layout.constant - dis
        }
        self.loadingView.alpha = 0.0
        self.bgColor = .clear
        
        self.delegate?.beginToBottom(true)
        UIView.animate(withDuration: animationTimeinterval) {
            self.moveBar(0)
            self.navgationBar.toBottom()
            layout.constant = self.frame.height - self.navgationBar.frame.height
            self.delegate?.toBottom(true)
            self.delegate?.upToDown(percent: 1)
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.delegate?.endToBottom(true)
        }
    }
    
    
    fileprivate func animationToTop() {
        guard let layout = self.delegate?.loadTopLayout() else {
            return
        }
        self.delegate?.beginToBottom(false)
        UIView.animate(withDuration: animationTimeinterval) {
            layout.constant = 0
            self.navgationBar.toBottom(false)
            self.delegate?.toBottom(false)
            self.bgColor = mainColor
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.showBar(false)
            self.delegate?.endToBottom(false)
            self.doAnimation = false
        }
    }
    
    fileprivate func showBar(_ show: Bool = true) {
        
        defer {
            self.delegate?.barChanged(show)
        }
        
        if show, self.navgationBar.isHidden {
            self.navgationBar.isHidden = false
            self.loadingView.isHidden = false
            self.loadingView.alpha = 1.0
            return
        }
        
        if show == false, self.navgationBar.isHidden == false {
            self.navgationBar.isHidden = true
        }
    }
    
    fileprivate func moveBar(_ y: CGFloat) {
        guard y < 0 else {
            guard self.barTopLayout.constant != 0 else {
                return
            }
            self.barTopLayout.constant = 0
            return
        }
        self.barTopLayout.constant = abs(y)
    }
}
