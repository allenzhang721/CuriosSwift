//
//  ToolsPannel.swift
//  
//
//  Created by Emiaostein on 6/11/15.
//
//

import UIKit

class ToolsPannel: UIControl {
    
    let factory = PannelFactory.shareInstance
    var subPannel = Pannel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(subPannel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubPannelWithType(type: PannelType) {
        
        let pannel = factory.createPannelWithType(type)
        addSubview(pannel)
        subPannel.removeFromSuperview()
        subPannel = pannel

        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    override func updateConstraints() {
        
        subPannel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        
        super.updateConstraints()
    }
}
