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
    
    func configureWithDict(dict: Dictionary<String, String>){
        if dict["status"] == "complete"{
            statusCompleteLabel.text = "C O M P L E T E"
            statusCompleteLabel.textColor = UIColor(red: 60/255, green: 242/255, blue: 119/255, alpha: 1)
            statusLightView.backgroundColor = UIColor(red: 60/255, green: 242/255, blue: 119/255, alpha: 1)
        }
        else if dict["status"] == "aborted"{
            statusCompleteLabel.text = "A B O R T E D"
            statusLightView.backgroundColor = UIColor.redColor()
        }
    }

}
