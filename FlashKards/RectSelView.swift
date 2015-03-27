//
//  RectSelView.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class RectSelView: UIView {
    var topLeftCircle: UIView!
    var topRightCircle: UIView!
    var bottomLeftCircle: UIView!
    var bottomRightCircle: UIView!
    var topLeftPanArea: UIView!
    var topRightPanArea: UIView!
    var bottomLeftPanArea: UIView!
    var bottomRightPanArea: UIView!
    var dashedBorder: CAShapeLayer!
    let MIN_WIDTH = 30, MIN_HEIGHT = 30
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
//        topLeftCircle = UIView(frame: CGRect(x: -5, y: -5, width: 10, height: 10))
//        topRightCircle = UIView(frame: CGRect(x: frame.width - 5, y: -5, width: 10, height: 10))
//        bottomLeftCircle = UIView(frame: CGRect(x: -5, y: frame.height - 5, width: 10, height: 10))
//        bottomRightCircle = UIView(frame: CGRect(x: frame.width - 5, y: frame.height - 5, width: 10, height: 10))
        
        dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 0.6).CGColor
        dashedBorder.fillColor = nil
        dashedBorder.lineDashPattern = [4, 4]
        dashedBorder.lineWidth = 1
        layer.addSublayer(dashedBorder)
        
        var panAreas = [topLeftPanArea, topRightPanArea, bottomLeftPanArea, bottomRightPanArea]
        for(var i = 0; i < panAreas.count; i++){
            var panArea = panAreas[i]
            let x = i % 2 == 0 ? 0 : frame.width / 2
            let y = (i < 2) ? 0 : frame.height / 2
            panArea = UIView(frame: CGRect(x: x, y: y, width: frame.width/2, height: frame.height/2))
            panArea.tag = i
            var pan = UIPanGestureRecognizer(target: self, action: "resizeDotPanned:")
            pan.maximumNumberOfTouches = 1
            pan.minimumNumberOfTouches = 1
            addSubview(panArea)
            panArea.addGestureRecognizer(pan)
        }
        
        var circles = [topLeftCircle, topRightCircle, bottomLeftCircle, bottomRightCircle]
        for(var i = 0; i < circles.count; i++){
            var circle = circles[i]
            let x = (i % 2 == 0) ? -5 : frame.width - 5
            let y = (i < 2) ? -5 : frame.width - 5
            circle = UIView(frame: CGRect(x: x, y: y, width: 10, height: 10))
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
    func resizeDotPanned(sender: UIPanGestureRecognizer!){
        if sender.state == UIGestureRecognizerState.Began{
            println("BEGAN with tag: \(sender.view!.tag)")
        }
        var translation = sender.translationInView(self.superview!)
        println("\(translation.x), \(translation.y)")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
