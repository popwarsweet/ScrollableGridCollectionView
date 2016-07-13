//
//  GridLayout.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/12/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

struct GridLayoutConst {
    static let zIndexCell = 0
    static let zIndexScrollView = 1
}

class GridLayout: UICollectionViewLayout {
    
    /// Cached attributes of cells
    var layoutAttributes = [[UICollectionViewLayoutAttributes]]()
    
    /// Cached attributes of scroll view attributes
    var supplementaryScrollViewAttributes = [ScrollViewSupplementaryLayoutAttributes]()
    
    /// Item size of cells
    var itemSize = CGSize(width: 296, height: 154)
    
    /// Spacing between each column
    var itemHorizontalSpacing: CGFloat = 7
    
    /// Spacing between each row
    var itemVerticalSpacing: CGFloat = 15
    
    /// The padding on the edges of the views bounds
    var edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    override func prepareLayout() {
        guard layoutAttributes.count == 0 else { return }
        computeInitialLayout()
    }
    
    
    // MARK: - Layout attributes init
    
    private func computeInitialLayout() {
        // ensure we have a collection view
        guard let collectionView = self.collectionView else { return }
        // grab meta data needed for layout
        let numSections = collectionView.numberOfSections()
        // iterate sections
        for sectionIdx in 0..<numSections {
            let numCols = collectionView.numberOfItemsInSection(sectionIdx)
            // cache items in row
            layoutAttributes.append(layoutAttributes(sectionIdx, numOfItems: numCols))
            // cache scroll view
            supplementaryScrollViewAttributes.append(supplementaryScrollViewAttributes(sectionIdx, numOfItems: numCols))
        }
    }
    
    /// Convenience init for layout attributes of a supplementary scroll view in a particular row.
    private func supplementaryScrollViewAttributes(inRow: Int, numOfItems: Int) -> ScrollViewSupplementaryLayoutAttributes {
        guard numOfItems > 0 else {
            fatalError("shouldn't be requesting scroll view for a section with no items")
        }
        // compute content width of scroll view for numOfItems
        let rowHeight = itemSize.height + itemVerticalSpacing
        let rowContentWidth = edgeInsets.left + edgeInsets.right + CGFloat(numOfItems)*itemSize.width + CGFloat(numOfItems-1)*itemHorizontalSpacing
        // create attributes & set properties
        let svAttributes = ScrollViewSupplementaryLayoutAttributes(forSupplementaryViewOfKind: ScrollViewSupplementaryViewConst.kind,
                                                                   withIndexPath: NSIndexPath(forItem: 0, inSection: inRow))
        svAttributes.frame = CGRect(origin: CGPoint(x: 0, y: edgeInsets.top + CGFloat(inRow)*rowHeight),
                                    size: CGSize(width: self.collectionView!.bounds.width, height: itemSize.height))
        svAttributes.contentSize = CGSize(width: rowContentWidth,
                                          height: svAttributes.frame.height)
        svAttributes.section = inRow
        svAttributes.zIndex = GridLayoutConst.zIndexScrollView
        return svAttributes
    }
    
    /// Convenience init for layout attributes in a particular row.
    private func layoutAttributes(inRow: Int, numOfItems: Int) -> [UICollectionViewLayoutAttributes] {
        var rowAttributes = [UICollectionViewLayoutAttributes]()
        // first frame in row
        let rowHeight = itemSize.height + itemVerticalSpacing
        var itemFrame = CGRect(origin: CGPoint(x: edgeInsets.left, y: edgeInsets.top + CGFloat(inRow)*rowHeight),
                               size: itemSize)
        // create items
        for col in 0..<numOfItems {
            let indexPath = NSIndexPath(forItem: col, inSection: inRow)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = itemFrame
            attributes.zIndex = GridLayoutConst.zIndexCell
            rowAttributes.append(attributes)
            // increment to next items frame
            itemFrame.origin.x += itemSize.width + itemHorizontalSpacing
        }
        return rowAttributes
    }
    
    
    // MARK: - Layout Updates
    
    func updateOffset(ofSection: Int, offset: CGFloat) {
        guard ofSection >= 0 && ofSection <= supplementaryScrollViewAttributes.count-1 else {
            return
        }
        let rowAttributes = layoutAttributes[ofSection]
        // update cell attributes
        for attributes in rowAttributes {
            attributes.transform = CGAffineTransformMakeTranslation(-offset, 0)
        }
        // update supplementary attributes
        supplementaryScrollViewAttributes[ofSection].contentOffset = CGPoint(x: offset, y: 0)
        self.invalidateLayout()
    }
    
    
    // MARK: - Cell Layout Attributes
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var items = Array(layoutAttributes.flatten())
        items.appendContentsOf(supplementaryScrollViewAttributes as [UICollectionViewLayoutAttributes])
        return items
    }
    
    
    // MARK: - Supplementary Layout Attributes
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == ScrollViewSupplementaryViewConst.kind {
            return supplementaryScrollViewAttributes[indexPath.section]
        } else {
            return nil
        }
    }
    
    
    // MARK: - Content Size
    
    override func collectionViewContentSize() -> CGSize {
        guard let lastScrollViewAttributes = supplementaryScrollViewAttributes.last, let collectionView = self.collectionView else {
            return CGSize.zero
        }
        let maxX = collectionView.bounds.width
        let maxY = lastScrollViewAttributes.frame.maxY + edgeInsets.bottom
        return CGSize(width: maxX, height: maxY)
    }
    
    
    // MARK: - Bounds change
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        // only change if collection view size has changed
        if self.collectionView!.bounds.size != newBounds.size {
            return true
        } else {
            return false
        }
    }
    
    func updateScrollViews(toWidth: CGFloat) {
        for scrollViewAttributes in supplementaryScrollViewAttributes {
            scrollViewAttributes.frame.size.width = toWidth
        }
    }
}
