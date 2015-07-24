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

class ThemeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var titleText: UIBarButtonItem!
  
  
  var defaultLayout: UICollectionViewFlowLayout {
    
    let layout = ThemeLayout()
    layout.scrollDirection = .Horizontal
    let width = view.bounds.width
    let height = view.bounds.height
    let top = height * 0
    let bottom = height * 0.1
    let itemHeight = height * 0.6
    let itemWidth = width * 0.6
    let left = width * 0.2
    let right = left
    let lineMin: CGFloat = 50.0
    
    layout.minimumLineSpacing = lineMin
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    
    return layout
  }
  
  var themeList = [ThemeModel]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "themeCell")
      collectionView.decelerationRate = 0.1
      collectionView.setCollectionViewLayout(defaultLayout, animated: false)

      ThemesManager.shareInstance.getThemes(0, size: 20) { [weak self](themes) -> () in
        
        self?.appThemes(themes)
        self?.collectionView.reloadData()
        self?.setupbackgroundImage()
      }
    }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  @IBAction func backAction(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - DataSource and Delegate
// MARK: -
extension ThemeViewController {
  
  // MARK: - CollectionView DataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return themeList.count
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
      
      let theme = themeList[indexPath.item]
      let url = NSURL(string: "http://img5.imgtn.bdimg.com/it/u=4088850196,318519569&fm=21&gp=0.jpg")
      
      imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "cover"), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
        
        imageView.image = image
      })
    }

    return cell
  }
  
  // MARK: - CollectionView Delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let themeID = themeList[indexPath.item].themeID
    
    TemplatesManager.shareInstance.getTemplates(themeID, start: 0, size: 1) {[unowned self] (templates) -> () in
      if templates.count <= 0 {
        return
      }
      let templateURL = templates[0].templateURL
        
        let url = NSURL(string: templateURL)!
      
      // Fetch Request
      Alamofire.request(.POST, url, parameters: nil)
        .validate(statusCode: 200..<300)
        .responseJSON{ (request, response, JSON, error) in
          if (error == nil)
          {
            
            if let jsondic = JSON as? [NSObject : AnyObject] {
              
              let pageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: jsondic as [NSObject : AnyObject] , error: nil) as! PageModel
              
              // change Page ID
              pageModel.Id = UniqueIDStringWithCount(count: 8)
              self.createANewBookWithPageModel(pageModel)
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
  }
  
  
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
    setupbackgroundImage()
    
  }
  
  func setupbackgroundImage() {
    
    if let indexPath = getCurrentIndexPath() {
      
      let theme = themeList[indexPath.item]
      let urls = ["http://img4.imgtn.bdimg.com/it/u=3984889015,3579614857&fm=21&gp=0.jpg", "http://img5.imgtn.bdimg.com/it/u=4088850196,318519569&fm=21&gp=1.jpg"]
      let string = urls[indexPath.item % 2]
      let url = NSURL(string: string)!
      
      titleText.title = theme.themeName
      
      let snapshot = backgroundImageView.snapshotViewAfterScreenUpdates(false)
      view.insertSubview(snapshot, belowSubview: backgroundImageView)
      //      backgroundImageView.alpha = 0
      
      backgroundImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil, completionHandler: { [weak self](image, error, cacheType, imageURL) -> () in
        
        self?.backgroundImageView.alpha = 0
        self?.backgroundImageView.image = image
        
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
  
  @IBAction func createBook(sender: UIBarButtonItem) {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      let themeID = themeList[currentIndexPath.item].themeID
      
      TemplatesManager.shareInstance.getTemplates(themeID, start: 0, size: 1) {[unowned self] (templates) -> () in
        if templates.count <= 0 {
          return
        }
        let templateURL = templates[0].templateURL
        
        let url = NSURL(string: templateURL)!
        
        // Fetch Request
        Alamofire.request(.POST, url, parameters: nil)
          .validate(statusCode: 200..<300)
          .responseJSON{ (request, response, JSON, error) in
            if (error == nil)
            {
              
              if let jsondic = JSON as? [NSObject : AnyObject] {
                
                let pageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: jsondic as [NSObject : AnyObject] , error: nil) as! PageModel
                
                self.createANewBookWithPageModel(pageModel)
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
  
  func createANewBookWithPageModel(pageModel: PageModel) {
    
    PublishIDRequest.requestWithComponents(getPublishID, aJsonParameter: nil) {[unowned self] (json) -> Void in
      
      if let newID = json["newID"] as? String {
        
        self.getBookWithBookID(newID) {[unowned self] (aBookModel) -> () in
          
          aBookModel.pageModels.append(pageModel)
          self.showEditViewControllerWithBook(aBookModel)
        }
      }
    }.sendRequest()
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
