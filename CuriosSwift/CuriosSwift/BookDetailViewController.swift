//
//  BookDetailViewController.swift
//
//
//  Created by Emiaostein on 6/18/15.
//
//

import UIKit
import Kingfisher

protocol BookDetailViewControllerDelegate: NSObjectProtocol {
  
  func bookDetailViewControllerDidChangeIcon(iconData: NSData)
}

class BookDetailViewController: UIViewController,UINavigationControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var delegate: BookDetailViewControllerDelegate?
  var bookModel: BookModel!
  
  var needuploadIcon = false
  
  let HOST = "http://7wy3u8.com2.z0.glb.qiniucdn.com/"
  
  var iconKey: String {
    
    get {
      let userID = UsersManager.shareInstance.getUserID()
      let publishID = bookModel.Id
      let icon = "icon.png"
      let path = pathByComponents([userID, publishID, icon])
      return path
    }
  }
  
  
  var bookTitle: String {
    
    let title = bookModel.title
    return title
  }
  
  var bookDescription: String {
    
    let title = bookModel.desc
    return title
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = localString("BOOKDETAIL_SETTING")
    
    tableView.registerNib(UINib(nibName: "BookDetailImageCell", bundle: nil), forCellReuseIdentifier: "BookDetailImageCell")
    tableView.registerNib(UINib(nibName: "BookDetailInfoCell", bundle: nil), forCellReuseIdentifier: "BookDetailInfoCell")
    tableView.estimatedRowHeight = 72
    tableView.rowHeight = UITableViewAutomaticDimension
    
    let iconString = HOST.stringByAppendingPathComponent(bookModel.icon)
    let iconURL = NSURL(string: iconString)!
    let aIconKey = iconKey
    KingfisherManager.sharedManager.retrieveImageWithURL(iconURL, optionsInfo: .None, progressBlock: nil) {[weak self] (image, error, cacheType, imageURL) -> () in
      if error != nil {
        println(error)
      } else {
        KingfisherManager.sharedManager.cache.storeImage(image!, forKey: aIconKey)
        self?.tableView.reloadData()
      }
    }
  }
  
  @IBAction func backAction(sender: UIBarButtonItem) {
    
    if needuploadIcon {
      KingfisherManager.sharedManager.cache.retrieveImageForKey(iconKey, options: KingfisherManager.DefaultOptions, completionHandler: { [weak self] (image, cacheType) -> () in
        
        if let image  = image {
          let imageData = UIImagePNGRepresentation(image)
          self?.delegate?.bookDetailViewControllerDidChangeIcon(imageData)
        }
        
        self?.dismissViewControllerAnimated(true, completion: nil)
        
      })
    } else {
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
}

// MARK: - DataSource and Delegate
// MARK: -

// MARK: - IBAction
// MARK: -

// MARK: - Private Method
// MARK: -
extension BookDetailViewController: UITableViewDataSource, UITableViewDelegate, textInputViewControllerProtocol {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if section == 0 {
      return 3
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    //BOOKDETAIL_ICON              = "图标";
//    BOOKDETAIL_TITLE             = "标题";
//    BOOKDETAIL_DESCRIPTION       = "简介";
    
    let section = indexPath.section
    let row = indexPath.row
    
    if section == 0 {
      if row == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
        cell.titleLabel?.text = localString("BOOKDETAIL_ICON")
        KingfisherManager.sharedManager.cache.retrieveImageForKey(iconKey, options: KingfisherManager.DefaultOptions) {[unowned self] (image, type) -> () in
          if let aImage = image {
            cell.iconImageView.image = aImage
          } else {
            cell.iconImageView.image = UIImage(named: "placeholder")
          }
        }
        
        return cell
        
      } else if row == 1{
        let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailInfoCell") as! BookDetailInfoCell
        cell.titleLabel?.text = localString("BOOKDETAIL_TITLE")
        cell.descriText?.text = bookTitle
        return cell
      } else {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailInfoCell") as! BookDetailInfoCell
        cell.titleLabel?.text = localString("BOOKDETAIL_DESCRIPTION")
        cell.tableView = tableView
        cell.descriText?.text = bookDescription
        return cell
      }
      
    } else {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
      cell.titleLabel?.text = localString("BOOKDETAIL_BACKGROUND")
      //            cell.iconImageView?.image = background
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = indexPath.section
    let row = indexPath.row
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if section == 0 {
      
      if row == 2{
        
        if let aInputVC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextInputViewController") as? TextInputViewController {
          aInputVC.text = bookModel.desc
          aInputVC.title = localString("BOOKDETAIL_DESCRIPTION")
          aInputVC.ID = "Description"
          aInputVC.type = "Content"
          aInputVC.delegate = self
          navigationController?.pushViewController(aInputVC, animated: true)
        }
      } else if row == 1 {
        if let aInputVC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextInputViewController") as? TextInputViewController {
          aInputVC.text = bookModel.title
          aInputVC.title = localString("BOOKDETAIL_TITLE")
          aInputVC.type = "Title"
          aInputVC.ID = "Title"
          aInputVC.delegate = self
          navigationController?.pushViewController(aInputVC, animated: true)
        }
      } else if row == 0 {
        
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: { imageP in
          
        })
      }
    }
  }
  
  func textInputViewControllerTextDidEnd(inputViewController: TextInputViewController, text: String) {
    
    if inputViewController.ID == "Description" {
      bookModel.desc = text
    } else if inputViewController.ID == "Title" {
      bookModel.title = text
    }
    
    tableView.reloadData()
  }
}

extension BookDetailViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
//    let imageData = UIImagePNGRepresentation(selectedImage)
    KingfisherManager.sharedManager.cache.storeImage(selectedImage, forKey: iconKey)
    bookModel.icon = iconKey
    needuploadIcon = true
    tableView.reloadData()
    dismissViewControllerAnimated(true, completion: nil)
  }
}
