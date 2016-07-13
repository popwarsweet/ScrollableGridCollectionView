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
    
    /// Layer used for styling the background view
    private lazy var backgroundGradientLayer: CAGradientLayer = { [unowned self] in
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = [
            UIColor(hue: 214/360, saturation: 4/100, brightness: 44/100, alpha: 1).CGColor,
            UIColor(hue: 240/360, saturation: 14/100, brightness: 17/100, alpha: 1).CGColor
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
    
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = self.view.bounds
    }
    
    
    // MARK: - Status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


// MARK: - CollectionView Datasource

extension GridCollectionViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
}