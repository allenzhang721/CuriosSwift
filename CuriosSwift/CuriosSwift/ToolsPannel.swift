//
//  ToolsPannel.swift
//  
//
//  Created by Emiaostein on 6/11/15.
//
//

import UIKit

class ToolsPannel: UIControl {
    
    
    weak var delegate: PannelProtocol?
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
        
        subPannel.delegate = self
    }
    
    override func updateConstraints() {
        
        subPannel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        
        super.updateConstraints()
    }
}

// MARK: - DataSource and Delegate
// MARK: -



// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
extension ToolsPannel: PannelProtocol {
    
    func pannelGetContainer() -> IContainer? {
        return delegate?.pannelGetContainer()
    }
    
    func pannelDidSendEvent(event: PannelEvent, object: AnyObject?) -> Void {
         delegate?.pannelDidSendEvent(event, object: object)
    }
}
