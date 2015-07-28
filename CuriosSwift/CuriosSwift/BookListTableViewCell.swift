//
//  BookListTableViewCell.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Kingfisher

class BookListTableViewCell: UITableViewCell {
    @IBOutlet weak var bookListCellImg: UIImageView!
    @IBOutlet weak var bookListCellTitle: UILabel!
    @IBOutlet weak var bookListCellDesc: UITextView!
    @IBOutlet weak var bookListCellDate: UILabel!
  
  let HOST = "http://7wy3u8.com2.z0.glb.qiniucdn.com/"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      bookListCellImg.layer.cornerRadius = 8
      bookListCellImg.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  func configWithModel(bookModel: BookListModel) {
    
    let iconUrlString = bookModel.publishIconURL
    let url = NSURL(string: iconUrlString)
    
    println("iconURL = \(url)")
    if let url = url {
      bookListCellImg.kf_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"))
    }
    
    bookListCellTitle.text = bookModel.publishTitle;
    bookListCellDesc.text = bookModel.publishDesc;
    bookListCellDate.text = bookModel.publishDate
    
//    if let date = bookModel.publishDate {
    
//      let dateFormatter = NSDateFormatter()
//      dateFormatter.dateFormat = "yyyy-MM-dd HH:MM"
//      let dateStr = dateFormatter.stringFromDate(date)
//      bookListCellDate.text = dateStr;
//    }
    
    
  }
}
