//
//  ReviewSummaryStatusCell.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-27.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ReviewSummaryStatusCell: UITableViewCell {

    @IBOutlet weak var statusCompleteLabel: UILabel!
    @IBOutlet weak var statusLightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusLightView.clipsToBounds = true
        statusLightView.layer.cornerRadius = 10
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
