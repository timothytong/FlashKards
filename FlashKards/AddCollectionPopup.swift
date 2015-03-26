//
//  InputPopup.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-23.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol AddCollectionPopupDelegate{
    func addCollectionPopupWillClose()
    func addCollectionPopupDoneButtonDidPressedWithInput(input:String!)
    func addCollectionInputAlreadyExists(input: String!)->Bool
}
class AddCollectionPopup: UIView, UITextFieldDelegate {
    private var inputField: UITextField!
    var delegate: AnyObject?
    private var acceptedCharset = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    private var errMsgLabel: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 0.7).CGColor
        
        // Instruction label
        var instrucLabel = UILabel(frame: CGRectMake(10, 25, frame.width - 20, frame.height/3))
        instrucLabel.text = "Name your new collection."
        instrucLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 30)
        instrucLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        instrucLabel.numberOfLines = 2
        instrucLabel.textAlignment = NSTextAlignment.Center
        addSubview(instrucLabel)
        
        // Input field & its border.
        inputField = UITextField(frame: CGRectMake(frame.width/8, frame.height/2 - 20, frame.width*3/4, 40))
        inputField.layer.borderWidth = 0
        inputField.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        inputField.font = UIFont(name: "AvenirNextCondensed-Regular", size: 25)
        inputField.textColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha:1)
        inputField.textAlignment = NSTextAlignment.Center
        inputField.returnKeyType = UIReturnKeyType.Done
        inputField.delegate = self
        var cancelImg = UIImage(named: "cancel-white.png")
        var cancelImg_hilighted = UIImage(named: "cancel-white-highlighted.png")
        var clrBtn = UIButton(frame:CGRectMake(0, 0, 22, 24))
        clrBtn.setImage(cancelImg, forState: .Normal)
        clrBtn.setImage(cancelImg_hilighted, forState: .Highlighted)
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
        resetInputPlaceHolder()
        
        // Error Message
        errMsgLabel = UILabel(frame: CGRect(x: frame.width/8, y: inputField.frame.origin.y + inputField.frame.height + 15, width: frame.width * 3/4, height: 35))
        errMsgLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        errMsgLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 12)
        errMsgLabel.textAlignment = NSTextAlignment.Center
        errMsgLabel.numberOfLines = 2
        errMsgLabel.text = ""
        addSubview(errMsgLabel)
        
        // Done Btn
        var doneBtn = UIButton(frame: CGRect(x: frame.width/2 - 50, y: frame.height * 3/4, width: 100, height: 50))
        var doneBtnLabel = UILabel(frame: CGRect(x: 0, y: 0, width: doneBtn.frame.width, height: doneBtn.frame.height))
        doneBtnLabel.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 25)
        doneBtnLabel.text = "Done"
        doneBtnLabel.textAlignment = NSTextAlignment.Center
        doneBtnLabel.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        doneBtn.addTarget(self, action: "doneBtnTapped", forControlEvents: UIControlEvents.TouchUpInside)
        doneBtn.addSubview(doneBtnLabel)
        addSubview(doneBtn)
        
        // Cancel Btn
        var cancelBtn = UIButton(frame: CGRect(x: frame.width - 25, y: 5, width: 20, height: 20))
        cancelBtn.setImage(cancelImg, forState: .Normal)
        cancelBtn.setImage(cancelImg_hilighted, forState: .Highlighted)
        cancelBtn.addTarget(self, action: "cancelBtnTapped", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(cancelBtn)
    }
    
    func clearTxt(){
        inputField.text = ""
    }
    
    private func checkInputValidity() -> Bool{
        let textFieldText = inputField.text
        if textFieldText.utf16Count == 0{
            showTextFieldWarning(1)
            return false
        }
        else if textFieldText.utf16Count > 20{
            inputField.text = (textFieldText as NSString).substringToIndex(20)
            errMsgLabel.text = "Maximum 20 characters."
            showTextFieldWarning(0)
            return false
        }
        return true
    }
    
    func cancelBtnTapped(){
        dismissKeyboard()
        clearTxt()
        closePopup()
    }
    
    func doneBtnTapped(){
        dismissKeyboard()
        if checkInputValidity(){
            let newCollectionName = inputField.text
            if delegate?.addCollectionInputAlreadyExists(newCollectionName) == false{
                delegate?.addCollectionPopupDoneButtonDidPressedWithInput(newCollectionName)
                clearTxt()
            }
        }
        
    }
    
    private func closePopup(){
        delegate?.addCollectionPopupWillClose()
    }
    
    private func resetInputPlaceHolder(){
        let attrs = [NSForegroundColorAttributeName: UIColor(red: 128/255, green: 132/255, blue: 131/255, alpha: 1)]
        if inputField.respondsToSelector("setAttributedPlaceholder:"){
            inputField.attributedPlaceholder = NSAttributedString(string: "Name here.", attributes: attrs)
        }
        else{
            inputField.placeholder = "Name here."
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: inputField)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.errMsgLabel.text = ""
            self.resetInputPlaceHolder()
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, -50)
                }) { (complete) -> Void in
            }
            UIView.transitionWithView(self.inputField, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.inputField.textColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    func textFieldTextDidChange(notification: NSNotification){
        checkInputValidity()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let charset = NSCharacterSet(charactersInString: acceptedCharset).invertedSet
        let components = string.componentsSeparatedByCharactersInSet(charset)
        let filteredText = join("", components)
        let allowedInput = (string == filteredText) ? true : false
        if !allowedInput{
            showTextFieldWarning(0)
            errMsgLabel.text = "Invalid character \"\((string as NSString).substringFromIndex(string.utf16Count - 1))\"\nAlphabets only."
        }
        else{
            errMsgLabel.text = ""
        }
        return allowedInput
    }
    
    private func showTextFieldWarning(errCode: Int){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            switch errCode{
            case 0:
                UIView.transitionWithView(self.inputField, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.inputField.textColor = UIColor(red: 247/255, green: 230/255, blue: 0, alpha: 1)
                    }, completion: { (complete) -> Void in
                        UIView.transitionWithView(self.inputField, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                            self.inputField.textColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
                            }, completion: { (complete) -> Void in
                        })
                })
            default:
                if self.inputField.respondsToSelector("setAttributedPlaceholder:"){
                    var attrs = [NSForegroundColorAttributeName: UIColor(red: 247/255, green: 230/255, blue: 0, alpha: 1)]
                    UIView.transitionWithView(self.inputField, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                        self.inputField.attributedPlaceholder = NSAttributedString(string: "Name here.", attributes: attrs)
                        }, completion: { (complete) -> Void in
                            attrs = [NSForegroundColorAttributeName: UIColor(red: 128/255, green: 132/255, blue: 131/255, alpha: 1)]
                            UIView.transitionWithView(self.inputField, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                self.inputField.attributedPlaceholder = NSAttributedString(string: "Name here.", attributes: attrs)
                                }, completion: { (complete) -> Void in
                            })
                    })
                }
                else{
                    self.inputField.placeholder = "Field is empty!"
                }
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        NSNotificationCenter.defaultCenter().removeObserver(UITextFieldTextDidChangeNotification)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        dismissKeyboard()
    }
    
    private func dismissKeyboard(){
        if inputField.isFirstResponder(){ inputField.resignFirstResponder() }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }) { (complete) -> Void in
            }
            let newCollectionName = self.inputField.text
            if self.delegate?.addCollectionInputAlreadyExists(newCollectionName) == true{
                self.showTextFieldWarning(0)
                self.errMsgLabel.text = "This collection already exists."
            }
            else{
                UIView.transitionWithView(self.inputField, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.inputField.textColor = UIColor(red: 0, green: 247/255, blue: 21/255, alpha: 1)
                    }, completion: { (complete) -> Void in
                })
            }
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
