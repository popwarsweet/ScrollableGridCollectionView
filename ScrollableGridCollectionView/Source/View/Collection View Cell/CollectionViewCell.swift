//
//  CollectionViewCell.swift
//  ScrollableGridCollectionView
//
//  Created by Kyle Zaragoza on 7/12/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

struct CollectionViewCellConst {
    static let reuseId = "CollectionViewCellId"
}

class CollectionViewCell: UICollectionViewCell {
    
    lazy var label: UILabel = { [unowned self] in
        let label = UILabel(frame: self.contentView.bounds)
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(22)
        self.contentView.addSubview(label)
        return label
    }()
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unimplemented")
    }
}
