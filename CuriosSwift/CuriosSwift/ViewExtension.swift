//
//  ViewExtension.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/7/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func snapshotImageAfterScreenUpdate(afterScreenUpdate: Bool) -> UIImage {
        
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}