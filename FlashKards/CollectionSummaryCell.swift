//
//  CollectionSummaryCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-03-26.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class CollectionSummaryCell: UITableViewCell {
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var subtext1Label: UILabel!
    @IBOutlet private weak var subtext2Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.None
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
