//
//  SmallFlashCardCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-05-13.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

@objc protocol SmallFlashCardCellDelegate{
    func smallFlashCardCellDeleteButtonTapped(index: Int)
}

class SmallFlashCardCell: UICollectionViewCell {
    @IBOutlet private weak var deleteButton: UIButton!
    private var index: Int!
    var delegate: AnyObject?
    @IBOutlet private weak var view: UIView!
    
    func populateViewWithDict(dictionary: NSDictionary, widthScale wScale: CGFloat, heightScale hScale: CGFloat, index: Int){
        Utilities.clearSubviews(view)
        Utilities.restoreViewsWithDictionary(dictionary, onView: view, widthScaleRatio: wScale, heightScaleRatio: hScale)
        let tapGesture = UITapGestureRecognizer(target: self, action: "deleteButtonTapped")
        deleteButton.addGestureRecognizer(tapGesture)
        self.index = index
    }
    
    func deleteButtonTapped(){
        self.delegate?.smallFlashCardCellDeleteButtonTapped(index)
    }
    
    func setIndex(newIndex: Int){
        index = newIndex
    }
}
