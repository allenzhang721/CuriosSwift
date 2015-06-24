//
//  BookDetailInfoCell.swift
//  
//
//  Created by Emiaostein on 6/19/15.
//
//

import UIKit

class BookDetailInfoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriText: UITextView!
    weak var tableView: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        descriText.resignFirstResponder()
        // Configure the view for the selected state
    }
    
}
