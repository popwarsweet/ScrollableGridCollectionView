//
//  ScrollViewSupplementaryLayoutAttributes.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/13/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

class ScrollViewSupplementaryLayoutAttributes: UICollectionViewLayoutAttributes {
    /// The content size of the scroll view.
    var contentSize = CGSize.zero
    /// The current content offset of the scroll view.
    var contentOffset = CGPoint.zero
    /// Section that the view is part of.
    var section: Int = -1
}
