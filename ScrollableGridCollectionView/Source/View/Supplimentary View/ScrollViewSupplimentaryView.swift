//
//  ScrollViewSupplementaryView.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/12/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

// MARK: - Constants

struct ScrollViewSupplementaryViewConst {
    static let kind = "ScrollViewSupplementaryView"
    static let reuseId = "ScrollViewSupplementaryViewId"
}


// MARK: - Delegate Protocol

protocol ScrollViewSupplementaryViewDelegate: class {
    func supplementaryScrollViewDidScroll(view: ScrollViewSupplementaryView)
}


// MARK: - ScrollViewSupplementaryView

class ScrollViewSupplementaryView: UICollectionReusableView {
    
    /// Scroll view delegate
    weak var delegate: ScrollViewSupplementaryViewDelegate?
    
    /// The section which the supplementary view is a part of.
    private(set) var section: Int = -1
    
    private(set) lazy var scrollView: UIScrollView = { [unowned self] in
        let sv = UIScrollView(frame: self.bounds)
        sv.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
        sv.scrollsToTop = false
        sv.delegate = self
        return sv
    }()
    
    
    // MARK: - Layout
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        guard layoutAttributes is ScrollViewSupplementaryLayoutAttributes else {
            fatalError("\(self) should always receive \(String(ScrollViewSupplementaryLayoutAttributes)) as layout attributes")
        }
        // update scroll view layout
        let svAttributes = layoutAttributes as! ScrollViewSupplementaryLayoutAttributes
        scrollView.contentSize = svAttributes.contentSize
        scrollView.contentOffset = svAttributes.contentOffset
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}


// MARK: - Scroll view delegate

extension ScrollViewSupplementaryView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.supplementaryScrollViewDidScroll(self)
    }
}
