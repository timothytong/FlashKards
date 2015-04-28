//
//  Utilities.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-23.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    static func calculateOptimalFontSizeWithText(text: String, inRect rect: CGRect) -> CGFloat{
        // Set the frame of the label to the targeted rectangle
        println("calculateOptimalFontSizeWithText - \(text)")
        var fontSize: CGFloat = 100;
        let minFontSize: CGFloat = 20;
        let adjustedText = " " + text + " "
        // Fit label width wize
        let constraintSize = CGSizeMake(rect.width, CGFloat.max)
        do {
            // Set current font size
            let font = UIFont(name: "AppleSDGothicNeo-Light", size: fontSize)
            // Find label size for current font size
            let textRect = (adjustedText as NSString).boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font!], context: nil)
            let labelSize = textRect.size
            // Done, if created label is within target size
            if labelSize.height <= rect.height{
                println("  --label width: \(labelSize.width) height \(labelSize.height), rect height \(rect.height)")
                break
            }
            fontSize--
        } while (fontSize > minFontSize)
        println("  --returning fontsize \(fontSize)")
        return fontSize
    }
    
    static func IS_IPHONE4()->Bool{
        return UIScreen.mainScreen().bounds.size.height < 568
    }
    
    static func IS_IPHONE5()->Bool{
        return UIScreen.mainScreen().bounds.size.height == 568
    }
}