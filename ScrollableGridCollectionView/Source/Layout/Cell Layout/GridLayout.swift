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
    
    /// Item size of cells
    var itemSize = CGSize(width: 296, height: 154)
    
    /// Spacing between each column
    var itemHorizontalSpacing: CGFloat = 7
    
    /// Spacing between each row
    var itemVerticalSpacing: CGFloat = 15
    
    /// The padding on the edges of the views bounds
    var edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    // Caches for keeping current/previous attributes
    private var currentCellAttributes = [[UICollectionViewLayoutAttributes]]()
    private var currentSupplementaryAttributesByKind = [String: [ScrollViewSupplementaryLayoutAttributes]]()
    private var cachedCellAttributes = [[UICollectionViewLayoutAttributes]]()
    private var cachedSupplementaryAttributesByKind = [String: [ScrollViewSupplementaryLayoutAttributes]]()
    
    // Containers for keeping track of changing items
    private var insertedIndexPaths = [NSIndexPath]()
    private var removedIndexPaths = [NSIndexPath]()
    private var insertedSectionIndices = [Int]()
    private var removedSectionIndices = [Int]()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        // Deep-copy attributes in current cache
        cachedCellAttributes = currentCellAttributes.map() {
            return $0.map() {
                return $0.copy() as! UICollectionViewLayoutAttributes
            }
        }
        for (kind, attributes) in currentSupplementaryAttributesByKind {
            cachedSupplementaryAttributesByKind[kind] = attributes.map() { $0.copy() as! ScrollViewSupplementaryLayoutAttributes }
        }
    }
    
    
    // MARK: - Layout attributes init
    
    private func computeEntireLayout(preserveScroll: Bool = true) {
        currentCellAttributes.removeAll()
        // ensure we have a collection view
        guard let collectionView = self.collectionView else { return }
        // grab meta data needed for layout
        let numSections = collectionView.numberOfSections()
        var scrollViewAttributesArray = [ScrollViewSupplementaryLayoutAttributes]()
        // iterate sections
        for sectionIdx in 0..<numSections {
            let numCols = collectionView.numberOfItemsInSection(sectionIdx)
            var existingRowOffset: CGFloat = 0
            let scrollViewAtts = supplementaryScrollViewAttributes(sectionIdx, numOfItems: numCols)
            // attempt to preserve old offset if we have it
            if preserveScroll {
                if let oldSvAttributes = currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind] where oldSvAttributes.count > sectionIdx {
                    existingRowOffset = oldSvAttributes[sectionIdx].contentOffset.x
                    scrollViewAtts.contentOffset = CGPoint(x: existingRowOffset, y: 0)
                }
            }
            // cache items in row
            currentCellAttributes.append(layoutAttributes(sectionIdx, numOfItems: numCols, itemOffset: existingRowOffset))
            // cache scroll view
            scrollViewAttributesArray.append(scrollViewAtts)
        }
        // these are all removed at the end instead of the beginning in case scroll position is attempting to be preserve
        currentSupplementaryAttributesByKind.removeAll()
        currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind] = scrollViewAttributesArray
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
    private func layoutAttributes(inRow: Int, numOfItems: Int, itemOffset: CGFloat = 0) -> [UICollectionViewLayoutAttributes] {
        var rowAttributes = [UICollectionViewLayoutAttributes]()
        // first frame in row
        let rowHeight = itemSize.height + itemVerticalSpacing
        var itemFrame = CGRect(origin: CGPoint(x: edgeInsets.left, y: edgeInsets.top + CGFloat(inRow)*rowHeight),
                               size: itemSize)
        // create items
        for col in 0..<numOfItems {
            let indexPath = NSIndexPath(forItem: col, inSection: inRow)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.transform3D = CATransform3DMakeTranslation(-itemOffset, 0, 0)
            attributes.frame = itemFrame
            attributes.zIndex = GridLayoutConst.zIndexCell
            rowAttributes.append(attributes)
            // increment to next items frame
            itemFrame.origin.x += itemSize.width + itemHorizontalSpacing
        }
        return rowAttributes
    }
    
    // Convenience init for a single item.
    private func layoutAttributesForCell(atIndexPath: NSIndexPath, itemOffset: CGFloat = 0) -> UICollectionViewLayoutAttributes {
        // compute position
        let rowHeight = itemSize.height + itemVerticalSpacing
        let rowWidth = itemSize.width + itemHorizontalSpacing
        let rowOrigin = CGPoint(x: edgeInsets.left + CGFloat(atIndexPath.item) * rowWidth,
                                y: edgeInsets.top + CGFloat(atIndexPath.section) * rowHeight)
        let itemFrame = CGRect(origin: rowOrigin,
                               size: itemSize)
        // create attributes
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: atIndexPath)
        attributes.transform3D = CATransform3DMakeTranslation(-itemOffset, 0, 0)
        attributes.frame = itemFrame
        attributes.zIndex = GridLayoutConst.zIndexCell
        return attributes
    }
    
    
    // MARK: - Layout Updates
    
    func updateOffset(ofSection: Int, offset: CGFloat) {
        guard ofSection >= 0 && ofSection <= currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]!.count-1 else {
            return
        }
        let rowAttributes = currentCellAttributes[ofSection]
        // update cell attributes
        for attributes in rowAttributes {
            attributes.transform = CGAffineTransformMakeTranslation(-offset, 0)
        }
        // update supplementary attributes
        currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]![ofSection].contentOffset = CGPoint(x: offset, y: 0)
        self.invalidateLayout()
    }
    
    
    // MARK: - Cell Layout Attributes
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return currentCellAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = Array(currentCellAttributes.flatten())
        let suppViewAttributes = currentSupplementaryAttributesByKind.flatMap { (kind, attributes) -> [ScrollViewSupplementaryLayoutAttributes] in
            return attributes
        }
        allAttributes.appendContentsOf(suppViewAttributes as [UICollectionViewLayoutAttributes])
        return allAttributes
    }
    
    
    // MARK: - Supplementary Layout Attributes
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return currentSupplementaryAttributesByKind[elementKind]![indexPath.section]
    }
    
    
    // MARK: - Collection view updates
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
        if insertedIndexPaths.contains(itemIndexPath) {
            // If this is a newly inserted item
        } else if insertedSectionIndices.contains(itemIndexPath.section) {
            // if it's part of a new section
        } else {
            // If being inserted becuase of another cell being removed, slide from right
            let scrollViewAtts = currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]![itemIndexPath.section]
            attributes = layoutAttributesForCell(NSIndexPath(forItem: itemIndexPath.item + 1, inSection: itemIndexPath.section),
                                                 itemOffset: scrollViewAtts.contentOffset.x)
        }
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: UICollectionViewLayoutAttributes?
        if (removedIndexPaths.contains(itemIndexPath) || removedSectionIndices.contains(itemIndexPath.section)) {
            // get current offset of row
            var rowOffset: CGFloat = 0
            if let suppKindAtts = currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind] where suppKindAtts.count > itemIndexPath.section {
                let scrollAttributes = suppKindAtts[itemIndexPath.section]
                rowOffset = scrollAttributes.contentOffset.x
            }
            // Make it fall off the screen
            attributes = layoutAttributesForCell(itemIndexPath)
            let transform = CATransform3DMakeTranslation(-rowOffset, 0, 0)
            attributes!.transform3D = transform
            attributes!.alpha = 0
        }
        return attributes
    }
    
    private func reloadAttributes(inRow: Int) {
        let colCount = self.collectionView!.numberOfItemsInSection(inRow)
        // preserve old contentOffset
        let oldScrollOffset = currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]![inRow].contentOffset
        let newAttributes = supplementaryScrollViewAttributes(inRow, numOfItems: colCount)
        newAttributes.contentOffset = oldScrollOffset
        currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]![inRow] = newAttributes
        currentCellAttributes[inRow] = layoutAttributes(inRow, numOfItems: colCount, itemOffset: oldScrollOffset.x)
    }
    
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayoutWithContext(context)
        if context.invalidateDataSourceCounts {
            // rebuild the world
            computeEntireLayout()
        }
    }
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        // Keep track of updates to items and sections so we can use this information to create nifty animations
        for item in updateItems {
            guard item.indexPathBeforeUpdate != nil || item.indexPathAfterUpdate != nil else { continue }
            if item.updateAction == .Insert {
                // If the update item's index path has an "item" value of NSNotFound, it means it was a section update, not an individual item.
                // This is 100% undocumented but 100% reproducible.
                if item.indexPathAfterUpdate?.item == NSNotFound {
                    insertedSectionIndices.append(item.indexPathAfterUpdate!.section)
                    let rowAttributes = layoutAttributes(item.indexPathAfterUpdate!.section,
                                                         numOfItems: self.collectionView!.numberOfItemsInSection(item.indexPathAfterUpdate!.section))
                    currentCellAttributes.insert(rowAttributes, atIndex: item.indexPathAfterUpdate!.section)
                } else {
                    let rowAttributes = layoutAttributes(item.indexPathAfterUpdate!.section,
                                                         numOfItems: self.collectionView!.numberOfItemsInSection(item.indexPathAfterUpdate!.section))
                    currentCellAttributes[item.indexPathAfterUpdate!.section] = rowAttributes
                    insertedIndexPaths.append(item.indexPathAfterUpdate!)
                }
            } else if item.updateAction == .Delete {
                if item.indexPathBeforeUpdate?.item == NSNotFound {
                    removedSectionIndices.append(item.indexPathBeforeUpdate!.section)
                } else {
                    removedIndexPaths.append(item.indexPathBeforeUpdate!)
                }
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        // dump all tracked updates
        insertedIndexPaths.removeAll()
        removedIndexPaths.removeAll()
        insertedSectionIndices.removeAll()
        removedSectionIndices.removeAll()
    }
 
 
    // MARK: - Content Size
 
    override func collectionViewContentSize() -> CGSize {
        guard let lastScrollViewAttributes = currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]?.last, let collectionView = self.collectionView else {
            return CGSize.zero
        }
        let maxX = collectionView.bounds.width
        let maxY = lastScrollViewAttributes.frame.maxY + edgeInsets.bottom
        return CGSize(width: maxX, height: maxY)
    }
    
    
    // MARK: - Bounds change
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        // only change if collection view size has changed
        if self.collectionView?.bounds.size != newBounds.size {
            return true
        } else {
            return false
        }
    }
    
    func updateScrollViews(toWidth: CGFloat) {
        for scrollViewAttributes in currentSupplementaryAttributesByKind[ScrollViewSupplementaryViewConst.kind]! {
            scrollViewAttributes.frame.size.width = toWidth
        }
    }
}
