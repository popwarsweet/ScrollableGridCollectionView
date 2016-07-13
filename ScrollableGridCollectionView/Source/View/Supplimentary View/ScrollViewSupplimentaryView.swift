//
//  ScrollViewSupplimentaryView.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/12/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

// MARK: - Constants

struct ScrollViewSupplimentaryViewConst {
    static let kind = "ScrollViewSupplimentaryView"
    static let reuseId = "ScrollViewSupplimentaryViewId"
}


// MARK: - Delegate Protocol

protocol ScrollViewSupplimentaryViewDelegate: class {
    func supplimentaryScrollViewDidScroll(view: ScrollViewSupplimentaryView)
}


// MARK: - ScrollViewSupplimentaryView

class ScrollViewSupplimentaryView: UICollectionReusableView {
    
    /// Scroll view delegate
    weak var delegate: ScrollViewSupplimentaryViewDelegate?
    
    /// The section which the supplimentary view is a part of.
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
        guard layoutAttributes is ScrollViewSupplimentaryLayoutAttributes else {
            fatalError("\(self) should always receive \(String(ScrollViewSupplimentaryLayoutAttributes)) as layout attributes")
        }
        // update scroll view layout
        let svAttributes = layoutAttributes as! ScrollViewSupplimentaryLayoutAttributes
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

extension ScrollViewSupplimentaryView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.supplimentaryScrollViewDidScroll(self)
    }
}
