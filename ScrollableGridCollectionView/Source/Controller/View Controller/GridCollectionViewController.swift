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

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCellConst.reuseId)
        self.collectionView!.registerClass(ScrollViewSupplimentaryView.self, forSupplementaryViewOfKind: ScrollViewSupplimentaryViewConst.kind, withReuseIdentifier: ScrollViewSupplimentaryViewConst.reuseId)
    }
    

    // MARK: UICollectionViewDataSource

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
        let sv = collectionView.dequeueReusableSupplementaryViewOfKind(ScrollViewSupplimentaryViewConst.kind,
                                                                       withReuseIdentifier: ScrollViewSupplimentaryViewConst.reuseId,
                                                                       forIndexPath: indexPath)
        return sv
    }
}


// MARK: - CollectionView Datasource
