//
//  SmallFlashCardCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-05-13.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class SmallFlashCardCell: UICollectionViewCell {

    @IBOutlet private weak var view: UIView!
    
    func populateViewWithDict(dictionary: NSDictionary, widthScale wScale: CGFloat, heightScale hScale: CGFloat){
        Utilities.clearSubviews(view)
        Utilities.restoreViewsWithDictionary(dictionary, onView: view, widthScaleRatio: wScale, heightScaleRatio: hScale)
    }
}
