//
//  EditTemplateViewController.swift
//
//
//  Created by Emiaostein on 7/19/15.
//
//

import UIKit
import Kingfisher

class EditTemplateViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var defaultLayout: UICollectionViewFlowLayout! {
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    let width = view.bounds.width
    let height = view.bounds.height
    let top = height * 0.1
    let bottom = height * 0.1
    let itemHeight = height * 0.35
    let itemWidth = width * 0.4
    let left = width * 0.3
    let right = left
    
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    
    return layout
  }
  
  var themeID: String!
  var templateList = [TemplateModel]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "TemplateCell")
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
    view.bringSubviewToFront(collectionView)
    
    println(themeID)
    TemplatesManager.shareInstance.getTemplates(themeID, start: 0, size: 20) {[unowned self] (aTemplates) -> () in
      
      self.appendTemplates(aTemplates)
      self.collectionView.reloadData()
    }
    
  }
  
  func appendTemplates(aTemplates: [TemplateModel]) {
    
    if aTemplates.count <= 0 {
      return
    }
    
    for template in aTemplates {
      println(template.templateURL)
      templateList.append(template)
    }
  }

  @IBAction func tapAction(sender: UITapGestureRecognizer) {
    navigationController?.popToRootViewControllerAnimated(true)
  }
  
  
  
  func begainResponseToLongPress(onScreenPoint: CGPoint) {
    
    if let indexPath = collectionView.indexPathForItemAtPoint(onScreenPoint) {
      
      let template = templateList[indexPath.item].templateURL
      let URL = NSURL(string: template)!
      EMJsonManager.sharedManager.retrieveJsonWithURL(URL, progressBlock: nil, completionHandler: {[unowned self] (Json, error, cacheType, jsonURL) -> () in
        
        if let Json: AnyObject = Json {
          if let navigationVC = self.navigationController as? EditNavigationViewController {
            
            navigationVC.editDelegate?.navigationViewController(navigationVC, didGetTemplateJson: Json)
          }
        }
      })
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
    
    cell.backgroundColor = UIColor.darkGrayColor()
    
    if let imageView = cell.backgroundView as? UIImageView {

      imageView.alpha = 0
      
      let url = NSURL(string: "http://img2.pconline.com.cn/pconline/1008/10/2190575_010_500.jpg")!
      imageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
        
        imageView.image = image
        UIView.animateWithDuration(0.3, animations: { () -> Void in
        imageView.alpha = 1
        })
      })
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    navigationController?.popToRootViewControllerAnimated(true)
    
  }
}
