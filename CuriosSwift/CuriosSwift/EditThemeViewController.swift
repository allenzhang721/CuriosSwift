//
//  EditThemeViewController.swift
//  
//
//  Created by Emiaostein on 7/19/15.
//
//

import UIKit
import Kingfisher

class EditThemeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate {

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
  
  var themeList = [ThemeModel]()
  
  @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      navigationController?.delegate = self
      collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
      collectionView.setCollectionViewLayout(defaultLayout, animated: false)
      
      ThemesManager.shareInstance.getThemes(0, size: 20) { [unowned self](themes) -> () in
        
        self.appThemes(themes)
        self.collectionView.reloadData()
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

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EditThemeViewController {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return themeList.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
    
    if cell.backgroundView == nil {
      cell.backgroundView = UIImageView(frame: cell.bounds)
    }
    
    if let imageView = cell.backgroundView as? UIImageView {
      
      let themeItem = themeList[indexPath.item]
      let url = NSURL(string: "http://img5.imgtn.bdimg.com/it/u=4088850196,318519569&fm=21&gp=0.jpg")!
      imageView.kf_setImageWithURL(url)
      
    }
    return cell
  }
  
  // delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let template = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditTemplateViewController") as! EditTemplateViewController
    
    let themeID = themeList[indexPath.item].themeID
    template.themeID = themeID
    
    navigationController?.pushViewController(template, animated: true)

  }
  
  func getSelectedOriginFrame() -> CGRect {
    
    let selectedIndex = collectionView.indexPathsForSelectedItems().first as! NSIndexPath
    let cell = collectionView.cellForItemAtIndexPath(selectedIndex)!
    let frame = collectionView.convertRect(cell.frame, toView: view)
    
    return frame
  }
  
  func getSelectedSnapshot() -> UIView {
    
    let selectedIndex = collectionView.indexPathsForSelectedItems().first as! NSIndexPath
    let cell = collectionView.cellForItemAtIndexPath(selectedIndex)!
    let snapshot = cell.snapshotViewAfterScreenUpdates(true)
    let frame = collectionView.convertRect(cell.frame, toView: view)
    snapshot.frame = frame
    
    return snapshot
  }
  
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if fromVC is EditThemeViewController {
      return EditNaviAimation(presended: true)
    } else {
      return EditNaviAimation(presended: false)
    }
  }
}
