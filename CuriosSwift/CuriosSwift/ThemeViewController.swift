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

protocol ThemeViewControllerDelegate: NSObjectProtocol {
  
  func viewController(controller: UIViewController, aNeedRefresh: Bool)
}

class ThemeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var titleText: UIBarButtonItem!
  
  weak var delegate: ThemeViewControllerDelegate?
  
  var defaultLayout: UICollectionViewFlowLayout {
    
    let layout = ThemeLayout()
    layout.scrollDirection = .Horizontal
    let width = collectionView.bounds.width
    let height = collectionView.bounds.height
//    let top = height * 0
//    let bottom = height * 0.1
    let top: CGFloat = 64.0 + 44.0 + 10.0
    let bottom: CGFloat = 64.0 + 44.0 + 10.0
    let itemHeight: CGFloat = height - top - bottom - 44.0
    let ss = ceil(itemHeight * 640.0 / 1008.0)
    let itemWidth: CGFloat = ss
    debugPrint.p("itemWidth = \(itemWidth)")
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
      
      collectionView.decelerationRate = UIScrollViewDecelerationRateFast
      collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "themeCell")
      
      if ThemesManager.shareInstance.getThemeList().count <= 0 {
        ThemesManager.shareInstance.getThemes(0, size: 20) { [unowned self](themes) -> () in
          
          //          self.appThemes(themes)
          self.collectionView.reloadData()
          debugPrint.p("contentSize = \(self.collectionView.contentSize)")
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
  
  override func viewDidAppear(animated: Bool) {
    
    self.setupbackgroundImage()
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
    
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
    
    debugPrint.p("contentSize = \(self.collectionView.contentSize)")
    return ThemesManager.shareInstance.getThemeList().count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("themeCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    if cell.backgroundView == nil {
      let imageView = UIImageView(frame: cell.bounds)
      imageView.contentMode = .ScaleAspectFill
      imageView.clipsToBounds = true
      cell.backgroundView = imageView
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
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
//    scrollView.bounds.origin = CGPointZero
//    debugPrint.p(scrollView.bounds.origin)
    
    setupbackgroundImage()
    
  }
  
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
      let image = backgroundImageView.image
      
      backgroundImageView.kf_setImageWithURL(url, placeholderImage: image, optionsInfo: nil, completionHandler: { [weak self](image, error, cacheType, imageURL) -> () in
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          
          self?.backgroundImageView.alpha = 0.5
          }, completion: { (finished) -> Void in
        })
        
//        self?.backgroundImageView.image = image
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
          
          self?.backgroundImageView.alpha = 1
          }, completion: { (finished) -> Void in
            
            if finished {
              snapshot.removeFromSuperview()
            }
        })
        
        })
    }
  }
}

// MARK: - IBAction
// MARK: -
extension ThemeViewController {
  
  @IBAction func createBook(sender: AnyObject) {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      let theme = ThemesManager.shareInstance.getThemeList()[currentIndexPath.item]
      let themeID = theme.themeID
      let themeURL = theme.themeURL
      
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
            self.createANewBookWithPageModel(pagemodel, begainThemeID: themeID , bookAttribute: bookAttribute)
          })
        }
      })
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
//         debugPrint.p(JSON)
//        if (error == nil)
//        {
//          
//          if let jsondic = JSON as? [NSObject : AnyObject] {
//            
//            debugPrint.p(jsondic)
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
    
    createBook(sender)
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
  
  func createANewBookWithPageModel(pageModel: PageModel, begainThemeID: String? ,bookAttribute: [String: AnyObject]?) {
    
    PublishIDRequest.requestWithComponents(GET_PUBLISH_ID, aJsonParameter: nil) {[unowned self] (json) -> Void in
      
      if let newID = json["newID"] as? String {
        
        self.getBookWithBookID(newID) {[unowned self] (aBookModel) -> () in
          
          aBookModel.insertPageModelsAtIndex([pageModel], FromIndex: 0)
          aBookModel.resetNeedAddFile()
          aBookModel.resetNeedUpload()
//          aBookModel.pageModels.append(pageModel)
          if let attributes = bookAttribute {
            self.configBookModel(aBookModel, attribute: attributes)
          }
          self.showEditViewControllerWithBook(aBookModel, begainThemeID: begainThemeID,isUploaded: false)
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
