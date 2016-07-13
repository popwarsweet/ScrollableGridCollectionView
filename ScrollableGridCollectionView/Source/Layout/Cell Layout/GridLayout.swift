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
    
    private func computeInitialLayout() {
        // ensure we have a collection view
        guard let collectionView = self.collectionView else { return }
        
        // grab meta data needed for layout
        let numSections = collectionView.numberOfSections()
        var itemOrigin = CGPoint(x: edgeInsets.left, y: edgeInsets.top)
        
        // TODO: break up layout by rows/columns
        
        // iterate sections
        for sectionIdx in 0..<numSections {
            // create attributes for each item
            let numRows = collectionView.numberOfItemsInSection(sectionIdx)
            var rowAttributes = [UICollectionViewLayoutAttributes]()
            for itemIdx in 0..<numRows {
                // get frame of item
                let itemFrame = CGRect(origin: itemOrigin, size: itemSize)
                // create attribute
                let indexPath = NSIndexPath(forItem: itemIdx, inSection: sectionIdx)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = itemFrame
                attributes.zIndex = GridLayoutConst.zIndexCell
                rowAttributes.append(attributes)
                // increment xOrigin to next column
                itemOrigin.x += itemSize.width + itemHorizontalSpacing
            }
            // cache row
            layoutAttributes.append(rowAttributes)
            
            // create attributes for each supplementary scroll view (using maxX of row for scroll views content width)
            let svAttributes = ScrollViewSupplementaryLayoutAttributes(forSupplementaryViewOfKind: ScrollViewSupplementaryViewConst.kind,
                                                                       withIndexPath: NSIndexPath(forItem: 0, inSection: sectionIdx))
            svAttributes.frame = CGRect(origin: CGPoint(x: edgeInsets.left, y: itemOrigin.y),
                                        size: CGSize(width: self.collectionView!.bounds.width, height: itemSize.height))
            svAttributes.contentSize = CGSize(width: itemOrigin.x - itemHorizontalSpacing + edgeInsets.right,
                                              height: svAttributes.frame.height)
            svAttributes.section = sectionIdx
            svAttributes.zIndex = GridLayoutConst.zIndexScrollView
            supplementaryScrollViewAttributes.append(svAttributes)
            
            // increment yOrigin to next row
            itemOrigin = CGPoint(x: edgeInsets.left, y: itemOrigin.y + itemSize.height + itemVerticalSpacing)
        }
    }
    
    
    // MARK: - Layout Updates
    
    // TODO: look at `UICollectionViewLayoutInvalidationContext` for smarter cache invalidation
    
    func updateOffset(ofSection: Int, offset: CGFloat) {
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

}
