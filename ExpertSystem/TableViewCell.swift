//
//  TableViewCell.swift
//  ExpertSystem
//
//  Created by Georgy on 19.10.2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var TextQuest: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
