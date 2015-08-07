//
//  EditTemplateViewController.swift
//
//
//  Created by Emiaostein on 7/19/15.
//
//

import UIKit
import Kingfisher

class EditTemplateViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var titleText: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var defaultLayout: UICollectionViewFlowLayout! {
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    let width = view.bounds.width
    let height = view.bounds.height
    let top = height * 0.1
    let bottom = height * 0.1
    let itemHeight = height * 0.45
    let itemWidth = width * 0.5
    let left = width * 0.25
    let right = left
    
    let lineSpace: CGFloat = 20.0
    
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumLineSpacing = lineSpace
    
    return layout
  }
  
  var themeID: String!
  var templateList = [TemplateModel]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleText.title = title

    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "TemplateCell")
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
    view.bringSubviewToFront(collectionView)
    view.bringSubviewToFront(toolBar)
    TemplatesManager.shareInstance.getTemplates(themeID, start: 0, size: 20) {[weak self] (aTemplates) -> () in
      
      self?.appendTemplates(aTemplates)
      self?.collectionView.reloadData()
    }
    
  }
  
  @IBAction func backAction(sender: UIBarButtonItem) {
    
    
    
    navigationController?.popToRootViewControllerAnimated(true)
    
  }
  func appendTemplates(aTemplates: [TemplateModel]) {
    
    if aTemplates.count <= 0 {
      return
    }
    
    for template in aTemplates {
      templateList.append(template)
    }
  }

  func begainResponseToLongPress(onScreenPoint: CGPoint) {
    
    let offset = collectionView.contentOffset
    let point = CGPoint(x: offset.x + onScreenPoint.x, y: offset.y + onScreenPoint.y)
    if let indexPath = collectionView.indexPathForItemAtPoint(point) {
      let cell = collectionView.cellForItemAtIndexPath(indexPath)
      let snapshot = cell!.snapshotViewAfterScreenUpdates(true)
      snapshot.transform = CGAffineTransformMakeScale(0.7, 0.7)
      
      
      let template = templateList[indexPath.item]
      if let json = template.retrivePageModel() {
        if let navigationVC = self.navigationController as? EditNavigationViewController {
          navigationVC.didSelectedBlock?(snapshot, json)
        }
      } else {
        return
      }
      
      
      
//      let template = templateList[indexPath.item].templateURL
//      let URL = NSURL(string: template)!
//      
//      debugPrint.p(URL)
//      
//      BlackCatManager.sharedManager.retrieveDataWithURL(URL, optionsInfo: nil, progressBlock: nil, completionHandler: {[unowned self] (data, error, cacheType, URL) -> () in
//        
//        
//        if let dic = Dictionary<NSObject, AnyObject>.converFromData(data).0 {
//          
//          
//        }
//        if let dic = PageModel.converFromData(data).0 {
//          debugPrint.p(dic)
//        }
        
//      })
      
//      EMJsonManager.sharedManager.retrieveJsonWithURL(URL, progressBlock: nil, completionHandler: {[unowned self] (Json, error, cacheType, jsonURL) -> () in
//        
//        if let Json: AnyObject = Json {
//          if let navigationVC = self.navigationController as? EditNavigationViewController {

//            navigationVC.editDelegate?.navigationViewController(navigationVC, didGetTemplateJson: Json)
//          }
//        }
//      })
    }
  }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EditTemplateViewController {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return templateList.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TemplateCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    if cell.backgroundView == nil {
      cell.backgroundView = UIImageView(frame: cell.bounds)
      
      cell.backgroundView!.layer.shadowRadius = 1
      cell.backgroundView!.layer.shadowOpacity = 0.5
      cell.backgroundView!.layer.shadowPath = UIBezierPath(rect: cell.bounds).CGPath
      cell.backgroundView!.layer.shadowOffset = CGSize(width: 1, height: 1)
      cell.backgroundView!.layer.shadowColor = UIColor.darkGrayColor().CGColor
    }
    
    let template = templateList[indexPath.item]
    template.retrivePageModel()
    
    if let imageView = cell.backgroundView as? UIImageView {

//      imageView.alpha = 0
      
//      let url = NSURL(string: "http://img2.pconline.com.cn/pconline/1008/10/2190575_010_500.jpg")!
       let url = NSURL(string: template.templateIconURL)!
      imageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "cover"), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
        
//        imageView.image = image
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//        imageView.alpha = 1
//        })
      })
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
//    navigationController?.popToRootViewControllerAnimated(true)
  }
}
