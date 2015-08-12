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
  
  var themeList = [ThemeModel]()
  
  var selectedIndex: NSIndexPath!
  var begainThemeID: String?
  var enteredTheme = false
  var begainIndex: NSIndexPath?
  
  @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      if let themeID = begainThemeID {
        
        let themes = ThemesManager.shareInstance.getThemeList()
        
        var aIndex = -1
        for (index,theme) in enumerate(themes) {
          if themeID == theme.themeID {
            aIndex = index
            break
          }
        }
        if aIndex != -1 {
          
          let theme = ThemesManager.shareInstance.getThemeList()[aIndex]
          let indexpath = NSIndexPath(forItem: aIndex, inSection: 0)
          begainIndex = NSIndexPath(forItem: aIndex, inSection: 0)
          
          
          //        let themeID = theme.themeID
          //        let themeName = theme.themeName
          //        showTemplatesWithThemeID(themeID, themeName: themeName)
        }
      }
      
      
      navigationController?.delegate = self
      collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
      collectionView.setCollectionViewLayout(defaultLayout, animated: false)
      
      if ThemesManager.shareInstance.getThemeList().count <= 0 {
        ThemesManager.shareInstance.getThemes(0, size: 20) { [unowned self](themes) -> () in
          
//          self.appThemes(themes)
          self.collectionView.reloadData()
        }
      } else {
      }
    }
  
  override func viewDidAppear(animated: Bool) {
    
    super.viewDidAppear(animated)
    
    if let bindex = begainIndex where enteredTheme == false {
      collectionView.scrollToItemAtIndexPath(bindex, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
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
    
    return ThemesManager.shareInstance.getThemeList().count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
    
    if cell.backgroundView == nil {
      cell.backgroundView = UIImageView(frame: cell.bounds)
      
      let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: cell.bounds.height + 0), size: CGSize(width: cell.bounds.width, height: 30)))
      label.tag = 100
      label.text = "sdfsdf"
      label.textAlignment = .Center
      cell.contentView.addSubview(label)
      cell.clipsToBounds = false
    }
    
    let themeItem = ThemesManager.shareInstance.getThemeList()[indexPath.item]
    let themeID = themeItem.themeID
    let themeName = themeItem.themeName
    if let imageView = cell.backgroundView as? UIImageView {
      
      let url = NSURL(string: themeItem.themeIconURL)!
//      imageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "cover"))
      imageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "cover"), optionsInfo: nil, progressBlock: nil, completionHandler: {[weak self] (image, error, cacheType, imageURL) -> () in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          
          if self?.enteredTheme == false {
            if let bgainID = self?.begainThemeID where bgainID == themeID {
              self?.showTemplatesWithThemeID(bgainID, themeName: themeName)
            }
          }
        })
      })
    }
    
    if let label = cell.viewWithTag(100) as? UILabel {
      label.text = themeItem.themeName
    }
    
    return cell
  }
  
  // delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    
    
    let themeID = ThemesManager.shareInstance.getThemeList()[indexPath.item].themeID
    let themeName = ThemesManager.shareInstance.getThemeList()[indexPath.item].themeName

    showTemplatesWithThemeID(themeID, themeName: themeName)
  }
  
  func showTemplatesWithThemeID(themeID: String, themeName: String) {
    let template = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditTemplateViewController") as! EditTemplateViewController
    
    template.themeID = themeID
    template.title = themeName
    navigationController?.pushViewController(template, animated: true)
    
  }
  
  func getSelectedOriginFrame() -> CGRect {

    let cell = collectionView.cellForItemAtIndexPath(selectedIndex)!
    let frame = collectionView.convertRect(cell.frame, toView: view)
    
    return frame
  }
  
  func getSelectedSnapshot() -> UIView {
    
    if let beIndex = begainIndex where enteredTheme == false  {
      enteredTheme = true
      selectedIndex = beIndex
      
    } else {
      selectedIndex = collectionView.indexPathsForSelectedItems().first as! NSIndexPath
    }
    
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
