//
//  Pannel.swift
//  
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

protocol PannelProtocol: NSObjectProtocol {
    
    func pannelGetContainer() -> IContainer
}

enum PannelType {
    
    case Effect
    case Font
    case FontSize
    case Typography
    case Animation
}

class Pannel: UIView {

    
    weak var delegate: PannelProtocol?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
