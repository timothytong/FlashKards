//
//  SidebarOptionsCell
//  FlashKards
//
//  Created by Timothy Tong on 2015-08-19.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class SidebarOptionsCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
