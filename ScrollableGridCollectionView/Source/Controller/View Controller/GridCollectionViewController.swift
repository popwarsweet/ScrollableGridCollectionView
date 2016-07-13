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
    
    /// The associated grid layout
    var gridLayout: GridLayout {
        return self.collectionViewLayout as! GridLayout
    }

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCellConst.reuseId)
        self.collectionView!.registerClass(ScrollViewSupplementaryView.self, forSupplementaryViewOfKind: ScrollViewSupplementaryViewConst.kind, withReuseIdentifier: ScrollViewSupplementaryViewConst.reuseId)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellConst.reuseId, forIndexPath: indexPath)
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
        print("offset: \(view.scrollView.contentOffset.x)")
    }
}