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
    func supplementaryScrollViewDidReceiveTap(atPoint: CGPoint, view: ScrollViewSupplementaryView)
}


// MARK: - ScrollViewSupplementaryView

class ScrollViewSupplementaryView: UICollectionReusableView {
    
    /// Scroll view delegate
    weak var delegate: ScrollViewSupplementaryViewDelegate?
    
    /// The section which the supplementary view is a part of.
    private(set) var section: Int = -1
    
    /// If layout attributes are set w/ animation, content size is set after the animated finishes
    private var finalContentSize = CGSize.zero
    
    private(set) lazy var scrollView: UIScrollView = { [unowned self] in
        let sv = UIScrollView(frame: self.bounds)
//        sv.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4) // UIColor.clearColor()
        sv.showsHorizontalScrollIndicator = false
        sv.scrollsToTop = false
        sv.delegate = self
        sv.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sv.addGestureRecognizer(tapGesture)
        return sv
    }()
    
    
    // MARK: - Layout
    
    func applyLayoutAttributes(layoutAttributes: ScrollViewSupplementaryLayoutAttributes, animated: Bool) {
        // note section should be set *before* contentSize/contentOffset so delegate is not called w/ incorrect section
        section = layoutAttributes.section
        // illegal scroll offset, update it
        // TODO: move this to layout, its affecting underlying object held by layout
        if abs((layoutAttributes.contentSize.width - layoutAttributes.contentOffset.x)) < layoutAttributes.frame.width {
            layoutAttributes.contentOffset = CGPoint(x: layoutAttributes.contentSize.width - layoutAttributes.frame.width, y: 0)
        }
        // if animated, we'll set content size after animation finishes
        if !animated || scrollView.contentOffset == layoutAttributes.contentOffset {
            // keep scroll content size at a minimum of scroll view bounds to allow bouncing
            let scrollViewContentWidth = max(layoutAttributes.contentSize.width, scrollView.bounds.width + 1)
            scrollView.contentSize = CGSize(width: scrollViewContentWidth, height: layoutAttributes.contentSize.height)
        }
        finalContentSize = layoutAttributes.contentSize
        // using animated=false api to stop any leftover momentum after cell is reused,
        // using min/max offset to ensure we don't set a contentOffset beyond contentSize
        let maxAllowableXOffset = max(0, layoutAttributes.contentSize.width - layoutAttributes.frame.width)
        let xContentOffset = min(maxAllowableXOffset , max(0, layoutAttributes.contentOffset.x))
        scrollView.setContentOffset(CGPoint(x: xContentOffset, y: layoutAttributes.contentOffset.y), animated: animated)
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        guard layoutAttributes is ScrollViewSupplementaryLayoutAttributes else {
            fatalError("\(self) should always receive \(String(ScrollViewSupplementaryLayoutAttributes)) as layout attributes")
        }
        applyLayoutAttributes(layoutAttributes as! ScrollViewSupplementaryLayoutAttributes, animated: false)
    }
    
    
    // MARK: - Gesture handling
    
    func handleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(self)
        delegate?.supplementaryScrollViewDidReceiveTap(location, view: self)
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
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.contentSize = finalContentSize
    }
}
