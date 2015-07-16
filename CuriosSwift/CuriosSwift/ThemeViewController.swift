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

class ThemeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var themeList = [ThemeModel]()
  
    override func viewDidLoad() {
        super.viewDidLoad()

      ThemesManager.shareInstance.getThemes(0, size: 20) { [unowned self](themes) -> () in
        
        self.appThemes(themes)
        self.collectionView.reloadData()
      }
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
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TemplateSelectCell", forIndexPath: indexPath) as! TemplateCollectionViewCell
    
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









// MARK: - IBAction
// MARK: -
extension ThemeViewController {
  
  @IBAction func cancelAction(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
}













// MARK: - Private Method
// MARK: -
extension ThemeViewController {
  
  func createANewBookWithPageModel(pageModel: PageModel) {
    
    PublishIDRequest.requestWithComponents(getPublishID, aJsonParameter: "") {[unowned self] (json) -> Void in
      
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
