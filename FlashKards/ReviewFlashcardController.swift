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
    @IBOutlet private weak var currentBackView: UIView!
    @IBOutlet private weak var currentFrontView: UIView!
    @IBOutlet private weak var nextFrontView: UIView!
    @IBOutlet private weak var nextBackView: UIView!
    @IBOutlet private weak var nextCardView: UIView!
    @IBOutlet private weak var controlButtonsContainer: UIView!
    @IBOutlet private weak var currentCardView: UIView!
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

    private var quizTimer: NSTimer!
    private var countDownTimer: NSTimer!
    private var collectionOfInterest: FlashCardCollection!
    private var cardSet: [FlashCard]!
    private var reviewedCardSet: [FlashCard]!
    private var numSecondsElapsed: Int64 = 0
    private var isPaused = true
    private var dimLayer: UIView!
    private var isStarted = false
    private let INITIAL_NEXT_TRANSFORM = CGAffineTransformMakeTranslation(-50, 0)
    private let INITIAL_FLIP_TRANSFORM = CGAffineTransformMakeScale(0.1, 0.1)
    private var flipAnimating = false
    private var resultsDictionary: NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        if let navbarHeight = Constants.navBarHeight{
            navBarHeight = navbarHeight
            containerViewTopConstraint.constant += navbarHeight
        }
        reviewedCardSet = [FlashCard]()
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
        
        currentBackView.hidden = true
        
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
        countDown()
        if let firstCard = cardSet.first as FlashCard!{
            reviewedCardSet.append(firstCard)
            cardSet.removeAtIndex(0)
            var frontDict = firstCard.front as! NSDictionary
            var backDict = firstCard.back as! NSDictionary
            restoreViewsWithDictionary(frontDict, onView: currentFrontView)
            restoreViewsWithDictionary(backDict, onView: currentBackView)
            
            if let secondCard = cardSet.first as FlashCard!{
                reviewedCardSet.append(secondCard)
                cardSet.removeAtIndex(0)
                frontDict = secondCard.front as! NSDictionary
                backDict = secondCard.back as! NSDictionary
                restoreViewsWithDictionary(frontDict, onView: nextFrontView)
                restoreViewsWithDictionary(backDict, onView: nextBackView)
            }
            else{
                println("There's only one card in collection")
            }
        }
        else{
            println("No card in collection")
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
                label.font = UIFont(name: "AppleSDGothicNeo-Light", size: 25)
                label.text = element.objectForKey("content") as? String
                label.textAlignment = .Center
                view.addSubview(label)
            }
            else if type == "img"{
                let frameValue = element.objectForKey("frame") as! NSValue
                let frame = frameValue.CGRectValue()
                let imgURL = element.objectForKey("content") as! String
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func remember(){
        
    }
    
    func forget(){
        flip()
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
    
    func nextCard(){
        
        hideSecondaryButtons()
        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.forgetButton.alpha = 1
            self.rememberButton.alpha = 1
            }, completion: { (complete) -> Void in
        })
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
            startQuiz()
            return
        }
        countdownLabel.text = "\(countDownLabelText)"
    }
    
    func startTiming(){
        quizTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateQuizTimer", userInfo: nil, repeats: true)
    }
    
    func startQuiz(){
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
        })
        self.startTiming()
    }
    
    func updateQuizTimer(){
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
    
    func endQuiz(){
//        dismissViewControllerAnimated(true, completion: { () -> Void in
//            
//        })
        self.performSegueWithIdentifier("completeReview", sender: self)
        
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
            flip()
        case 6:
            nextCard()
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
        if quizTimer != nil{
            quizTimer.invalidate()
            quizTimer = nil
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
        quizTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateQuizTimer", userInfo: nil, repeats: true)
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
        endQuiz()
    }
    
    func hideDimLayer(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.dimLayer.alpha = 0
                }, completion: { (complete) -> Void in
            })
        })
    }
    
    func flip(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !self.flipAnimating{
                self.flipAnimating = true
                UIView.transitionWithView(self.currentCardView, duration: 0.6, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
                    self.currentFrontView.hidden = !self.currentFrontView.hidden
                    self.currentBackView.hidden = !self.currentBackView.hidden
                    }, completion: { (complete) -> Void in
                        self.flipAnimating = false
                })
            }
            
        })
        
    }
    

    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("preparing for segue \(segue.identifier!)　")
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    
    


    
    
}
