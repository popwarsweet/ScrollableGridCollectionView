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
        self.contentView.backgroundColor = UIColor(hue:0.17, saturation:0.02, brightness:0.96, alpha:1.00)
        self.layer.borderColor = UIColor(white: 0, alpha: 0.02).CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unimplemented")
    }
}
