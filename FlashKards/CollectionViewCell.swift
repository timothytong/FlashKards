//
//  CollectionViewCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-31.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.clipsToBounds = true
        imgView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    func putImage(newImg: UIImage!, withAnimation animate: Bool!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.alpha = 0
            self.transform = CGAffineTransformMakeScale(0.7, 0.7)
            self.imgView.image = newImg
            if animate == true{
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    println("Animating")
                    self.alpha = 1
                    self.transform = CGAffineTransformIdentity
                    }) { (complete) -> Void in
                        
                }
            }
            else{
                self.transform = CGAffineTransformIdentity
                self.alpha = 1
            }
            
        })
        
    }
    
}
