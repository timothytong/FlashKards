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
        print("calculateOptimalFontSizeWithText - \(text)")
        var fontSize: CGFloat = 100;
        let minFontSize: CGFloat = 20;
        let adjustedText = " " + text + " "
        // Fit label width wize
        let constraintSize = CGSizeMake(rect.width, CGFloat.max)
        repeat {
            // Set current font size
            let font = UIFont(name: "HelveticaNeue-Light", size: fontSize)
            // Find label size for current font size
            let textRect = (adjustedText as NSString).boundingRectWithSize(constraintSize, options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: font!], context: nil)
            let labelSize = textRect.size
            // Done, if created label is within target size
            if labelSize.height <= rect.height{
                print("  --label width: \(labelSize.width) height \(labelSize.height), rect height \(rect.height)")
                break
            }
            fontSize--
        } while (fontSize > minFontSize)
        print("  --returning fontsize \(fontSize)")
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
    
    static func restoreViewsWithDictionary(dict: NSDictionary, onView view: UIView, widthScaleRatio widthRatio: CGFloat, heightScaleRatio heightRatio: CGFloat)->UIView{
        for key in dict.allKeys{
            let element = dict.objectForKey(key) as! NSDictionary
            let type = element.objectForKey("type") as! String
            
            let frameValue = element.objectForKey("frame") as! NSValue
            let frame = frameValue.CGRectValue()
            let actualFrame = CGRect(x: frame.origin.x * widthRatio, y: frame.origin.y * heightRatio, width: frame.width * widthRatio, height: frame.height * heightRatio)
            
            if type == "txt"{
                let label = UILabel(frame: actualFrame)
                var fontSize = element.objectForKey("font_size") as! CGFloat
                if(widthRatio < 1 || heightRatio < 1){
                    fontSize *= (widthRatio < heightRatio) ? widthRatio : heightRatio
                }
                label.font = UIFont(name: element.objectForKey("font") as! String, size: fontSize)
                label.text = element.objectForKey("content") as? String
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.lineBreakMode = NSLineBreakMode.ByWordWrapping
                view.addSubview(label)
            }
            else if type == "img"{
                let imgURL = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) + "/" + (element.objectForKey("content") as! String)
                let imageView = UIImageView(frame: actualFrame)
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let image = UIImage(contentsOfFile: imgURL)
                    /*
                    if image != nil && (widthRatio < 1 || heightRatio < 1){
                    // Lower the quality of the image!
                    let imageWidth = image!.size.width
                    let imageHeight = image!.size.height
                    let aspectRatio = imageWidth / imageHeight
                    let size = (imageWidth > imageHeight) ? CGSize(width: actualFrame.width, height: actualFrame.height * aspectRatio) : CGSize(width: actualFrame.width * aspectRatio, height: actualFrame.height)
                    UIGraphicsBeginImageContext(size)
                    //                        let imageFrame = (imageWidth > imageHeight) ? CGRect(x: actualFrame.origin.x, y: (actualFrame.height / 2 - size.height / 2), width: size.width, height: size.height) : CGRect(x: (actualFrame.width / 2 - size.width / 2), y: actualFrame.origin.y, width: size.width, height: size.height)
                    image!.drawInRect(actualFrame)
                    image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    println("Resolution lowered")
                    
                    }
                    */
                    imageView.image = image
                    view.addSubview(imageView)
                    
                })
                
                
            }
        }
        return view
    }
    
    static func clearSubviews(viewToBeCleared: UIView){
        for subview in viewToBeCleared.subviews{
            subview.removeFromSuperview()
        }
    }
    
    static func getScreenSize()->CGSize{
        return UIScreen.mainScreen().bounds.size
    }
    
}