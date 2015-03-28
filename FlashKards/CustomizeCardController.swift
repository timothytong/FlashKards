//
//  CustomizeCardController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class CustomizeCardController: UIViewController, PopupDelegate {
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
    private var elementsExists = false
    private var isInEditMode = false
    private var numElementsFront = 0
    private var numElementsBack = 0
    private var dimLayer: UIView!
    private var frontShowing = true
    private var isAnimating = false
    private var rectSel: RectSelView!
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
        addImgBtn.addTarget(self, action: "imgIconTapped:", forControlEvents: .TouchUpInside)
        addTextBtn.addTarget(self, action: "textIconTapped:", forControlEvents: .TouchUpInside)
        flipBtn.addTarget(self, action: "flip", forControlEvents: .TouchUpInside)
        deleteBtn.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
        cancelBtn.addTarget(self, action: "exitEditMode", forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enterEditMode(){
        self.isInEditMode = true
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
        UIView.transitionWithView(self.addTextBtn, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.addTextBtn.setImage(UIImage(named: "text-white.png"), forState: UIControlState.Normal)
            }) { (complete) -> Void in
        }
        UIView.transitionWithView(self.addImgBtn, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.addImgBtn.setImage(UIImage(named: "newImg-white.png"), forState: UIControlState.Normal)
            }) { (complete) -> Void in
        }
        
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
    
    func back(sender: UIButton) {
        // Ask user if they really want to quit without saving.
        var backConfirmPopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
        backConfirmPopup.message = "Are you sure you want to quit without saving?"
        backConfirmPopup.confirmButtonText = "YES"
        backConfirmPopup.delegate = self
        backConfirmPopup.instructionLabelFontSize = 25
        navigationController?.view.addSubview(backConfirmPopup)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
            })
        })
        backConfirmPopup.show()
    }
    
    func popupConfirmBtnDidTapped() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
            })
        })
        navigationController?.popViewControllerAnimated(true)
    }
    
    func popupCancelBtnDidTapped() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    func textIconTapped(sender: UIButton!){
        if !isInEditMode{
            UIView.transitionWithView(self.addTextBtn, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.addTextBtn.setImage(UIImage(named: "text-blue.png"), forState: UIControlState.Normal)
                }) { (complete) -> Void in
                    
            }
            enterEditMode()
        }
    }
    
    func imgIconTapped(sender: UIButton!){
        if !isInEditMode{
            enterEditMode()
        }
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
