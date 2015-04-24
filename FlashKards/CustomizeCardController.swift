//
//  CustomizeCardController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
import AssetsLibrary
enum EditMode{
    case AddTextMode
    case AddImgMode
}

class CustomizeCardController: UIViewController, PopupDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {
    // MARK: Variables
    // IBOutlets
    @IBOutlet private weak var confirmAddTextBtn: UIButton!
    @IBOutlet private weak var cancelAddTxtBtn: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var galleryCollectionView: UICollectionView!
    @IBOutlet private weak var cancelImportBtn: UIButton!
    @IBOutlet private weak var dissmissImportImgViewBtnTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imgOptionsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imgOptionsView: UIView!
    @IBOutlet private weak var importImgBtn: UIButton!
    @IBOutlet private weak var enterURLBtn: UIButton!
    @IBOutlet private weak var confirmBtnsContainerView: UIView!
    @IBOutlet private weak var exitEditBtn: UIButton!
    @IBOutlet private weak var saveBtn: UIButton!
    @IBOutlet private weak var confirmAddElementBtn: UIButton!
    @IBOutlet private weak var sideLabel: UILabel!
    @IBOutlet private weak var cardHeightConstraint: NSLayoutConstraint! // If iPhone 4 decrease, if 6/6+ increase!
    @IBOutlet private weak var imgOptionsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dismissImportImgViewBtn: UIButton!
    @IBOutlet private weak var flashcardContainerView: UIView!
    @IBOutlet private weak var flipBtn: UIButton!
    @IBOutlet private weak var frontView: UIView!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var addTextBtn: UIButton!
    @IBOutlet private weak var addImgBtn: UIButton!
    @IBOutlet private weak var deleteBtn: UIButton!
    
    // Additional UI's
    private var activePopup: Popup?
    private var dimLayer: UIView!
    private var rectSel: RectSelView!
    private var editMode: EditMode?
    private var activeButton: UIButton?
    private var fullImageView: UIView!
    private var fullUIImageView: UIImageView!
    private var completeImgImportBtn: UIButton!
    
    // Flashcards & collection
    private var numElementsFront = 0
    private var numElementsBack = 0
    private var numCardsInCollection: Int!
    private var newElementTag = 20 // Reserve some tags for buttons
    private var imgOptionsHeightInitialHeight: CGFloat!
    private var collectionID: Int!
    private var collectionName: String!
    private var cardID: Int!
    private var frontElementsDict: NSMutableDictionary!
    private var backElementsDict: NSMutableDictionary!
    private var frontUIDict: Dictionary<String, UIView>!
    private var backUIDict: Dictionary<String, UIView>!
    
    // Flags
    private var isInEditMode = false
    private var frontShowing = true
    private var isAnimating = false
    private var imgOptionsViewIsExpanded = false
    private var hideStatusBar = false
    
    private var animatedBools: Array<Bool>!
    
    // ALAssets.
    private var library: ALAssetsLibrary!
    private var assetThumbnails: Array<UIImage>!
    private var thumbnails: Array<UIImage>!
    private var alreadyEnumerated = false
    private var urls: Array<NSURL>!
    
    private var documentsDir: String!
    
    private var fileManager: FileManager!
    
    private var textViewBeingAdded: UITextView?
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        frontView.userInteractionEnabled = false
        backView.userInteractionEnabled = false
        navigationItem.hidesBackButton = true
        
        
        // Dim layer
        dimLayer = UIView(frame: UIScreen.mainScreen().bounds)
        dimLayer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dimLayer.userInteractionEnabled = true
        dimLayer.alpha = 0
        navigationController?.view.addSubview(dimLayer)
        
        // Buttons
        exitEditBtn.alpha = 0
        confirmAddElementBtn.hidden = true
        
        // -- Glowing effects
        addImgBtn.addTarget(self, action: "touchDownGlow:", forControlEvents: .TouchDown)
        addTextBtn.addTarget(self, action: "touchDownGlow:", forControlEvents: .TouchDown)
        addImgBtn.addTarget(self, action: "removeTouchDownGlow:", forControlEvents: .TouchUpOutside)
        addTextBtn.addTarget(self, action: "removeTouchDownGlow:", forControlEvents: .TouchUpOutside)
        
        // Glow
        var blueGlowColor = UIColor(red: 2/255, green: 210/255, blue: 255/255, alpha: 1)
        var greenGlowColor = UIColor(red: 4/255, green: 247/255, blue: 21/255, alpha: 1)
        var redGlowColor = UIColor(red: 247/255, green: 5/255, blue: 2/255, alpha: 1)
        
        addImgBtn.layer.shadowColor = blueGlowColor.CGColor
        addImgBtn.layer.shadowRadius = 0
        addImgBtn.layer.shadowOpacity = 0.9
        addImgBtn.layer.shadowOffset = CGSizeZero
        addImgBtn.layer.masksToBounds = false
        
        addTextBtn.layer.shadowColor = blueGlowColor.CGColor
        addTextBtn.layer.shadowRadius = 0
        addTextBtn.layer.shadowOpacity = 0.9
        addTextBtn.layer.shadowOffset = CGSizeZero
        addTextBtn.layer.masksToBounds = false
        
        imgOptionsView.layer.shadowColor = blueGlowColor.CGColor
        imgOptionsView.layer.shadowRadius = 8
        imgOptionsView.layer.shadowOpacity = 0.9
        imgOptionsView.layer.shadowOffset = CGSizeMake(0, 3)
        imgOptionsView.layer.masksToBounds = false
        
        cancelAddTxtBtn.layer.shadowColor = blueGlowColor.CGColor
        cancelAddTxtBtn.layer.shadowRadius = 4
        cancelAddTxtBtn.layer.shadowOpacity = 0.9
        cancelAddTxtBtn.layer.shadowOffset = CGSizeZero
        cancelAddTxtBtn.layer.masksToBounds = false
        
        confirmAddTextBtn.layer.shadowColor = blueGlowColor.CGColor
        confirmAddTextBtn.layer.shadowRadius = 4
        confirmAddTextBtn.layer.shadowOpacity = 0.9
        confirmAddTextBtn.layer.shadowOffset = CGSizeZero
        confirmAddTextBtn.layer.masksToBounds = false
        
        exitEditBtn.layer.shadowColor = redGlowColor.CGColor
        exitEditBtn.layer.shadowRadius = 0
        exitEditBtn.layer.shadowOpacity = 0.9
        exitEditBtn.layer.shadowOffset = CGSizeZero
        exitEditBtn.layer.masksToBounds = false
        
        confirmAddElementBtn.layer.shadowColor = greenGlowColor.CGColor
        confirmAddElementBtn.layer.shadowRadius = 0
        confirmAddElementBtn.layer.shadowOpacity = 0.9
        confirmAddElementBtn.layer.shadowOffset = CGSizeZero
        confirmAddElementBtn.layer.masksToBounds = false
        
        // ImgOptionsPopup (prompts user to choose either import / enter URL)
        imgOptionsViewBottomConstraint.constant = -imgOptionsViewHeightConstraint.constant
        imgOptionsHeightInitialHeight = imgOptionsViewHeightConstraint.constant
        
        // CollectionView
        animatedBools = Array<Bool>()
        assetThumbnails = Array<UIImage>()
        thumbnails = Array<UIImage>()
        urls = Array<NSURL>()
        
        // Full Image View
        fullImageView = UIView(frame: navigationController!.view.bounds)
        fullImageView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        fullImageView.alpha = 0
        fullUIImageView = UIImageView(frame: navigationController!.view.bounds)
        fullUIImageView.contentMode = UIViewContentMode.ScaleAspectFit
        fullUIImageView.backgroundColor = UIColor.clearColor()
        fullUIImageView.userInteractionEnabled = false
        
        let hideFullViewTap = UITapGestureRecognizer(target: self, action: "hideFullImage")
        fullImageView.addGestureRecognizer(hideFullViewTap)
        fullImageView.addSubview(fullUIImageView)
        navigationController?.view.addSubview(fullImageView)
        
        // Finish Image Import Process Button
        completeImgImportBtn = UIButton(frame: CGRect(x: navigationController!.view.frame.width - 70, y: navigationController!.view.frame.height - 70, width: 55, height: 55))
        let completeImgImportBtnImage = UIImage(named: "ok-white.png")
        completeImgImportBtn.setImage(completeImgImportBtnImage, forState: .Normal)
        completeImgImportBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        completeImgImportBtn.backgroundColor = UIColor(red: 2/255, green: 142/255, blue: 232/255, alpha: 1)
        completeImgImportBtn.layer.masksToBounds = false
        completeImgImportBtn.layer.cornerRadius = 27.5
        completeImgImportBtn.layer.shadowColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1).CGColor
        completeImgImportBtn.layer.shadowRadius = 5
        completeImgImportBtn.layer.shadowOffset = CGSizeMake(0, 3)
        completeImgImportBtn.layer.shadowOpacity = 1
        fullImageView.addSubview(completeImgImportBtn)
        
        // Dictionaries
        frontElementsDict = NSMutableDictionary()
        backElementsDict = NSMutableDictionary()
        frontUIDict = Dictionary<String, UIView>()
        backUIDict = Dictionary<String, UIView>()
        
        
        // -- Tags
        addImgBtn.tag = 0
        addTextBtn.tag = 1
        flipBtn.tag = 2
        deleteBtn.tag = 3
        exitEditBtn.tag = 4
        saveBtn.tag = 5
        confirmAddElementBtn.tag = 6
        dismissImportImgViewBtn.tag = 7
        cancelImportBtn.tag = 7
        importImgBtn.tag = 8
        completeImgImportBtn.tag = 10
        cancelAddTxtBtn.tag = 11
        confirmAddTextBtn.tag = 12
        
        // -- Actual presses
        addImgBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        addTextBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        flipBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        deleteBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        exitEditBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        saveBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        confirmAddElementBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        dismissImportImgViewBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        importImgBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        cancelImportBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        completeImgImportBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        cancelAddTxtBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        confirmAddTextBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        
        // Misc
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        documentsDir = paths[0] as? String
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        fileManager = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fileManager = FileManager()
    }
    
    func configureWithCollection(collection: FlashCardCollection!){
        collectionID = collection.collectionID.integerValue
        println("collectionID: \(collectionID)")
        collectionName = collection.name
        cardID = collection.numCards.integerValue + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if !isInEditMode{
            self.assetThumbnails.removeAll(keepCapacity: false)
            self.thumbnails.removeAll(keepCapacity: false)
            self.alreadyEnumerated = false
        }
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
        confirmAddElementBtn.userInteractionEnabled = true
        exitEditBtn.userInteractionEnabled = true
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.confirmBtnsContainerView, duration: 0.6, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                self.saveBtn.hidden = true
                self.confirmAddElementBtn.hidden = false
                }) { (complete) -> Void in
            }
            UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.rectSel.alpha = 1
                }) { (complete) -> Void in
            }
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.exitEditBtn.alpha = 1
                    self.exitEditBtn.transform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.exitEditBtn.transform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.exitEditBtn.transform = CGAffineTransformMakeRotation(3/3 * CGFloat(M_PI))
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
                self.confirmAddElementBtn.hidden = true
                }) { (complete) -> Void in
                    self.isInEditMode = false
            }
            UIView.animateKeyframesWithDuration(0.4, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.exitEditBtn.transform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.exitEditBtn.transform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI))
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                    self.exitEditBtn.transform = CGAffineTransformMakeRotation(3/3 * CGFloat(M_PI))
                    self.exitEditBtn.alpha = 0
                })
                
                }, completion: nil)
        })
        removeActiveGlow()
    }
    
    func flip(){
        if isInEditMode{
            cancelAddTextAction()
        }
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
    func back() {
        var backConfirmPopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
        backConfirmPopup.message = "Are you sure you want to quit without saving?"
        backConfirmPopup.confirmButtonText = "YES"
        backConfirmPopup.delegate = self
        backConfirmPopup.instructionLabelFontSize = 25
        navigationController?.view.addSubview(backConfirmPopup)
        showDimLayer()
        activePopup = backConfirmPopup
        backConfirmPopup.show()
    }
    
    // MARK: Popup delegation methods
    func popupConfirmBtnDidTapped(popup: Popup) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
                    if self.activePopup != nil{
                        self.activePopup = nil
                    }
            })
        })
        self.navigationController?.popViewControllerAnimated(true)
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
    
    // MARK: Button interactions
    func addElementBtnsTapped(sender: UIButton!){
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
                var color = UIColor(red: 2/255, green: 210/255, blue: 255/255, alpha: 1)
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
    
    // MARK: Buttons processing
    func buttonPressed(sender:UIButton!){
        switch(sender.tag){
        case 0,1:
            addElementBtnsTapped(sender)
        case 2:
            flip()
        case 3:
            back()
        case 4:
            exitEditMode()
        case 5:
            save()
        case 6:
            confirmAddElement()
        case 7:
            dismissImportImgView()
        case 8:
            importImageAction()
        case 9:
            cancelImportImageAction()
        case 10:
            completeImgImportProcessWithImage(fullUIImageView.image!)
        case 11:
            cancelAddTextAction()
        case 12:
            completeAddTextAction()
        default:
            break
        }
    }
    
    func save(){
        println("front count: \(frontElementsDict.count) back count: \(backElementsDict.count)")
        var savePopup: Popup!
        if numElementsBack == 0 || numElementsFront == 0 {
            savePopup = Popup(frame: CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
            savePopup.numOptions = 1
            savePopup.cancelBtnText = "OK"
            var message = ""
            if numElementsFront == 0 && numElementsBack == 0{
                message = "Save Error:\nEmpty Kard."
            }
            else if numElementsFront == 0{
                message = "Save Error:\nFront side is empty."
            }
            else{
                message = "Save Error:\nBack side is empty."
            }
            savePopup.message = message
            savePopup.delegate = self
            navigationController?.view.addSubview(savePopup)
            showDimLayer()
            savePopup.show()
            return
        }
        savePopup = Popup(frame: CGRect(x: view.frame.width/2 - 60, y: view.frame.height/2 - 30, width: 120, height: 60))
        savePopup.numOptions = 0
        savePopup.alpha = 0
        savePopup.message = "Saving"
        savePopup.transform = CGAffineTransformIdentity
        navigationController?.view.addSubview(savePopup)
        showDimLayer()
        self.fileManager.deleteDirectory("\(self.collectionName)/tmp", andAllItsFiles: false, withCompletionHandler: { () -> () in})
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                savePopup.alpha = 1
                }, completion: { (complete) -> Void in
                    let dictionary: NSDictionary = NSDictionary(dictionary: ["front": self.frontElementsDict, "back": self.backElementsDict])
                    let collectionManager = CollectionsManager()
                    collectionManager.addNewFlashcardWithData(dictionary, toCollection: self.collectionName)
                    savePopup.message = "Saved."
                    UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseIn, animations: { () -> Void in
                        savePopup.alpha = 0
                        self.dimLayer.alpha = 0
                        self.navigationController?.popViewControllerAnimated(true)
                        }, completion: { (complete) -> Void in
                            savePopup.removeFromSuperview()
                    })
                    
            })
        })
        
    }
    
    func confirmAddElement(){
        if let eMode = editMode{
            if eMode == EditMode.AddImgMode{
                showImgOptionsView()
            }
            else{
                createTextAction()
            }
        }
    }
    
    func dismissImportImgView(){
        collapseImgOptionsView()
        hideImgOptionsView()
        exitEditMode()
    }
    
    func showDimLayer(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    func showImgOptionsView(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.imgOptionsViewBottomConstraint.constant != 0{ // it is NOT open
                self.imgOptionsViewBottomConstraint.constant = 0
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    }, completion: { (complete) -> Void in
                })
            }
        })
    }
    
    func hideImgOptionsView(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.imgOptionsViewBottomConstraint.constant == 0{ // it is NOT open
                self.imgOptionsViewBottomConstraint.constant = -self.imgOptionsViewHeightConstraint.constant
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    }, completion: { (complete) -> Void in
                })
            }
        })
    }
    
    func importImageAction(){
        if !alreadyEnumerated{
            self.spinner.startAnimating()
            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.spinner.alpha = 1
                }) { (complete) -> Void in
            }
            enumerateAssetsWithCompletionHandler { () -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.spinner.alpha = 0
                        }) { (complete) -> Void in
                            self.spinner.stopAnimating()
                            self.expandImgOptionsView()
                    }
                })
                
            }
        }
        else{
            self.expandImgOptionsView()
        }
    }
    
    func textViewTapped(sender: UITapGestureRecognizer){
        println("TextView tapped!")
        if let textView = sender.view{
            if textView.isKindOfClass(UITextField){
                if !textView.isFirstResponder(){
                    sender.view!.becomeFirstResponder()
                }
            }
        }
    }
    
    func createTextAction(){
        // Show the image with an UIImageView
        confirmAddElementBtn.userInteractionEnabled = false
        exitEditBtn.userInteractionEnabled = false
        var textField = UITextView(frame: CGRect(x: rectSel.frame.origin.x, y: rectSel.frame.origin.y, width: rectSel.frame.width, height: rectSel.frame.height))
        textField.tag = newElementTag
        textField.layer.borderWidth = 1
        textField.editable = true
        textField.alpha = 0
        textField.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        textField.font = UIFont(name: "AppleSDGothicNeo-Light", size: 25)
        textField.textAlignment = .Center
        textField.delegate = self
        textField.becomeFirstResponder()
        textViewBeingAdded = textField
        // TODO: Add logic to move elements up when the keyboard is up so the user can see the center of the textfield
        // TODO: Add pan gesture and long press gesture (option to delete)...
        if frontShowing{
            frontView.addSubview(textField)
            frontView.bringSubviewToFront(textField)
        }
        else{
            backView.addSubview(textField)
            backView.bringSubviewToFront(textField)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Transition animation
            UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.cancelAddTxtBtn.alpha = 1
                self.confirmAddTextBtn.alpha = 1
                textField.alpha = 1
                }, completion: { (complete) -> Void in
                    self.confirmAddElementBtn.alpha = 0
                    self.exitEditBtn.alpha = 0
            })
            // TODO: In the future: don't hide rectSel and let user adjust size of textfield
            if self.rectSel != nil && self.rectSel.isDescendantOfView(self.view){
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.rectSel.alpha = 0
                    }) { (complete) -> Void in
                        self.rectSel.removeFromSuperview()
                        self.rectSel = nil
                }
            }
            UIView.transitionWithView(textField, duration: 0.7, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                textField.layer.borderColor = UIColor(red: 2/255, green: 210/255, blue: 255/255, alpha: 1).CGColor
                }, completion: { (complete) -> Void in
                    UIView.transitionWithView(textField, duration: 0.7, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                        textField.layer.borderColor = UIColor.blackColor().CGColor
                        }, completion: { (complete) -> Void in
                    })
            })
            
        })
        
        
    }
    
    func completeAddTextAction(){
        // Store in a dictionary then show it
        if let textField = textViewBeingAdded{
            UIView.transitionWithView(textField, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                textField.layer.borderWidth = 0
                }, completion: { (complete) -> Void in
                    self.textViewBeingAdded = nil
                    self.exitEditMode()
                    self.cancelAddTxtBtn.alpha = 0
                    self.confirmAddTextBtn.alpha = 0
                    self.confirmAddElementBtn.alpha = 1
            })
            if count(textField.text) > 0{
                textField.editable = false
                textField.tag = newElementTag
                let optimalFontSize = Utilities.calculateOptimalFontSizeWithText(textField.text, inRect: textField.frame)
                textField.font = textField.font.fontWithSize(optimalFontSize)
                var dictionary = NSDictionary(dictionary:[
                    "id": newElementTag,
                    "frame": NSValue(CGRect: textField.frame),
                    "content": textField.text,
                    "type": "txt",
                    "font_size": optimalFontSize,
                    "font": "AppleSDGothicNeo-Light"
                    ])
                
                if frontShowing{
                    frontElementsDict.setObject(dictionary, forKey: "\(newElementTag)")
                    frontUIDict["\(newElementTag)"] = textField
                    numElementsFront++
                }
                else{
                    backElementsDict.setObject(dictionary, forKey: "\(newElementTag)")
                    backUIDict["\(newElementTag)"] = textField
                    numElementsBack++
                }
                newElementTag++
            }
            else{
                var warningPopup = Popup(frame: CGRect(x: view.frame.width / 2 - 80, y: view.frame.height / 2 - 70, width: 160, height: 140))
                warningPopup.numOptions = 1
                warningPopup.message = "Please enter some text."
                warningPopup.cancelBtnText = "OK"
                activePopup = warningPopup
                self.navigationController?.view.addSubview(warningPopup)
                warningPopup.show()
            }
            
        }
        
        
    }
    
    func cancelImportImageAction(){
        collapseImgOptionsView()
    }
    
    func cancelAddTextAction(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let textView = self.textViewBeingAdded{
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                    textView.alpha = 0
                    self.cancelAddTxtBtn.alpha = 0
                    self.confirmAddTextBtn.alpha = 0
                    self.confirmAddElementBtn.alpha = 1
                    }, completion: { (complete) -> Void in
                        textView.removeFromSuperview()
                        self.textViewBeingAdded = nil
                        self.exitEditMode()
                })
            }
        })
    }
    
    func expandImgOptionsView(){
        if !imgOptionsViewIsExpanded{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imgOptionsViewHeightConstraint.constant = self.navigationController!.view.frame.height - self.navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.size.height
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    }, completion: { (complete) -> Void in
                })
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.importImgBtn.alpha = 0
                    self.enterURLBtn.alpha = 0
                    }, completion: { (complete) -> Void in
                        UIView.animateWithDuration(0.6, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            self.dismissImportImgViewBtn.transform = CGAffineTransformMakeTranslation(-30, 0)
                            self.cancelImportBtn.alpha = 1
                            self.galleryCollectionView.alpha = 1
                            }, completion: { (complete) -> Void in
                                self.dismissImportImgViewBtn.tag = 9
                                self.cancelImportBtn.tag = 7
                                self.imgOptionsViewIsExpanded = true
                                if !self.alreadyEnumerated{
                                    self.alreadyEnumerated = true
                                    if let assetthumbs = self.assetThumbnails{
                                        for i in 0 ..< assetthumbs.count{
                                            self.convertAndAppendThumbnail(i)
                                        }
                                        self.assetThumbnails.removeAll(keepCapacity: false)
                                    }
                                }
                        })
                })
            })
        }
    }
    
    func collapseImgOptionsView(){
        if imgOptionsViewIsExpanded{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.galleryCollectionView.alpha = 0
                    self.dismissImportImgViewBtn.transform = CGAffineTransformIdentity
                    self.cancelImportBtn.alpha = 0
                    }, completion: { (complete) -> Void in
                        self.dismissImportImgViewBtn.tag = 7
                        self.imgOptionsViewHeightConstraint.constant = self.imgOptionsHeightInitialHeight
                        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            self.view.layoutIfNeeded()
                            }, completion: { (complete) -> Void in
                        })
                        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            self.importImgBtn.alpha = 1
                            self.enterURLBtn.alpha = 1
                            }, completion: { (complete) -> Void in
                                self.imgOptionsViewIsExpanded = false
                                if self.library != nil{
                                    self.library = nil;
                                }
                        })
                })
            })
        }
    }
    
    func convertAndAppendThumbnail(index: Int!){
        let thumbnail = assetThumbnails[index]
        thumbnails.append(thumbnail)
        galleryCollectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: thumbnails.count - 1, inSection: 0)])
    }
    
    // MARK: ALAssetsLibrary
    func enumerateAssetsWithCompletionHandler(handler:()->()){
        var numPics = 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            self.library = ALAssetsLibrary()
            self.library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos), usingBlock: { (group: ALAssetsGroup?, stop) -> Void in
                if group != nil{
                    //                    println("Group is not nil.")
                    group!.setAssetsFilter(ALAssetsFilter.allPhotos())
                    group!.enumerateAssetsUsingBlock({ (result: ALAsset?, index, stop) -> Void in
                        //                        println("Enumerating assets..")
                        if result != nil{
                            let representation = result!.defaultRepresentation()
                            var tempImg = result!.aspectRatioThumbnail()
                            self.assetThumbnails.append(UIImage(CGImage: tempImg.takeUnretainedValue())!)
                            tempImg = nil
                            self.urls.append(representation.url())
                            numPics++
                            //                            println("Result is not nil")
                        }
                    })
                }
                else{
                    //                    println("Enumeration complete")
                    for i in 0 ..< numPics{
                        self.animatedBools.append(false)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        handler()
                    })
                }
                }, failureBlock: { (error) -> Void in
                    self.library = nil
            })
        })
    }
    
    func showFullImageWithURL(sender: NSIndexPath){
        /*
        var attrs = galleryCollectionView.layoutAttributesForItemAtIndexPath(sender)
        var cellFrame = attrs?.frame;
        if let frame = cellFrame{
        fullUIImageView.center = CGPointMake(frame.origin.x + frame.width/2 + navigationController!.view.frame.width, frame.origin.y + frame.height/2 + navigationController!.view.frame.height - galleryCollectionView.contentOffset.y)
        }
        else{
        */
        fullUIImageView.center = CGPointMake(view.frame.width/2, view.frame.height/2)
        // }
        fullUIImageView.transform = CGAffineTransformMakeScale(90 / fullUIImageView.frame.width, 90 / fullUIImageView.frame.height)
        
        if library == nil{
            library = ALAssetsLibrary()
        }
        let url = urls[sender.row]
        library.assetForURL(url, resultBlock: { (asset: ALAsset?) -> Void in
            if asset != nil{
                let rep = asset!.defaultRepresentation()
                var image = rep.fullScreenImage()
                self.fullUIImageView.image = UIImage(CGImage: image.takeUnretainedValue())
                image = nil
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.hideStatusBar = true
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.setNeedsStatusBarAppearanceUpdate()
                        self.fullUIImageView.transform = CGAffineTransformIdentity
                        self.fullUIImageView.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
                        self.fullImageView.alpha = 1
                        }, completion: { (complete) -> Void in
                            self.library = nil
                    })
                })
            }
            }) { (error) -> Void in
                println("ERROR when fetching individual full image")
        }
        
    }
    
    func hideFullImage(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hideStatusBar = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
                self.fullImageView.alpha = 0
                self.fullUIImageView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                }, completion: { (complete) -> Void in
                    self.fullUIImageView.image = nil
            })
        })
    }
    
    func completeImgImportProcessWithImage(newImage: UIImage!){
        confirmAddElementBtn.userInteractionEnabled = false
        exitEditBtn.userInteractionEnabled = false
        // Save image to disk, grab a url to it.
        let side = frontShowing ? "front" : "back"
        let tmpImgPath = documentsDir!.stringByAppendingPathComponent("\(collectionName)/tmp/\(collectionName)-\(cardID)-\(side)-\(newElementTag).png")
        let imgPath = "\(collectionName)/\(collectionName)-\(cardID)-\(side)-\(newElementTag).png"
        
        UIImagePNGRepresentation(newImage).writeToFile(tmpImgPath, atomically: true)
        
        // Show the image with an UIImageView
        var imageView = UIImageView(frame: CGRect(x: rectSel.frame.origin.x, y: rectSel.frame.origin.y, width: rectSel.frame.width, height: rectSel.frame.height))
        imageView.image = newImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.tag = newElementTag
        imageView.layer.borderWidth = 1
        
        // TODO: Add pan gesture and long press gesture (option to delete)...
        
        // Store in a dictionary then show it
        var dictionary = NSDictionary(dictionary:[
            "id": newElementTag,
            "frame": NSValue(CGRect: imageView.frame),
            "content": imgPath,
            "type": "img",
            "img_width": newImage.size.width,
            "img_height": newImage.size.height
            ])
        
        if frontShowing{
            frontView.addSubview(imageView)
            frontElementsDict.setObject(dictionary, forKey: "\(newElementTag)")
            frontUIDict["\(newElementTag)"] = imageView
            numElementsFront++
        }
        else{
            backView.addSubview(imageView)
            backElementsDict.setObject(dictionary, forKey: "\(newElementTag)")
            backUIDict["\(newElementTag)"] = imageView
            numElementsBack++
        }
        newElementTag++
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(imageView, duration: 0.7, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                imageView.layer.borderColor = UIColor(red: 2/255, green: 210/255, blue: 255/255, alpha: 1).CGColor
                }, completion: { (complete) -> Void in
                    UIView.transitionWithView(imageView, duration: 0.7, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                        imageView.layer.borderColor = UIColor.blackColor().CGColor
                        }, completion: { (complete) -> Void in
                            UIView.transitionWithView(imageView, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                imageView.layer.borderWidth = 0
                                }, completion: { (complete) -> Void in
                            })
                    })
            })
            
        })
        // 4. Hide full img and exit edit mode
        hideFullImage()
        dismissImportImgView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.hideStatusBar
    }
    
    // MARK: UICollectionView
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("imgCollectionCell", forIndexPath: indexPath) as! CollectionViewCell
        cell.putImage(self.thumbnails[indexPath.row] as UIImage!, withAnimation: !animatedBools[indexPath.row])
        if !animatedBools[indexPath.row]{ animatedBools[indexPath.row] = true }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        showFullImageWithURL(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch{
            if let tv = self.textViewBeingAdded{
                let location = touch.locationInView(tv)
                if CGRectContainsPoint(tv.bounds, location){
                    if !tv.isFirstResponder() && tv.editable{
                        tv.becomeFirstResponder()
                        return
                    }
                }
            }
            
        }
        if let textView = textViewBeingAdded{
            textView.resignFirstResponder()
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
