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
      
      debugPrint.p(theme)
      
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
      
      let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: cell.bounds.height + 0), size: CGSize(width: cell.bounds.width, height: 30)))
      label.tag = 100
      label.text = "sdfsdf"
      label.textAlignment = .Center
      cell.contentView.addSubview(label)
      cell.clipsToBounds = false
    }
    
    let themeItem = themeList[indexPath.item]
    
    if let imageView = cell.backgroundView as? UIImageView {
      
      let url = NSURL(string: themeItem.themeIconURL)!
      imageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "cover"))
      
    }
    
    if let label = cell.viewWithTag(100) as? UILabel {
      label.text = themeItem.themeName
    }
    
    return cell
  }
  
  // delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let template = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditTemplateViewController") as! EditTemplateViewController
    
    let themeID = themeList[indexPath.item].themeID
    template.themeID = themeID
    template.title = themeList[indexPath.item].themeName
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
