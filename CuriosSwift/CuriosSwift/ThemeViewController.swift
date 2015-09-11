//
//  ThemeViewController.swift
//  
//
//  Created by Emiaostein on 7/14/15.
//
//

import UIKit
import Mantle
import Alamofire
import ReachabilitySwift
import Kingfisher

protocol ThemeViewControllerDelegate: NSObjectProtocol {
  
  func viewController(controller: UIViewController, aNeedRefresh: Bool)
}

class ThemeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var titleText: UIBarButtonItem!
  
  let reachability = Reachability.reachabilityForInternetConnection()
  weak var delegate: ThemeViewControllerDelegate?
  
  var defaultLayout: UICollectionViewFlowLayout {
    
    let layout = ThemeLayout()
    layout.scrollDirection = .Horizontal
    let width = collectionView.bounds.width
    let height = collectionView.bounds.height
//    let top = height * 0
//    let bottom = height * 0.1
    let top: CGFloat = 64.0 + 44.0 + 10.0
    let bottom: CGFloat = 64.0 + 44.0 + 5.0
    let itemHeight: CGFloat = height - top - bottom - 44.0
    let ss = ceil(itemHeight * 640.0 / 1008.0)
    let itemWidth: CGFloat = ss
    let left = (width - itemWidth) / 2.0
    let right = left
    let lineMin: CGFloat = 50.0
    
    layout.minimumLineSpacing = lineMin
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.scrollDirection = .Horizontal
    
    return layout
  }
  
  var themeList = [ThemeModel]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
//      navigationController?.navigationBarHidden = true
      
      HUD.save_sync()
      ServePathsManger.getServePaths { [unowned self] (compeleted) -> () in
        
        if compeleted {
          HUD.dismiss(0.5)
        }
      }  //
      
      collectionView.decelerationRate = UIScrollViewDecelerationRateFast
      collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "themeCell")
      
      if ThemesManager.shareInstance.getThemeList().count <= 0 {
        ThemesManager.shareInstance.getThemes(0, size: 20) { [unowned self](themes) -> () in
          
          //          self.appThemes(themes)
          self.collectionView.reloadData()
          self.setupbackgroundImage()
        }
      } else {
      }

//      ThemesManager.shareInstance.getThemes(0, size: 20) { [weak self](themes) -> () in
//        
//        self?.appThemes(themes)
//        self?.collectionView.reloadData()
//        
//      }
    }
  
  var demoTheme: ThemeModel {
    return ThemesManager.shareInstance.getThemeList()[0]
  }
  
  override func viewDidAppear(animated: Bool) {
    
    self.setupbackgroundImage()
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
    updateSelectBorder()
    
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  @IBAction func backAction(sender: UIBarButtonItem) {
    
    delegate?.viewController(self, aNeedRefresh: false)
    navigationController?.popToRootViewControllerAnimated(true)
  }
}

// MARK: - DataSource and Delegate
// MARK: -
extension ThemeViewController {
  
  // MARK: - CollectionView DataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return ThemesManager.shareInstance.getThemeList().count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("themeCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    if cell.backgroundView == nil {
      let imageView = UIImageView(frame: cell.bounds)
      imageView.contentMode = .ScaleAspectFill
      imageView.clipsToBounds = true
      cell.backgroundView = imageView
      imageView.backgroundColor = UIColor.whiteColor()
      imageView.layer.cornerRadius = 8.0
      cell.layer.borderWidth = 0.5
      cell.layer.cornerRadius = 8.0
      cell.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2).CGColor
//      cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 8).CGPath
      cell.layer.shadowColor = UIColor.darkGrayColor().CGColor
      cell.layer.shadowOffset = CGSize(width: 0, height: 1)
      cell.layer.shadowOpacity = 0.5
      cell.layer.shadowRadius = 0.5
    }
    
    if let imageView = cell.backgroundView as? UIImageView {
      
      let theme = ThemesManager.shareInstance.getThemeList()[indexPath.item]
//      let url = NSURL(string: "http://img5.imgtn.bdimg.com/it/u=4088850196,318519569&fm=21&gp=0.jpg")
      let url = NSURL(string: theme.themeIconURL)
      
      imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "cover"), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
        
        imageView.image = image
      })
    }
    return cell
  }
  
  // MARK: - CollectionView Delegate
  
//  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//    
////    scrollView.bounds.origin = CGPointZero
//    
//    setupbackgroundImage()
//    
//  }
  
  func setupbackgroundImage() {
    
    if let indexPath = getCurrentIndexPath() {
      
      let theme = ThemesManager.shareInstance.getThemeList()[indexPath.item]
//      let urls = ["http://img4.imgtn.bdimg.com/it/u=3984889015,3579614857&fm=21&gp=0.jpg", "http://img5.imgtn.bdimg.com/it/u=4088850196,318519569&fm=21&gp=1.jpg"]
//      let string = urls[indexPath.item % 2]
      let url = NSURL(string: theme.themeIconURL)!
      
      titleText.title = theme.themeName
      
      let snapshot = backgroundImageView.snapshotViewAfterScreenUpdates(false)
      view.insertSubview(snapshot, belowSubview: backgroundImageView)
      //      backgroundImageView.alpha = 0

      
//      backgroundImageView.layer.contents =
      
        KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
          
//          self.backgroundImageView.layer.contents = (image as! CGImageRef)
          if error == nil {
            let transition = CATransition()
            
            transition.startProgress = 0.0
            transition.endProgress = 1.0
            transition.duration = 0.4
            
            self.backgroundImageView.layer.contents = image!.CGImage
            self.backgroundImageView.layer.addAnimation(transition, forKey: "contents")
          }
          
          

        })
      
      
      
//      backgroundImageView.kf_setImageWithURL(url, placeholderImage: image, optionsInfo: nil, completionHandler: { [weak self](image, error, cacheType, imageURL) -> () in
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//          
//          self?.backgroundImageView.alpha = 0.5
//          }, completion: { (finished) -> Void in
//        })
//        
////        self?.backgroundImageView.image = image
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//          
//          self?.backgroundImageView.alpha = 1
//          }, completion: { (finished) -> Void in
//            
//            if finished {
//              snapshot.removeFromSuperview()
//            }
//        })
//        
//        })
    }
  }
  
  // MARK: - ScrollView Delegate
  func resetSeletctBorder() {
    
    if let indexPath = getCurrentIndexPath() {
      let cells = collectionView.visibleCells() as! [UICollectionViewCell]
      
      for cell in cells {
        cell.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2).CGColor
      }
    }
  }
  
  func updateSelectBorder() {
    if let indexPath = getCurrentIndexPath() {
      let cells = collectionView.visibleCells() as! [UICollectionViewCell]
      
      for cell in cells {
        
        if let aIndexPath = collectionView.indexPathForCell(cell) where aIndexPath.compare(indexPath) == .OrderedSame {
          cell.layer.borderColor = UIColor.blueColor().colorWithAlphaComponent(0.2).CGColor
        } else {
          cell.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2).CGColor
        }
      }
    }
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    resetSeletctBorder()
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
    updateSelectBorder()
    setupbackgroundImage()
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    
    updateSelectBorder()
    setupbackgroundImage()
  }
}

// MARK: - IBAction
// MARK: -
extension ThemeViewController {
  
  @IBAction func createBook(sender: AnyObject?) {
    
    if reachability.currentReachabilityStatus == .NotReachable {
      self.needConnectNet()
    } else if reachability.currentReachabilityStatus != .ReachableViaWiFi  {
      let alert = AlertHelper.alert_internetconnection {[unowned self] (confirmed) -> () in
        
        if confirmed {
          self.createBook()
        }
      }
      presentViewController(alert, animated: true, completion: nil)
    } else {
      self.createBook()
    }
  }
  
  func retriveThemeStyle(themeURL: String, completed: ([String:AnyObject]) -> ()) {
    
    let url = NSURL(string: themeURL)!
    
    BlackCatManager.sharedManager.retrieveDataWithURL(url, optionsInfo: nil, progressBlock: nil) { (data, error, cacheType, URL) -> () in
      
      
        if let dic = Dictionary<NSObject, AnyObject>.converFromData(data).0 as? [String: AnyObject] {
            completed(dic)
        }
    }
    
    // Fetch Request
//    Alamofire.request(.POST, url, parameters: nil)
//      .validate(statusCode: 200..<300)
//      .responseJSON{ (request, response, JSON, error) in
//
//        if (error == nil)
//        {
//          
//          if let jsondic = JSON as? [NSObject : AnyObject] {
//            
////            let pageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: jsondic as [NSObject : AnyObject] , error: nil) as! PageModel
////            pageModel.Id = UniqueIDStringWithCount(count: 8)
////            self.createANewBookWithPageModel(pageModel, bookAttribute: nil)
//          }
//        }
//        else
//        {
//          if let aError = error{
//            
//          }
//          println("HTTP HTTP Request failed: \(error)")
//        }
//    }
  }
  
  func retriveFirstTemplatePage(templateURL: String, completed: (PageModel) -> ()) {
    
    let url = NSURL(string: templateURL)!
    // Fetch Request
    Alamofire.request(.POST, url, parameters: nil)
      .validate(statusCode: 200..<300)
      .responseJSON{ (request, response, JSON, error) in
        if (error == nil)
        {
          
          if let jsondic = JSON as? [NSObject : AnyObject] {
            
            let pageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: jsondic as [NSObject : AnyObject] , error: nil) as! PageModel
            pageModel.Id = UniqueIDStringWithCount(count: 8)
            completed(pageModel)
//            self.createANewBookWithPageModel(pageModel, bookAttribute: nil)
          }
        }
        else
        {
          if let aError = error{
            
          }
          println("HTTP HTTP Request failed: \(error)")
        }
    }
    
  }
  
  @IBAction func doubleTapAction(sender: UITapGestureRecognizer) {
    
//    createBook(sender)
    
    if reachability.currentReachabilityStatus == .NotReachable {
      self.needConnectNet()
    } else if reachability.currentReachabilityStatus != .ReachableViaWiFi  {
      let alert = AlertHelper.alert_internetconnection {[unowned self] (confirmed) -> () in
        
        if confirmed {
          self.createBook()
        }
      }
      presentViewController(alert, animated: true, completion: nil)
    } else {
      self.createBook()
    }
  }
  
  func needConnectNet() {
    
    let alert = AlertHelper.alert_needConnected()
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func createBook() {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      let theme = ThemesManager.shareInstance.getThemeList()[currentIndexPath.item]
      let themeID = theme.themeID
      let themeURL = theme.themeURL
      
      HUD.editor_creating()
      // 1. theme Style
      retriveThemeStyle(themeURL, completed: { [unowned self] (bookAttribute) -> () in
        
        
        
        // 2. templateURL
        TemplatesManager.shareInstance.getTemplates(themeID, start: 0, size: 1) {[unowned self] (templates) -> () in
          if templates.count <= 0 {
            return
          }
          
          let templateURL = templates[0].templateURL
          
          // 3. first template
          self.retriveFirstTemplatePage(templateURL, completed: {[unowned self] (pagemodel) -> () in
            
            // 4. create a new book
            self.createANewBookWithPageModel(pagemodel, begainThemeID: themeID , bookAttribute: bookAttribute) { () -> Void in
              
              HUD.dismiss()
            }
            })
        }
        })
    }
  }

  
  @IBAction func cancelAction(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
}













// MARK: - Private Method
// MARK: -
extension ThemeViewController {
  
  // Current Indexpath
  private func getCurrentIndexPath() -> NSIndexPath? {
    let offsetMiddleX = collectionView.contentOffset.x + CGRectGetWidth(collectionView.bounds) / 2.0
    let offsetMiddleY = CGRectGetHeight(collectionView.bounds) / 2.0
    return collectionView.indexPathForItemAtPoint(CGPoint(x: offsetMiddleX, y: offsetMiddleY))
  }
  
  func createANewBookWithPageModel(pageModel: PageModel, begainThemeID: String? ,bookAttribute: [String: AnyObject]?, completed: (() -> Void)?) {
    
    let userID = UsersManager.shareInstance.getUserID()
    PublishIDRequest.requestWithComponents(GET_PUBLISH_ID, aJsonParameter: nil) {[unowned self] (json) -> Void in
      
      if let newID = json["newID"] as? String {
        
        self.getBookWithBookID(newID) {[unowned self] (aBookModel) -> () in
          
          aBookModel.insertPageModelsAtIndex([pageModel], FromIndex: 0)
          
          aBookModel.resetNeedAddFile()
          aBookModel.resetNeedUpload()
//          aBookModel.pageModels.append(pageModel)
          if let attributes = bookAttribute {
            self.configBookModel(aBookModel, attribute: attributes)
            aBookModel.authorID = userID
          }
          self.showEditViewControllerWithBook(aBookModel, begainThemeID: begainThemeID,isUploaded: false)
          completed?()
        }
      }
    }.sendRequest()
  }
  
  func configBookModel(book: BookModel, attribute: [String: AnyObject]) {
    //["FlipLoop": false, "MainBackgroundAlpha": 1, "MainBackgroundColor": 255,255,255, "FlipType": translate3d, "MainTitle": 青春的回忆, "FlipDirection": ver, "MainDesc": 在那美好的年代，有那美好的记忆, "MainMusic": ])
    
    if let fliploop = attribute["FlipLoop"] as? String {
      book.flipLoop = fliploop
    }
    
    if let value = attribute["MainBackgroundAlpha"] as? CGFloat {
      book.mainbackgroundAlpha = value
    }
    
    if let value = attribute["MainBackgroundColor"] as? String {
      book.mainbackgroundColor = value
    }
    
    if let value = attribute["MainTitle"] as? String {
      book.title = value
    }
    
    if let value = attribute["MainDesc"] as? String {
      book.desc = value
    }
    
    if let value = attribute["MainMusic"] as? String {
      book.mainMusic = value
    }
    
    if let type = attribute["FlipType"] as? String {
      switch type {
        case "translate3d":
        book.flipType = .translate3d
      default:
        ()
      }
    }
    
    if let type = attribute["FlipDirection"] as? String {
      switch type {
      case "ver":
        book.flipDirection = .ver
        case "hor":
        book.flipDirection = .hor
      default:
        ()
      }
    }
    
    
  }
  
  func appThemes(themes: [ThemeModel]) {
    
    if themes.count <= 0 {
      return
    }
    
    for theme in themes {
      themeList.append(theme)
    }
  }
}
