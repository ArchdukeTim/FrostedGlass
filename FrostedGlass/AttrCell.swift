//
//  AttributeTableViewCell.swift
//  FrostedGlass
//
//  Created by Tim Winters on 10/10/18.
//  Copyright © 2018 Tim Winters. All rights reserved.
//

import UIKit

class AttrCell: UITableViewCell {
    
    //MARK: Properties

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var value: UILabel!
    @IBAction func onUpdate(_ sender: UISlider) {
        value.text = "\(sender.value)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
