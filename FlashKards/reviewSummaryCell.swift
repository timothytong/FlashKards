//
//  reviewSummaryCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-27.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class reviewSummaryCell: UITableViewCell {
    @IBOutlet weak var sepLineLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var sepLine: UIView!
    @IBOutlet weak var attrLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        sepLineLeadingConstraint.constant = UIScreen.mainScreen().bounds.width / 2 - 15 - 28
        // Initialization code
    }

    func configureWithDict(dict: Dictionary<String, String>){
        attrLabel.text = dict.keys.first!
        valueLabel.text = dict.values.first!
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
