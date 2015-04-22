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
    var frontIsShowing: Bool{
        get{
            return frontShowing
        }
    }
    
    required init(coder aDecoder: NSCoder) {
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
                UIView.transitionWithView(self, duration: 0.6, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
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
        clearSubviews(front)
        clearSubviews(back)
        let frontDict = card.front as! NSDictionary
        let backDict = card.back as! NSDictionary
        restoreViewsWithDictionary(frontDict, onView: front)
        restoreViewsWithDictionary(backDict, onView: back)
    }
    
    private func clearSubviews(viewToBeCleared: UIView){
        for subview in viewToBeCleared.subviews{
            subview.removeFromSuperview()
        }
    }
    
    private func restoreViewsWithDictionary(dict: NSDictionary, onView view: UIView){
        for key in dict.allKeys{
            let element = dict.objectForKey(key) as! NSDictionary
            let type = element.objectForKey("type") as! String
            if type == "txt"{
                let frameValue = element.objectForKey("frame") as! NSValue
                let frame = frameValue.CGRectValue()
                var label = UILabel(frame: frame)
                label.font = UIFont(name: element.objectForKey("font") as! String, size: element.objectForKey("font_size") as! CGFloat)
                label.text = element.objectForKey("content") as? String
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.lineBreakMode = NSLineBreakMode.ByCharWrapping
                view.addSubview(label)
            }
            else if type == "img"{
                let frameValue = element.objectForKey("frame") as! NSValue
                let frame = frameValue.CGRectValue()
                let imgURL = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String) + "/" + (element.objectForKey("content") as! String)
                var imageView = UIImageView(frame: frame)
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let image = UIImage(contentsOfFile: imgURL)
                    imageView.image = image
                    view.addSubview(imageView)
                })
            }
        }
    }
    
}
