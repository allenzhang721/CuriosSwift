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
  
  var bookIconUrlString: String {
    
    get {
      let icon = bookModel.icon
      return HOST.stringByAppendingString(icon)
    }
    
  }
  
  var iconKey: String {
    
    get {
      let userID = UsersManager.shareInstance.getUserID()
      let publishID = bookModel.Id
      let icon = "icon.png"
      let path = pathByComponents([userID, publishID, icon])
      return path
    }
  }
  
  var iconKeyUrl: String {
    
    get {
      return HOST.stringByAppendingString(iconKey)
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
    
    let iconURL = NSURL(string: bookIconUrlString)!
    
    debugPrint.p("bookIconUrlString = \(bookIconUrlString)")
    
    KingfisherManager.sharedManager.retrieveImageWithURL(iconURL, optionsInfo: .None, progressBlock: nil) {[weak self] (image, error, cacheType, imageURL) -> () in
      if error != nil {
        println(error)
      } else {
//        KingfisherManager.sharedManager.cache.storeImage(image!, forKey: aIconKey)
        self?.tableView.reloadData()
      }
    }
  }
  
  
  // show Sheet
  private func showsheet() {
    
    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    if (UIImagePickerController.availableMediaTypesForSourceType(.Camera) != nil) {
      
      let string = localString("CAMERA")
      let CameraAction = UIAlertAction(title: string, style: .Default) { (action) -> Void in
        
        self.showImagePicker(.Camera)
      }
      sheet.addAction(CameraAction)
    }
    
    let libarayString = localString("LIBARAY")
    let LibarayAction = UIAlertAction(title: libarayString, style: .Default) { (action) -> Void in
      
      self.showImagePicker(.PhotoLibrary)
    }
    
    let cancel = localString("CANCEL")
    let CancelAction = UIAlertAction(title: cancel, style: .Cancel) { (action) -> Void in
      
    }
    
    sheet.addAction(LibarayAction)
    sheet.addAction(CancelAction)
    presentViewController(sheet, animated: true, completion: nil)
  }
  
  // show Image Picker
  private func showImagePicker(type: UIImagePickerControllerSourceType) {
    
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = type
    imagePicker.delegate = self
        imagePicker.allowsEditing = true
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  
  
  @IBAction func backAction(sender: UIBarButtonItem) {
    
    if needuploadIcon {
      KingfisherManager.sharedManager.cache.retrieveImageForKey(iconKeyUrl, options: KingfisherManager.DefaultOptions, completionHandler: { [weak self] (image, cacheType) -> () in
        
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
    
//    BOOKDETAIL_ICON              = "图标";
//    BOOKDETAIL_TITLE             = "标题";
//    BOOKDETAIL_DESCRIPTION       = "简介";
    let section = indexPath.section
    let row = indexPath.row
    
    if section == 0 {
      if row == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
        cell.titleLabel?.text = localString("BOOKDETAIL_ICON")
        KingfisherManager.sharedManager.cache.retrieveImageForKey(bookIconUrlString, options: KingfisherManager.DefaultOptions) {[unowned self] (image, type) -> () in
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
        showsheet()
      }
    }
  }
  
  func textInputViewControllerTextDidEnd(inputViewController: TextInputViewController, text: String) {
    
    if inputViewController.ID == "Description" {
      bookModel.setBookDescription(text)
    } else if inputViewController.ID == "Title" {
      bookModel.setBookTitle(text)
    }
    
    tableView.reloadData()
  }
}

extension BookDetailViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
//    let imageData = UIImagePNGRepresentation(selectedImage)
    
//    debugPrint.p("bookModel = \(bookModel)")
    KingfisherManager.sharedManager.cache.removeImageForKey(bookIconUrlString)
    bookModel.setBookIcon(iconKey)
//    debugPrint.p("iconKeyUrl = \(iconKeyUrl)")
    KingfisherManager.sharedManager.cache.storeImage(selectedImage, forKey: iconKeyUrl)
    needuploadIcon = true
    tableView.reloadData()
    dismissViewControllerAnimated(true, completion: nil)
  }
}
