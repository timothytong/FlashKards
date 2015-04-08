//
//  ConfirmDeletePopup.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-25.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol PopupDelegate{
    optional func popupConfirmBtnDidTapped(popup: Popup)
    optional func popupCancelBtnDidTapped(popup: Popup)
}
class Popup: UIView {
    var message:String!{
        get{
            return ""
        }
        set(messageText){
            instrucLabel.text = messageText
        }
    }
    var instructionLabelFontSize: CGFloat!{
        get{
            return 0
        }
        set(newFontSize){
            instrucLabel.font = instrucLabel.font.fontWithSize(newFontSize)
        }
    }
    var confirmButtonText: String!{
        get{
            return confirmBtnLabel.text
        }
        set(newText){
            confirmBtnLabel.text = newText
        }
    }
    var numOptions: Int!{
        get{
            return 0
        }
        set(newVal){
            removeButtons()
            if newVal == 0{
                instrucLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                instrucLabel.transform = self.transform
            }
            else if newVal == 1{
                cancelBtn.frame = CGRect(x: instrucLabel.frame.origin.x, y: cancelBtn.frame.origin.y, width: instrucLabel.frame.width, height: cancelBtn.frame.height)
                cancelBtnLabel.frame = CGRect(x: 0, y: cancelBtnLabel.frame.origin.y, width: instrucLabel.frame.width, height: cancelBtn.frame.height)
                addSubview(cancelBtn)
            }
            else{
                confirmBtn.frame = CGRect(x: 10, y: frame.height * 2/3, width: frame.width/2 - 15, height: 50)
                confirmBtnLabel.frame = CGRect(x: 0, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height)
                addSubview(confirmBtn)
                
                cancelBtn.frame = CGRect(x: frame.width/2 + 5, y: frame.height * 2/3, width: frame.width/2 - 15, height: 50)
                cancelBtnLabel.frame = CGRect(x: 0, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height)
                addSubview(cancelBtn)
            }
        }
    }
    var cancelBtnText: String!{
        get{
            return cancelBtnLabel.text
        }
        set(newText){
            cancelBtnLabel.text = newText
        }
    }
    var delegate: AnyObject?
    private var confirmBtnLabel: UILabel!
    private var instrucLabel: UILabel!
    private var confirmBtn: UIButton!
    private var cancelBtn: UIButton!
    private var cancelBtnLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 0.7).CGColor
        
        alpha = 0
        transform = CGAffineTransformMakeScale(1.1, 1.1)
        
        // Instruction label
        instrucLabel = UILabel(frame: CGRectMake(10, 25, frame.width - 20, frame.height/2))
        instrucLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 27)
        instrucLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        instrucLabel.numberOfLines = 3
        instrucLabel.textAlignment = NSTextAlignment.Center
        instrucLabel.adjustsFontSizeToFitWidth = true
        instrucLabel.minimumScaleFactor = 0.7
        addSubview(instrucLabel)
        
        // Confirm Btn
        confirmBtn = UIButton(frame: CGRect(x: 10, y: frame.height * 2/3, width: frame.width/2 - 15, height: 50))
        confirmBtnLabel = UILabel(frame: CGRect(x: 0, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height))
        confirmBtnLabel.font = UIFont(name: "Avenir-Roman", size: 22)
        confirmBtnLabel.text = "DELETE"
        confirmBtnLabel.textAlignment = NSTextAlignment.Center
        confirmBtnLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        confirmBtn.addTarget(self, action: "confirmBtnTapped", forControlEvents: UIControlEvents.TouchUpInside)
        confirmBtn.addSubview(confirmBtnLabel)
        addSubview(confirmBtn)
        
        // Cancel Btn
        cancelBtn = UIButton(frame: CGRect(x: frame.width/2 + 5, y: frame.height * 2/3, width: frame.width/2 - 15, height: 50))
        cancelBtnLabel = UILabel(frame: CGRect(x: 0, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height))
        cancelBtnLabel.font = UIFont(name: "Avenir-Roman", size: 22)
        cancelBtnLabel.text = "CANCEL"
        cancelBtnLabel.textAlignment = NSTextAlignment.Center
        cancelBtnLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        cancelBtn.addTarget(self, action: "cancelBtnTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cancelBtn.addSubview(cancelBtnLabel)
        addSubview(cancelBtn)
    }
    
    func removeButtons(){
        if confirmBtn.isDescendantOfView(self){
            confirmBtn.removeFromSuperview()
        }
        if cancelBtn.isDescendantOfView(self){
            cancelBtn.removeFromSuperview()
        }
    }
    
    func confirmBtnTapped(){
        hide()
        if (self.delegate?.respondsToSelector(Selector("popupConfirmBtnDidTapped:")) == true){
            self.delegate!.popupConfirmBtnDidTapped!(self)
        }
        
    }
    func cancelBtnTapped(){
        hide()
        if (self.delegate?.respondsToSelector(Selector("popupCancelBtnDidTapped:")) == true){
            println("Calling delegate...")
            self.delegate!.popupCancelBtnDidTapped!(self)
        }
    }
    
    func show(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.alpha = 0.5
                self.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: { (complete) -> Void in
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.alpha = 1
                        self.transform = CGAffineTransformIdentity
                        }, completion: { (complete) -> Void in
                    })
            })
        })
    }
    
    func hide(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(0.8, 0.8)
                self.alpha = 0
                }, completion: { (complete) -> Void in
                    self.transform = CGAffineTransformMakeScale(1.1, 1.1)
            })
        })
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
