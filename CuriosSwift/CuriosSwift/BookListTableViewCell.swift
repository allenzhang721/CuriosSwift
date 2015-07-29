//
//  BookListTableViewCell.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Kingfisher
import DateTools

class BookListTableViewCell: UITableViewCell {
    @IBOutlet weak var bookListCellImg: UIImageView!
    @IBOutlet weak var bookListCellTitle: UILabel!
    @IBOutlet weak var bookListCellDesc: UITextView!
    @IBOutlet weak var bookListCellDate: UILabel!
  
  weak var date: NSDate!
  var timer: NSTimer!
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
  
  override func prepareForReuse() {
    
    super.prepareForReuse()
    timer.fireDate = NSDate.distantPast() as! NSDate
  }
  
  func configWithModel(bookModel: BookListModel) {
    
    let iconUrlString = bookModel.publishIconURL
    let url = NSURL(string: iconUrlString)
    if let url = url {
      bookListCellImg.kf_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"))
    }
    
    date = bookModel.publishDate
    bookListCellTitle.text = bookModel.publishTitle;
    bookListCellDesc.text = bookModel.publishDesc;
//    bookListCellDate.text = date.timeAgoSinceNow()
    bookListCellDesc.textColor = UIColor.lightGrayColor()
    
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "updateDate", userInfo: nil, repeats: true)
      timer.fireDate = NSDate.distantFuture() as! NSDate
    }
    
    timer.fire()
  }
  
  func updateDate() {
    bookListCellDate.text = date.timeAgoSinceNow()
  }
}
