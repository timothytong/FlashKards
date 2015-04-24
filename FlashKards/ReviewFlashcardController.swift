//
//  ReviewFlashcardController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-11.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ReviewFlashcardController: UIViewController, PopupDelegate {
    @IBOutlet private weak var flipButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var nextCardView: FlashCardView!
    @IBOutlet private weak var controlButtonsContainer: UIView!
    @IBOutlet private weak var currentCardView: FlashCardView!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var rememberButton: UIButton!
    @IBOutlet private weak var quitButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var forgetButton: UIButton!
    @IBOutlet private weak var timeElapsedLabel: UILabel!
    @IBOutlet private weak var completedCardsNumLabel: UILabel!
    @IBOutlet private weak var coverView: UIView!
    @IBOutlet private weak var countdownLabel: UILabel!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var mainCardContainer: UIView!
    @IBOutlet private weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerViewBottomConstraint: NSLayoutConstraint!
    private var countDownLabelText = 3
    private var navBarHeight: CGFloat = 0
    private let INITIAL_MAIN_TOP_CONSTRAINT_CONSTANT = 40
    private let INITIAL_NEXT_CARD_VIEW_SCALE_TRANSFORM = CGAffineTransformMakeScale(0.8, 0.8)
    private var reviewTimer: NSTimer!
    private var countDownTimer: NSTimer!
    private var collectionOfInterest: FlashCardCollection!
    private var cardSet: [FlashCard]!
    private var forgottenCardSet: [FlashCard]!
    private var numSecondsElapsed: Int64 = 0
    private var isPaused = true
    private var dimLayer: UIView!
    private var isStarted = false
    private let INITIAL_NEXT_TRANSFORM = CGAffineTransformMakeTranslation(-50, 0)
    private let INITIAL_FLIP_TRANSFORM = CGAffineTransformMakeScale(0.1, 0.1)
    private var flipAnimating = false
    private var resultsDictionary: NSDictionary!
    private var currentCard: FlashCard!
    private var nextCard: FlashCard!
    private var endReviewPopup: Popup!
    private var cardsDone = 0

    var quizResultsDict:NSDictionary?{
        get{
            return self.resultsDictionary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        if let navbarHeight = Constants.navBarHeight{
            navBarHeight = navbarHeight
            containerViewTopConstraint.constant += navbarHeight
        }
        forgottenCardSet = [FlashCard]()
        view.sendSubviewToBack(backgroundView)
        forgetButton.userInteractionEnabled = false
        rememberButton.userInteractionEnabled = false
        pauseButton.userInteractionEnabled = false
        mainCardContainer.layer.cornerRadius = 3
        mainCardContainer.layer.borderWidth = 1
        mainCardContainer.layer.borderColor = UIColor(white: 0.5, alpha: 1).CGColor
        mainCardContainer.clipsToBounds = false
        
        currentCardView.layer.cornerRadius = 3
        currentCardView.layer.borderWidth = 1
        currentCardView.layer.borderColor = UIColor(white: 0.5, alpha: 1).CGColor
        currentCardView.clipsToBounds = true
        
        
        nextCardView.layer.cornerRadius = 3
        nextCardView.layer.borderWidth = 1
        nextCardView.layer.borderColor = UIColor(white: 0.5, alpha: 1).CGColor
        nextCardView.clipsToBounds = true
        completedCardsNumLabel.text = "0/\(collectionOfInterest.numCards)"
        continueButton.hidden = true
        
        quitButton.tag = 0
        pauseButton.tag = 1
        rememberButton.tag = 2
        forgetButton.tag = 3
        continueButton.tag = 4
        flipButton.tag = 5
        nextButton.tag = 6
        
        quitButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        pauseButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        forgetButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        rememberButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        continueButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        flipButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        
        // Dim layer
        dimLayer = UIView(frame: UIScreen.mainScreen().bounds)
        dimLayer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dimLayer.userInteractionEnabled = true
        dimLayer.alpha = 0
        view.addSubview(dimLayer)
        
        // Transforms
        
        nextButton.transform = INITIAL_NEXT_TRANSFORM
        flipButton.transform = INITIAL_FLIP_TRANSFORM
        
        //        view.bringSubviewToFront(cardsContainer)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        resultsDictionary = NSDictionary()
        countDown()
        if !self.cardSet.isEmpty{
            let firstCard = cardSet.removeAtIndex(0) as FlashCard
            currentCard = firstCard
            currentCardView.restoreViewsWithFlashcard(firstCard)
            
            if !self.cardSet.isEmpty{
                let secondCard = cardSet.removeAtIndex(0) as FlashCard!
                nextCard = secondCard
                nextCardView.restoreViewsWithFlashcard(secondCard)
                nextCardView.alpha = 0
                nextCardView.transform = INITIAL_NEXT_CARD_VIEW_SCALE_TRANSFORM
            }
            else{
                println("There's only one card in collection")
            }
        }
        else{
            println("No card in collection")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func remember(){
        cardsDone++
        updateCardsDoneLabel()
        showNextCard()
    }
    
    func updateCardsDoneLabel(){
        completedCardsNumLabel.text = "\(cardsDone)/\(collectionOfInterest.numCards)"
    }
    
    func forget(){
        forgottenCardSet.append(currentCard)
        currentCardView.flip()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.forgetButton.alpha = 0
                self.rememberButton.alpha = 0
                }, completion: { (complete) -> Void in
                    self.showSecondaryButtons()
            })
        })
    }
    
    private func showSecondaryButtons(){
        UIView.animateKeyframesWithDuration(0.6, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                self.flipButton.alpha = 1
                self.nextButton.alpha = 1
                var scaleTransform = CGAffineTransformMakeScale(0.5, 0.5)
                var rotationTransform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI))
                let flipTransform = CGAffineTransformConcat(scaleTransform, rotationTransform)
                self.flipButton.transform = flipTransform
                
                let nextTransform = CGAffineTransformMakeTranslation(-30, 0)
                self.nextButton.transform = nextTransform
            })
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                var scaleTransform = CGAffineTransformMakeScale(0.8, 0.8)
                var rotationTransform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI))
                let flipTransform = CGAffineTransformConcat(scaleTransform, rotationTransform)
                self.flipButton.transform = flipTransform
                
                let nextTransform = CGAffineTransformMakeTranslation(-10, 0)
                self.nextButton.transform = nextTransform
            })
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                var scaleTransform = CGAffineTransformMakeScale(1, 1)
                var rotationTransform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let flipTransform = CGAffineTransformConcat(scaleTransform, rotationTransform)
                self.flipButton.transform = flipTransform
                
                let nextTransform = CGAffineTransformMakeTranslation(0, 0)
                self.nextButton.transform = nextTransform
            })
            }, completion: nil)
    }
    
    private func hideSecondaryButtons(){
        UIView.animateKeyframesWithDuration(0.2, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                self.flipButton.alpha = 0
                self.nextButton.alpha = 0
                var scaleTransform = CGAffineTransformMakeScale(0.5, 0.5)
                var rotationTransform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI))
                let flipTransform = CGAffineTransformConcat(scaleTransform, rotationTransform)
                self.flipButton.transform = flipTransform
                
                let nextTransform = CGAffineTransformMakeTranslation(-30, 0)
                self.nextButton.transform = nextTransform
            })
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                var scaleTransform = CGAffineTransformMakeScale(0.3, 0.3)
                var rotationTransform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI))
                let flipTransform = CGAffineTransformConcat(scaleTransform, rotationTransform)
                self.flipButton.transform = flipTransform
                
                let nextTransform = CGAffineTransformMakeTranslation(-40, 0)
                self.nextButton.transform = nextTransform
            })
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: {
                self.resetSecondaryButtons()
            })
            }, completion: nil)
    }
    
    private func resetSecondaryButtons(){
        flipButton.transform = INITIAL_FLIP_TRANSFORM
        nextButton.transform = INITIAL_NEXT_TRANSFORM
    }
    
    func showNextCard(){
        if self.cardSet != nil{
            currentCard = nextCard
            nextCardView.alpha = 1
            if !currentCardView.frontIsShowing{
                currentCardView.flip()
            }
            forgetButton.userInteractionEnabled = false
            rememberButton.userInteractionEnabled = false
            hideSecondaryButtons()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let rotationTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI/6))
                let translationTransform = CGAffineTransformMakeTranslation(-200, 100)
                let scaleTransform = CGAffineTransformMakeScale(1.2, 1.2)
                let transform = CGAffineTransformConcat(rotationTransform, translationTransform)
                let finalTransform = CGAffineTransformConcat(transform, scaleTransform)
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.currentCardView.transform = finalTransform
                    self.currentCardView.alpha = 0
                    self.nextCardView.transform = CGAffineTransformIdentity
                    self.nextCardView.alpha = 1
                    }, completion: { (complete) -> Void in
                        self.forgetButton.userInteractionEnabled = true
                        self.rememberButton.userInteractionEnabled = true
                        
                        // Swap...
                        
                        let tempCardView = self.currentCardView
                        self.currentCardView = self.nextCardView
                        self.nextCardView = tempCardView
                        
                        self.mainCardContainer.bringSubviewToFront(self.currentCardView)
                        
                        self.nextCardView.transform = CGAffineTransformIdentity
                        self.nextCardView.alpha = 0
                        
                        println("Swapped!")
                        self.nextCardView.transform = self.INITIAL_NEXT_CARD_VIEW_SCALE_TRANSFORM
                        
                        if !self.cardSet.isEmpty{
                            println("Preparing next card...")
                            let nextCard = self.cardSet.removeAtIndex(0) as FlashCard
                            self.nextCard = nextCard
                            self.nextCardView.restoreViewsWithFlashcard(nextCard)
                        }
                        else if !self.forgottenCardSet.isEmpty{
                            println("Preparing a forgotten card...")
                            let nextCard = self.forgottenCardSet.removeAtIndex(0) as FlashCard
                            self.nextCard = nextCard
                            self.nextCardView.restoreViewsWithFlashcard(nextCard)
                        }
                        else{
                            self.cardSet = nil
                            self.countdownLabel.text = "Done"
                        }
                        
                        
                        
                        
                        
                })
                UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.forgetButton.alpha = 1
                    self.rememberButton.alpha = 1
                    }, completion: { (complete) -> Void in
                })
                
            })
        }
        else{
            self.mainCardContainer.bringSubviewToFront(self.coverView)
            if self.reviewTimer != nil{
                self.reviewTimer.invalidate()
                self.reviewTimer = nil
            }
            
            UIView.transitionWithView(self.mainCardContainer, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                self.coverView.hidden = false
                }, completion: { (complete) -> Void in
            })
            self.pauseButton.userInteractionEnabled = false
            self.forgetButton.userInteractionEnabled = false
            self.rememberButton.userInteractionEnabled = false
            self.quitButton.userInteractionEnabled = false
            UIView.transitionWithView(self.forgetButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.forgetButton.setImage(UIImage(named: "cancel-white-highlighted.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.rememberButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.rememberButton.setImage(UIImage(named: "ok-gray.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.pauseButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.pauseButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                }, completion: { (complete) -> Void in
                    self.endReview()
            })
        }
    }
    
    func countDown(){
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateCountDownLabel:", userInfo: nil, repeats: true)
    }
    
    func updateCountDownLabel(timer: NSTimer){
        countDownLabelText--
        if countDownLabelText == 0{
            countdownLabel.text = "GO."
            return
        }
        else if countDownLabelText == -1{
            timer.invalidate()
            startReview()
            return
        }
        countdownLabel.text = "\(countDownLabelText)"
    }
    
    func startTiming(){
        reviewTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updatereviewTimer", userInfo: nil, repeats: true)
    }
    
    func startReview(){
        isStarted = true
        isPaused = false
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.pauseButton.userInteractionEnabled = true
            self.forgetButton.userInteractionEnabled = true
            self.rememberButton.userInteractionEnabled = true
            UIView.transitionWithView(self.mainCardContainer, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                self.coverView.hidden = true
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.forgetButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.forgetButton.setImage(UIImage(named: "cancel-red-forget.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.rememberButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.rememberButton.setImage(UIImage(named: "ok-green.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.pauseButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.pauseButton.setTitleColor(UIColor(red: 11/255, green: 124/255, blue: 250/255, alpha: 1), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.quitButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.quitButton.setTitleColor(UIColor(red: 11/255, green: 124/255, blue: 250/255, alpha: 1), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
        })
        self.startTiming()
    }
    
    func updatereviewTimer(){
        numSecondsElapsed++
        timeElapsedLabel.text = formatTimeWithSeconds()
    }
    
    private func formatTimeWithSeconds() -> String{
        var timeElapsed = numSecondsElapsed
        let hour = timeElapsed / 3600
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        timeElapsed -= (hour * 3600)
        let min = timeElapsed / 60
        let minString = min < 10 ? "0\(min)" : "\(min)"
        let sec = timeElapsed - (min * 60)
        let secString = sec < 10 ? "0\(sec)" : "\(sec)"
        return "Elapsed: " + hourString + ":" + minString + ":" + secString
    }
    
    func endReview(){
        let dimLayer = UIView(frame: UIScreen.mainScreen().bounds)
        dimLayer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dimLayer.userInteractionEnabled = true
        dimLayer.alpha = 0
        view.addSubview(dimLayer)
        
        endReviewPopup = Popup(frame: CGRect(x: view.frame.width/2 - 80, y: view.frame.height/2 - 30, width: 160, height: 60))
        endReviewPopup.numOptions = 0
        endReviewPopup.message = "Exiting in 3"
        endReviewPopup.alpha = 1
        endReviewPopup.transform = CGAffineTransformIdentity
        dimLayer.addSubview(endReviewPopup)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.25, delay: 0.25, options: .CurveEaseInOut, animations: { () -> Void in
                dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
                    self.countDownLabelText = 3
                    let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "exitCountDown:", userInfo: nil, repeats: true)
            })
        })
    }
    
    func exitCountDown(timer: NSTimer){
        if countDownLabelText > 0 {
            countDownLabelText--
            endReviewPopup.message = "Exiting in \(countDownLabelText)"
        }
        else{
            timer.invalidate()
            self.performSegueWithIdentifier("completeReview", sender: self)
        }
    }
    
    func buttonPressed(sender: UIButton){
        switch sender.tag{
        case 0:
            quit()
        case 1:
            pause()
        case 2:
            remember()
        case 3:
            forget()
        case 4:
            resume()
        case 5:
            currentCardView.flip()
        case 6:
            showNextCard()
        default:
            break
        }
    }
    
    func quit(){
        if !isPaused && isStarted{
            pause()
        }
        else if !isStarted && isPaused{
            if countDownTimer != nil{
                countDownTimer.invalidate()
                countDownTimer = nil
            }
        }
        var quitConfirmPopup = Popup(frame:CGRect(x: 35, y: view.frame.height/3, width: view.frame.width - 70, height: view.frame.height/3))
        quitConfirmPopup.message = "Are you sure you want to quit?"
        quitConfirmPopup.confirmButtonText = "YES"
        quitConfirmPopup.cancelBtnText = "NO"
        quitConfirmPopup.delegate = self
        view.addSubview(quitConfirmPopup)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            quitConfirmPopup.show()
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 1
                }, completion: { (complete) -> Void in
            })
        })
        
    }
    
    func configureWithCollection(collection: FlashCardCollection){
        collectionOfInterest = collection
        cardSet = (collectionOfInterest.flashcards as NSSet).allObjects as! [FlashCard]
    }
    
    func pause(){
        isPaused = true
        self.mainCardContainer.bringSubviewToFront(coverView)
        if reviewTimer != nil{
            reviewTimer.invalidate()
            reviewTimer = nil
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.countdownLabel.text = "Paused."
            UIView.transitionWithView(self.mainCardContainer, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                self.coverView.hidden = false
                }, completion: { (complete) -> Void in
                    UIView.transitionWithView(self.controlButtonsContainer, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
                        self.continueButton.hidden = false
                        self.pauseButton.hidden = true
                        }, completion: { (complete) -> Void in
                            
                    })
            })
            self.pauseButton.userInteractionEnabled = false
            self.forgetButton.userInteractionEnabled = false
            self.rememberButton.userInteractionEnabled = false
            UIView.transitionWithView(self.forgetButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.forgetButton.setImage(UIImage(named: "cancel-white-highlighted.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.rememberButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.rememberButton.setImage(UIImage(named: "ok-gray.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    func resume(){
        isPaused = false
        reviewTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updatereviewTimer", userInfo: nil, repeats: true)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.transitionWithView(self.controlButtonsContainer, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                self.continueButton.hidden = true
                self.pauseButton.hidden = false
                }, completion: { (complete) -> Void in
                    
            })
            UIView.transitionWithView(self.mainCardContainer, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                self.coverView.hidden = true
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.forgetButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.forgetButton.setImage(UIImage(named: "cancel-red-forget.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            UIView.transitionWithView(self.rememberButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.rememberButton.setImage(UIImage(named: "ok-green.png"), forState: .Normal)
                }, completion: { (complete) -> Void in
            })
            self.pauseButton.userInteractionEnabled = true
            self.forgetButton.userInteractionEnabled = true
            self.rememberButton.userInteractionEnabled = true
        })
    }
    
    func popupCancelBtnDidTapped(popup: Popup) {
        popup.removeFromSuperview()
        hideDimLayer()
        if !isStarted && isPaused{
            countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateCountDownLabel:", userInfo: nil, repeats: true)
        }
    }
    
    func popupConfirmBtnDidTapped(popup: Popup) {
        popup.removeFromSuperview()
        hideDimLayer()
        endReview()
    }
    
    func hideDimLayer(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    private func clearSubviews(viewToBeCleared: UIView){
        for subview in viewToBeCleared.subviews{
            subview.removeFromSuperview()
        }
    }
    
    
    
}
