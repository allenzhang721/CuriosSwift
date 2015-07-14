//
//  BookListTableViewCell.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class BookListTableViewCell: UITableViewCell {
    @IBOutlet weak var bookListCellImg: UIImageView!
    @IBOutlet weak var bookListCellTitle: UILabel!
    @IBOutlet weak var bookListCellDesc: UITextView!
    @IBOutlet weak var bookListCellDate: UILabel!

    var bookModel:BookListModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if self.bookModel != nil {
            let bookIconURL = self.bookModel!.publishIconURL;
//            if bookIconURL != nil && bookIconURL != "" {
                bookListCellImg.image = UIImage(contentsOfFile: bookIconURL);
//            }else{
//                
//            }
            bookListCellTitle.text = self.bookModel!.publishTitle;
            bookListCellDesc.text = self.bookModel!.publishDesc;
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:MM"
            let dateStr = dateFormatter.stringFromDate(self.bookModel!.publishDate)
            bookListCellDate.text = dateStr;
        }
    }

    func setBookMode(bookModel:BookListModel){
        self.bookModel = bookModel;
    }
}
