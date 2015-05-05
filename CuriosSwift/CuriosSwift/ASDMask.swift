//
//  ASDMask.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/5/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ASDMask: UIView {
    
    var listener: containerListener! {
        didSet {
            listener.lX.bindAndFire {
                [unowned self] in
                self.frame.size.width = $0
                self.frame.size.height = $0
            }
        }
    }
    
    var name = "em" {
        didSet {
            println(name)
        }
    }
    
    init(aListener: containerListener) {
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

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
