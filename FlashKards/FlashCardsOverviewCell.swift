//
//  FlashCardsOverviewCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-22.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class FlashCardsOverviewCell: UITableViewCell {
    @IBOutlet private weak var separatorLine: UIView!
    @IBOutlet private weak var sepLineWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionLabel: UILabel!
    @IBOutlet private weak var collectionProgressLabel: UILabel!
    @IBOutlet private weak var lastReviewedLabel: UILabel!
    @IBOutlet private weak var numCardsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionLabel.adjustsFontSizeToFitWidth = true
        self.collectionLabel.numberOfLines = 2
        self.collectionLabel.minimumScaleFactor = 0.5
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted{
        }
        else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
            })
        }
    }
    
    func populateCellWithCollection(collection: FlashCardCollection!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            /* Calculate optimal width based on string length
            var collNameOptimalBounds = (collectionName as NSString!).boundingRectWithSize(self.collectionLabel.frame.size,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:self.collectionLabel.font],
            context: nil)
            */
            let collectionName = collection.collectionName
            let progress = collection.progress
            let lastReviewedDate = collection.lastReviewed
            let numCardsInCollection = collection.numCards
            
            self.collectionLabel.text = collectionName.utf16Count >= 20 ? (collectionName as NSString!).substringToIndex(18) + "..": collectionName
            self.collectionProgressLabel.text = "\(progress)%"
            self.lastReviewedLabel.text = lastReviewedDate
            self.numCardsLabel.text = "\(numCardsInCollection)"
            var progressColor:UIColor
            switch progress{
            case 0...20:
                progressColor = UIColor(red: 247/255, green: 4/255, blue: 0, alpha: 1)
            case 21...50:
                progressColor = UIColor(red: 247/255, green: 100/255, blue: 0, alpha: 1)
            case 51...75:
                progressColor = UIColor(red: 247/255, green: 230/255, blue: 0, alpha: 1)
            case 76...90:
                progressColor = UIColor(red: 108/255, green: 247/255, blue: 0, alpha: 1)
            default:
                progressColor = UIColor(red: 0, green: 247/255, blue: 21/255, alpha: 1)
            }
            self.collectionProgressLabel.textColor = progressColor
            self.separatorLine.backgroundColor = progressColor
            self.sepLineWidthConstraint.constant = (self.frame.width - 30) * (CGFloat(progress)/100.0)
            UIView.animateWithDuration(1, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.layoutIfNeeded()
                }) { (complete) -> Void in

            }
            
        })
    }
}
