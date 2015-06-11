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

class EditViewController: UIViewController, IPageProtocol {
    
    enum ToolState {
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
    var pageViewModels: [PageViewModel] = []
    let queue = NSOperationQueue()
    var fakePageView: FakePageView?
    var transitionLayout: TransitionLayout!
    let maxY = Float(LayoutSpec.layoutConstants.maxTransitionLayoutY)
    var beganPanY: CGFloat = 0.0
    var isToSmallLayout = false
    var multiSection = false
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
        "font" : "Editor_Text",
        "typography": "Editor_Typography",
        "animation": "Editor_Animation",
        "interact": "Editor_Interact"
    ]
    
    let barActionName: [String : String] = [
    
       "setting": "settingAction:",
        "addImage": "ImageAction:",
        "addText": "addTextAction:",
        "preview": "previewAction:",
        "effects": "effectsAction:",
        "font" : "fontAction:",
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
        
        let itemsKey = ["effects", "font", "typography", "animation", "interact"]
        return getBarButtonItem(itemsKey)
    }
    
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
        
        SmallLayout.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        let normal = NormalLayout()
        collectionView.setCollectionViewLayout(normal, animated: false)
        collectionView.decelerationRate = 0.1
        
        bottomToolBar = ToolsBar(aframe:CGRect(x: 0, y: 568 - 64, width: 320, height: 64) , aItems: defaultBarItems, aDelegate: self)
        pannel = ToolsPannel()
        pannel.backgroundColor = UIColor.lightGrayColor()
        
        
        view.addSubview(bottomToolBar)
        view.addSubview(pannel)
        
        setupConstraints()
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
        
//        println("aBookID = \(aBookID)")
        bookModel = getbookModelWith(aBookID)
    }
    
    deinit {
        
        println("deinit")
    }
    
    override func updateViewConstraints() {
        
        updateWithState(toolState)
     
        super.updateViewConstraints()
    }
}

// MARK: - IBActions
extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func doubleTapAction(sender: UITapGestureRecognizer) {
        println("double")
        if let currentIndexPath = getCurrentIndexPath() {
            
            if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
                let location = sender.locationInView(view)
                page.setDelegate(self)
                page.respondToLocation(location, onTargetView: view, sender: sender)
            }
        }
    }
    
    @IBAction func TapAction(sender: UITapGestureRecognizer) {
        println("tap")
        
        if let currentIndexPath = getCurrentIndexPath() {
            
            if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
                let location = sender.locationInView(view)
                self.collectionView.scrollEnabled = false
                page.setDelegate(self)
                page.respondToLocation(location, onTargetView: view, sender: sender)
            }
        }
    }
    
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
                        page.respondToLocation(location, onTargetView: view, sender: sender)
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
    
    @IBAction func ImageAction(sender: UIBarButtonItem) {
        
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: { imageP in
            
        })
    }
    
    @IBAction func addTextAction(sender: UIBarButtonItem) {

        if let indexPath = getCurrentIndexPath() {
            
            if let page = collectionView.cellForItemAtIndexPath(indexPath) as? IPage {
                


                let textComponentModel = TextContentModel()
                textComponentModel.type = .Text
                textComponentModel.attributes = ["contentText": "New Text"]
                let aContainer = ContainerModel()
                aContainer.component = textComponentModel
//                println(aContainer.component)
                page.addContainer(aContainer)
                page.saveInfo()
            }
            
//
//            let currentPageViewModel = pageViewModels[indexPath.item]
//            let textComponentModel = TextContentModel()
//            textComponentModel.type = .Text
//            textComponentModel.attributes = ["contentText": "New Text"]
//            let aContainer = ContainerModel()
//            aContainer.component = textComponentModel
//            let aContainerViewModel = ContainerViewModel(model: aContainer, aspectRatio: currentPageViewModel.aspectRatio)
//            currentPageViewModel.containers.append(aContainerViewModel)
//            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PageCell
//            let contanerNode = ContainerNode(aContainerViewModel: aContainerViewModel, aspectR: currentPageViewModel.aspectRatio)
//            cell.containerNode?.addSubnode(contanerNode)
        }
    }
    
    
    
    @IBAction func previewAction(sender: UIBarButtonItem) {
        
        if let preeviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PreviewController") as? PreviewViewController {
            
            let previewName = "CuriosPreview"
            let previewPath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(previewName)
            let previewURL = NSURL.fileURLWithPath(previewPath!, isDirectory: true)
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
            let cachePreview = cacheDirectory.stringByAppendingPathComponent(previewName) as String
            let res = cachePreview.stringByAppendingPathComponent("res")
            let fileManager = NSFileManager.defaultManager()
            var isDirectory = false
            if !fileManager.fileExistsAtPath(cachePreview) {
                
                if fileManager.copyItemAtURL(NSURL(fileURLWithPath: previewPath!)!, toURL: NSURL(fileURLWithPath: cachePreview)!, error: nil) {
                    println("copy preview file success")
                }
            } else {
                
                if fileManager.fileExistsAtPath(res) {
                    if fileManager.removeItemAtURL(NSURL(fileURLWithPath: res, isDirectory: true)!, error: nil) {
                        println("remove res success")
                    }
                }
            }
            
            let demoBookID = "QWERTASDFGZXCVB"
            let tempBookPath = NSTemporaryDirectory().stringByAppendingPathComponent(demoBookID)
            if fileManager.copyItemAtURL(NSURL(fileURLWithPath: tempBookPath, isDirectory: true)!, toURL: NSURL(fileURLWithPath: res, isDirectory: true)!, error: nil) {
                
                println("copy book to preview res success")
            }

            presentViewController(preeviewVC, animated: true, completion: nil)
        }
        
    }
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        
        saveBook()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func settingAction(sender: UIButton) {
        
        debugPrintln("Setting")
    }
    
    func effectsAction(sender: UIButton) {
        
        toolState = .didSelect
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func fontAction(sender: UIButton) {
        
        toolState = .didSelect
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func typographyAction(sender: UIButton) {
        
        toolState = .didSelect
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func animationAction(sender: UIButton) {
        
        toolState = .didSelect
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

// MARK: - DataSource And Delegate
// MARK: -
extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate ,SmallLayoutDelegate, IPageProtocol, EditToolsBarProtocol {
    
    // MARK: - UICollectionViewDataSource and CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return bookModel.pageModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PageCollectionViewCell
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.configCell(bookModel.pageModels[indexPath.item], queue: queue)
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout! {
        return TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
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
                
                println("Copy template page succeess")
                
                let copyPageOriginJson = URL(bookModel.filePath)(isDirectory: true)(pages, newPageId ,aPage.Id + ".json")
                let copyPageNewJson = URL(bookModel.filePath)(isDirectory: true)(pages,newPageId ,newPageId + ".json")
                let copyPageOriginData = NSData(contentsOfURL: copyPageOriginJson)
                var newJson = NSJSONSerialization.JSONObjectWithData(copyPageOriginData!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]
                newJson["ID"] = newPageId
                let newJsonData = NSJSONSerialization.dataWithJSONObject(newJson, options: NSJSONWritingOptions(0), error: nil)
                newJsonData?.writeToURL(copyPageNewJson, atomically: true)
                
                let newPageModel = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: newJson, error: nil) as! PageModel
                
//                println(newPageModel.containers)
                
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
        
        println("Did Move in = \(indexPath.item)")
    }
    
    func layoutDidMoveOut(layout: UICollectionViewLayout) {
         println("Did Move Out")
        if !fakePageView!.fromTemplate {
            let aPageModel = fakePageView!.getPlaceholderPage()
            let bookPath = bookModel.filePath
            let pagePath = bookPath.stringByAppendingPathComponent("Pages/" + aPageModel.Id)
            let fileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtPath(pagePath, error: nil)
        }
    }
    
    func layout(layout: UICollectionViewLayout, didFinished finished: Bool) {
        println("didFinished")
        bookModel.savePagesInfo()
    }
    
    // MARK: - EditToolsBarProtocol 
    func editToolsBarDidSelectedAccessoryView(editToolsBar: ToolsBar) {
        
        if let currentIndexPath = getCurrentIndexPath() {
            
            if let page = collectionView.cellForItemAtIndexPath(currentIndexPath) as? IPage  {
                let location = CGPointZero
                self.collectionView.scrollEnabled = false
                page.setDelegate(self)
                page.respondToLocation(location, onTargetView: view, sender: singleTapGesture)
            }
        }
    }
    
    
    // MARK: - Ipage Protocol
    
    func pageDidSelected(page: IPage, selectedContainer: IContainer, position: CGPoint, size: CGSize, rotation: CGFloat, inTargetView: UIView) {
        
        let mask = ContainerMaskView.createMask(position, size: size, rotation: rotation)
        mask.setTarget(selectedContainer)
        
        if let aMask = mask as? UIView {
            view.addSubview(aMask)
        }
        
        changeToContainer(selectedContainer)
        
        
        maskAttributes.append(mask)
    }
    
    func pageDidDeSelected(page: IPage, deSelectedContainers: [IContainer]) {
        
        if deSelectedContainers.count > 0 {
            for container in deSelectedContainers {
                var index = 0
                println(index)
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
    
    func shouldMultiSelection() -> Bool {
        
        return multiSection
    }
    
    func didEndEdit(page: IPage) {
        page.saveInfo()
        page.cancelDelegate()
        collectionView.scrollEnabled = true
        
        endContainer()
        toolState = .endEdit
        view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - imagePicker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

//        if let indexPath = getCurrentIndexPath() {
//
//            let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
//            let imageData = UIImagePNGRepresentation(selectedImage)
//            
//            let currentPageViewModel = pageViewModels[indexPath.item]
//            let relativeImagePath = "QWERTASDFGZXCVB/Pages/\(currentPageViewModel.model.Id)/images/\(UniqueIDString()).png"
//            let imagePath = NSTemporaryDirectory().stringByAppendingString(relativeImagePath)
//            let imageURl = NSURL.fileURLWithPath(imagePath, isDirectory: false)
//            
//            
//            let aError = NSErrorPointer()
//            if NSFileManager.defaultManager().createFileAtPath(imagePath, contents: imageData, attributes: nil) {
//
//            }
//            
//            let imageComponentModel = ImageContentModel()
//            imageComponentModel.type = .Image
//            imageComponentModel.attributes = ["ImagePath": relativeImagePath]
//            let aContainer = ContainerModel()
//            aContainer.component = imageComponentModel
//            let aContainerViewModel = ContainerViewModel(model: aContainer, aspectRatio: currentPageViewModel.aspectRatio)
//            currentPageViewModel.containers.append(aContainerViewModel)
//            collectionView.reloadItemsAtIndexPaths([indexPath])
//        }
        
        
        if let indexPath = getCurrentIndexPath() {
            
            
            
            if let page = collectionView.cellForItemAtIndexPath(indexPath) as? IPage {
                
                let imageName = UniqueIDString()
                
                let pageFile = bookModel.pageModels[indexPath.item]
                let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
                let imageData = UIImagePNGRepresentation(selectedImage)
                
                let pagePath = pageFile.fileGetSuperPath(pageFile)
                let realtiveImagePath = "images/" + imageName + ".png"
                let imagePath = pagePath.stringByAppendingPathComponent(realtiveImagePath)
                
                println("the Image = \(imagePath)")
                if imageData.writeToFile(imagePath, atomically: true) {
                    println("iamge save = \(imagePath)")
                }
                
                

                let textComponentModel = ImageContentModel()
                textComponentModel.type = .Image
                textComponentModel.imagePath = realtiveImagePath
                let aContainer = ContainerModel()
                aContainer.component = textComponentModel
                //                println(aContainer.component)
                page.addContainer(aContainer)
                page.saveInfo()
            }
        }
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - Gesture Delegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        switch gestureRecognizer {
            
        case let gesture as UITapGestureRecognizer where gesture.numberOfTapsRequired == 1 :
            
            let location = gesture.locationInView(bottomToolBar)
            if CGRectContainsPoint(bottomToolBar.bounds, location) {
                return false
            }
            
            return self.collectionView.collectionViewLayout is NormalLayout ? true : false
            
        case let gesture where gesture is UIPanGestureRecognizer:
            
            for subView in view.subviews {
                if subView is ContainerMaskView {
                    return false
                }
            }
            return transitionLayout == nil ? true : false
        case let gesture where gesture is UILongPressGestureRecognizer:
            return true
            
        default:
            return true
        }
    }
}


// MARK: - Private Methods
// MARK: -
extension EditViewController {
    
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
        
        for pageInfo in book.pagesInfo {
            let path: String = pageInfo["Path"]!
            let index: String = pageInfo["Index"]!
            let pageJsonURL = basePagePath(path,index)
            let data: AnyObject? = NSData(contentsOfURL: pageJsonURL)
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
            book.appendPageModel(page)
        }
        
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
        toolState = ToolState.didSelect
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
        
        let userID = UsersManager.shareInstance.getUserID()
        let bookId = bookModel.Id
        let originBookUrl = documentDirectory(users,userID,books,bookId)
        let tempBookUlr = temporaryDirectory(userID,bookId)
        
        if NSFileManager.defaultManager().replaceItemAtURL(originBookUrl, withItemAtURL: tempBookUlr, backupItemName: bookId + "backup", options: NSFileManagerItemReplacementOptions(0), resultingItemURL: nil, error: nil) {
            
            let saveDate = NSDate();
            UsersManager.shareInstance.updateBookWith(bookId, aBookName: bookModel.title, aDescription: bookModel.desc, aDate: saveDate, aIconUrl: NSURL(string: "")!)
            
            NSFileManager.defaultManager().removeItemAtURL(temporaryDirectory(userID), error: nil)
        }
    }
    
    func setupConstraints() {
        
        bottomToolBar.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(64).constraint
            make.left.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        pannel.snp_updateConstraints({ (make) -> Void in
            make.height.equalTo(80).constraint
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

            
        case .endEdit:
            bottomToolBar.snp_updateConstraints({ (make) -> Void in
                make.bottom.equalTo(view)
            })
            
        default:
            return
        }
    }
}
