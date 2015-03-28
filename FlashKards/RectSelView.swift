//
//  RectSelView.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class RectSelView: UIView {
    private var topLeftCircle: UIView!
    private var topRightCircle: UIView!
    private var bottomLeftCircle: UIView!
    private var bottomRightCircle: UIView!
    private var topLeftPanArea: UIView!
    private var topRightPanArea: UIView!
    private var bottomLeftPanArea: UIView!
    private var bottomRightPanArea: UIView!
    private var dashedBorder: CAShapeLayer!
    private let MIN_WIDTH : CGFloat = 40, MIN_HEIGHT : CGFloat = 40
    private var panAreas: Array<UIView>!
    private var circles: Array<UIView>!
    private var prevTranslation: CGPoint!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        
        // Dashed border
        dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 0.6).CGColor
        dashedBorder.fillColor = nil
        dashedBorder.lineDashPattern = [4, 4]
        dashedBorder.lineWidth = 1
        layer.addSublayer(dashedBorder)
        
        // Pan gesture (drag move) for the view itself
        var dragPan = UIPanGestureRecognizer(target: self, action: "selRectPanned:")
        self.addGestureRecognizer(dragPan)
        
        // The 4 resize grippers.
        topLeftPanArea = UIView()
        topRightPanArea = UIView()
        bottomLeftPanArea = UIView()
        bottomRightPanArea = UIView()
        topLeftCircle = UIView()
        topRightCircle = UIView()
        bottomLeftCircle = UIView()
        bottomRightCircle = UIView()
        
        prevTranslation = CGPointMake(0, 0)
        
        // Invisible pannable areas
        panAreas = [topLeftPanArea, topRightPanArea, bottomLeftPanArea, bottomRightPanArea]
        for(var i = 0; i < panAreas.count; i++){
            var panArea = panAreas[i]
            let x = i % 2 == 0 ? -10 : frame.width - 20
            let y = (i < 2) ? -10 : frame.height - 20
            panArea.frame = CGRect(x: x, y: y, width: 30, height: 30)
            panArea.tag = i
            var pan = UIPanGestureRecognizer(target: self, action: "resizeDotPanned:")
            pan.maximumNumberOfTouches = 1
            pan.minimumNumberOfTouches = 1
            addSubview(panArea)
            panArea.backgroundColor = UIColor.clearColor()
            panArea.addGestureRecognizer(pan)
            panAreas[i] = panArea
        }
        // Circles
        circles = [topLeftCircle, topRightCircle, bottomLeftCircle, bottomRightCircle]
        for(var i = 0; i < circles.count; i++){
            var circle = circles[i]
            let x = (i % 2 == 0) ? -5 : frame.width - 5
            let y = (i < 2) ? -5 : frame.width - 5
            circle.frame = CGRect(x: x, y: y, width: 10, height: 10)
            circle.userInteractionEnabled = false
            circle.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            circle.layer.borderColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1).CGColor
            circle.layer.borderWidth = 1
            circle.layer.cornerRadius = 5
            bringSubviewToFront(circle)
            addSubview(circle)
            circles[i] = circle
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashedBorder.path = UIBezierPath(rect: bounds).CGPath
        dashedBorder.frame = bounds
    }
    
    // MARK: Pan Gestures
    func selRectPanned(sender: UIPanGestureRecognizer!){
        if sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed{
            prevTranslation.x = 0
            prevTranslation.y = 0
            return
        }
        var translation = sender.translationInView(self)
        var temp = translation
        //        println("\(translation.x), \(translation.y)")
        translation.x -= prevTranslation.x
        translation.y -= prevTranslation.y
        prevTranslation = temp
        var newX: CGFloat = 0,
        newY: CGFloat = 0
        if frame.origin.x + translation.x >= 0{
            if frame.origin.x + translation.x + frame.width <= superview!.frame.width{
                newX = center.x + translation.x
            }
            else{
                newX = superview!.frame.width - frame.width/2
            }
        }
        else{
            newX = frame.width / 2
        }
        
        if frame.origin.y + translation.y >= 0{
            if frame.origin.y + translation.y + frame.height <= superview!.frame.height{
                newY = center.y + translation.y
            }
            else{
                newY = superview!.frame.height - frame.height/2
            }
        }
        else{
            newY = frame.height / 2
        }
        center = CGPointMake(newX, newY)
    }
    
    func resizeDotPanned(sender: UIPanGestureRecognizer!){
        if sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed{
            prevTranslation.x = 0
            prevTranslation.y = 0
            return
        }
        var translation = sender.translationInView(self)
        var temp = translation
        //        println("\(translation.x), \(translation.y)")
        translation.x -= prevTranslation.x
        translation.y -= prevTranslation.y
        prevTranslation = temp
        var changeInX : CGFloat = 0,
        changeInY : CGFloat = 0,
        changeInWidth : CGFloat = 0,
        changeInHeight : CGFloat = 0
        
        switch sender.view!.tag{
        case 0: // Top left
            changeInX = translation.x
            changeInY = translation.y
            if frame.origin.x + changeInX < 0 { changeInX = -frame.origin.x } // Edge case on x-axis
            else if changeInX + MIN_WIDTH >= frame.width { changeInX = 0 }    // Check if width is still > MIN_WIDTH
            
            if frame.origin.y + changeInY < 0 { changeInY = -frame.origin.y } // Edge case on y-axis
            else if changeInY + MIN_HEIGHT >= frame.height { changeInY = 0 }  // Check if width is still > MIN_HEIGHT
            changeInWidth = frame.width - changeInX
            changeInHeight = frame.height - changeInY
            frame = CGRect(x: frame.origin.x + changeInX, y: frame.origin.y + changeInY, width: changeInWidth, height: changeInHeight)
        case 1: // Top Right
            changeInWidth = translation.x
            changeInY = translation.y
            if frame.origin.x + frame.width + changeInWidth > superview!.frame.width {
                changeInWidth = superview!.frame.width - frame.origin.x - frame.width // Edge case on x-axis
            }
            else if frame.width + changeInWidth < MIN_WIDTH { changeInWidth = 0 }  // Check if width is still > MIN_WIDTH
            
            if frame.origin.y + changeInY < 0 { changeInY = -frame.origin.y } // Edge case on y-axis
            else if changeInY + MIN_HEIGHT >= frame.height { changeInY = 0 }  // Check if width is still > MIN_HEIGHT
            changeInHeight = frame.height - changeInY
            frame = CGRect(x: frame.origin.x, y: frame.origin.y + changeInY, width: frame.width + changeInWidth, height: changeInHeight)
        case 2:
            changeInX = translation.x
            changeInHeight = translation.y
            if frame.origin.x + changeInX < 0 { changeInX = -frame.origin.x } // Edge case on x-axis
            else if changeInX + MIN_WIDTH >= frame.width { changeInX = 0 }    // Check if width is still > MIN_WIDTH
            if frame.origin.y + frame.height + changeInHeight > superview!.frame.height {
                changeInHeight = superview!.frame.height - frame.origin.y - frame.height // Edge case on y-axis
            }
            else if frame.height + changeInHeight < MIN_HEIGHT { changeInHeight = 0 }  // Check if height is still > MIN_HEIGHT
            changeInWidth = frame.width - changeInX
            frame = CGRect(x: frame.origin.x + changeInX, y: frame.origin.y, width: changeInWidth, height: frame.height + changeInHeight)
        case 3:
            changeInWidth = translation.x
            changeInHeight = translation.y
            if frame.origin.x + frame.width + changeInWidth > superview!.frame.width {
                changeInWidth = superview!.frame.width - frame.origin.x - frame.width // Edge case on x-axis
            }
            else if frame.width + changeInWidth < MIN_WIDTH { changeInWidth = 0 }  // Check if width is still > MIN_WIDTH
            
            if frame.origin.y + frame.height + changeInHeight > superview!.frame.height {
                changeInHeight = superview!.frame.height - frame.origin.y - frame.height // Edge case on y-axis
            }
            else if frame.height + changeInHeight < MIN_HEIGHT { changeInHeight = 0 }  // Check if height is still > MIN_HEIGHT
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width + changeInWidth, height: frame.height + changeInHeight)
        default:
            break
        }
        
        for(var i = 0; i < circles.count; i++){
            var circle = circles[i]
            let x = (i % 2 == 0) ? -5 : frame.width - 5
            let y = (i < 2) ? -5 : frame.height - 5
            circle.frame = CGRect(x: x, y: y, width: 10, height: 10)
            circles[i] = circle
        }
        
        for(var i = 0; i < panAreas.count; i++){
            var panArea = panAreas[i]
            let x = i % 2 == 0 ? -10 : frame.width - 20
            let y = (i < 2) ? -10 : frame.height - 20
            panArea.frame = CGRect(x: x, y: y, width: 30, height: 30)
            panAreas[i] = panArea
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
