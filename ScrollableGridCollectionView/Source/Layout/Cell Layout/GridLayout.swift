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
    var supplimentaryScrollViewAttributes = [ScrollViewSupplimentaryLayoutAttributes]()
    
    /// Item size of cells
    var itemSize = CGSize(width: 296, height: 154)
    
    /// Spacing between each column
    var itemHorizontalSpacing: CGFloat = 5
    
    /// Spacing between each row
    var itemVerticalSpacing: CGFloat = 20
    
    /// The padding on the edges of the views bounds
    var edgeInsets = UIEdgeInsetsZero
    
    override func prepareLayout() {
        // clear all items
        layoutAttributes.removeAll()
        supplimentaryScrollViewAttributes.removeAll()
        
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
            
            // create attributes for each supplimentary scroll view (using maxX of row for scroll views content width)
            let svAttributes = ScrollViewSupplimentaryLayoutAttributes(forSupplementaryViewOfKind: ScrollViewSupplimentaryViewConst.kind,
                                                                       withIndexPath: NSIndexPath(forItem: 0, inSection: sectionIdx))
            svAttributes.frame = CGRect(origin: CGPoint(x: edgeInsets.left, y: itemOrigin.y),
                                        size: CGSize(width: self.collectionView!.bounds.width, height: itemSize.height))
            svAttributes.contentSize = CGSize(width: itemOrigin.x - itemHorizontalSpacing + edgeInsets.right,
                                              height: svAttributes.frame.height)
            svAttributes.zIndex = GridLayoutConst.zIndexScrollView
            supplimentaryScrollViewAttributes.append(svAttributes)
            
            // increment yOrigin to next row
            itemOrigin = CGPoint(x: edgeInsets.left, y: itemOrigin.y + itemSize.height + itemVerticalSpacing)
        }
    }
    
    
    // MARK: - Cell Layout Attributes
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var items = Array(layoutAttributes.flatten())
        items.appendContentsOf(supplimentaryScrollViewAttributes as [UICollectionViewLayoutAttributes])
        return items
    }
    
    
    // MARK: - Supplimentary Layout Attributes
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == ScrollViewSupplimentaryViewConst.kind {
            return supplimentaryScrollViewAttributes[indexPath.section]
        } else {
            return nil
        }
    }
    
    
    // MARK: - Content Size
    override func collectionViewContentSize() -> CGSize {
        guard let lastScrollViewAttributes = supplimentaryScrollViewAttributes.last, let collectionView = self.collectionView else {
            return CGSize.zero
        }
        let maxX = collectionView.bounds.width + edgeInsets.right
        let maxY = lastScrollViewAttributes.frame.maxY + edgeInsets.bottom
        return CGSize(width: maxX, height: maxY)
    }

}
