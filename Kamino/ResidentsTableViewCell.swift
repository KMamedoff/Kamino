//
//  ResidentsTableViewCell.swift
//  Kamino
//
//  Created by Kenan Mamedoff on 02/04/2019.
//  Copyright © 2019 Kenan Mamedoff. All rights reserved.
//

import UIKit

class ResidentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var residentInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
