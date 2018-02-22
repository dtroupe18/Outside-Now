//
//  HourlyTableViewCell.swift
//  Outside Now
//
//  Created by Dave on 2/22/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class HourlyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var condImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
