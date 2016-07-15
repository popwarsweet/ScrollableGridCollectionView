//
//  GridCollectionViewController.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/12/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class GridCollectionViewController: UICollectionViewController {
    
    /// Dummy data source
    var numItemsInSection = Array(count: 10, repeatedValue: 3)
    
    /// Layer used for styling the background view
    private lazy var backgroundGradientLayer: CAGradientLayer = { [unowned self] in
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = [
            UIColor(hue:0.00, saturation:0.00, brightness:0.26, alpha:1).CGColor,
            UIColor(hue:0.00, saturation:0.00, brightness:0.00, alpha:1).CGColor
        ]
        return gradient
    }()
    
    /// The associated grid layout
    var gridLayout: GridLayout {
        return self.collectionViewLayout as! GridLayout
    }

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // style
        self.collectionView?.backgroundView = {
            let view = UIView(frame: self.view.bounds)
            view.layer.addSublayer(self.backgroundGradientLayer)
            return view
        }()
        // Register cell classes
        self.collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCellConst.reuseId)
        self.collectionView!.registerClass(ScrollViewSupplementaryView.self, forSupplementaryViewOfKind: ScrollViewSupplementaryViewConst.kind, withReuseIdentifier: ScrollViewSupplementaryViewConst.reuseId)
    }
    
    
    // MARK: - Cell insertion/removal
    
    func insertCell(path: NSIndexPath) {
        let newCount = numItemsInSection[path.section] + 1
        numItemsInSection[path.section] = newCount
        self.collectionView!.performBatchUpdates(
            {
                if self.numItemsInSection[path.section] == 1 {
                    self.collectionView!.insertSections(NSIndexSet(index: path.section))
                } else {
                    self.collectionView!.insertItemsAtIndexPaths([path])
                }
            }, completion: { (success) in
                if let suppScrollView = self.collectionView!.supplementaryViewForElementKind(ScrollViewSupplementaryViewConst.kind,
                    atIndexPath: NSIndexPath(forItem: 0, inSection: path.section)) as? ScrollViewSupplementaryView {
                    let attributes = self.gridLayout.layoutAttributesForSupplementaryViewOfKind(ScrollViewSupplementaryViewConst.kind,
                        atIndexPath: NSIndexPath(forItem: 0, inSection: path.section)) as! ScrollViewSupplementaryLayoutAttributes
                    suppScrollView.scrollView.contentSize = attributes.contentSize
                    suppScrollView.scrollView.contentOffset = attributes.contentOffset
                }
        })
    }
    func deleteCell(path: NSIndexPath) {
        let newCount = numItemsInSection[path.section] - 1
        numItemsInSection[path.section] = newCount
        var deleteSection = false
        if newCount == 0 {
            deleteSection = true
            self.numItemsInSection.removeAtIndex(path.section)
        }
        self.collectionView!.performBatchUpdates(
            {
                if deleteSection {
                    self.collectionView!.deleteSections(NSIndexSet(index: path.section))
                } else {
                    self.collectionView!.deleteItemsAtIndexPaths([path])
                }
            }, completion: { (success) in
                if deleteSection == false {
                    if let suppScrollView = self.collectionView!.supplementaryViewForElementKind(ScrollViewSupplementaryViewConst.kind,
                        atIndexPath: NSIndexPath(forItem: 0, inSection: path.section)) as? ScrollViewSupplementaryView {
                        let attributes = self.gridLayout.layoutAttributesForSupplementaryViewOfKind(ScrollViewSupplementaryViewConst.kind,
                            atIndexPath: NSIndexPath(forItem: 0, inSection: path.section)) as! ScrollViewSupplementaryLayoutAttributes
                        suppScrollView.applyLayoutAttributes(attributes)
                    }
                }
        })
    }
    
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = self.view.bounds
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        // invalidate widths of scroll views used for horizontal scrolling
        self.gridLayout.updateScrollViews(size.width)
        self.gridLayout.invalidateLayout()
    }
    
    
    // MARK: - Status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


// MARK: - CollectionView Delegate

extension GridCollectionViewController {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selected: \(indexPath.section): \(indexPath.row)")
        deleteCell(indexPath)
    }
}


// MARK: - CollectionView Datasource

extension GridCollectionViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numItemsInSection.filter(){ $0 > 0 }.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numItemsInSection[section]
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellConst.reuseId,
                                                                         forIndexPath: indexPath) as! CollectionViewCell
        cell.label.text = String(indexPath.row)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let sv = collectionView.dequeueReusableSupplementaryViewOfKind(ScrollViewSupplementaryViewConst.kind,
                                                                       withReuseIdentifier: ScrollViewSupplementaryViewConst.reuseId,
                                                                       forIndexPath: indexPath) as! ScrollViewSupplementaryView
        sv.delegate = self
        return sv
    }
}


// MARK: Supplementary scroll view delegate

extension GridCollectionViewController: ScrollViewSupplementaryViewDelegate {
    func supplementaryScrollViewDidScroll(view: ScrollViewSupplementaryView) {
        // update offset of items in layout
        self.gridLayout.updateOffset(view.section, offset: view.scrollView.contentOffset.x)
    }
    func supplementaryScrollViewDidReceiveTap(atPoint: CGPoint, view: ScrollViewSupplementaryView) {
        let locationInCv = view.convertPoint(atPoint, toView: self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(locationInCv) {
            self.collectionView?.delegate?.collectionView!(self.collectionView!, didSelectItemAtIndexPath: indexPath)
        }
    }
}