//
//  ComponentTextNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentTextNode: ASTextNode, ITextComponent {
   
    var componentModel: TextContentModel
  
    required init(aComponentModel: TextContentModel) {
        self.componentModel = aComponentModel
        super.init()
        userInteractionEnabled = false
      
      componentModel.updateAttributeStringBlock { [weak self] (attributeString) -> () in
        
        self?.updateByAttributeString(attributeString)
      }
      
      componentModel.generateAttributeString()
    }
  
  // MARK: - Update
  
  func updateByAttributeString(attrString: NSAttributedString) {
    
    attributedString = attrString
//    let size = measure(CGSize(width: CGFloat.max, height: CGFloat.max))
//    bounds.size = size
  }
  
// MARK: - ITextComponent
    
    func iBecomeFirstResponder() {
        userInteractionEnabled = true
    }
    func iResignFirstResponder() {
        userInteractionEnabled = false
    }
    func iIsFirstResponder() -> Bool {
        return false
    }
  
  func resizeScale(scale: CGFloat) {
    
  }
    
    func getSnapshotImage() -> UIImage {
        
        UIGraphicsBeginImageContext(self.bounds.size)
        self.view.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
