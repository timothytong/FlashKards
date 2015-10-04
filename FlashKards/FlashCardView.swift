//
//  FlashCardView.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-21.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class FlashCardView: UIView {
    var front: UIView!
    var back: UIView!
    private var flipAnimating = false
    private var frontShowing = true
    private var isLast = false
    var frontIsShowing: Bool{
        get{
            return frontShowing
        }
    }
    var isEndOfQuizCard: Bool{
        get{
            return isLast
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        front = UIView()
        back = UIView()
        let viewsDict = ["front": front, "back": back]
        front.backgroundColor = UIColor.redColor()
        back.backgroundColor = UIColor.greenColor()
        
        addSubview(front)
        addSubview(back)
        
        let frontVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[front]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewsDict)
        let frontHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[front]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewsDict)
        let backVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[back]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewsDict)
        let backHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[back]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewsDict)
        for constraint in [frontVConstraints, frontHConstraints, backVConstraints, backHConstraints]{
            addConstraints(constraint)
        }
        
        
        back.hidden = true
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    func flip(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !self.flipAnimating{
                self.flipAnimating = true
                UIView.transitionWithView(self, duration: 0.4, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
                    self.front.hidden = !self.front.hidden
                    self.back.hidden = !self.back.hidden
                    }, completion: { (complete) -> Void in
                        self.frontShowing = !self.frontShowing
                        self.flipAnimating = false
                })
            }
            
        })
    }
    
    func restoreViewsWithFlashcard(card: FlashCard){
        Utilities.clearSubviews(front)
        Utilities.clearSubviews(back)
        let frontDict = card.front as! NSDictionary
        let backDict = card.back as! NSDictionary
        front = Utilities.restoreViewsWithDictionary(frontDict, onView: front, widthScaleRatio: 1, heightScaleRatio: 1)
        back = Utilities.restoreViewsWithDictionary(backDict, onView: back, widthScaleRatio: 1, heightScaleRatio: 1)
    }
    
}
