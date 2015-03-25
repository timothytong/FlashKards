//
//  ConfirmDeletePopup.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-25.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol ConfirmDeletePopupDelegate{
    func confirmDeletePopupCancelDidTapped()
    func confirmDeletePopupConfirmDidTapped()
}
class ConfirmDeletePopup: UIView {
    var collectionName:String!{
        get{
            return "";
        }
        set(collectionName){
            self.instrucLabel.text = "Confirm delete:\n\(collectionName)?"
        }
    }

    var delegate: AnyObject?
    private var instrucLabel: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 0.7).CGColor
        
        // Instruction label
        instrucLabel = UILabel(frame: CGRectMake(10, 25, frame.width - 20, frame.height/3))
        instrucLabel.font = UIFont(name: "AvenirNextCondensed-Ultralight", size: 35)
        instrucLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        instrucLabel.numberOfLines = 2
        instrucLabel.textAlignment = NSTextAlignment.Center
        instrucLabel.transform = CGAffineTransformMakeScale(1, 0.8)
        addSubview(instrucLabel)
        
        
        // Confirm Btn
        var confirmBtn = UIButton(frame: CGRect(x: 10, y: frame.height * 2/3, width: frame.width/2 - 15, height: 50))
        var confirmBtnLabel = UILabel(frame: CGRect(x: 0, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height))
        confirmBtnLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        confirmBtnLabel.text = "Delete"
        confirmBtnLabel.textAlignment = NSTextAlignment.Center
        confirmBtnLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        confirmBtn.addTarget(self, action: "confirmBtnTapped", forControlEvents: UIControlEvents.TouchUpInside)
        confirmBtn.addSubview(confirmBtnLabel)
        addSubview(confirmBtn)
        
        // Cancel Btn
        var cancelBtn = UIButton(frame: CGRect(x: frame.width/2 + 5, y: frame.height * 2/3, width: frame.width/2 - 15, height: 50))
        var cancelBtnLabel = UILabel(frame: CGRect(x: 0, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height))
        cancelBtnLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        cancelBtnLabel.text = "Cancel"
        cancelBtnLabel.textAlignment = NSTextAlignment.Center
        cancelBtnLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        cancelBtn.addTarget(self, action: "cancelBtnTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cancelBtn.addSubview(cancelBtnLabel)
        addSubview(cancelBtn)
    }
    
    func confirmBtnTapped(){
        self.delegate?.confirmDeletePopupConfirmDidTapped()
    }
    func cancelBtnTapped(){
        self.delegate?.confirmDeletePopupCancelDidTapped()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
