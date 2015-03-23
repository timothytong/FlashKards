//
//  FlashCardsOverviewCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-22.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class FlashCardsOverviewCell: UITableViewCell {
    @IBOutlet weak var separatorLine: UIView!

    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var collectionProgressLabel: UILabel!
    @IBOutlet weak var lastReviewedLabel: UILabel!
    @IBOutlet weak var numCardsLabel: UILabel!
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
    
    func populateCellWithCollectionName(collectionName: String!, progress: Int!, lastReviewedDate: String!, numCardsInCollection: Int!){
        /* Calculate optimal width based on string length
        var collNameOptimalBounds = (collectionName as NSString!).boundingRectWithSize(self.collectionLabel.frame.size,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:self.collectionLabel.font],
            context: nil)
        */
        
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
    }
}
