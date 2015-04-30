//
//  EditViewController.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle
import pop

class EditViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var pageModels: [PageModel] = []
    let queue = NSOperationQueue()
    var transitionLayout: TransitionLayout!
    var progress: Float = 0.0 {
        didSet {
            
            if transitionLayout != nil {
                
                transitionByProgress(progress)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let normal = NormalLayout()
        collectionView.setCollectionViewLayout(normal, animated: false)
        collectionView.decelerationRate = 0.1
        pageModels = getPageModels()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
}

// MARK: - IBActions
extension EditViewController {
    
    @IBAction func PanAction(sender: UIPanGestureRecognizer) {
        
        let transition = sender.translationInView(view)
        
        switch sender.state {
        case .Began:
            
            let nextLayout = collectionView.collectionViewLayout is NormalLayout ? smallLayout() : NormalLayout()
            transitionLayout = collectionView.startInteractiveTransitionToCollectionViewLayout(nextLayout, completion: { [unowned self] (completed, finish) -> Void in

                    self.transitionLayout = nil
                    self.progress = 0

                }) as! TransitionLayout
            
        case .Changed:
            collectionView.transform = CGAffineTransformTranslate(collectionView.transform, 0, 5)
            progress += 0.01
            
            
        case .Ended:
            
            if transitionLayout != nil {
                let animation = togglePopAnimation(true)
                
            }
            
        default:
            return
            
        }
        sender.setTranslation(CGPointZero, inView: view)
    }
}


// MARK: - Delegate and DateSource
extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK - CollectionView Datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PageCell
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.configCell(pageModels[indexPath.item], queue: queue)
        return cell
    }
    
    // MARK - CollectionView Delegate
    func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout! {
        return TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
}

extension EditViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return transitionLayout == nil ? true : false
    }
}

// MARK: - Private Methods
extension EditViewController {
    
    private func POPTransition(progress: Float, startValue: Float, endValue: Float) -> CGFloat {
        
        return CGFloat(startValue + (progress * (endValue - startValue)))
    }
    
    private func getPageModels() -> [PageModel] {
        
        let demobookPath: String = NSBundle.mainBundle().pathForResource("main", ofType: "json", inDirectory: "res")!
        let data: AnyObject? = NSData.dataWithContentsOfMappedFile(demobookPath)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
        
        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
        //        println(book)
        
        var pageArray: [PageModel] = []
        for pageInfo in book.pagesInfo {
            
            //            println(pageInfo)
            
            let pagePath = NSBundle.mainBundle().pathForResource(pageInfo["PageID"]!, ofType: "json", inDirectory: "res/Pages" + pageInfo["Path"]!)!
            let data: AnyObject? = NSData.dataWithContentsOfMappedFile(pagePath)
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
            //            println(page.containers[0].animations[0].delay)
            pageArray.append(page)
        }
        return pageArray
    }
    
    private func togglePopAnimation(on: Bool) -> POPSpringAnimation {
        var animation: POPSpringAnimation! = self.pop_animationForKey("Pop") as! POPSpringAnimation!
        if animation == nil {
            animation = POPSpringAnimation()
            animation.springBounciness = 5
            animation.springSpeed = 5
            
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
                
                self.collectionView.finishInteractiveTransition()
                
            }
        }
        
        return animation
    }

    
    private func transitionByProgress(aProgress: Float) {
        
        // collectionView Translation 0 ~ 1
        
        // layout Transition  0 ~ 1
        if transitionLayout != nil {
            transitionLayout.transitionProgress = CGFloat(aProgress)
            transitionLayout.invalidateLayout()
        }
    }

}
