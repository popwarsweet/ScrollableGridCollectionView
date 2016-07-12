//
//  ScrollViewSupplimentaryView.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/12/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

struct ScrollViewSupplimentaryViewConst {
    static let kind = "ScrollViewSupplimentaryView"
    static let reuseId = "ScrollViewSupplimentaryViewId"
}

class ScrollViewSupplimentaryView: UICollectionReusableView {
    
    lazy var scrollView: UIScrollView = { [unowned self] in
        let sv = UIScrollView(frame: self.bounds)
        sv.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
        sv.scrollsToTop = false
        return sv
    }()
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
