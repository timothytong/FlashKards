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
            let font = UIFont(name: "HelveticaNeue-Light", size: fontSize)
            // Find label size for current font size
            let textRect = (adjustedText as NSString).boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading, attributes: [NSFontAttributeName: font!], context: nil)
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
    
    static func IS_IPHONE6()->Bool{
        return UIScreen.mainScreen().bounds.size.height == 667
    }
    
    static func IS_IPHONE6P()->Bool{
        return UIScreen.mainScreen().bounds.size.height == 736
    }
    
    static func restoreViewsWithDictionary(dict: NSDictionary, onView view: UIView)->UIView{
        for key in dict.allKeys{
            let element = dict.objectForKey(key) as! NSDictionary
            let type = element.objectForKey("type") as! String
            if type == "txt"{
                let frameValue = element.objectForKey("frame") as! NSValue
                let frame = frameValue.CGRectValue()
                var label = UILabel(frame: frame)
                label.font = UIFont(name: element.objectForKey("font") as! String, size: element.objectForKey("font_size") as! CGFloat)
                label.text = element.objectForKey("content") as? String
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.lineBreakMode = NSLineBreakMode.ByCharWrapping
                view.addSubview(label)
            }
            else if type == "img"{
                let frameValue = element.objectForKey("frame") as! NSValue
                let frame = frameValue.CGRectValue()
                let imgURL = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String) + "/" + (element.objectForKey("content") as! String)
                var imageView = UIImageView(frame: frame)
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let image = UIImage(contentsOfFile: imgURL)
                    imageView.image = image
                    view.addSubview(imageView)
                })
            }
        }
        return view
    }

}