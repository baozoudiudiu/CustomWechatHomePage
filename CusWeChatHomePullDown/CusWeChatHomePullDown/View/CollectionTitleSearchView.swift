//
//  CollectionTitleSearchView.swift
//  CusWeChatHomePullDown
//
//  Created by 陈旺 on 2021/11/12.
//

import UIKit

class CollectionTitleSearchView: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        let label = UILabel.init(frame: CGRect.zero)
            .set
            .text("最近")
            .textAlignment(.center)
            .textColor(.white)
            .font(.systemFont(ofSize: 16, weight: .medium))
            .get
        let searchView = self.createSearchView()
        let map: [String: UIView] = [
            "lab": label,
            "search": searchView
        ]
        map.addToSuperView(self.contentView)
        self.contentView.withVFL("H:|[lab]|", views: map)
        self.contentView.withVFL("V:|-(\(UITool.statusBarHeight + UITool.navBarHeight))-[lab(50)]-10-[search(40)]|", views: map, options: [.alignAllLeading, .alignAllTrailing])
    }
    
    fileprivate func createSearchView() -> UIView {
        let label = UILabel.init(frame: CGRect.zero)
            .set
            .text("搜索小程序")
            .textColor(.white)
            .textAlignment(.center)
            .font(.systemFont(ofSize: 14))
            .get
        
        let labView = UIView(frame: CGRect.zero)
            .set
            .backgroundColor(rgba(250, 250, 250, 0.15))
            .get
        labView.layer.cornerRadius = 4
        labView.layer.masksToBounds = true
        
        var map: [String: UIView] = ["lab": label]
        map.addToSuperView(labView)
        labView.withVFL("H:|[lab]|", views: map)
        labView.withVFL("V:|[lab]|", views: map)
        
        let view = UIView.init(frame: CGRect.zero)
        map = ["labView": labView]
        map.addToSuperView(view)
        view.withVFL("H:|[labView]|", views: map)
        view.withVFL("V:[labView(40)]", views: map)
        labView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }
}

class CollectionSectionView: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate func configureCell() {
        func createLabel(title: String) -> UILabel {
            return UILabel(frame: CGRect.zero)
                .set
                .textColor(.white)
                .font(.systemFont(ofSize: 12))
                .text(title)
                .get
        }
        let map: [String: UIView] = [
            "left": createLabel(title: "最近使用的小程序"),
            "right": createLabel(title: "更多")
        ]
        map.addToSuperView(self.contentView)
        self.contentView.withVFL("H:|[left]-(>=0)-[right]|", views: map, options: [.alignAllCenterY])
        self.contentView.withVFL("V:[left]|", views: map)
    }
}

class CollectionItemView: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate func configureCell() {
        
        let width: CGFloat = 60
        
        let icon = UIView()
            .set
            .backgroundColor(.white)
            .get
        
        let lab = UILabel()
            .set
            .text("我是标题")
            .textColor(.white)
            .font(.systemFont(ofSize: 13))
            .textAlignment(.center)
            .get
        
        icon.layer.cornerRadius = width * 0.5
        icon.layer.masksToBounds = true
        
        let map: [String: UIView] = [
            "icon": icon,
            "lab": lab
        ]
        map.addToSuperView(self.contentView)
        self.contentView.withVFL("V:[icon(\(width))]-4-[lab]|", views: map, options: [.alignAllCenterX])
        self.contentView.withVFL("H:[icon(\(width))]", views: map)
        self.contentView.withVFL("H:|[lab]|", views: map)
    }
}
