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


 func exchange<T>(inout data: [T], i:Int, j:Int) {
    let temp:T = data[i]
    data[i] = data[j]
    data[j] = temp
}

func pathByComponents(components: [String]) -> String {
  let begain = ""
  let path = components.reduce(begain) {$0.stringByAppendingString("/" + $1)}
  return path
}


class EditViewController: UIViewController, UIViewControllerTransitioningDelegate, MaskViewDelegate, PageCollectionViewCellDelegate, IPageProtocol, preViewControllerProtocol {
    
    enum ToolState {
        case willSelect
        case didSelect
        case endEdit
    }
    
    var bottomToolBar: ToolsBar!
    var pannel: ToolsPannel!
    var toolState: ToolState = .endEdit
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var singleTapGesture: UITapGestureRecognizer!
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!

    var bookModel: BookModel!
    var templateViewController: EditorTemplateNavigationController!
    var SmallLayout = smallLayout()
    var normalLayout = NormalLayout()
    let queue = NSOperationQueue()
    var fakePageView: FakePageView?
    var transitionLayout: TransitionLayout!
    let maxY = Float(LayoutSpec.layoutConstants.maxTransitionLayoutY)
    var beganPanY: CGFloat = 0.0
    var isToSmallLayout = false
    var multiSection = false
    var maskView: MaskView?
  var isReplacedImage: Bool = false
  
  
    var maskAttributes = [IMaskAttributeSetter]()
    var currentEditContainer: IContainer?
    var pageEditing: Bool {
        get {
            return multiSection && maskAttributes.count > 0
        }
    }
    var progress: Float = 0.0 {
        didSet {
            
            if transitionLayout != nil {
                transitionByProgress(progress)
            }
        }
    }
    
    let barName: [String : String] = [
        "setting": "Editor_Setting",
        "addImage": "Editor_ImagePicker",
        "addText": "Editor_Text",
        "preview": "Editor_Preview",
        "effects": "Editor_Effects",
        "fontName": "Editor_FontName",
        "fontAttribute" : "Editor_Text",
        "typography": "Editor_Typography",
        "animation": "Editor_Animation",
        "interact": "Editor_Interact"
    ]
    
    let barActionName: [String : String] = [
    
       "setting": "settingAction:",
        "addImage": "addImageAction:",
        "addText": "addTextAction:",
        "preview": "previewAction:",
        "effects": "effectsAction:",
        "fontName": "fontNameAction:",
        "fontAttribute" : "fontAction:",
        "typography": "typographyAction:",
        "animation": "animationAction:",
        "interact": "interactActtion:"
    ]
    
    var defaultBarItems: [UIBarButtonItem] {

        let itemsKey = ["setting", "addImage", "addText", "preview"]
        return getBarButtonItem(itemsKey)
    }
    
    var imageBarItems: [UIBarButtonItem] {
        
        let itemsKey = ["effects", "typography", "animation", "interact"]
        return getBarButtonItem(itemsKey)
    }
    
    var textBarItems: [UIBarButtonItem] {
        
        let itemsKey = ["effects", "fontName", "fontAttribute", "typography", "animation", "interact"]
        return getBarButtonItem(itemsKey)
    }
    
    var textInputView: TextInputView?
    var colorPickView: ColorPickView?
    
    func getBarButtonItem(itemsKey: [String]) -> [UIBarButtonItem] {
        var items = [UIBarButtonItem]()
        for akey in itemsKey {
            let imageName = barName[akey]!
            let action = barActionName[akey]!
            let barItem = UIBarButtonItem(title: imageName, style: .Plain, target: self, action: Selector(action))
            items.append(barItem)
        }
        return items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      prepareForPreivew { (finished) -> () in
        
        
      }
        
        SmallLayout.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        let normal = NormalLayout()
        collectionView.setCollectionViewLayout(normal, animated: false)
        collectionView.decelerationRate = 0.1
        
        bottomToolBar = ToolsBar(aframe:CGRect(x: 0, y: 568 - 64, width: 320, height: 64) , aItems: defaultBarItems, aDelegate: self)
        pannel = ToolsPannel()
        pannel.delegate = self
        pannel.backgroundColor = UIColor.lightGrayColor()
        
        
        view.addSubview(bottomToolBar)
        view.addSubview(pannel)
        
        setupConstraints()
        
        addKeyboardNotification()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if templateViewController == nil {
            
            setupTemplateController()

        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func loadBookWith(aBookID: String) {
        
        bookModel = getbookModelWith(aBookID)
    }
    
    deinit {
        
        removeKeyboardNotification()
    }
    
    override func updateViewConstraints() {
        
        updateWithState(toolState)
     
        super.updateViewConstraints()
    }
}

// MARK: - IBActions
extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    
    @IBAction func PanAction(sender: UIPanGestureRecognizer) {
        
        let transition = sender.translationInView(view)
        
        switch sender.state {
        case .Began:
            
            beganPanY = LayoutSpec.layoutConstants.screenSize.height - sender.locationInView(view).y
            isToSmallLayout = collectionView.collectionViewLayout is NormalLayout
            let nextLayout = isToSmallLayout ? SmallLayout : normalLayout
            transitionLayout = collectionView.startInteractiveTransitionToCollectionViewLayout(nextLayout, completion: { [unowned self] (completed, finish) -> Void in
                
                self.transitionLayout = nil
                self.progress = 0
                
                }) as! TransitionLayout
            
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
        switch sender.state {
        case .Began:
            
            if collectionView.collectionViewLayout is smallLayout {
                // collectionView
                if CGRectContainsPoint(collectionView.frame, location) {
                    let pageLocation = sender.locationInView(collectionView)
                    if let aSmallLayout = collectionView.collectionViewLayout as? smallLayout
                        where aSmallLayout.selectedItemBeganAtLocation(pageLocation) {
                        if let snapShot = aSmallLayout.getSelectedItemSnapShot() {
                            fakePageView = FakePageView.fakePageViewWith(snapShot, array: [bookModel.pageModels[aSmallLayout.placeholderIndexPath!.item]])
                            fakePageView?.fromTemplate = false
                            fakePageView?.center = location
                            view.addSubview(fakePageView!)
                        }
                    }
                // template
                } else if CGRectContainsPoint(templateViewController.view.bounds, sender.locationInView(templateViewController.view)) {
                    
                    let loction = sender.locationInView(templateViewController.view)
                    if let snapShot = templateViewController.getSnapShotInPoint(location) {
                        
                        if let aPageModels = templateViewController.getPageModels(location) {
                            fakePageView = FakePageView.fakePageViewWith(snapShot, array: aPageModels)
                            fakePageView?.fromTemplate = true
                            fakePageView?.center = location
                            view.addSubview(fakePageView!)
                        } else {
                            fallthrough
                        }
                    }
                }
                
                // LongPress In NormalLayout
            } else if collectionView.collectionViewLayout is NormalLayout {
                
                // TODO: Mask
                if let currentIndexPath = getCurrentIndexPath() {
                    if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
                        let location = sender.locationInView(view)
                        page.setDelegate(self)
                    }
                }
            }
            
        case .Changed:
            
            if collectionView.collectionViewLayout is smallLayout {
                if let fake = fakePageView {
                    fake.center = location
                    
                    if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
                        let inEditBoundsLocation = sender.locationInView(collectionView)
                        aSmallLyout.selectedItem(CGRectContainsPoint(collectionView.frame, location), AtLocation: inEditBoundsLocation)
                    }
                }
                
            } else if collectionView.collectionViewLayout is NormalLayout {
                
                // TODO: Mask
            }
            
        case .Cancelled, .Ended:
            
            if collectionView.collectionViewLayout is smallLayout {
                if fakePageView != nil {
                    if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
                        //                    if CGRectContainsPoint(collectionView.frame, location) {
                        aSmallLyout.selectedItemMoveFinishAtLocation(location, fromeTemplate: fakePageView!.fromTemplate)
                        //                    }
                    }
                    
                    fakePageView?.removeFromSuperview()
                    fakePageView?.clearnPageArray()
                    fakePageView = nil
                }
                
                
            } else if collectionView.collectionViewLayout is NormalLayout {
                
                // TODO: Mask
                
                multiSection = false
                if !pageEditing {
                    if let currnetIndexPath = getCurrentIndexPath() {
                        if let page = collectionView.cellForItemAtIndexPath(currnetIndexPath) as? IPage {
                            page.cancelDelegate()
                        }
                    }
                }
            }
            
        default:
           return
        }
    }
    

    
  
    
    func defaultTextSize() -> CGSize {
        
        let textTextContent = NSString(string: "双击\n修改")
        let font = UIFont.systemFontOfSize(40)
        let size = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let rect = textTextContent.boundingRectWithSize(
            size,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: textFontAttributes,
            context: nil
        )
        
        return rect.size
    }

    
    @IBAction func previewAction(sender: UIBarButtonItem) {
        
        let userID = UsersManager.shareInstance.getUserID()
        let bookID = bookModel.Id
//        let mainjsonPath = temporaryDirectory(userID,bookID,"main.json").path!
//        let key = userID.stringByAppendingPathComponent(bookID).stringByAppendingPathComponent("main.json")
//        FileUplodRequest.uploadFileWithKeyFile([key: mainjsonPath])
//        
//       if let preeviewNavigationC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("PreviewNavigationController") as? UINavigationController,
//        let prev = preeviewNavigationC.topViewController as? PreviewViewController {
//            prev.bookId = bookID
//            prev.delegate = self
//            presentViewController(preeviewNavigationC, animated: true, completion: nil)
//        }
        
        
        // cache preview dir
        let previewName = "CuriosPreview"
        
        // bundle preview
        let bundlePreviewURL = bundle(previewName)
        // cache preview
        let cachePreviewURL = temporaryDirectory(previewName)
        
        // /res
        let cachePreviewResURL = temporaryDirectory(previewName, "res")
        
        // curiosRes.js
        let curiosResURL = temporaryDirectory(previewName, "js", "curiosRes.js")
        
        // copy cachePreviewURL
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtURL(cachePreviewURL, error: nil)
        if !fileManager.copyItemAtURL(bundlePreviewURL, toURL: cachePreviewURL, error: nil) {

            assert(false, "preview fail: can not copy bundle preview file to cache")

        } else {
        
            // write mainjson and pagejson to curiosRes.js
            let bookmodel = bookModel
            let pagesmodel = bookModel.pageModels
            bookmodel.previewPageID = pagesmodel[0].Id
            
            let bookmodeljsonDic = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)
            let bookmodeljsonData = NSJSONSerialization.dataWithJSONObject(bookmodeljsonDic, options: NSJSONWritingOptions(0), error: nil)
            let pagesjsonDic = MTLJSONAdapter.JSONArrayFromModels(pagesmodel, error: nil)
            let pagesjsonData = NSJSONSerialization.dataWithJSONObject(pagesjsonDic, options: NSJSONWritingOptions(0), error: nil)
            let bookmodeljsonString = NSString(data: bookmodeljsonData!, encoding: NSUTF8StringEncoding) as! String
            let pagesjsonString = NSString(data: pagesjsonData!, encoding: NSUTF8StringEncoding) as! String
            let curiosResString = "curiosMainJson=" + bookmodeljsonString + ";" + "curiosPagesJson = " + pagesjsonString
        
            if !curiosResString.writeToURL(curiosResURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil) {

            } else {
                
                println("curiosRes.js write successful")
                
                let fileKeys  = getFileKeys(previewName, rootURL: cachePreviewURL, userID: userID, publishID: bookID)
                
                FileUplodRequest.uploadFileWithKeyFile(fileKeys)
                
                publish()
                
                println(fileKeys)
            }
        }
        
        
        
        
        
        
        
        
        
        
////        if let preeviewVC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("PreviewController") as? PreviewViewController {
        
            
            // create cache preview book
        
//            if !fileManager.copyItemAtURL(bundlePreviewURL, toURL: cachePreviewURL, error: nil) {
//                
//                assert(false, "preview fail: can not copy bundle preview file to cache")
//                
//            } else {
//                
//                // copy editing book to res dir
//                fileManager.removeItemAtURL(cachePreviewResURL, error: nil)
//                if !fileManager.copyItemAtURL(editingBookURL, toURL: cachePreviewResURL, error: nil) {
//                    assert(false, "preview fail: can not copy edit book file to res dir")
//                } else {

//
//                    if !curiosResString.writeToURL(curiosResURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil) {
//                        assert(false, "preview fail: fail to write curiosRes.js")
//                    } else {
//                        
//                        let string = NSString(contentsOfURL: curiosResURL, encoding: NSUTF8StringEncoding, error: nil)
//                        
//                       if let preeviewNavigationC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("PreviewNavigationController") as? UINavigationController,
//                        let prev = preeviewNavigationC.topViewController as? PreviewViewController {
//                            prev.bookId = bookid
//                            prev.delegate = self
//                            presentViewController(preeviewNavigationC, animated: true, completion: nil)
//                        }
//                    }
//                }
//            }
//        }
    }
    
    func publish() {
        
        let userID = UsersManager.shareInstance.getUserID()
        let publishID = bookModel.Id
        let publishURL = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("index.html")
        let snapshot = [["pageNumber":"1","snapshotURL":"73ed8dc9b0794a079d430c8f7fce9d79/91abba1e30f848c7a4fde6c96bd95a0c/snapshot/1.png"]]
        
       let requset = PublishRequest.requestWith(userID, publishID: publishID, publishURL: publishURL, publisherIconURL: "", publishTitle: "Emiaostein", publishDesc: "hhaah", publishSnapshots: snapshot) { (result) -> Void in
            
            println("publish reslut = \(result)")
        }
        
        requset.sendRequest()
    }
    
    
    func getFileKeys(rootDirectoryName: String, rootURL: NSURL, userID: String, publishID: String) -> [String : String] {
        
        
        let fileManger = NSFileManager.defaultManager()
        var error = NSErrorPointer()
        let mainDirEntries = fileManger.enumeratorAtURL(rootURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsPackageDescendants | NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, error) -> Bool in
            println(url.lastPathComponent)
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
        
        let userid = UsersManager.shareInstance.getUserID()
        saveBook()
        deleteTemporaryBookWithUserId(userid)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // book detail Action
    func settingAction(sender: UIButton) {
        
        if let bookdetailNavigationController = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("bookdetailNavigationController") as? UINavigationController,
            let bookdetailController = bookdetailNavigationController.topViewController as? BookDetailViewController {
                
                bookdetailController.bookModel = bookModel
                presentViewController(bookdetailNavigationController, animated: true, completion: nil)
        }
    }
    
    func effectsAction(sender: UIButton) {
        
        toolState = .didSelect
        pannel.setupSubPannelWithType(.Effect)
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func fontNameAction(sender: UIButton) {
        toolState = .didSelect
        pannel.setupSubPannelWithType(.Font)
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func fontAction(sender: UIButton) {
        
        toolState = .didSelect
        pannel.setupSubPannelWithType(.FontAttribute)
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func typographyAction(sender: UIButton) {
        
        toolState = .didSelect
        pannel.setupSubPannelWithType(.Typography)
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func animationAction(sender: UIButton) {
        
        toolState = .didSelect
        pannel.setupSubPannelWithType(.Animation)
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func interactActtion(sender: UIButton) {
        
        toolState = .didSelect
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}








// MARK: - ToolBar Action
extension EditViewController {
  
  @IBAction func addImageAction(sender: UIBarButtonItem) {
    showsheet()
  }
  
  @IBAction func addTextAction(sender: UIBarButtonItem) {

    addText("")
    
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
      
      if toolState != .didSelect {
        
        if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? PageCollectionViewCell  {
          page.setDelegate(self)
          let location = sender.locationInView(page)
          page.begainResponseToTap(location, tapCount: 1)
        }
      } else {
        if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
          let location = CGPointZero
          page.setDelegate(self)
        }
      }
    }
  }
}


// MARK: - Action  - New
extension EditViewController {
  
  func addText(text: String) {
    
    EndEdit()
    
    if let indexPath = getCurrentIndexPath() {
      
      if bookModel.pageModels.count <= 0 {
        return
      }
      
      let pageModel = bookModel.pageModels[indexPath.item]
      
      let defaultTextAttribute = [ "Text": "Double Click\nto Change",
        "FontName": "RTWSYueRoudGoG0v1-Regular",
        "FontSize": 30,
        "TextColor": "#282A35",
        "TextAligment": "Center",
        "ImagePath": " "
      ]
      
      let textComponent = TextContentModel()
      textComponent.type = .Text
      textComponent.attributes = defaultTextAttribute
      let container = ContainerModel()
      container.component = textComponent
      
      pageModel.addContainerModel(container, OnScreenSize: CGSize(width: 100, height: 50))
      begainEdit()
    }
  }
  
  
  func addImage(image: UIImage, userID: String, publishID: String) {
    
    EndEdit()
    
    if let indexPath = getCurrentIndexPath() {
      
      if bookModel.pageModels.count <= 0 {
        return
      }
      
      let pageModel = bookModel.pageModels[indexPath.item]
      
      let defaultTextAttribute = [ "ImageSourceType": "Relative",
        "ImagePath": ""
      ]
      
      let imageComponent = ImageContentModel()
      imageComponent.type = .Image
      imageComponent.updateImage(image, userID: userID, PublishID: publishID)
      let container = ContainerModel()
      container.component = imageComponent
      
      pageModel.addContainerModel(container, OnScreenSize: image.size)
      begainEdit()
    }
  }
  
  func replaceImage(image: UIImage, userID: String, publishID: String) {
    
    if let aMaskView = maskView,
      let imagecomponent = aMaskView.containerMomdel.component as? ImageContentModel {
        imagecomponent.updateImage(image, userID: userID, PublishID: publishID)
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
  
  func begainUploadResourseWithModel(containerModel: ContainerModel) {
    
    let compoent = containerModel.component
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
    
    ImageTokenRequest.requestWithComponents(getImageToken, aJsonParameter: imageTokenDic) { (json) -> Void in
      
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
      let attriString = component.getDemoAttributeString()
      showTextInputControllerWithAttributeString(attriString) { [unowned self](attri) -> () in
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          containerModel.needUpdateOnScreenSize(true)
        })
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
  }
  
  func pageDidDeSelected(page: PageModel, deselectedContainer container: ContainerModel) {
    
    container.setSelectedState(false)
    removeMaskByModel(targetContainerModel: container)
    
    begainUploadResourseWithModel(container)
  }
  
  func pageDidDoubleSelected(page: PageModel, doubleSelectedContainer container: ContainerModel) {
    
    if container.component is ImageContentModel {
      isReplacedImage = true
      showsheet()
    } else if let textComponent = container.component as? TextContentModel {
      
      let attriString = textComponent.getDemoAttributeString()
      showTextInputControllerWithAttributeString(attriString) { [unowned self](attri) -> () in
        
       dispatch_async(dispatch_get_main_queue(), { () -> Void in
        container.needUpdateOnScreenSize(true)
       })
      }
    }
  }
  
  func pageDidEndEdit(page: PageModel) {
    collectionView.scrollEnabled = true
  }
}




  
  
  
  
  
  
  
  
  
  
  
  

// MARK: - ImageEditor
extension EditViewController {
  
  // show Sheet
  private func showsheet() {
    
    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    if (UIImagePickerController.availableMediaTypesForSourceType(.Camera) != nil) {
      
      let CameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) -> Void in
        
        self.showImagePicker(.Camera)
      }
      sheet.addAction(CameraAction)
    }
    
    let LibarayAction = UIAlertAction(title: "Libaray", style: .Default) { (action) -> Void in
      
      self.showImagePicker(.PhotoLibrary)
    }
    let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
      
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
    
    // Selected Image
    let selectedImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
    let imageData = UIImageJPEGRepresentation(selectedImage, 0.001)
    let image = UIImage(data: imageData)!
    
    isReplacedImage ? replaceImage(image, userID: userID, publishID: publishID) : addImage(image, userID: userID, publishID: publishID)
    isReplacedImage = false
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}




 // MARK: - TextEditor
extension EditViewController {
  
  private func showTextInputControllerWithAttributeString(attributeString: NSAttributedString, compelectedBlock: (NSAttributedString) -> ()) {
    
    if let textEditorViewController = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextEditorViewController") as? TextEditorViewController {
      textEditorViewController.setAttributeString(attributeString)
      textEditorViewController.transitioningDelegate = self
      textEditorViewController.completeBlock = compelectedBlock
      presentViewController(textEditorViewController, animated: true, completion: nil)
    }
  }
}
  
// MARK: - PreviewEditor
extension EditViewController {
  

  
  //Upload main json and html file
  func prepareForPreivew(completedBlock:(Bool) -> ()) {
    
//    let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)
//    let data = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
    
    UploadsManager.shareInstance.setCompeletedHandler { (finished) -> () in
      
      println(" upload finished")
    }
    
    uploadPublishFile { (datas, keys, tokens) -> () in
      
      UploadsManager.shareInstance.upload(datas, keys: keys, tokens: tokens)
    }
  }
  
  func uploadPublishFile(compeletedBlock:([NSData], [String], [String]) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let bookID = bookModel.Id
    let res = "res"
    let js = "js"
    let ani = "curiosAnim.js"
    let cur = "curiosRes.js"
    let jqu = "jquery-1.10.1.min.js"
    let mai = "main.js"
    let index = "index.html"
    let main = "main.json"
    
    let indexKey = pathByComponents([userID, bookID, index])
    let aniKey = pathByComponents([userID, bookID, js, ani])
    let curKey = pathByComponents([userID, bookID, js, cur])
    let jquKey = pathByComponents([userID, bookID, js, jqu])
    let maiKey = pathByComponents([userID, bookID, js, mai])
    
    let publishTokenDic: String = {
      let dic = ["list":[
//        ["key": indexKey],
//        ["key": aniKey],
        ["key": curKey]
//        ["key": jquKey],
//        ["key": maiKey]
        ]
      ]
      let jsondata = NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(0), error: nil)
      let string = NSString(data: jsondata!, encoding: NSUTF8StringEncoding) as! String
      return string
    }()
    
    let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)
    let data = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
    
    PublishTokenRequest.requestWithComponents(getPublishToken, aJsonParameter: publishTokenDic) { (json) -> Void in
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










  
  


// MARK: - UIViewControllerTransitionDelegate
extension EditViewController {
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return TextEditorTransitionAnimation(dismissed: false)
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return TextEditorTransitionAnimation(dismissed: true)
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


// MARK: - ☄
// MARK: - ☄ Deprecated









  // MARK: - Ipage Protocol - Old
extension EditViewController {
  // selected
  func pageDidSelected(page: IPage, selectedContainer: IContainer, position: CGPoint, size: CGSize, rotation: CGFloat, ratio: CGFloat, inTargetView: UIView) {
    
    let mask: IMaskAttributeSetter = ContainerMaskView.createMask(position, size: size, rotation: rotation, aRatio: ratio)
    mask.setTarget(selectedContainer)
    mask.setDelegate(self)
    if let aMask = mask as? UIView {
      view.addSubview(aMask)
    }
    
    changeToContainer(selectedContainer)
    
    
    maskAttributes.append(mask)
  }
  
  // deseleted
  func pageDidDeSelected(page: IPage, deSelectedContainers: [IContainer]) {
    
    if deSelectedContainers.count > 0 {
      for container in deSelectedContainers {
        var index = 0
        
        for maskAttribute in maskAttributes {
          
          if let aTarget = maskAttribute.getTarget() {
            if aTarget.isEqual(container) {
              
              maskAttribute.remove()
              maskAttributes.removeAtIndex(index)
              break
            }
          }
          index++
        }
      }
    }
  }
  
  // wheather multiSelection
  func shouldMultiSelection() -> Bool {
    
    return multiSection
  }
  
  // end edit
  func didEndEdit(page: IPage) {

    page.saveInfo()
    
    let userID = UsersManager.shareInstance.getUserID()
    let bookID = bookModel.Id
    
    page.uploadInfo(userID, publishID: bookID)
    
    page.cancelDelegate()
    
    endContainer()
    toolState = .endEdit
    view.setNeedsUpdateConstraints()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
}



















// MARK: - DataSource And Delegate
// MARK: -
extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate ,SmallLayoutDelegate, IPageProtocol, EditToolsBarProtocol, PannelProtocol, IMaskAttributeSetterProtocol {
  
    // MARK: - UICollectionViewDataSource and CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return bookModel.pageModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PageCollectionViewCell
        cell.backgroundColor = UIColor.darkGrayColor()
      cell.pageCellDelegate = self
        cell.configCell(bookModel.pageModels[indexPath.item], queue: queue)
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout! {
        return TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    
    // MARK: - Pannel Delegate
    func pannelGetContainer() -> IContainer? {
        
        return currentEditContainer
    }
    
    func pannelDidSendEvent(event: PannelEvent, object: AnyObject?) -> Void {
        
        switch event {
            
        case .FontNameChanged:
            if let aCurrentContainer = currentEditContainer, atextComponent = aCurrentContainer.component as? ITextComponent, let name = object as? String {
//                let size = atextComponent.settFontsName(name)
//                    aCurrentContainer.setResize(size, center: CGPointZero, resizeComponent: false, scale: false)
              
                if !maskAttributes.isEmpty {
                    
                    let mask = maskAttributes[0]
//                    mask.setMaskSize(size)
                }
            }
            
        case .FontColorSetting:
            if let aCurrentContainer = currentEditContainer, atextComponent = aCurrentContainer.component as? ITextComponent {
                
                colorPickView = UINib(nibName: "ColorPickView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as? ColorPickView

                colorPickView?.setDidSelectedBlock({ (colorDic) -> Void in
                    
//                    atextComponent.setTextColor(colorDic)
                })
                
                colorPickView?.setdissmissBlock({[unowned self] () -> () in
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.colorPickView?.alpha = 0.0
                        
                    }, completion: { (finished) -> Void in
                        
                        self.colorPickView?.removeFromSuperview()
                        self.colorPickView = nil
                    })
                })
                
//                colorPickView?.setSelectedColorString(atextComponent.getTextColor())
                
                view.addSubview(colorPickView!)
                colorPickView?.alpha = 0.0
                
                colorPickView!.snp_makeConstraints({[unowned self] (make) -> Void in
                    
                    make.height.equalTo(149)
                    make.left.right.bottom.equalTo(self.view)
                })

                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.colorPickView?.alpha = 1.0
                })

            }
            
        default:
            return
        }
    }
    
    // MARK: - SmallLayout Delegate
    
    func layout(layout: UICollectionViewLayout, willMoveInAtIndexPath indexPath: NSIndexPath) {
        if (fakePageView!.fromTemplate) {
            bookModel.insertPageModelsAtIndex([PageModel()], FromIndex: indexPath.item)
        } else {
            bookModel.insertPageModelsAtIndex([fakePageView!.getPlaceholderPage()], FromIndex: indexPath.item)
        }
        
    }
    
    func layout(layout: UICollectionViewLayout, willMoveOutFromIndexPath indexPath: NSIndexPath) {
        bookModel.removePageModelAtIndex(indexPath.item)
    }
    
    func layout(layout: UICollectionViewLayout, willChangeFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        exchange(&bookModel.pageModels, fromIndexPath.item, toIndexPath.item)
    }
    
    func layoutDidMoveIn(layout: UICollectionViewLayout, didMoveInAtIndexPath indexPath: NSIndexPath) {
        bookModel.removePageModelAtIndex(indexPath.item)
        
        collectionView?.performBatchUpdates({ () -> Void in
            
            self.collectionView?.deleteItemsAtIndexPaths([indexPath])
            
            }, completion: { (completed) -> Void in
        })
        
        let fileManager = NSFileManager.defaultManager()
        
        var indexPaths = [NSIndexPath]()
        var newPages = [PageModel]()
        var Index = indexPath.item
        let pageModels = fakePageView!.getPageArray()
        for aPage in pageModels {
            
            let newPageId = UniqueIDString()
            let originBookPath = aPage.delegate?.fileGetSuperPath(aPage)
            let orginPageURL = URL(originBookPath!)(isDirectory: true)(pages, aPage.Id)
            let newPageURL = URL(bookModel.filePath)(isDirectory: true)(pages, newPageId)
            
            if fileManager.copyItemAtURL(orginPageURL, toURL: newPageURL, error: nil) {
                
                let copyPageOriginJson = URL(bookModel.filePath)(isDirectory: true)(pages, newPageId ,aPage.Id + ".json")
                let copyPageNewJson = URL(bookModel.filePath)(isDirectory: true)(pages,newPageId ,newPageId + ".json")
                let copyPageOriginData = NSData(contentsOfURL: copyPageOriginJson)
                var newJson = NSJSONSerialization.JSONObjectWithData(copyPageOriginData!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]
                newJson["ID"] = newPageId
                let newJsonData = NSJSONSerialization.dataWithJSONObject(newJson, options: NSJSONWritingOptions(0), error: nil)
                newJsonData?.writeToURL(copyPageNewJson, atomically: true)
                
                let newPageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: newJson, error: nil) as! PageModel
                
                fileManager.removeItemAtURL(copyPageOriginJson, error: nil)
                
                newPages.append(newPageModel)
                let indexPath = NSIndexPath(forItem: Index, inSection: 0)
                indexPaths.append(indexPath)
                Index++
            }
        }
        bookModel.insertPageModelsAtIndex(newPages, FromIndex: indexPath.item)
        collectionView?.performBatchUpdates({ () -> Void in
            
            self.collectionView?.insertItemsAtIndexPaths(indexPaths)
            
            }, completion: { (completed) -> Void in
        })
    }
    
    func layoutDidMoveOut(layout: UICollectionViewLayout) {

        if !fakePageView!.fromTemplate {
            let aPageModel = fakePageView!.getPlaceholderPage()
            let bookPath = bookModel.filePath
            let pagePath = bookPath.stringByAppendingPathComponent("Pages/" + aPageModel.Id)
            let fileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtPath(pagePath, error: nil)
        }
    }
    
    func layout(layout: UICollectionViewLayout, didFinished finished: Bool) {

        bookModel.savePagesInfo()
    }
    
    // MARK: - EditToolsBarProtocol 
    func editToolsBarDidSelectedAccessoryView(editToolsBar: ToolsBar) {
        
//        if let currentIndexPath = getCurrentIndexPath() {
//            
//            if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
//                let location = CGPointZero
//                self.collectionView.scrollEnabled = false
//                page.setDelegate(self)
//                page.respondToLocation(location, onTargetView: view, sender: singleTapGesture)
//            }
//        }
        toolState = .willSelect
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    
  
    
    // MARK: - IMaskAttributer Protocol
    func maskAttributeWillDeleted(sender: IMaskAttributeSetter) {
        
        if let currentIndexPath = getCurrentIndexPath() {
                if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
                    let location = CGPointZero
                    page.setDelegate(self)
                }
        }
    }
    
    func maskAttributeWillSetting(sender: IMaskAttributeSetter) {
        
        if let aContainer = currentEditContainer {
            
            if let aTextCom = aContainer.component as? ITextComponent {
                
                if textInputView == nil {
                    
                    textInputView = UINib(nibName: "TextInputView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as? TextInputView
                    
                    view.addSubview(textInputView!)
                    textInputView?.alpha = 0
                    
//                    let attribute = aTextCom.getAttributeText()
//                    textInputView?.setAttributeText(attribute, confirmHander: { [unowned self] (string) -> () in
//                        
//                        self.editTextContent(string, container: aContainer, textCompoent: aTextCom)
//                        })
                }
                
                //            println("pageDidDoubleSelected ITextComponent")
                //            editTextContent(doubleSelectedContainer, textCompoent: aTextComponent)
            } else if let aImageCom = aContainer.component as? IImageComponent {
                
                showsheet()
            }
        }
    }
    
    // MARK: - imagePicker Delegate
  
    
    // MARK: - PreviewController delegate
    func previewControllerGetBookModel(controller: PreviewViewController) -> BookModel {
        
        return bookModel
    }
    
    
    // MARK: - Gesture Delegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        switch gestureRecognizer {
            
        case let gesture as UITapGestureRecognizer where gesture.numberOfTapsRequired == 1 :
            
            let location = gesture.locationInView(bottomToolBar)
            let locationinPannel = gesture.locationInView(pannel)
            
            if CGRectContainsPoint(bottomToolBar.bounds, location) || CGRectContainsPoint(pannel.bounds, locationinPannel) {
                return false
            }
            
            if let aColorPickView = colorPickView {
                
                let locationInColorPick = gesture.locationInView(aColorPickView)
                if CGRectContainsPoint(aColorPickView.bounds, locationInColorPick) {
                    return false
                }
            }
            
            return self.collectionView.collectionViewLayout is NormalLayout ? true : false
            
        case let gesture where gesture is UIPanGestureRecognizer:
          
          if maskView != nil {
            return false
          }
          
            return transitionLayout == nil ? true : false
        case let gesture where gesture is UILongPressGestureRecognizer:
            return true
            
        default:
            return true
        }
    }
}

// MARK: - TextEdit
extension EditViewController {
    
    func editTextContent(string: String, container: IContainer, textCompoent: ITextComponent) {
        
//       let size = textCompoent.setTextContent(string)
//        container.setResize(CGSize(width: size.width , height: size.height + 10 ), center: CGPointZero, resizeComponent: false, scale: false)
//        
//        if !maskAttributes.isEmpty {
//            
//            let mask = maskAttributes[0]
//            mask.setMaskSize(size)
//        }
    }
}

// MARK: - UIKeyBoard

extension EditViewController {
    
    func addKeyboardNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
//        println(notification)
        let point = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let bottom = point.CGRectValue().size.height
//        println("bottom = \(bottom)")
        let edges = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        textInputView?.snp_makeConstraints({ [unowned self] (make) -> Void in
            make.edges.equalTo(self.view).insets(edges)
            })
        textInputView?.alpha = 0
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.textInputView?.alpha = 1
        })
    }
    
    func keyboardWillHidden(notification: NSNotification) {
        
        if textInputView != nil {
            
            textInputView?.alpha = 1
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.textInputView?.alpha = 0
                
            }, completion: { (finished) -> Void in
                
                if finished {
                    self.textInputView?.removeFromSuperview()
                    self.textInputView = nil
                }
            })
//            UIView.animateWithDuration(0.25, animations: { () -> Void in
//                
//                self.textInputView.apha = 0
//            }, completion: { (finished) -> Void in
//                
//                if finished {
//                    self.textInputView?.removeFromSuperview()
//                    textInputView = nil
//                }
//            })
        }
    }
    
}


// MARK: - Private Methods
// MARK: -
extension EditViewController {
    
    // MARK: - ImagePick
    
  
    

    
    
    //
    private func POPTransition(progress: Float, startValue: Float, endValue: Float) -> CGFloat {
        
        return CGFloat(startValue + (progress * (endValue - startValue)))
    }
    
    private func getCurrentIndexPath() -> NSIndexPath? {
        
        let offsetMiddleX = collectionView.contentOffset.x + CGRectGetWidth(collectionView.bounds) / 2.0
        let offsetMiddleY = CGRectGetHeight(collectionView.bounds) / 2.0
        
        return collectionView.indexPathForItemAtPoint(CGPoint(x: offsetMiddleX, y: offsetMiddleY))
    }
    
    private func getbookModelWith(aBookID: String) -> BookModel {
        
        let userId = UsersManager.shareInstance.getUserID()
        let bookURL = NSURL(string: aBookID, relativeToURL: temporaryDirectory(userId))
        let bookMainjsonURL = temporaryDirectory(userId,aBookID,main_json)
        
        let data: AnyObject? = NSData(contentsOfURL: bookMainjsonURL)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
        book.filePath = bookURL!.path!
        let basePagePath = URL(bookURL!.URLByAppendingPathComponent(pages).absoluteString!)(isDirectory: true)
        
//        for pageInfo in book.pagesInfo {
//            let path: String = pageInfo["Path"]!
//            let index: String = pageInfo["Index"]!
//            let pageJsonURL = basePagePath(path,index)
//            let data: AnyObject? = NSData(contentsOfURL: pageJsonURL)
//            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
//            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
//            book.appendPageModel(page)
//        }
      
      book.paraserPageInfo()
      
        return book
        
    }
    
    private func changeToContainer(container: IContainer) {
        
        if let aContainer = currentEditContainer {
            
            if !aContainer.component.isEqual(container.component) {
                
                currentEditContainer = container
                if container.component is IImageComponent {
                    bottomToolBar.changeToItems(imageBarItems, animationed: false, allowShowAccessView: true)
                } else if container.component is ITextComponent {
                    bottomToolBar.changeToItems(textBarItems, animationed: false, allowShowAccessView: true)
                }
            }
            
        } else {
            currentEditContainer = container
            if container.component is IImageComponent {
                bottomToolBar.changeToItems(imageBarItems, animationed: true, allowShowAccessView: true)
            } else if container.component is ITextComponent {
                bottomToolBar.changeToItems(textBarItems, animationed: true, allowShowAccessView: true)
            }
        }
        toolState = ToolState.willSelect
    }
    
    private func endContainer() {
        
        if let aContainer = currentEditContainer {
            currentEditContainer = nil
            bottomToolBar.changeToItems(defaultBarItems, animationed: true, allowShowAccessView: false, needHiddenAccessView: true)
            
        }
    }
    
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
    
    private func transitionByProgress(aProgress: Float) {
        
        // collectionView Translation 0 ~ 1
        if transitionLayout != nil {
            let y = POPTransition(aProgress, startValue: isToSmallLayout ? 0 : maxY, endValue: isToSmallLayout ? maxY : 0)
            let toolBarAlpha = POPTransition(aProgress, startValue: isToSmallLayout ? 1 : 0, endValue: isToSmallLayout ? 0 : 1)
            let yTran = min(max(y, 0), CGFloat(maxY))
            collectionView.transform = CGAffineTransformMakeTranslation(0, yTran)
            topToolBar.alpha = toolBarAlpha
            bottomToolBar.alpha = toolBarAlpha
        }
        
        // layout Transition  0 ~ 1
        if transitionLayout != nil {
            let pro = min(max(aProgress, 0), 1)
            transitionLayout.transitionProgress = CGFloat(pro)
            transitionLayout.invalidateLayout()
        }
    }
    
    private func setupTemplateController() {
    
       templateViewController = storyboard?.instantiateViewControllerWithIdentifier("EditorTemplateNavigationController") as! EditorTemplateNavigationController
        
        addChildViewController(templateViewController)
        view.addSubview(templateViewController.view)
        view.sendSubviewToBack(templateViewController.view)
    
        templateViewController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view).insets(UIEdgeInsets(top: 0, left: 0, bottom: CGRectGetHeight(view.bounds) * (1 - LayoutSpec.layoutConstants.goldRatio), right: 0))
        }
    }
    
    private func saveBook() {
        
        let fileManager = NSFileManager.defaultManager()
        let userID = UsersManager.shareInstance.getUserID()
        let bookId = bookModel.Id
      
      let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)
      let data = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
      let main = temporaryDirectory(userID,bookId,"main.json")
      data?.writeToURL(main, atomically: true)

        let originBookUrl = documentDirectory(users,userID,books,bookId)
        let tempBookUlr = temporaryDirectory(userID,bookId)
        
        if fileManager.replaceItemAtURL(originBookUrl, withItemAtURL: tempBookUlr, backupItemName: bookId + "backup", options: NSFileManagerItemReplacementOptions(0), resultingItemURL: nil, error: nil) {
            
            let saveDate = NSDate();
            UsersManager.shareInstance.updateBookWith(bookId, aBookName: bookModel.title, aDescription: bookModel.desc, aDate: saveDate, aIconUrl: NSURL(string: "")!)

        }
    }
    
    private func deleteTemporaryBookWithUserId(userID: String) {
        NSFileManager.defaultManager().removeItemAtURL(temporaryDirectory(userID), error: nil)
    }
    
    func setupConstraints() {
        
        bottomToolBar.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(44).constraint
            make.left.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        pannel.snp_updateConstraints({ (make) -> Void in
            make.height.equalTo(85).constraint
            make.left.right.equalTo(view)
            make.top.equalTo(bottomToolBar.snp_bottom)
        })
    }
    
    
    func updateWithState(state: ToolState) {
        
        switch state {
            
            
        case .didSelect:
            bottomToolBar.snp_updateConstraints({ (make) -> Void in
                make.bottom.equalTo(view.snp_bottom).offset(-80)
            })
            
            topToolBar.snp_updateConstraints({ (make) -> Void in
                
                make.top.equalTo(view.snp_top).offset(-44)
            })
            
            if let currentIndexPath = getCurrentIndexPath() {
                
                let cell = collectionView.cellForItemAtIndexPath(currentIndexPath)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    cell?.center.y = self.collectionView.bounds.height / 2.0 - 80
                    
                    for mask in self.maskAttributes {
                        let currentCeter = mask.currentCenter
                        if let aMask = mask as? UIView {
                            aMask.center.y = currentCeter.y - 80
                            aMask.userInteractionEnabled = false
                        }
                    }
                })
                
                for indexPath in collectionView.indexPathsForVisibleItems() as! [NSIndexPath] {
                    
                    if indexPath != currentIndexPath {
                        let cell = collectionView.cellForItemAtIndexPath(indexPath)
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            
                            cell?.alpha = 0
                        })
                    }
                }
            }
  
        case .willSelect, .endEdit:
            bottomToolBar.snp_updateConstraints({ (make) -> Void in
                make.bottom.equalTo(view)
            })
            
            if let currentIndexPath = getCurrentIndexPath() {
                
                let cell = collectionView.cellForItemAtIndexPath(currentIndexPath)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    cell?.center.y = self.collectionView.bounds.height / 2.0
                    
                    for mask in self.maskAttributes {
                        let currentCeter = mask.currentCenter
                        if let aMask = mask as? UIView {
                            aMask.center.y = currentCeter.y
                            aMask.userInteractionEnabled = true
                        }
                    }
                })
                
                for indexPath in collectionView.indexPathsForVisibleItems() as! [NSIndexPath] {
                    
                    if indexPath != currentIndexPath {
                        let cell = collectionView.cellForItemAtIndexPath(indexPath)
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            
                            cell?.alpha = 1
                        })
                    }
                }
            }
            
            topToolBar.snp_updateConstraints({ (make) -> Void in
                
                make.top.equalTo(view.snp_top)
            })
            
            bottomToolBar.deselected()
            
            if let acolorPick = colorPickView {
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    acolorPick.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        
                        acolorPick.removeFromSuperview()
                        self.colorPickView = nil
                })
            }
            
        default:
            return
        }
    }
}
