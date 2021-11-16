//
//  AppletMainView.swift/Users/chenwang/Desktop/chenwang/CusWeChatHomePullDown/CusWeChatHomePullDown
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/11/1.
//

import Foundation
import UIKit


fileprivate let cellId = "UICollectionViewCell"

extension AppletMainView {
    
    func setUpdownPercent(_ percent: CGFloat) {
        let scale = percent * (1 - minScale) + minScale
        let y = self.updownBeginY * (1 - percent)
        self.collectionView.transform = CGAffineTransform.init(translationX: 0, y: -y).scaledBy(x: scale, y: scale)
    }
    
    func setDownToUpDistance(_ distance: CGFloat) {
        var dis = distance
        
        if dis < 0 {
            dis = 0
        }
        
        if dis > self.collectionView.bounds.height {
            dis = self.collectionView.bounds.height
        }
        
        self.collectionView.transform = CGAffineTransform.init(translationX: 0, y: -dis)
    }
    
    func initUpdownStatus() {
        self.collectionView.transform = CGAffineTransform.init(translationX: 0, y: -(self.updownBeginY)).scaledBy(x: minScale, y: minScale)
    }
    
    func endUpdownStatus() {
        self.collectionView.transform = CGAffineTransform.identity
    }
    
    func endCloseStatus() {
        self.collectionView.transform = CGAffineTransform.init(translationX: 0, y: -self.collectionView.bounds.height)
    }
        
    func upDownAnimateToEnd() {
        guard self.isAnimation == false else {return}
        self.isAnimation = true
        UIView.animate(withDuration: animationTimeinterval) {
            self.endUpdownStatus()
        } completion: { _ in
            self.isAnimation = false
        }
    }
    
    func closeAnimation() {
        guard self.isAnimation == false else {return}
        self.isAnimation = true
        UIView.animate(withDuration: animationTimeinterval) {
            self.endCloseStatus()
        } completion: { _ in
            self.isAnimation = false
            self.initUpdownStatus()
        }
    }
}

class AppletMainView: UIView {
    
    fileprivate var gLayer: CAGradientLayer?
    
    fileprivate var isAnimation: Bool = false
    
    fileprivate var updownBeginY: CGFloat {
        return (self.bounds.height - self.bounds.height * self.minScale) * 0.5
    }
    
    fileprivate let minScale: CGFloat = 0.7
    
    lazy var collectionView: UICollectionView = {
        let collect = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init()).cc
            .delegate(self)
            .dataSource(self)
            .backgroundColor(.clear)
            .content
        collect.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collect.register(CollectionTitleSearchView.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionTitleSearchView.self))
        collect.register(CollectionSectionView.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionSectionView.self))
        collect.register(CollectionItemView.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionItemView.self))
        if #available(iOS 11.0, *) {
            collect.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 13.0, *) {
            collect.automaticallyAdjustsScrollIndicatorInsets = false
        }
        return collect
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.gLayer != nil {
            return
        }
        
        self.gLayer = CAGradientLayer()
            .set
            .frame(self.bounds)
            .colors([rgba(24, 22, 40).cgColor , rgba(85, 80, 108).cgColor])
            .startPoint(CGPoint(x: 0, y: 0))
            .endPoint(CGPoint(x: 1, y: 1))
            .get
        
        let layerView = UIView(frame: self.bounds)
        layerView.layer.addSublayer(self.gLayer!)
        self.addSubview(layerView)
        self.sendSubviewToBack(layerView)
        self.initUpdownStatus()
    }
    
    fileprivate func configureView() {
        let map: [String: UIView] = [
            "collect": self.collectionView
        ]
        map.addToSuperView(self)
        self.withVFL("H:|[collect]|", views: map)
        self.withVFL("V:|[collect]|", views: map)
    }
}

extension AppletMainView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.loadCellAt(indexPath: indexPath)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return loadCellSize(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    fileprivate func loadCellAt(indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
            case 0:
                return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionTitleSearchView.self), for: indexPath)
        default: 
            switch row {
                case 0:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionSectionView.self), for: indexPath)
                default:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionItemView.self), for: indexPath)
            }
        }
    }
    
    fileprivate func loadCellSize(at indexPath: IndexPath) -> CGSize {
        var size = CGSize.zero
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            size = CGSize.init(width: self.frame.width - 60, height: 100 + UITool.statusBarHeight + UITool.navBarHeight)
        default:
            switch row {
                case 0: size = CGSize(width: self.frame.width - 60, height: 40)
                default: size = CGSize(width: (self.frame.width - 60) / 4, height: 94)
                    
            }
        }
        return size
    }
}

