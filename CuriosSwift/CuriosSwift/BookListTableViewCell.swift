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
    @IBOutlet weak var bookListCellDesc: UILabel!
    @IBOutlet weak var bookListCellDate: UILabel!
  
  weak var date: NSDate!
  var timer: NSTimer!
    
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
    
    let iconUrlString = bookModel.publishIconURL.stringByAppendingString(ICON_THUMBNAIL)
    let url = NSURL(string: iconUrlString)
    debugPrint.p("iconUrlString = \(iconUrlString)")
    bookListCellImg.image = UIImage(named : "placeholder")
    if let url = url {
      KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: .None, progressBlock: nil) {[weak self] (image, error, cacheType, imageURL) -> () in
        if error != nil {
          println(error)
        } else {
          //        KingfisherManager.sharedManager.cache.storeImage(image!, forKey: aIconKey)
          self?.bookListCellImg.image = image
        }
      }
//      bookListCellImg.kf_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"))
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
