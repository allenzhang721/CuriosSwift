//
//  Pannel.swift
//  
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

protocol PannelProtocol: NSObjectProtocol {
    
    func pannelGetContainer() -> IContainer?
    func pannelDidSendEvent(event: PannelEvent, object: AnyObject?) -> Void
}

enum PannelType {
    
    case Effect
    case Font
    case FontAttribute
    case FontSize
    case Typography
    case Animation
}

enum PannelEvent {
    
    case FontNameChanged, FontAligementChanged
}

class Pannel: UIView {

    
    weak var delegate: PannelProtocol? {
        
        didSet {
            didSetDelegate()
        }
    }
    
    func didSetDelegate() {
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
