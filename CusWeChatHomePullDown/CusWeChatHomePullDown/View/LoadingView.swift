//
//  LoadingView.swift
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/10/29.
//

import Foundation
import UIKit

extension LoadingView {
    
    func updatePercent(_ per: CGFloat) {
        
        var p = per
        
        p = p < 0 ? 0 : p
        p = p > 1 ? 1 : p
        
        guard p != self.currentPercent else {
            return
        }
        
        let main: CGFloat = 0.4
        let mid: CGFloat = 0.5
        let end: CGFloat = 1
        
        func toMain(_ p: CGFloat) {
            let percent = (p / main)
            let size = self.normalSize * percent
            let mainSize = self.bigSize * percent
            [self.leftDoitSize, self.rightDoitSize].forEach { item in
                item?.updateSize(size)
            }
            self.mainDoitSize.updateSize(mainSize)
            self.leftDoitRightMargin.constant = 0
            self.rightDoitLeftMargin.constant = 0
            self.currentPercent = p
        }
        
        func toMid(_ p: CGFloat) {
            let c = mid - main
            let k = (self.normalSize - self.bigSize) / c
            let b = (mid * self.bigSize -  main * self.normalSize) / (mid - main)
            let size = k * p + b
            self.mainDoitSize.updateSize(size)
            self.leftDoitRightMargin.constant = 0
            self.rightDoitLeftMargin.constant = 0
            self.currentPercent = p
        }
        
        func toLast(_ p: CGFloat) {
            let percent = (p - end + mid) / (end - mid)
            self.leftDoitRightMargin.constant = -self.hMargin * percent
            self.rightDoitLeftMargin.constant = self.hMargin * percent
            self.currentPercent = p
        }
        
        if p < main {
            
            if self.currentPercent >= mid {
                toLast(mid)
            }
            
            if self.currentPercent >= main {
                toMid(main)
            }
            
            toMain(p)
            return
        }
        
        if p < mid {
            
            if self.currentPercent <= main {
                toMain(main)
            }
            
            if self.currentPercent > mid {
                toLast(mid)
            }
            
            toMid(p)
            return
        }
        
        if self.currentPercent <= main {
            toMain(main)
        }
        
        if self.currentPercent <= mid {
            toMid(mid)
        }
        
        toLast(p)
    }
}


fileprivate let doitColor: UIColor = rgba(153, 153, 153, 1)

class LoadingView: UIView {
    
    class DoitSizeLayout {
        let widthLayout: NSLayoutConstraint
        let heightLayout: NSLayoutConstraint
        var view: UIView?
        
        init(widthLayout: NSLayoutConstraint, heightLayout: NSLayoutConstraint, view: UIView? = nil) {
            self.widthLayout = widthLayout
            self.heightLayout = heightLayout
            self.view = view
        }
        
        func updateSize(_ size: CGFloat) {
            self.widthLayout.constant = size
            self.heightLayout.constant = size
            self.view?.layer.cornerRadius = size * 0.5
            self.view?.layer.masksToBounds = true
        }
    }
    
    //MARK: - Property
    fileprivate var leftDoit: UIView = UIView().cc.backgroundColor(doitColor).content
    fileprivate var leftDoitSize: DoitSizeLayout!
    fileprivate var leftDoitRightMargin: NSLayoutConstraint!
    
    fileprivate var mainDoit: UIView = UIView().cc.backgroundColor(doitColor).content
    fileprivate var mainDoitSize: DoitSizeLayout!
    
    fileprivate var rightDoit: UIView = UIView().cc.backgroundColor(doitColor).content
    fileprivate var rightDoitSize: DoitSizeLayout!
    fileprivate var rightDoitLeftMargin: NSLayoutConstraint!
    
    fileprivate var normalSize: CGFloat = 10
    fileprivate var bigSize: CGFloat = 15
    fileprivate var hMargin: CGFloat = 20
    fileprivate var currentPercent: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate func configureView() {
        let map: [String: UIView] = [
            "left": self.leftDoit,
            "main": self.mainDoit,
            "right": self.rightDoit
        ]
        map.addToSuperView(self)
        
        self.leftDoitSize = self.createDoitSize(self.leftDoit)
        self.mainDoitSize = self.createDoitSize(self.mainDoit)
        self.rightDoitSize = self.createDoitSize(self.rightDoit)
        
        self.mainDoit.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.mainDoit.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.leftDoit.centerYAnchor.constraint(equalTo: self.mainDoit.centerYAnchor).isActive = true
        self.leftDoitRightMargin = self.leftDoit.centerXAnchor.constraint(equalTo: self.mainDoit.centerXAnchor)
            .cc
            .isActive(true)
            .content
        
        self.rightDoit.centerYAnchor.constraint(equalTo: self.mainDoit.centerYAnchor).isActive = true
        self.rightDoitLeftMargin = self.rightDoit.centerXAnchor.constraint(equalTo: self.mainDoit.centerXAnchor)
            .cc
            .isActive(true)
            .content
    }
    
    fileprivate func createDoitSize(_ doit: UIView) -> DoitSizeLayout {
        return DoitSizeLayout(widthLayout: doit.widthAnchor.constraint(equalToConstant: 0)
                                .cc
                                .isActive(true)
                                .content,
                               heightLayout: doit.heightAnchor.constraint(equalToConstant: 0)
                                .cc
                                .isActive(true)
                                .content,
                               view: doit)
    }
}

    
    

