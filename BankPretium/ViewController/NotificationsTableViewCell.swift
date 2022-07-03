//
//  NotificationsTableViewCell.swift
//  BankPretium
//
//  Created by Turgay Ceylan on 2.07.2022.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tCell: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
