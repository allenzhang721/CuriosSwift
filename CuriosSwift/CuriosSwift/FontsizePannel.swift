//
//  FontsizePannel.swift
//  
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

class FontsizePannel: Pannel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        addSubview(subPannel)
        backgroundColor = UIColor.blackColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
