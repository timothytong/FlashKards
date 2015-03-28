//
//  CustomizeCardController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
enum EditMode{
    case AddTextMode
    case AddImgMode
}

class CustomizeCardController: UIViewController, PopupDelegate {
    // MARK: Variables
    @IBOutlet weak var confirmBtnsContainerView: UIView!
    @IBOutlet private weak var cancelBtn: UIButton!
    @IBOutlet private weak var saveBtn: UIButton!
    @IBOutlet private weak var okBtn: UIButton!
    @IBOutlet private weak var sideLabel: UILabel!
    @IBOutlet private weak var cardHeightConstraint: NSLayoutConstraint! // If iPhone 4 decrease, if 6/6+ increase!
    @IBOutlet private weak var flashcardContainerView: UIView!
    @IBOutlet private weak var flipBtn: UIButton!
    @IBOutlet private weak var frontView: UIView!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var addTextBtn: UIButton!
    @IBOutlet private weak var addImgBtn: UIButton!
    @IBOutlet private weak var rectSelView: RectSelView!
    @IBOutlet private weak var deleteBtn: UIButton!
    private var backConfirmPopup: Popup!
    private var elementsExists = false
    private var isInEditMode = false
    private var numElementsFront = 0
    private var numElementsBack = 0
    private var dimLayer: UIView!
    private var frontShowing = true
    private var isAnimating = false
    private var rectSel: RectSelView!
    private var editMode: EditMode?
    private var activeButton: UIButton?
    private var savePopup: Popup!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        frontView.userInteractionEnabled = false
        backView.userInteractionEnabled = false
        //        navigationItem.hidesBackButton = true
        
        
        // Dim layer
        dimLayer = UIView(frame: UIScreen.mainScreen().bounds)
        dimLayer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dimLayer.userInteractionEnabled = true
        dimLayer.alpha = 0
        navigationController?.view.addSubview(dimLayer)
        
        // Buttons
        cancelBtn.alpha = 0
        okBtn.hidden = true
        addImgBtn.tag = 0
        addTextBtn.tag = 1
        
        addImgBtn.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        addTextBtn.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        addImgBtn.addTarget(self, action: "touchDownGlow:", forControlEvents: .TouchDown)
        addTextBtn.addTarget(self, action: "touchDownGlow:", forControlEvents: .TouchDown)
        addImgBtn.addTarget(self, action: "removeTouchDownGlow:", forControlEvents: .TouchUpOutside)
        addTextBtn.addTarget(self, action: "removeTouchDownGlow:", forControlEvents: .TouchUpOutside)
        flipBtn.addTarget(self, action: "flip", forControlEvents: .TouchUpInside)
        deleteBtn.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
        cancelBtn.addTarget(self, action: "exitEditMode", forControlEvents: .TouchUpInside)
        saveBtn.addTarget(self, action: "saveBtnTapped:", forControlEvents: .TouchUpInside)
        
        // Glow
        var color = UIColor(red: 2/255, green: 210/255, blue: 255/255, alpha: 1);
        addImgBtn.layer.shadowColor = color.CGColor;
        addImgBtn.layer.shadowRadius = 0;
        addImgBtn.layer.shadowOpacity = 0.9;
        addImgBtn.layer.shadowOffset = CGSizeZero;
        addImgBtn.layer.masksToBounds = false;
        
        addTextBtn.layer.shadowColor = color.CGColor;
        addTextBtn.layer.shadowRadius = 0;
        addTextBtn.layer.shadowOpacity = 0.9;
        addTextBtn.layer.shadowOffset = CGSizeZero;
        addTextBtn.layer.masksToBounds = false;
        
        // Back confirm popup
        backConfirmPopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
        backConfirmPopup.message = "Are you sure you want to quit without saving?"
        backConfirmPopup.confirmButtonText = "YES"
        backConfirmPopup.delegate = self
        backConfirmPopup.instructionLabelFontSize = 25
        
        // Save popup
        savePopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchDownGlow(sender: UIButton!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(sender, duration: 0.15, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                sender.layer.shadowRadius = 4
                }) { (complete) -> Void in
            }
        })
    }
    
    func removeTouchDownGlow(sender: UIButton!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.isInEditMode{
                UIView.transitionWithView(sender, duration: 0.15, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    sender.layer.shadowRadius = 0
                    }) { (complete) -> Void in
                }
            }
        })
    }
    
    func enterEditMode(mode: EditMode!){
        isInEditMode = true
        editMode = mode
        rectSel = RectSelView(frame: CGRect(x: 5, y: 5, width: 100, height: 100))
        rectSel.alpha = 0
        flashcardContainerView.addSubview(rectSel)
        flashcardContainerView.bringSubviewToFront(rectSel)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.confirmBtnsContainerView, duration: 0.6, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                self.saveBtn.hidden = true
                self.okBtn.hidden = false
                }) { (complete) -> Void in
            }
            UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.rectSel.alpha = 1
                }) { (complete) -> Void in
            }
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.cancelBtn.alpha = 1
                    self.cancelBtn.transform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.cancelBtn.transform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.cancelBtn.transform = CGAffineTransformMakeRotation(3/3 * CGFloat(M_PI))
                })
                }, completion: nil)
        })
        
        
        
    }
    
    func exitEditMode(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.rectSel != nil && self.rectSel.isDescendantOfView(self.view){
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.rectSel.alpha = 0
                    }) { (complete) -> Void in
                        self.rectSel.removeFromSuperview()
                        self.rectSel = nil
                }
            }
            UIView.transitionWithView(self.confirmBtnsContainerView, duration: 0.4, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                self.saveBtn.hidden = false
                self.okBtn.hidden = true
                }) { (complete) -> Void in
                    self.isInEditMode = false
            }
            UIView.animateKeyframesWithDuration(0.4, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.cancelBtn.transform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.cancelBtn.transform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.cancelBtn.transform = CGAffineTransformMakeRotation(3/3 * CGFloat(M_PI))
                    self.cancelBtn.alpha = 0
                })
                
                }, completion: nil)
        })
        removeActiveGlow()
    }
    
    func flip(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !self.isAnimating{
                self.isAnimating = true
                let newLabel = self.frontShowing ? "BACK" : "FRONT"
                UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.sideLabel.alpha = 0
                    }, completion: { (complete) -> Void in
                        self.sideLabel.text = newLabel
                        UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            self.sideLabel.alpha = 1
                            }, completion: { (complete) -> Void in
                                
                        })
                })
                UIView.transitionWithView(self.flashcardContainerView, duration: 0.7, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
                    if self.frontShowing{
                        self.frontView.hidden = true
                    }
                    else{
                        self.frontView.hidden = false
                    }
                    }) { (complete) -> Void in
                        self.frontShowing = !self.frontShowing
                        self.isAnimating = false
                }
            }
        })
    }
    
    // Ask user if they really want to quit without saving.
    func back(sender: UIButton) {
        navigationController?.view.addSubview(backConfirmPopup)
        showDimLayer()
        backConfirmPopup.show()
    }
    
    // MARK: Popup delegation methods
    func popupConfirmBtnDidTapped(popup: Popup) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
                    popup.removeFromSuperview()
            })
        })
        navigationController?.popViewControllerAnimated(true)
    }
    
    func popupCancelBtnDidTapped(popup: Popup) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
                    popup.removeFromSuperview()
            })
        })
    }
    
    // MARK:
    // Button interactions
    func buttonTapped(sender: UIButton!){
        if !isInEditMode{
            sender.layer.shadowRadius = 0;
            addActiveGlow(sender)
            let editingMode : EditMode = (sender.tag == 0) ? .AddImgMode : .AddTextMode
            enterEditMode(editingMode)
            activeButton = sender
        }
        else{
            if let activeBtn = activeButton{
                
                if sender != activeBtn{
                    removeTouchDownGlow(sender)
                }
            }
        }
    }
    
    func addActiveGlow(sender: UIButton!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(sender, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                let newImgString = (sender.tag == 0) ? "newImg-blue.png" : "text-blue.png"
                sender.setImage(UIImage(named: newImgString), forState: UIControlState.Normal)
                var color = UIColor(red: 2/255, green: 210/255, blue: 255/255, alpha: 1);
                sender.layer.shadowColor = color.CGColor;
                sender.layer.shadowRadius = 4.0;
                sender.layer.shadowOpacity = 0.9;
                sender.layer.shadowOffset = CGSizeZero;
                sender.layer.masksToBounds = false;
                }) { (complete) -> Void in
            }
        })
    }
    
    func removeActiveGlow(){
        let newImgString = (editMode == .AddImgMode) ? "newImg-white.png" : "text-white.png"
        let button = (editMode == .AddImgMode) ? addImgBtn : addTextBtn
        UIView.transitionWithView(button, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            button.setImage(UIImage(named: newImgString), forState: UIControlState.Normal)
            button.layer.shadowRadius = 0
            }) { (complete) -> Void in
                self.editMode = nil
        }
    }
    
    func saveBtnTapped(sender: UIButton!){
        if numElementsBack == 0 || numElementsFront == 0 {
            savePopup.oneOptionOnly = true
            savePopup.cancelBtnText = "OK"
            var message = ""
            if numElementsFront == 0 && numElementsBack == 0{
                message = "Error:\nEmpty Kard."
            }
            else if numElementsFront == 0{
                message = "Error:\nFront side is empty."
            }
            else{
                message = "Errpr:\nBack side is empty."
            }
            savePopup.message = message
            savePopup.delegate = self
            navigationController?.view.addSubview(savePopup)
            showDimLayer()
            savePopup.show()
        }
    }
    
    func showDimLayer(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
