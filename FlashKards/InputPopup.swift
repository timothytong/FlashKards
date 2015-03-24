//
//  InputPopup.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-23.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class InputPopup: UIView, UITextFieldDelegate {
    private var inputField: UITextField!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 0.7).CGColor
        
        var instrucLabel = UILabel(frame: CGRectMake(0, 25, frame.width, frame.height/3))
        instrucLabel.text = "Name your new collection."
        instrucLabel.font = UIFont(name: "AvenirNextCondensed-Ultralight", size: 35)
        instrucLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        instrucLabel.numberOfLines = 2
        instrucLabel.textAlignment = NSTextAlignment.Center
        instrucLabel.transform = CGAffineTransformMakeScale(1, 0.8)
        addSubview(instrucLabel)
        
        // Input field & it's border.
        inputField = UITextField(frame: CGRectMake(frame.width/8, frame.height/2 - 20, frame.width*3/4, 40))
        inputField.layer.borderWidth = 0
        inputField.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        inputField.font = UIFont(name: "AvenirNextCondensed-Regular", size: 25)
        inputField.textColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha:1)
        inputField.placeholder = "Name here."
        inputField.textAlignment = NSTextAlignment.Center
        inputField.returnKeyType = UIReturnKeyType.Done
        inputField.delegate = self
        var cancelImg = UIImage(named: "cancel-white.png")
        var clrBtn = UIButton(frame:CGRectMake(0, 0, 22, 24))
        clrBtn.setImage(cancelImg, forState: .Normal)
        clrBtn.setImage(cancelImg, forState: .Highlighted)
        clrBtn.addTarget(self, action: "clearTxt", forControlEvents: .TouchUpInside)
        inputField.rightView = clrBtn
        inputField.rightViewMode = .WhileEditing
        var border = CALayer()
        border.frame = CGRect(x: 0, y: inputField.frame.size.height - 1, width: inputField.frame.size.width, height: inputField.frame.size.height)
        border.borderColor = UIColor(red: 247/255, green: 4/255, blue: 0, alpha: 1).CGColor
        border.borderWidth = 1
        inputField.layer.addSublayer(border)
        inputField.layer.masksToBounds = true
        addSubview(inputField)
        
        var doneBtn = UIButton(frame: CGRect(x: frame.width/2 - 50, y: frame.height * 2/3, width: 100, height: 50))
        var doneBtnLabel = UILabel(frame: CGRect(x: 0, y: 0, width: doneBtn.frame.width, height: doneBtn.frame.height))
        doneBtnLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        doneBtnLabel.text = "DONE"
        doneBtnLabel.textAlignment = NSTextAlignment.Center
        doneBtnLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        doneBtn.addSubview(doneBtnLabel)
        addSubview(doneBtn)
        
    }
    
    func clearTxt(){
        inputField.text = ""
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: inputField)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, -50)
                }) { (complete) -> Void in
            }
        })
    }
    
    func textFieldTextDidChange(notification: NSNotification){
        let textFieldText = inputField.text
        if textFieldText.utf16Count > 20{
            inputField.text = (textFieldText as NSString).substringToIndex(20)
            showTextFieldWarning()
        }
    }
    
    func showTextFieldWarning(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.inputField, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.inputField.textColor = UIColor(red: 247/255, green: 230/255, blue: 0, alpha: 1)
            }, completion: { (complete) -> Void in
                UIView.transitionWithView(self.inputField, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.inputField.textColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
                    }, completion: { (complete) -> Void in
                })
            })
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        dismissKeyboard()
    }
    
    func dismissKeyboard(){
        if inputField.isFirstResponder(){ inputField.resignFirstResponder() }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }) { (complete) -> Void in
            }
            UIView.transitionWithView(self.inputField, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.inputField.textColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
                }, completion: { (complete) -> Void in
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
