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

class EditViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var singleTapGesture: UITapGestureRecognizer!
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!

    var bookModel: BookModel!
//    var pageModels: [PageModel] = []
    var pageViewModels: [PageViewModel] = []
    let queue = NSOperationQueue()
    var fakePageView: FakePageView?
    var transitionLayout: TransitionLayout!
    let maxY = Float(LayoutSpec.layoutConstants.maxTransitionLayoutY)
    var beganPanY: CGFloat = 0.0
    var isToSmallLayout = false
    var multiSection = false
    var progress: Float = 0.0 {
        didSet {
            
            if transitionLayout != nil {
                transitionByProgress(progress)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        
        if BookManager.copyDemoBook() {
            
            println("copyDemoBook success")
        }
        
//        BookManager.createBookAtURL(BookManager.constants.temporaryDirectoryURL!)
        
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let normal = NormalLayout()
        collectionView.setCollectionViewLayout(normal, animated: false)
        collectionView.decelerationRate = 0.1
        pageViewModels = getPageViewModels()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
}

// MARK: - IBActions
extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func doubleTapAction(sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func TapAction(sender: UITapGestureRecognizer) {
        
        if let currentIndexPath = getCurrentIndexPath() {
            
            if multiSection == false {
                let pageViewModel = pageViewModels[currentIndexPath.item]
                let cell = collectionView.cellForItemAtIndexPath(currentIndexPath) as! PageCell
                if let contentNode = cell.containerNode {
                    onContainer(contentNode, location: sender.locationInView(contentNode.view))
                }
                
            } else {
                
            }
        }
    }
    
    @IBAction func PanAction(sender: UIPanGestureRecognizer) {
        
        let transition = sender.translationInView(view)
        
        switch sender.state {
        case .Began:
            
            beganPanY = LayoutSpec.layoutConstants.screenSize.height - sender.locationInView(view).y
            isToSmallLayout = collectionView.collectionViewLayout is NormalLayout
            let nextLayout = isToSmallLayout ? smallLayout() : NormalLayout()
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
        
        println("longpress")
        let location = sender.locationInView(view)
        switch sender.state {
        case .Began:
            
            if collectionView.collectionViewLayout is smallLayout {
                if CGRectContainsPoint(collectionView.frame, location) {
                    let pageLocation = sender.locationInView(collectionView)
                    if let aSmallLayout = collectionView.collectionViewLayout as? smallLayout where aSmallLayout.shouldRespondsToGestureLocation(pageLocation) {
                        println("shouldRespondsToGestureLocation")
                        if let snapShot = aSmallLayout.getResponseViewSnapShot() {
                            fakePageView = FakePageView.fakePageViewWith(snapShot, array: [pageViewModels[aSmallLayout.placeholderIndexPath!.item]])
                            fakePageView?.center = location
                            view.addSubview(fakePageView!)
                        }
                    }
                }
                
            } else if collectionView.collectionViewLayout is NormalLayout {
                
                // TODO: Mask
            }
            
        case .Changed:
            
            if collectionView.collectionViewLayout is smallLayout {
                if let fake = fakePageView {
                    fake.center = location
                    
                    if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
                        let inEditBoundsLocation = sender.locationInView(collectionView)
                        aSmallLyout.responseToPointMoveInIfNeed(CGRectContainsPoint(collectionView.frame, location), AtPoint: inEditBoundsLocation)
                    }
                }
                
            } else if collectionView.collectionViewLayout is NormalLayout {
                
                // TODO: Mask
            }
            
        case .Cancelled, .Ended:
            
            if collectionView.collectionViewLayout is smallLayout {
                if let aSmallLyout = collectionView.collectionViewLayout as? smallLayout {
                    if CGRectContainsPoint(collectionView.frame, location) {
                        aSmallLyout.responsetoPointMoveEnd()
                    }
                }
                
                fakePageView?.removeFromSuperview()
                fakePageView = nil
                
            } else if collectionView.collectionViewLayout is NormalLayout {
                
                
                // TODO: Mask
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
}


// MARK: - Delegate and DateSource
extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK - CollectionView Datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageViewModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PageCell
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.configCell(pageViewModels[indexPath.item], queue: queue)
        
        return cell
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout! {
        return TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    
    // MARK: - Gesture Delegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        switch gestureRecognizer {
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
    
    // MARK: - imagePicker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        /*
        
        [UIImagePickerControllerEditedImage: <UIImage: 0x7ff24c99ac20>
        size {638, 426} orientation 0 scale 1.000000,
        UIImagePickerControllerOriginalImage: <UIImage: 0x7ff24c990730>
        size {1500, 1001} orientation 0
        scale 1.000000,
        UIImagePickerControllerCropRect: NSRect: {{0, 0}, {1500, 1003}}, UIImagePickerControllerReferenceURL: assets-library://asset/asset.JPG?id=B6C0A21C-07C3-493D-8B44-3BA4C9981C25&ext=JPG, UIImagePickerControllerMediaType: public.image]
        
        */
        if let indexPath = getCurrentIndexPath() {
            
            println("imageURl = \(indexPath)")
            
            let selectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
            let imageData = UIImagePNGRepresentation(selectedImage)
            
            let currentPageViewModel = pageViewModels[indexPath.item]
            let relativeImagePath = "QWERTASDFGZXCVB/Pages/\(currentPageViewModel.model.Id)/images/\(UniqueIDString()).png"
            let imagePath = NSTemporaryDirectory().stringByAppendingString(relativeImagePath)
            let imageURl = NSURL.fileURLWithPath(imagePath, isDirectory: false)
            
            
            let aError = NSErrorPointer()
            if NSFileManager.defaultManager().createFileAtPath(imagePath, contents: imageData, attributes: nil) {
                println("save image success")
            }
            
            let imageComponentModel = ImageContentModel()
            imageComponentModel.type = .Image
            imageComponentModel.attributes = ["ImagePath": relativeImagePath]
            let aContainer = ContainerModel()
            aContainer.component = imageComponentModel
            let aContainerViewModel = ContainerViewModel(model: aContainer, aspectRatio: currentPageViewModel.aspectRatio)
            currentPageViewModel.containers.append(aContainerViewModel)
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            
        })
    }
    
    //TODO: SmallLayout autoscroll delegate
    //MARK: - SmallLayout Delegate
    
}

extension EditViewController: UIGestureRecognizerDelegate {
    
    
}

// MARK: - Private Methods - selected 
extension EditViewController {
    
    private func onContainer(contentNode:ASDisplayNode, location: CGPoint) {
        
        if let ContainerNodes = contentNode.subnodes as? [ContainerNode] {
            
            let onContainers = ContainerNodes.filter({ (containerNode) -> Bool in
                let comtainView = containerNode.view
                let convertPoint = contentNode.view.convertPoint(location, toView: comtainView)
                return CGRectContainsPoint(comtainView.bounds, convertPoint)
            })
            
            if onContainers.count <= 0 {
                resetAllMask()
                return
            }
            
            if let selectedNode = onContainers.last {
                println("find Node")
                resetAllMask()
                collectionView.scrollEnabled = false
                
                let position = contentNode.view.convertPoint(selectedNode.position, toView: view)
                let size = selectedNode.bounds.size
                let rotation = selectedNode.containerViewModel.rotation.value
                let mask = ContainerMaskView(postion: position, size: size, rotation: rotation, forViewModel: selectedNode.containerViewModel)
                self.view.addSubview(mask)
                
                
                return
            }
            
            resetAllMask()
            return
        }
    }
    
//    private func addMaskForContainer(aContainerNode: ContainerNode) -> ContainerMaskView {
//        
//        return ContainerMaskView(aContainerNode: aContainerNode)
//    }
    
    private func resetAllMask() {
    
        for subView in view.subviews {
            
            if subView is ContainerMaskView {
                subView.removeFromSuperview()
            }
        }
        
        collectionView.scrollEnabled = true
    }
}

// MARK: - Private Methods
extension EditViewController {
    
    private func POPTransition(progress: Float, startValue: Float, endValue: Float) -> CGFloat {
        
        return CGFloat(startValue + (progress * (endValue - startValue)))
    }
    
    private func getCurrentIndexPath() -> NSIndexPath? {
        
        var visualCells = collectionView.visibleCells() as! [UICollectionViewCell]
        
        if visualCells.count <= 0 {
            return nil
        }
        
        let offsetMiddleX = collectionView.contentOffset.x + CGRectGetWidth(collectionView.bounds) / 2.0
        let sortedVisualCells: [UICollectionViewCell] = visualCells.sorted{ (CellA: UICollectionViewCell, CellB: UICollectionViewCell) -> Bool in
            
            return fabs(CellA.center.x - offsetMiddleX) < fabs(CellB.center.x - offsetMiddleX)
        }
        
        return collectionView.indexPathForCell(sortedVisualCells[0])
    }
    
//    private func getPageModels() -> [PageModel] {
//        
//        let file = NSTemporaryDirectory().stringByAppendingString("QWERTASDFGZXCVB")
//        let demobookPath = file.stringByAppendingPathComponent("/main.json")
//        let data: AnyObject? = NSData.dataWithContentsOfMappedFile(demobookPath)
//        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
//        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
//        var pageArray: [PageModel] = []
//        for pageInfo in book.pagesInfo {
//            let path: String = pageInfo["Path"]!
//            let index: String = pageInfo["Index"]!
//            let relpagePath = path + index
//            let pagePath = file.stringByAppendingPathComponent("Pages").stringByAppendingString(relpagePath)
//            let data: AnyObject? = NSData.dataWithContentsOfMappedFile(pagePath)
//            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
//            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
//            pageArray.append(page)
//        }
//        return pageArray
//    }
    
    private func getPageViewModels() -> [PageViewModel] {
        
        let file = NSTemporaryDirectory().stringByAppendingString("QWERTASDFGZXCVB")
        let demobookPath = file.stringByAppendingPathComponent("/main.json")
        let data: AnyObject? = NSData.dataWithContentsOfMappedFile(demobookPath)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
        var pageArray: [PageViewModel] = []
        for pageInfo in book.pagesInfo {
            let path: String = pageInfo["Path"]!
            let index: String = pageInfo["Index"]!
            let relpagePath = path + index
            let pagePath = file.stringByAppendingPathComponent("Pages").stringByAppendingString(relpagePath)
            let data: AnyObject? = NSData.dataWithContentsOfMappedFile(pagePath)
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
            let pageViewModel = PageViewModel(aModel: page)
            pageArray.append(pageViewModel)
        }
        return pageArray
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
            let yTran = min(max(y, 0), CGFloat(maxY))
            collectionView.transform = CGAffineTransformMakeTranslation(0, yTran)
        }
        
        // layout Transition  0 ~ 1
        if transitionLayout != nil {
            let pro = min(max(aProgress, 0), 1)
            transitionLayout.transitionProgress = CGFloat(pro)
            transitionLayout.invalidateLayout()
        }
    }
    
}
