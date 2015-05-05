//
//  ContainerMaskView.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/5/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ContainerMaskView: UIView {

    var aspectRatio: CGFloat = 1.0
    var listener: containerListener! {
        didSet {
            listener.lWidth.bindAndFire {
                [weak self] in
                self!.bounds.size.width = $0 * self!.aspectRatio
            }
            listener.lHeight.bindAndFire {
                [weak self] in
                self!.bounds.size.height = $0  * self!.aspectRatio
            }
            listener.lX.bindAndFire {
                [weak self] in
                self!.center.x = ($0 + self!.frame.size.width / 2.0)  * self!.aspectRatio
            }
            listener.lY.bindAndFire {
                [weak self] in
                self!.center.y = ($0 + self!.frame.size.height / 2.0)  * self!.aspectRatio
            }
            
            listener.lRotation.bindAndFire {
                [weak self] in
                self!.transform = CGAffineTransformMakeRotation($0)
            }
        }
    }
    
    init(aListener: containerListener, Ratio: CGFloat) {
        aspectRatio = Ratio
        listener = aListener
        super.init(frame: CGRectZero)
        setupBy(aListener)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBy(aListener: containerListener) {
        listener = aListener
    }

}
