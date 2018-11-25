//
//  MetroStationTableViewCell.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/21/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import UIKit

class MetroStationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stationName: UILabel!
    
    @IBOutlet weak var stationAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
