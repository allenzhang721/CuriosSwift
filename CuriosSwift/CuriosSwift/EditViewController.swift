//
//  EditViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle
import pop
import SnapKit
import Kingfisher


func exchange<T>(inout data: [T], i:Int, j:Int) {
  let temp:T = data[i]
  data[i] = data[j]
  data[j] = temp
}

func pathByComponents(components: [String]) -> String {
  let begain = ""
  let path = components.reduce(begain) {$0.stringByAppendingString($1 + "/")} as NSString
  let subPath = path.substringToIndex(path.length - 1) as String
  return subPath
}


class EditViewController: UIViewController, UIViewControllerTransitioningDelegate, EditNavigationViewControllerDelegate,EditToolBarDelegate,MaskViewDelegate, PageCollectionViewCellDelegate, BookDetailViewControllerDelegate, preViewControllerProtocol {
  
  //deprecated
  enum ToolState {
    case willSelect
    case didSelect
    case endEdit
  }
  
  enum ConstraintsState {
    
    case Default, ShowPannel
  }
  
  // UI
  @IBOutlet weak var generateTemplateButton: UIBarButtonItem!
  
    @IBOutlet weak var templatebutton: UIBarButtonItem!
  var isUploaded = false   // bookModel in server
  
  var begainThemeID: String?
  
  var bottomToolBar: ToolsBar!  //deprecated
  var pannel: ToolsPannel!      //deprecated
  var templateViewController: EditorTemplateNavigationController! //deprecated
  
    var fakePageView: FakePageView?
  var editToolBar: EditToolBar!
  var editToolPannel: EditToolPannel!
  var editNavigationViewController: EditNavigationViewController!
  var editDeletedButton: UIImageView?
  
  var maskView: MaskView?
  var toolState: ToolState = .endEdit
  @IBOutlet weak var topToolBar: UIToolbar!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet var singleTapGesture: UITapGestureRecognizer!
  @IBOutlet var doubleTapGesture: UITapGestureRecognizer!
  
  //Model
  var didLoadBegainConstraint = false
  
  var bookModel: BookModel!
  
  var SmallLayout = smallLayout()
  var normalLayout = NormalLayout()
  let queue = NSOperationQueue()
  
  var transitionLayout: TransitionLayout!
  let maxY = Float(LayoutSpec.layoutConstants.maxTransitionLayoutY)
  var beganPanY: CGFloat = 0.0
  var isToSmallLayout = false
  var multiSection = false
  
  var isReplacedImage: Bool = false
  
  var longPressBegainLocation: CGPoint!
  
  var maskAttributes = [IMaskAttributeSetter]()
  var currentEditContainer: IContainer?
  var pageEditing: Bool {
    get {
      return multiSection && maskAttributes.count > 0
    }
  }
  
  var currentPageModel: PageModel? {
    
    if let currentIndexPath = getCurrentIndexPath() {
      let pageModel = bookModel.pageModels[currentIndexPath.item]
      return pageModel
      
    } else {
      
      return nil
    }
  }
    
    var currentPageCell: PageCollectionViewCell? {
        if let currentIndexPath = getCurrentIndexPath() {
            let pageCell = collectionView.cellForItemAtIndexPath(currentIndexPath)! as! PageCollectionViewCell
            return pageCell
        } else {
            return nil
        }
    }
  
  var currentPageCellSnapshot: UIImage? {
    
    if let currentIndexPath = getCurrentIndexPath() {
      let pageCell = collectionView.cellForItemAtIndexPath(currentIndexPath)!
      let abounds = pageCell.bounds
      UIGraphicsBeginImageContextWithOptions(abounds.size, true, 2.0)
      pageCell.drawViewHierarchyInRect(abounds, afterScreenUpdates: true)
      let image = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      return image
      
    } else {
      
      return nil
    }
    
  }
  
  var constraintsState: ConstraintsState = .Default {
    
    // updateConstraintsWill animation update layout
    didSet {
      view.setNeedsUpdateConstraints()
      UIView.animateWithDuration(0.2, animations: {[unowned self] () -> Void in
        self.view.layoutIfNeeded()
      })
    }
  }
  
  var progress: Float = 0.0 {
    didSet {
      
      if transitionLayout != nil {
        transitionByProgress(progress)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // show the template Maker Button
    
//    templatebutton = nil
    generateTemplateButton = UIBarButtonItem(customView: UIView(frame: CGRectZero))
    
    
    SmallLayout.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
    let normal = NormalLayout()
    collectionView.setCollectionViewLayout(normal, animated: false)
    collectionView.decelerationRate = 0.1
    
    setupSubView()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    updateSelectBorder()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    EndEdit()
    setupGenerateTemplateVC(segue)
    
  }
  
  
  func setupGenerateTemplateVC(segue: UIStoryboardSegue) {
    
    if let generateTemplateNavigationController = segue.destinationViewController as? UINavigationController,
      let generateTemplateVC = generateTemplateNavigationController.topViewController as? GenerateTemplateViewController {
        
        generateTemplateVC.dataSource = self
    }
  }

}

// MARK: - generateTemplateVC DataSource
extension EditViewController: GenerateTemplateViewControllerDataSource {
  
  func generateTemplateViewControllerPageTitle(ViewController: GenerateTemplateViewController) -> String {
    
    return currentPageModel!.pageTitle
    
  }
  
  func generateTemplateViewControllerPageDescription(ViewController: GenerateTemplateViewController) -> String {
    return currentPageModel!.pageDesc
  }
  
  func generateTemplateViewControllerPublishID(ViewController: GenerateTemplateViewController) -> String {
    return bookModel.Id
  }
  
  func generateTemplateViewControllerPageID(ViewController: GenerateTemplateViewController) -> String {
    return currentPageModel!.Id
  }
  
  func generateTemplateViewControllerPageBackgroundColorWithHex(ViewController: GenerateTemplateViewController) -> String {
    
    let color = currentPageModel!.pageBackgroundColor
    if color.isEmpty {
      return "#FFFFFF"
    }
    let rgb = color.componentsSeparatedByString(",")
    let r = rgb[0].toInt()!
    let g = rgb[1].toInt()!
    let b = rgb[2].toInt()!
    
    return UIColor.toHexWithr(r, g: g, b: b)
  }
  
  func generateTemplateViewControllerPageAlpha(ViewController: GenerateTemplateViewController) -> Float {
    
    return Float(currentPageModel!.pageBackgroundAlpha)
  }
  
  func generateTemplateViewControllerPageSnapshot(ViewController: GenerateTemplateViewController) -> UIImage {
    
    return currentPageCellSnapshot!
  }
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedTitle pageTitle: String) {
    
    currentPageModel?.pageTitle = pageTitle
  }
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedDescri pageDescri: String) {
    
    currentPageModel?.pageDesc = pageDescri
  }
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedBackgroundColor colorHex: String) {
    
    currentPageModel?.pageBackgroundColor = colorHex
    currentPageCell?.updateColorAndAlpha()
  }
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedBackAlpha alpha: CGFloat) {
    
    currentPageModel?.pageBackgroundAlpha = alpha
    currentPageCell?.updateColorAndAlpha()
  }
  
  func generateTemplateViewControllerChangedPageJsonData(ViewController: GenerateTemplateViewController) -> NSData {
    
    let pagejson = MTLJSONAdapter.JSONDictionaryFromModel(currentPageModel, error: nil)
    debugPrint.p(pagejson)
    let originData = NSJSONSerialization.dataWithJSONObject(pagejson, options: NSJSONWritingOptions(0), error: nil)!
    return originData
//    let string = NSString(data: originData!, encoding: NSUTF8StringEncoding) as! String
//    let appString = string
//    let data = appString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
  }
  
}


// MARK: - private Init
extension EditViewController {
  
  private func setupSubView() {
    
    //top naviBar
    editToolBar = EditToolBar(frame: CGRect(x: 0, y: view.bounds.height - 44.0, width: view.bounds.width, height: 44.0))
    editToolPannel = EditToolPannel(frame: CGRectZero)
    
    editToolBar.backgroundColor = UIColor.whiteColor()
    editToolPannel.backgroundColor = UIColor.whiteColor()
    
    // navigationController
    editNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditNavigationController") as! EditNavigationViewController
    
    if let theme = editNavigationViewController.topViewController as? EditThemeViewController {
      theme.begainThemeID = begainThemeID
    }
    
    addChildViewController(editNavigationViewController)
    editNavigationViewController.editDelegate = self
    
    editToolBar.delegate = self
    editToolBar.settingDelegate = editToolPannel
    
    view.addSubview(editToolBar)
    view.addSubview(editToolPannel)
    view.insertSubview(editNavigationViewController.view, atIndex: 0)

  }
  
}
















// MARK: - IBActions
extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBAction func PanAction(sender: UIPanGestureRecognizer) {
    
    let transition = sender.translationInView(view)
    
    switch sender.state {
    case .Began:
      
      resetSeletctBorder()
      beganPanY = LayoutSpec.layoutConstants.screenSize.height - sender.locationInView(view).y
      isToSmallLayout = collectionView.collectionViewLayout is NormalLayout
      let nextLayout = isToSmallLayout ? smallLayout() : NormalLayout()
      
      var nextisSmall = false
      if let aSma = nextLayout as? smallLayout {
        nextisSmall = true
        aSma.delegate = self
      }
      
      transitionLayout = collectionView.startInteractiveTransitionToCollectionViewLayout(nextLayout, completion: { [unowned self] (completed, finish) -> Void in
        
        if completed {
          
//          if self.transitionLayout.currentLayout is NormalLayout {
            self.updateSelectBorder()
//          }
        self.transitionLayout = nil
          self.progress = 0
          
        }

        }) as? TransitionLayout
      
    case .Changed:
      progress = isToSmallLayout ? Float(transition.y / beganPanY) : -Float(transition.y / beganPanY)
      
    case .Ended:
      
      if transitionLayout != nil {
        let animation = togglePopAnimation(progress >= 0.5 ? true : false)
      }
      
    default:
      return
    }
  }
  
  @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
    
    let location = sender.locationInView(view)
    if collectionView.collectionViewLayout is smallLayout {
      switch sender.state {
      case .Began:
        // collectionView
        if CGRectContainsPoint(collectionView.frame, location) {
          
          if bookModel.pageModels.count <= 1 {
            fallthrough
          }
          let pageLocation = sender.locationInView(collectionView)
          if let aSmallLayout = collectionView.collectionViewLayout as? smallLayout
            where aSmallLayout.begainSelectedAtOnScreenPoint(pointOnCollectionViewContent: pageLocation) {
//              fakePageView!.center = location
              longPressBegainLocation = location
          }

        // editNavigationController
        } else if CGRectContainsPoint(editNavigationViewController.view.frame, location) {
          
          let location = sender.locationInView(editNavigationViewController.view)
          
          editNavigationViewController.didSelectedBlock = {[unowned self](snapshot, json) -> () in
            
            if let page: PageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as? PageModel {
              
              // change Page id
              page.Id = UniqueIDStringWithCount(count: 8)
              
              self.fakePageView = FakePageView.fakePageViewWith(snapshot, array: [page])
              self.fakePageView?.fromTemplate = true
              self.fakePageView?.center = location
              self.view.addSubview(self.fakePageView!)
              
              if let aSmallLayout = self.collectionView.collectionViewLayout as? smallLayout {
                let pageLocation = sender.locationInView(self.collectionView)
                
                self.longPressBegainLocation = location
                aSmallLayout.begainInsertSelectedAtOnScreenPoint(pointOnCollectionViewContent: pageLocation)
              }
            }
          }
          
          editNavigationViewController.begainResponseToLongPress(location)
        }
        
      case .Changed:
//        return
        // collectionView
        if collectionView.collectionViewLayout is smallLayout {
          if let fake = fakePageView {
            let transition = CGPoint(x: location.x - longPressBegainLocation.x, y: location.y - longPressBegainLocation.y)
            longPressBegainLocation = location
            fake.center.x += transition.x
            fake.center.y += transition.y
            if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
              let inEditBoundsLocation = sender.locationInView(collectionView)
//              let mapLocation = CGPoint(x: inEditBoundsLocation.x, y: 150)
              aSmallLyout.changedOnScreenPointTransition(pointOnCollectionContent: transition)
              
              let onViewLocation = sender.locationInView(view)
              let location = sender.locationInView(collectionView)
              if CGRectContainsPoint(CGRect(x: 0, y: 568 - 50, width: 320, height: 50), onViewLocation) {
                updateDeleteButton(true)
//              } else if !CGRectContainsPoint(collectionView.bounds, location) {
//                updateDeleteButton(true)
              } else {
                updateDeleteButton(false)
              }
//              aSmallLyout.selectedItem(CGRectContainsPoint(collectionView.frame, location), AtLocation: inEditBoundsLocation)
            }
          }
          
        }
          // reorder
        
          // deleted
        
        // editNavigationController
          // reorder
        
          // insert
        
        
      case .Cancelled, .Ended:
//        return
        
        // remove fakeView
      if collectionView.collectionViewLayout is smallLayout {
        if fakePageView != nil {
          if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
            //                    if CGRectContainsPoint(collectionView.frame, location) {
            
//            if !(fakePageView!.fromTemplate) {
            let onViewLocation = sender.locationInView(view)
              let location = sender.locationInView(collectionView)
              if CGRectContainsPoint(CGRect(x: 0, y: 568 - 50, width: 320, height: 50), onViewLocation) {
                aSmallLyout.endSelected(true)
//                aSmallLyout.selectedItemMoveFinishAtLocation(CGPoint(x: 0, y: -CGFloat.max), fromeTemplate: true)
                
              } else if !CGRectContainsPoint(collectionView.bounds, location) {
                
                aSmallLyout.endSelected(fakePageView!.fromTemplate)
//              let location = sender.locationInView(collectionView)
//              aSmallLyout.selectedItemMoveFinishAtLocation(location, fromeTemplate: fakePageView!.fromTemplate)
              } else {
                aSmallLyout.endSelected(false)
            }
            //                    }
          }

          showDeletedButton(false, animated: true)
          fakePageView?.removeFromSuperview()
          fakePageView?.clearnPageArray()
          fakePageView = nil
        }
      }
        
        
        // did action(insert / deleted)
        
      default:
        return
        
      }
      
      
      
      
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    switch sender.state {
//    case .Began:
//      
//      if collectionView.collectionViewLayout is smallLayout {
//        // collectionView
//        if CGRectContainsPoint(collectionView.frame, location) {
//          let pageLocation = sender.locationInView(collectionView)
//          if let aSmallLayout = collectionView.collectionViewLayout as? smallLayout
//            where aSmallLayout.selectedItemBeganAtLocation(pageLocation) {
//              if let snapShot = aSmallLayout.getSelectedItemSnapShot() {
//                fakePageView = FakePageView.fakePageViewWith(snapShot, array: [bookModel.pageModels[aSmallLayout.placeholderIndexPath!.item]])
//                fakePageView?.fromTemplate = false
//                fakePageView?.center = location
//                view.addSubview(fakePageView!)
//              }
//          }
//          // template
//        } else if CGRectContainsPoint(templateViewController.view.bounds, sender.locationInView(templateViewController.view)) {
//          
//          let loction = sender.locationInView(templateViewController.view)
//          if let snapShot = templateViewController.getSnapShotInPoint(location) {
//            
//            if let aPageModels = templateViewController.getPageModels(location) {
//              fakePageView = FakePageView.fakePageViewWith(snapShot, array: aPageModels)
//              fakePageView?.fromTemplate = true
//              fakePageView?.center = location
//              view.addSubview(fakePageView!)
//            } else {
//              fallthrough
//            }
//          }
//        }
//        
//        // LongPress In NormalLayout
//      } else if collectionView.collectionViewLayout is NormalLayout {
//        
//        // TODO: Mask
//        if let currentIndexPath = getCurrentIndexPath() {
//          if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
//            let location = sender.locationInView(view)
////            page.setDelegate(self)
//          }
//        }
//      }
//      
//    case .Changed:
//      
//      if collectionView.collectionViewLayout is smallLayout {
//        if let fake = fakePageView {
//          fake.center = location
//          
//          if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
//            let inEditBoundsLocation = sender.locationInView(collectionView)
//            aSmallLyout.selectedItem(CGRectContainsPoint(collectionView.frame, location), AtLocation: inEditBoundsLocation)
//          }
//        }
//        
//      } else if collectionView.collectionViewLayout is NormalLayout {
//
//        // TODO: Mask
//      }
//      
//    case .Cancelled, .Ended:
//      
//      if collectionView.collectionViewLayout is smallLayout {
//        if fakePageView != nil {
//          if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
//            //                    if CGRectContainsPoint(collectionView.frame, location) {
//            aSmallLyout.selectedItemMoveFinishAtLocation(location, fromeTemplate: fakePageView!.fromTemplate)
//            //                    }
//          }
//          
//          fakePageView?.removeFromSuperview()
//          fakePageView?.clearnPageArray()
//          fakePageView = nil
//        }
//        
//        
//      } else if collectionView.collectionViewLayout is NormalLayout {
//        
//        // TODO: Mask
//        
//        multiSection = false
//        if !pageEditing {
//          if let currnetIndexPath = getCurrentIndexPath() {
//            if let page = collectionView.cellForItemAtIndexPath(currnetIndexPath) as? IPage {
//              page.cancelDelegate()
//            }
//          }
//        }
//      }
//      
//    default:
//      return
//    }
  }

  func getFileKeys(rootDirectoryName: String, rootURL: NSURL, userID: String, publishID: String) -> [String : String] {
    
    
    let fileManger = NSFileManager.defaultManager()
    var error = NSErrorPointer()
    let mainDirEntries = fileManger.enumeratorAtURL(rootURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsPackageDescendants | NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, error) -> Bool in
      return true
    }
    
    var dics = [String : String]()
    while let url = mainDirEntries?.nextObject() as? NSURL {
      //           var dic = [String : String]()
      var flag = ObjCBool(false)
      fileManger.fileExistsAtPath(url.path!, isDirectory: &flag)
      if flag.boolValue == false {
        
        let relativePath = url.pathComponents?.reverse()
        var relative = ""
        for path in relativePath as! [String] {
          
          if path != rootDirectoryName {
            relative = ("/" + path + relative)
          } else {
            break
          }
        }
        let key = userID + "/" + publishID + relative
        dics[key] = url.path!
        //                dics.append(dic)
      }
    }
    return dics
    
  }
  
  
  @IBAction func saveAction(sender: UIBarButtonItem) {
    
    
    EndEdit()
    if UploadsManager.shareInstance.uploadFinished() && !bookModel.isNeedUpload() && !bookModel.isNeedAddFile() {
      UploadsManager.shareInstance.setCompeletedHandler(nil)
      self.dismissViewControllerAnimated(true, completion: nil)
    } else {
      HUD.save_sync()
      prepareUploadBookModelToServer {[unowned self] (finished) -> () in
        
        if finished {
          let time: NSTimeInterval = 2.0
          let delay = dispatch_time(DISPATCH_TIME_NOW,
            Int64(time * Double(NSEC_PER_SEC)))
          dispatch_after(delay, dispatch_get_main_queue()) {
            HUD.dismiss()
            self.dismissViewControllerAnimated(true, completion: nil)
          }
        }
      }
    }
  }
  
  // book detail Action
  func settingAction(sender: UIButton) {
    
    if let bookdetailNavigationController = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("bookdetailNavigationController") as? UINavigationController,
      let bookdetailController = bookdetailNavigationController.topViewController as? BookDetailViewController {
        
        bookdetailController.bookModel = bookModel
        presentViewController(bookdetailNavigationController, animated: true, completion: nil)
    }
  }
}




// MARK: - Gesture - New
extension EditViewController {
  
  @IBAction func doubleTapAction(sender: UITapGestureRecognizer) {
    
    if let currentIndexPath = getCurrentIndexPath() {
      if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? PageCollectionViewCell  {
        page.setDelegate(self)
        let location = sender.locationInView(page)
        page.begainResponseToTap(location, tapCount: 2)
      }
    }
  }
  
  @IBAction func TapAction(sender: UITapGestureRecognizer) {
    
    if CUAnimationFactory.shareInstance.isAnimationing() {
      CUAnimationFactory.shareInstance.cancelAnimation()
      return
    }
    
    if let currentIndexPath = getCurrentIndexPath() {
      
//      if toolState != .didSelect {
      
        if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? PageCollectionViewCell  {
          page.setDelegate(self)
          let location = sender.locationInView(page)
          page.begainResponseToTap(location, tapCount: 1)
        }
//      } else {
//        if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
//          let location = CGPointZero
//          page.setDelegate(self)
//        }
//      }
    }
  }
}


// MARK: - Action  - New
extension EditViewController {
  
//  func retriveThumbnailImage(image: UIImage, size: CGSize) -> UIImage {
//    let scale: CGFloat = (image.size.width > size.width && image.size.height > size.height) ? 0.5 : 1.0
//  UIGraphicsBeginImageContextWithOptions(size, true, scale)
////  image.drawInRect(CGRect(origin: CGPointZero, size: size))
//  image.drawAtPoint(CGPointZero)
//  let aImage = UIGraphicsGetImageFromCurrentImageContext()
//  UIGraphicsEndImageContext()
//  return aImage
//  }
  
  func retriveThumbnailImage(image: UIImage, size: CGSize) -> UIImage {
    
    let maxScale = max(size.width / image.size.width, size.height / image.size.height)
    let width = image.size.width * maxScale
    let height = image.size.height * maxScale
    let imageSize = CGSize(width: width, height: height)
    UIGraphicsBeginImageContextWithOptions(imageSize, true, maxScale)
    image.drawInRect(CGRect(origin: CGPointZero, size: imageSize))
    let aImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return aImage
  }
  
  func addText(text: String) {
    
    EndEdit()
    
    if let indexPath = getCurrentIndexPath() {
      
      if bookModel.pageModels.count <= 0 {
        return
      }
      
      let pageModel = bookModel.pageModels[indexPath.item]
      
      let defaultTextAttribute = [ "Text": "",
        "FontName": "RTWSYueRoudGoG0v1-Regular",
        "FontSize": 30,
        "TextColor": "#282B35",
        "TextAligment": "center",
        "ImagePath": " "
      ]
      
      let textComponent = TextContentModel()
      textComponent.type = .Text
      textComponent.needUpload = true
      textComponent.attributes = defaultTextAttribute
      textComponent.imageID = UniqueIDStringWithCount(count: 8)
      let container = ContainerModel()
      container.Id = UniqueIDStringWithCount(count: 5)
      container.component = textComponent
      
      pageModel.addContainerModel(container, OnScreenSize: CGSize(width: 0, height: 0))
      begainEdit()
    }
  }
  
  
  func addImage(image: UIImage, userID: String, publishID: String, ispng: Bool) {
    
    EndEdit()
    
    if let indexPath = getCurrentIndexPath() {
      
      if bookModel.pageModels.count <= 0 {
        return
      }
      
      let pageModel = bookModel.pageModels[indexPath.item]
      
      let defaultImageAttribute = [
        "ImagePath": ""
      ]
      
      let imageComponent = ImageContentModel()
      imageComponent.type = .Image
      imageComponent.needUpload = true
      imageComponent.attributes = defaultImageAttribute
      let imageID = UniqueIDStringWithCount(count: 8)
      imageComponent.imageID = imageID
      
      if bookModel.isDefaultIcon() {
        let key = pathByComponents([userID, publishID, "icon.jpg"])
        let cacheKey = ServePathsManger.imagePath!.stringByAppendingString(key).stringByAppendingString(ICON_THUMBNAIL)
        debugPrint.p("cacheKey = \(cacheKey)")
        let thumbNail = retriveThumbnailImage(image, size: CGSize(width: 320, height: 320))
        
        let iconData = UIImageJPEGRepresentation(thumbNail, 1.0)
        uploadIcon(iconData)
        
        KingfisherManager.sharedManager.cache.storeImage(thumbNail, forKey: cacheKey)
        bookModel.setBookIcon(key)
      }
      
      imageComponent.updateImage(image, userID: userID, PublishID: publishID, ispng: ispng)
      let container = ContainerModel()
      container.Id = UniqueIDStringWithCount(count: 5)
      container.component = imageComponent
      
      pageModel.addContainerModel(container, OnScreenSize: image.size)
      begainEdit()
    }
  }
  
  func replaceImage(image: UIImage, userID: String, publishID: String, ispng: Bool) {
    
    if let aMaskView = maskView,
      let imagecomponent = aMaskView.containerMomdel.component as? ImageContentModel {
        imagecomponent.updateImage(image, userID: userID, PublishID: publishID, ispng: ispng)
    }
  }
  
  func addMask(center: CGPoint, size: CGSize, angle: CGFloat, targetContainerModel containerModel: ContainerModel) {
    
    if let aMaskView = maskView {
      aMaskView.removeFromSuperview()
      maskView = nil
    }
    
    maskView = MaskView.maskWithCenter(center, size: size, angle: angle, targetContainerModel: containerModel)
    maskView!.delegate = self
    
    view.insertSubview(maskView!, aboveSubview: collectionView)
  }
  
  func removeMaskByModel(targetContainerModel containerModel: ContainerModel) {
    
    if let aMaskView = maskView where aMaskView.containerMomdel == containerModel {
      aMaskView.removeFromSuperview()
      maskView = nil
    }
  }
  
  func begainEdit() {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? PageCollectionViewCell  {
        page.setDelegate(self)
        let location = page.contentView.center
        page.begainResponseToTap(location, tapCount: 1)
      }
    }
  }
  
  func EndEdit() {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? PageCollectionViewCell  {
        page.setDelegate(self)
        let location = CGPoint(x: CGFloat.max, y: CGFloat.max)
        page.begainResponseToTap(location, tapCount: 1)
      }
    }
  }
  
  // deselected container will check wheather need upload new resourse, and set needUpload false
  func checkUploadResourseWithModel(containerModel: ContainerModel) {
    
    let component = containerModel.component
    
    if component.needUpload {
      component.needUpload = false
      containerModel.component.getResourseData {[unowned self] (data, key) -> () in
        // upload data
        if let aKey = key {
          
          self.prepareUploadImageData(data!, key: aKey, compeletedBlock: { (theData, theKey, theToken) -> () in
            
            UploadsManager.shareInstance.upload([theData], keys: [theKey], tokens: [theToken])
          })
        }
      }
    }
  }
  
  func begainUploadPageSnapShotWithModel(pageModel: PageModel) {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      if let pageCell = collectionView.cellForItemAtIndexPath(currentIndexPath) as? PageCollectionViewCell  {
        
        // should get text/ image snapshot
        let abounds = pageCell.bounds
        UIGraphicsBeginImageContext(abounds.size)
        pageCell.drawViewHierarchyInRect(abounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let userID = UsersManager.shareInstance.getUserID()
        let publishID = bookModel.Id
        let pageID = pageModel.Id
        
        let key = pathByComponents([userID, publishID, pageID, "icon.jpg"])
        let data = UIImageJPEGRepresentation(image, 0.01)
        
        prepareUploadImageData(data!, key: key, compeletedBlock: { (theData, theKey, theToken) -> () in
          
          UploadsManager.shareInstance.upload([theData], keys: [theKey], tokens: [theToken])
        })
      }
    }
  }
  
  
  func uploadComplete(completed:((String?) -> ())?) {
    
    let userID = UsersManager.shareInstance.getUserID()
    
    let publishID = bookModel.Id
    let publishURL = pathByComponents([userID, publishID]) + "/"
    let bookTitle = bookModel.title
    let bookDes = bookModel.desc
    
    let para = UPLOAD_COMPELTED_paras(publishID, userID, publishURL, bookTitle, bookDes)
    
    UploadCompleteReqest.requestWithComponents(UPLOAD_COMPELTED, aJsonParameter: para) { [unowned self] (json) -> Void in
      
      if let publishURL = json["data"] as? String {
        
        self.publishFile()
        self.bookModel.savePublishURL(publishURL)
        
        completed?(publishURL)
        
        let time: NSTimeInterval = 1.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,
          Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
//          self.showPreviewControllerWithUrl(publishURL)
        }
      } else {
        completed?(nil)
      }
      }.sendRequest()
  }
  
  
  func publishFile() {
    
    let userID = UsersManager.shareInstance.getUserID()
    let publishID = bookModel.Id
    let atitle = bookModel.title
    let desc = bookModel.desc
    let icon = bookModel.icon
    let index = "index.html"
    let publishURL = pathByComponents([userID, publishID,index])
    let publishResURL = pathByComponents([userID, publishID, "res", "curiosRes.json"])
    
    let string = PUBLISH_FILE_paras(userID, publishID, publishURL, publishResURL, publisherIconURL: icon, publishTitle: atitle, publishDesc: desc)
    PublishFileRequest.requestWithComponents(PUBLISH_FILE, aJsonParameter: string) { (json) -> Void in
    }.sendRequest()
  }
  
  func showPreviewControllerWithUrl(url: String, completion: (() -> Void)?) {
    
    HUD.dismiss()
    if let previewNavVC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("PreviewNavigationController") as? UINavigationController {
      
      if let previewVC = previewNavVC.topViewController as? PreviewViewController {
        previewVC.urlString = url
        previewVC.delegate = self
//        presentViewController(previewNavVC, animated: true, completion: nil)
        presentViewController(previewNavVC, animated: true, completion: completion)
      }
    }
  }
  
  func backToNormalLayout(sender: UITapGestureRecognizer) {
    if collectionView.collectionViewLayout is smallLayout {
      let location = sender.locationInView(collectionView)
      if CGRectContainsPoint(collectionView.bounds, location) {
        if transitionLayout == nil {
          progress = 0
          isToSmallLayout = false
          transitionLayout = collectionView.startInteractiveTransitionToCollectionViewLayout(normalLayout, completion: { [unowned self] (completed, finish) -> Void in
            
            self.transitionLayout = nil
            self.progress = 0
            
            }) as! TransitionLayout
          
          togglePopAnimation(true)
        }
      }
      return
    }
  }
  
  func updateDeleteButton(deleted: Bool) {
    
    if let aDeletedBu = editDeletedButton {
      if deleted {
        
        UIView.animateWithDuration(0.2, animations: {[unowned self] () -> Void in
          self.fakePageView?.alpha = 0.5
          aDeletedBu.transform = CGAffineTransformMakeScale(1.2, 1.2)
        })
        
        let image = UIImage(named: "Edit_deleted_delete")
        aDeletedBu.image = image
        
      } else {
        UIView.animateWithDuration(0.2, animations: {[unowned self] () -> Void in
          self.fakePageView?.alpha = 1
          aDeletedBu.transform = CGAffineTransformMakeScale(1.0, 1.0)
          })
        let image = UIImage(named: "Edit_deleted_normal")
        aDeletedBu.image = image
        
      }
    }
    
    
    
  }
  
  func showDeletedButton(show: Bool, animated: Bool) {
    
    if show {
      
      if editDeletedButton != nil {
        editDeletedButton?.removeFromSuperview()
      }
      let image = UIImage(named: "Edit_deleted_normal")
      editDeletedButton = UIImageView(image: image)
      let translation = editDeletedButton!.bounds.midY
      editDeletedButton!.center = CGPoint(x: view.bounds.midX, y: view.bounds.height + translation)
      
      view.addSubview(editDeletedButton!)
      if animated {
        UIView.animateWithDuration(0.3, animations: {[unowned self] () -> Void in
          
          self.editDeletedButton!.center.y -=  2 * translation
        })
      } else {
        self.editDeletedButton!.center.y -=  2 * translation
      }
      
      // hidden
    } else {
      
      if let deletedButton = editDeletedButton {
        let translation = editDeletedButton!.bounds.midY
        if animated {
          UIView.animateWithDuration(0.3, animations: {[unowned self] () -> Void in
            self.editDeletedButton!.center.y +=  2 * translation
            
          }, completion: { (finished) -> Void in
            if finished {
              deletedButton.removeFromSuperview()
            }
            
          })
        } else {
          deletedButton.removeFromSuperview()
        }
      }
    }
  }
}

// MARK: - NET WORK
extension EditViewController {
  
  func prepareUploadImageData(data: NSData, key: String, compeletedBlock:(NSData, String, String) -> ()) {
    
    let imageTokenDic: String = {
      let dic = ["list":[
        ["key": key]
        ]
      ]
      let jsondata = NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(0), error: nil)
      let string = NSString(data: jsondata!, encoding: NSUTF8StringEncoding) as! String
      return string
      }()
    
    let para = GET_IMAGE_TOKEN_paras(key)
    
    ImageTokenRequest.requestWithComponents(GET_IMAGE_TOKEN, aJsonParameter: para) { (json) -> Void in
      
      if let keyTokens = json["list"] as? [[String:String]] {
        
        let keyToken = keyTokens[0]
        let token = keyToken["upToken"]!
        
        compeletedBlock(data, key, token)
      }
      }.sendRequest()
  }
}



// MARK: - MaskViewDelgate - New
extension EditViewController {
  
  func maskViewDidSelectedDeleteItem(mask: MaskView, deletedContainerModel containerModel: ContainerModel) {
    
    if let currentIndexPath = getCurrentIndexPath() {
      
      // EndEdit
      EndEdit()
      
      // remove Model
      let pageModel = bookModel.pageModels[currentIndexPath.item]
      pageModel.removeContainerModel(containerModel)
    }
  }
  
  
  func maskViewDidSelectedEditItem(mask: MaskView, EditedContainerModel containerModel: ContainerModel) {
    
    // Replace Image
    if let component = containerModel.component as? ImageContentModel {
      isReplacedImage = true
      showsheet()
    } else if let component = containerModel.component as? TextContentModel {
      // Edit Text
      let attriString = component.getDemoStringAttributes()
      showTextInputControllerWithAttributeString(attriString) { [unowned self](attri, needUpdate) -> () in
        if needUpdate {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            component.updateFromDemoAttributeString(attri)
            containerModel.needUpdateOnScreenSize(true)
          })
        }
      }
    }
  }
}











// MARK: - Ipage Protocol - New
extension EditViewController {
  
  func pageDidSelected(page: PageModel, selectedContainer container: ContainerModel, onView: UIView ,onViewCenter: CGPoint, size: CGSize, angle: CGFloat) {
    
    collectionView.scrollEnabled = false
    let aCenter = onView.convertPoint(onViewCenter, toView: view)
    addMask(aCenter, size: size, angle: angle, targetContainerModel: container)
    
    container.setSelectedState(true)
    
    editToolBar.updateWithModel(container)
  }
  
  func pageDidDeSelected(page: PageModel, deselectedContainer container: ContainerModel) {
    
    container.setSelectedState(false)
    removeMaskByModel(targetContainerModel: container)
    
    // wheather need upload resourse when deselected a container and set needUpload false
    checkUploadResourseWithModel(container)
  }
  
  func pageDidDoubleSelected(page: PageModel, doubleSelectedContainer container: ContainerModel) {
    
    if container.component is ImageContentModel {
      isReplacedImage = true
      showsheet()
    } else if let textComponent = container.component as? TextContentModel {
      
      let attri = textComponent.getDemoStringAttributes()
      showTextInputControllerWithAttributeString(attri) { [unowned self](aAttribute, needUpdate) -> () in
        
        if needUpdate {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            textComponent.updateFromDemoAttributeString(aAttribute)
            container.needUpdateOnScreenSize(true)
          })
        }
      }
    }
  }
  
  func pageDidEndEdit(page: PageModel) {
    collectionView.scrollEnabled = true
    //    begainUploadPageSnapShotWithModel(page)
    editToolBar.updateWithModel(nil)
  }
}

















// MARK: - ImageEditor
extension EditViewController {
  
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
    //    imagePicker.allowsEditing = true
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  
  // ImagePicker
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let publishID = bookModel.Id
    
//    assetslibaray
    
    // Selected Image
//    let selectedImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
//    let imageData = UIImageJPEGRepresentation(selectedImage, 0.001)
//    let image = UIImage(data: imageData)!
    
    let targetSize = CGSize(width: bookModel.width, height: bookModel.height)
    
    ImageHelper.optimizeImageFromLibrary(MediaWithInfo: info, targetRect: targetSize, successBlock: { [weak self] (image, size, ispng) -> () in
      
      if let strongSelf = self {
        strongSelf.isReplacedImage ? strongSelf.replaceImage(image, userID: userID, publishID: publishID, ispng: ispng) : strongSelf.addImage(image, userID: userID, publishID: publishID, ispng: ispng)
        strongSelf.isReplacedImage = false
        picker.dismissViewControllerAnimated(true, completion: nil)
      }
      
      
    }) { [weak self]() -> () in
      
      if let strongSelf = self {
        picker.dismissViewControllerAnimated(true, completion: nil)
      }
      
    }
    
    
    
    
    
  }
}




// MARK: - TextEditor
extension EditViewController {
  
  private func showTextInputControllerWithAttributeString(textAttributes: textAttribute, compelectedBlock: (textAttribute, Bool) -> ()) {
    
    if let textEditorViewController = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextEditorViewController") as? TextEditorViewController {
      textEditorViewController.setAttributeString(textAttributes)
      textEditorViewController.transitioningDelegate = self
      textEditorViewController.completeBlock = compelectedBlock
      presentViewController(textEditorViewController, animated: true, completion: nil)
    }
  }
}

// MARK: - PreviewEditor
extension EditViewController {
  
  
  func begainToPreview(completedBlock:(String?, Bool) -> ()) {
    
    // 1. book whether in server
    if isUploaded && !bookModel.needUpload && !bookModel.isEditedTitle() && !bookModel.publishURLIsEmpty() && UploadsManager.shareInstance.uploadFinished() {
      let publishURL = bookModel.retrivePublishURL()!
       completedBlock(publishURL, false)
      return
    }
    
    // 2. book whether make changed
    if isUploaded {
      if bookModel.needUpload {
        // uploadCurios
        begainUploadCuriosRes({[unowned self] (completed) -> () in
          
          self.willPreview({ (publishURL) -> () in
            completedBlock(publishURL, true)
          })
        })
        return
        
      } else {
        willPreview({ (publishURL) -> () in
          completedBlock(publishURL, true)
        })
      }
    } else {
      begainUploadCuriosRes({[unowned self] (completed) -> () in
        
        self.willPreview({ (publishURL) -> () in
          completedBlock(publishURL, true)
        })
        })
    }
  }
  
  func willPreview(completed:(String?) -> ()) {
    
    if bookModel.publishURLIsEmpty() {
      self.uploadComplete({[unowned self] (publishUrl) -> () in
        completed(publishUrl)
        })
    } else {
      
      if bookModel.isEditedTitle() {
        bookModel.resetEditedTitle()
        self.uploadComplete({[unowned self] (publishUrl) -> () in
          completed(publishUrl)
          })
      } else {
        self.publishFile()
        let publishURL = bookModel.retrivePublishURL()
        completed(publishURL)
      }
    }
  }
  
  
  func begainUploadCuriosRes(completedBlock:(Bool) -> ()) {
    
    UploadsManager.shareInstance.setCompeletedHandler {[unowned self] (finished) -> () in
      
      completedBlock(finished)
      UploadsManager.shareInstance.setCompeletedHandler(nil)
    }
    
    uploadCuriosRes { (datas, keys, tokens) -> () in
      
      UploadsManager.shareInstance.upload(datas, keys: keys, tokens: tokens)
    }
    
  }
  
  
  func begainUploadCompeleted(completedBlock:(String?) -> ()) {
    
    self.uploadComplete { (publishURL) -> () in
      
      completedBlock(publishURL)
    }
  }
  
  
  
  
  
  //Upload main json and html file
  func prepareForPreivew(completedBlock:(Bool) -> ()) {
    
    UploadsManager.shareInstance.setCompeletedHandler {[unowned self] (finished) -> () in
      
      completedBlock(finished)
      UploadsManager.shareInstance.setCompeletedHandler(nil)
    }
    
    if !(!bookModel.isNeedUpload() && isUploaded) {
      self.isUploaded = true
      bookModel.resetNeedUpload()
      HUD.preview_upload()
      uploadCuriosRes { (datas, keys, tokens) -> () in
        
        UploadsManager.shareInstance.upload(datas, keys: keys, tokens: tokens)
      }
    }
  }
  
  func uploadCuriosRes(compeletedBlock:([NSData], [String], [String]) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let bookID = bookModel.Id
    let js = "res"
    let cur = "curiosRes.json"
    let curKey = pathByComponents([userID, bookID, js, cur])

    
    let paras = GET_PUBLISH_TOKEN_paras(curKey)
    
    let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)
    let originData = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
    
    let string = NSString(data: originData!, encoding: NSUTF8StringEncoding) as! String
//    let appString = "curiosMainJson=" + string
    let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    PublishTokenRequest.requestWithComponents(GET_PUBLISH_TOKEN, aJsonParameter: paras) { (json) -> Void in
      if let keyLokens = json["list"] as? [[String:String]] {
        
        var datas = [NSData]()
        var keys = [String]()
        var tokens = [String]()
        
        for keyToken in keyLokens {
          if let key = keyToken["key"],
            let token = keyToken["upToken"] {
              if key == curKey {
                datas.append(data!)
                keys.append(key)
                tokens.append(token)
              }
          }
        }
        
        compeletedBlock(datas, keys, tokens)
      }
      
      }.sendRequest()
  }
}



// MARK: - Add Edit File
extension EditViewController {
  
  func addEditFile(completedBlock: (Bool) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let bookID = bookModel.Id
    let atitle = bookModel.title
    let desc = bookModel.desc
    let icon = bookModel.icon
    let addEditFilePath = pathByComponents([userID, bookID, "res", "curiosRes.json"])
    
//    let string = ADD_EDITED_FILE_paras(userID, bookID, addEditFilePath)
    let string = ADD_EDITED_FILE_paras(userID, bookID, addEditFilePath, publisherIconURL: icon, publishTitle: atitle, publishDesc: desc)
    
    AddEditFileRequest.requestWithComponents(ADD_EDITED_FILE, aJsonParameter: string) { (json) -> Void in
      completedBlock(true)
      }.sendRequest()
  }
  
  func prepareUploadBookModelToServer(completedBlock: (Bool) -> ()) {
    
    UploadsManager.shareInstance.setCompeletedHandler {[unowned self] (finished) -> () in
      
      //      completedBlock(finished)
      if finished {

        self.addEditFile({ (finished) -> () in
          
          if finished {
            UploadsManager.shareInstance.setCompeletedHandler(nil)
            completedBlock(true)
          }
        })
      }
    }
    
    if bookModel.isNeedUpload() {
      bookModel.resetNeedUpload()
      uploadBookModelToserver { (datas, keys, tokens) -> () in
        UploadsManager.shareInstance.upload(datas, keys: keys, tokens: tokens)
      }
    }
    
    if UploadsManager.shareInstance.uploadFinished() && bookModel.isNeedAddFile() {
      bookModel.resetNeedAddFile()
      self.addEditFile({ (finished) -> () in
        
        if finished {
          UploadsManager.shareInstance.setCompeletedHandler(nil)
          completedBlock(true)
        }
      })
    }
  }
  
  func uploadBookModelToserver(compeletedBlock:([NSData], [String], [String]) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let bookID = bookModel.Id
    let main = "curiosRes.json"
    let res = "res"
    
    let curKey = pathByComponents([userID, bookID, res, main])
    
//    let publishTokenDic: String = {
//      let dic = ["list":[
//        ["key": curKey]
//        ]
//      ]
//      let jsondata = NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(0), error: nil)
//      let string = NSString(data: jsondata!, encoding: NSUTF8StringEncoding) as! String
//      return string
//      }()
    
    let paras = GET_PUBLISH_TOKEN_paras(curKey)
    
    let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)
    
    let originData = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
    let string = NSString(data: originData!, encoding: NSUTF8StringEncoding) as! String
    let appString = string
    let data = appString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    PublishTokenRequest.requestWithComponents(GET_PUBLISH_TOKEN, aJsonParameter: paras) { (json) -> Void in
      if let keyLokens = json["list"] as? [[String:String]] {
        
        var datas = [NSData]()
        var keys = [String]()
        var tokens = [String]()
        
        for keyToken in keyLokens {
          if let key = keyToken["key"],
            let token = keyToken["upToken"] {
              if key == curKey {
                datas.append(data!)
                keys.append(key)
                tokens.append(token)
              }
          }
        }
        
        compeletedBlock(datas, keys, tokens)
      }
      
      }.sendRequest()
  }
}



// MARK: - SmallLayoutDelegate
extension EditViewController {
  
  func layout(layout: smallLayout, begainSelectedItemAtIndexPath indexPath: NSIndexPath) {
    
    if let snapShot = layout.getSelectedItemSnapShot() {
      fakePageView = FakePageView.fakePageViewWith(snapShot, array: [bookModel.pageModels[indexPath.item]])
      fakePageView!.fromTemplate = false
      showDeletedButton(true, animated: true)
      view.addSubview(fakePageView!)
      
      let cell = collectionView.cellForItemAtIndexPath(indexPath)!
      let center = view.convertPoint(cell.center, fromView: collectionView)
      
      fakePageView!.center = center
      
      UIView.animateWithDuration(0.2, animations: {[unowned self] () -> Void in
        self.fakePageView!.transform = CGAffineTransformMakeScale(1.2, 1.2)
      })
      
    }
    
    layout.invalidateLayout()    
  }
  
  func layout(layout: smallLayout, willInsertSelectedItemAtIndexPath indexPath: NSIndexPath) {
    
    bookModel.insertPageModelsAtIndex(fakePageView!.getPageArray(), FromIndex: indexPath.item)
    collectionView.performBatchUpdates({ [weak self] () -> Void in
      self?.collectionView.insertItemsAtIndexPaths([indexPath])
      
    }, completion: { (finished) -> Void in
      
      if finished {
        layout.invalidateLayout()
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
      }
      
    })
    
  }
  
  func layout(layout: smallLayout, willMovedItemAtIndexPath FromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    bookModel.exchangePageModel(FromIndexPath.item, toIndex: toIndexPath.item)
//    exchange(&bookModel.pageModels, FromIndexPath.item, toIndexPath.item)
    collectionView.performBatchUpdates({[weak self] () -> Void in
    
      self?.collectionView.moveItemAtIndexPath(FromIndexPath, toIndexPath: toIndexPath)
      
    }, completion: { (finished) -> Void in
    
      if finished {
        layout.allowChangedItem = true
      }
    })
  }
  
  func layout(layout: smallLayout, willDeletedItemAtIndexPath indexPath: NSIndexPath) {
    bookModel.removePageModelAtIndex(indexPath.item)
    collectionView.performBatchUpdates({[weak self] () -> Void in
      
      self?.collectionView.deleteItemsAtIndexPaths([indexPath])
      
      }, completion: { (finished) -> Void in
    })
  }
  
  func layoutDidEndSelected(layout: smallLayout) {
    
    layout.invalidateLayout()
  }
  
  
}

















// MARK: - UIViewControllerTransitionDelegate
extension EditViewController {
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return TextEditorTransitionAnimation(dismissed: false)
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return TextEditorTransitionAnimation(dismissed: true)
  }
}

// MARK: - EditNavigationControllerDelegate
extension EditViewController {
  
  
  func navigationViewController(navigationController: EditNavigationViewController, didGetTemplateJson json: AnyObject) {
    
    
//    let page: PageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
//    bookModel.pageModels.insert(page, atIndex: 0)
//    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
//    self.collectionView.collectionViewLayout.layoutAttributesForElementsInRect(self.collectionView.bounds)
    
//    println(page)
  }
}


// MARK: - PageCellDelegate
extension EditViewController {
  
  func pageCollectionViewCellGetUserIDandPublishID(cell: PageCollectionViewCell) -> (String, String) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let publishID = bookModel.Id
    
    return (userID, publishID)
  }
}

// MARK: - EditToolBar Delegate
extension EditViewController {
  
  // begain \ change \ end
  func editToolBar(toolBar: EditToolBar, activedWithContainerModel containerModel: ContainerModel) {
    
    constraintsState = .ShowPannel
  }
  func editToolBar(toolBar: EditToolBar, didChangedToContainerModel containerModel: ContainerModel) {
  }
  func editToolBarDidDeactived(toolBar: EditToolBar) {
    constraintsState = .Default
  }
  
  // Default - Setting / AddText / AddImage / Preview
  func editToolBarDidSelectedSetting(toolBar: EditToolBar) {
    
    if let bookdetailNavigationController = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("bookdetailNavigationController") as? UINavigationController,
      let bookdetailController = bookdetailNavigationController.topViewController as? BookDetailViewController {
        
        bookdetailController.bookModel = bookModel
        bookdetailController.delegate = self
        presentViewController(bookdetailNavigationController, animated: true, completion: nil)
    }
    
  }
  func editToolBarDidSelectedPreview(toolBar: EditToolBar) {
    
//    EndEdit()
    HUD.preview_preparing()
    begainToPreview {[unowned self] (publishURL, delay) -> () in
      
      
      if let publishURL = publishURL {
//        HUD.dismiss()
        
        let time: NSTimeInterval = delay ? 1.0 : 0.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,
          Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
          
          self.showPreviewControllerWithUrl(publishURL, completion: { () -> Void in
            HUD.dismiss()
          })
        }
      } else {
        HUD.preview_fail()
      }
    }
    
//    if UploadsManager.shareInstance.uploadFinished() && !bookModel.isNeedUpload() && isUploaded && !bookModel.publishURLIsEmpty() {
//      
//      self.uploadComplete()
//      
//    } else {
//      
//      prepareForPreivew {[unowned self] (finished) -> () in
//        
//        if finished {
//          println(self.bookModel.Id)
//          
//          self.uploadComplete()
//        }
//      }
//    }
    
    
  }

  func editToolBarDidSelectedAddImage(toolBar: EditToolBar) {
    showsheet()
  }

  func editToolBarDidSelectedAddText(toolBar: EditToolBar) {
    addText("")
  }
  
   func editToolBarDidSelectedCancel(toolBar: EditToolBar) {
    EndEdit()
  }

}

// MARK: - BookDetailDelegate
extension EditViewController {
  
  func bookDetailViewControllerDidChangeIcon(iconData: NSData) {
    
    uploadIcon(iconData)
    
  }
  
  func uploadIcon(iconData: NSData) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let publishID = bookModel.Id
    let icon = "icon.jpg"
    let key = pathByComponents([userID, publishID, icon])
    
    prepareUploadImageData(iconData, key: key, compeletedBlock: { (theData, theKey, theToken) -> () in
      UploadsManager.shareInstance.upload([theData], keys: [theKey], tokens: [theToken])
    })
    
  }
}























// MARK: - Private Methods - Constraints
extension EditViewController {
  
  override func updateViewConstraints() {
    
    if !didLoadBegainConstraint {
      didLoadBegainConstraint = true
      setupConstraintsDefault()
    } else {
      switch constraintsState {
      case .Default:
        updateConstraintsToDefault()
        cellDown()
      case .ShowPannel:
        updateConstraintsToShowPannel()
        cellUp()
      default:
        return
      }
    }
    super.updateViewConstraints()
  }
  
  func setupConstraintsDefault() {
    
    editToolBar.snp_makeConstraints { (make) -> Void in
      make.height.equalTo(44)
      make.left.right.equalTo(view)
      make.bottom.equalTo(view)
    }
    
    editToolPannel.snp_makeConstraints { (make) -> Void in
      make.height.equalTo(85).constraint
      make.right.left.equalTo(view)
      make.top.equalTo(editToolBar.snp_bottom)
    }
    
    editNavigationViewController.view.snp_makeConstraints { (make) -> Void in
      make.left.right.top.equalTo(view)
      make.height.equalTo(maxY)
    }
  }
  
  
  // change to deafault constraints
  func updateConstraintsToDefault() {
    
    editToolBar.snp_updateConstraints { (make) -> Void in
      make.bottom.equalTo(view)
    }
    
    topToolBar.snp_updateConstraints { (make) -> Void in
      make.top.equalTo(view)
    }
  }
  
  // change to showPannel constraints
  func updateConstraintsToShowPannel() {
    editToolBar.snp_updateConstraints { (make) -> Void in
      make.bottom.equalTo(view).offset(-85)
    }
    
    topToolBar.snp_updateConstraints { (make) -> Void in
      make.top.equalTo(view).offset(-44)
    }
  }
  
  
  func cellUp() {
    
    if let indexpath = getCurrentIndexPath() {
      
      let cell = collectionView.cellForItemAtIndexPath(indexpath)
      let y = cell!.frame.origin.y

      if let visualCells = collectionView.visibleCells() as? [UICollectionViewCell] {
        
        for acell in visualCells {
          if acell != cell {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
            acell.alpha = 0
            })
          }
          
        }
      }
      
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.maskView?.center.y -= y
        cell!.transform = CGAffineTransformMakeTranslation(0, -y)

      }, completion: { (finished) -> Void in
        
      })
    }
  }
  
  func cellDown() {
    
    if let indexpath = getCurrentIndexPath() {
      
      let cell = collectionView.cellForItemAtIndexPath(indexpath)
      
      if let visualCells = collectionView.visibleCells() as? [UICollectionViewCell] {
        
        for acell in visualCells {
          if acell != cell {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
              acell.alpha = 1
            })
          }
        }
      }
      
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        
        cell!.transform = CGAffineTransformMakeTranslation(0, 0)
      })
    }
  }
  
//  func setupConstraints() {
//    
//    bottomToolBar.snp_makeConstraints({ (make) -> Void in
//      make.height.equalTo(44).constraint
//      make.left.right.equalTo(view)
//      make.bottom.equalTo(view)
//    })
//    
//    pannel.snp_updateConstraints({ (make) -> Void in
//      make.height.equalTo(85).constraint
//      make.left.right.equalTo(view)
//      make.top.equalTo(bottomToolBar.snp_bottom)
//    })
//  }
}










// MARK: - Private Methods
// MARK: -
extension EditViewController {
  
  // Current Indexpath
  private func getCurrentIndexPath() -> NSIndexPath? {
    let offsetMiddleX = collectionView.contentOffset.x + CGRectGetWidth(collectionView.bounds) / 2.0
    let offsetMiddleY = CGRectGetHeight(collectionView.bounds) / 2.0
    return collectionView.indexPathForItemAtPoint(CGPoint(x: offsetMiddleX, y: offsetMiddleY))
  }
  
  // Pop
  private func POPTransition(progress: Float, startValue: Float, endValue: Float) -> CGFloat {
    return CGFloat(startValue + (progress * (endValue - startValue)))
  }
  
  // pop
  private func togglePopAnimation(on: Bool) -> POPBasicAnimation {
    var animation: POPBasicAnimation! = self.pop_animationForKey("Pop") as! POPBasicAnimation!
    if animation == nil {
      animation = POPBasicAnimation()
      
      typealias PopInitializer = ((POPMutableAnimatableProperty!) -> Void)!
      
      let ainitializer: PopInitializer = {
        (prop: POPMutableAnimatableProperty!) -> Void in
        prop.readBlock = {
          (obj: AnyObject!, values: UnsafeMutablePointer<CGFloat>) in
          if let controller = obj as? EditViewController {
            values[0] = CGFloat(controller.progress)
          }
          
        }
        
        prop.writeBlock = {
          (obj: AnyObject!, values: UnsafePointer<CGFloat>) -> Void in
          if let controller = obj as? EditViewController {
            controller.progress = Float(values[0])
          }
        }
        prop.threshold = 0.001
      }
      animation.property = POPAnimatableProperty.propertyWithName("progress", initializer: ainitializer) as! POPAnimatableProperty
      self.pop_addAnimation(animation, forKey: "Pop")
      
    }
    animation.toValue = on ? 1.0 : 0.0
    animation.completionBlock = {
      (pop: POPAnimation!, finished: Bool) -> Void in
      
      if finished {
        if on {
          self.collectionView.finishInteractiveTransition()
        } else {
          self.collectionView.cancelInteractiveTransition()
        }
      }
    }
    
    return animation
  }
  
  // pop
  private func transitionByProgress(aProgress: Float) {
    
    // collectionView Translation 0 ~ 1
    if transitionLayout != nil {
      let y = POPTransition(aProgress, startValue: isToSmallLayout ? 0 : maxY, endValue: isToSmallLayout ? maxY : 0)
      let toolBarAlpha = POPTransition(aProgress, startValue: isToSmallLayout ? 1 : 0, endValue: isToSmallLayout ? 0 : 1)
      let yTran = min(max(y, 0), CGFloat(maxY))
      collectionView.transform = CGAffineTransformMakeTranslation(0, yTran)
      topToolBar.alpha = toolBarAlpha
      editToolBar.alpha = toolBarAlpha
    }
    
    // layout Transition  0 ~ 1
    if transitionLayout != nil {
      let pro = min(max(aProgress, 0), 1)
      transitionLayout.transitionProgress = CGFloat(pro)
      transitionLayout.invalidateLayout()
    }
  }
  
  // deprecated
  
  
  // deprecated
  
  
  // deprecated

  // deprecated
}


// MARK: - ☄
// MARK: - ☄ Deprecated



// MARK: - DataSource And Delegate
// MARK: -
extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate ,SmallLayoutDelegate, IPageProtocol, EditToolsBarProtocol {
  
  // MARK: - UICollectionViewDataSource and CollectionView Delegate
  
//  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//    collectionView.collectionViewLayout.invalidateLayout()
//    
//    return 1
//  }
  
  func resetSeletctBorder() {
    
    if let indexPath = getCurrentIndexPath() where collectionView.collectionViewLayout is NormalLayout {
      let cells = collectionView.visibleCells() as! [UICollectionViewCell]
      
      for cell in cells {
          cell.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
      }
    }
  }
  
  func updateSelectBorder() {
    if let indexPath = getCurrentIndexPath() where collectionView.collectionViewLayout is NormalLayout {
      let cells = collectionView.visibleCells() as! [UICollectionViewCell]
      
      for cell in cells {
        
        if let aIndexPath = collectionView.indexPathForCell(cell) where aIndexPath.compare(indexPath) == .OrderedSame {
          cell.layer.borderColor = UIColor.blueColor().colorWithAlphaComponent(0.5).CGColor
        } else {
          cell.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        }
      }
    }
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    resetSeletctBorder()
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
    updateSelectBorder()
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    
    updateSelectBorder()
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return bookModel.pageModels.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PageCollectionViewCell
    cell.backgroundColor = UIColor.whiteColor()
    cell.pageCellDelegate = self
    cell.configCell(bookModel.pageModels[indexPath.item], queue: queue)
    
    cell.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
    cell.layer.borderWidth = 1
    
    return cell
  }
  
  
  func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout! {
    return TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
  }
  
  
  // MARK: - SmallLayout Delegate
  
  func layout(layout: UICollectionViewLayout, willMoveInAtIndexPath indexPath: NSIndexPath) {
    
    bookModel.insertPageModelsAtIndex([self.fakePageView!.getPlaceholderPage()], FromIndex: indexPath.item)
    collectionView?.performBatchUpdates({ [weak self] () -> Void in
      
      self!.collectionView?.insertItemsAtIndexPaths([indexPath])
      
      }, completion: { (completed) -> Void in
    })
    
    if (fakePageView!.fromTemplate) {
      
      
    } else {
      bookModel.insertPageModelsAtIndex([fakePageView!.getPlaceholderPage()], FromIndex: indexPath.item)
    }
    
  }
  
  func layout(layout: UICollectionViewLayout, willMoveOutFromIndexPath indexPath: NSIndexPath) {
    
    collectionView?.performBatchUpdates({ [weak self]() -> Void in
      self!.bookModel.removePageModelAtIndex(indexPath.item)
      self!.collectionView?.deleteItemsAtIndexPaths([indexPath])
      }, completion: { [unowned self] (completed) -> Void in
      })
    
  }
  
  func layout(layout: UICollectionViewLayout, willChangeFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    bookModel.exchangePageModel(fromIndexPath.item, toIndex: toIndexPath.item)
//    collectionView?.performBatchUpdates({ [weak self] () -> Void in
//      exchange(&self!.bookModel.pageModels, fromIndexPath.item, toIndexPath.item)
      collectionView?.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
//      }, completion: nil)
    
  }
  
  func layoutDidMoveIn(layout: UICollectionViewLayout, didMoveInAtIndexPath indexPath: NSIndexPath) {
    bookModel.removePageModelAtIndex(indexPath.item)
    
//    collectionView?.performBatchUpdates({ () -> Void in
    
      self.collectionView?.deleteItemsAtIndexPaths([indexPath])
      
//      }, completion: { (completed) -> Void in
//    })
    
//    let fileManager = NSFileManager.defaultManager()
//    
//    var indexPaths = [NSIndexPath]()
//    var newPages = [PageModel]()
//    var Index = indexPath.item
//    let pageModels = fakePageView!.getPageArray()
//    for aPage in pageModels {
//      
//      let newPageId = UniqueIDStringWithCount(count: 10)
//      let originBookPath = aPage.delegate?.fileGetSuperPath(aPage)
//      let orginPageURL = URL(originBookPath!)(isDirectory: true)(pages, aPage.Id)
//      let newPageURL = URL(bookModel.filePath)(isDirectory: true)(pages, newPageId)
//      
//      if fileManager.copyItemAtURL(orginPageURL, toURL: newPageURL, error: nil) {
//        
//        let copyPageOriginJson = URL(bookModel.filePath)(isDirectory: true)(pages, newPageId ,aPage.Id + ".json")
//        let copyPageNewJson = URL(bookModel.filePath)(isDirectory: true)(pages,newPageId ,newPageId + ".json")
//        let copyPageOriginData = NSData(contentsOfURL: copyPageOriginJson)
//        var newJson = NSJSONSerialization.JSONObjectWithData(copyPageOriginData!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]
//        newJson["ID"] = newPageId
//        let newJsonData = NSJSONSerialization.dataWithJSONObject(newJson, options: NSJSONWritingOptions(0), error: nil)
//        newJsonData?.writeToURL(copyPageNewJson, atomically: true)
//        
//        let newPageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: newJson, error: nil) as! PageModel
//        
//        fileManager.removeItemAtURL(copyPageOriginJson, error: nil)
//        
//        newPages.append(newPageModel)
//        let indexPath = NSIndexPath(forItem: Index, inSection: 0)
//        indexPaths.append(indexPath)
//        Index++
//      }
//    }
//    bookModel.insertPageModelsAtIndex(newPages, FromIndex: indexPath.item)
//    collectionView?.performBatchUpdates({ () -> Void in
//      
//      self.collectionView?.insertItemsAtIndexPaths(indexPaths)
//      
//      }, completion: { (completed) -> Void in
//    })
  }
  
  func layoutDidMoveOut(layout: UICollectionViewLayout) {
    
//    if !fakePageView!.fromTemplate {
//      let aPageModel = fakePageView!.getPlaceholderPage()
//      let bookPath = bookModel.filePath
//      let pagePath = bookPath.stringByAppendingPathComponent("Pages/" + aPageModel.Id)
//      let fileManager = NSFileManager.defaultManager()
//      fileManager.removeItemAtPath(pagePath, error: nil)
//    }
  }
  
  func layout(layout: UICollectionViewLayout, didFinished finished: Bool) {
    
//    bookModel.savePagesInfo()
  }
  
  
  // MARK: - PreviewController delegate
  func previewControllerGetBookModel(controller: PreviewViewController) -> BookModel {
    
    return bookModel
  }
  
  
  // MARK: - Gesture Delegate
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
      
      switch gestureRecognizer {
        
      case let gesture as UITapGestureRecognizer where gesture == singleTapGesture :
        
          
          let location = gesture.locationInView(editToolBar)
          let locationinPannel = gesture.locationInView(editToolPannel)
          
          if CGRectContainsPoint(editToolBar.bounds, location) || CGRectContainsPoint(editToolPannel.bounds, locationinPannel) {
            return false
          }
          
          let isNormalLayout = self.collectionView.collectionViewLayout is NormalLayout
          if !isNormalLayout {
            backToNormalLayout(gesture)
          }

        return isNormalLayout ? true : false
        
      case let gesture where gesture is UIPanGestureRecognizer:
        
        if maskView != nil {
          return false
        }
        
        return transitionLayout == nil ? true : false
      case let gesture where gesture is UILongPressGestureRecognizer:
        return collectionView.collectionViewLayout is smallLayout
        
      default:
        return true
      }
    }
}


