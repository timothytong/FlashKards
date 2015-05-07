//
//  CollectionSummaryCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class CollectionSummaryCell: UITableViewCell {
    @IBOutlet weak var numberWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberSepLineHConstraint: NSLayoutConstraint!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var subtext1Label: UILabel!
    @IBOutlet private weak var subtext2Label: UILabel!
    
    @IBOutlet weak var numberSubtextHConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.None

        if Utilities.IS_IPHONE4() || Utilities.IS_IPHONE5(){
        numberWidthConstraint.constant = frame.width/2.5
            numberSubtextHConstraint.constant = frame.width/9.5
        }
        else{
            numberWidthConstraint.constant = frame.width/2
            numberSubtextHConstraint.constant = frame.width/5.5
        }
        
        numberSepLineHConstraint.constant = numberSubtextHConstraint.constant / 2
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func populateFieldsWithNumberString(number: String!, Subtext1 subtext:String!, andSubtext2 subtextTwo:String!){
        numberLabel.text = number
        subtext1Label.text = subtext
        subtext2Label.text = subtextTwo
    }
}
