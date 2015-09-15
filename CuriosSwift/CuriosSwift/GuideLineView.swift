//
//  GuideLineView.swift
//  
//
//  Created by Emiaostein on 9/15/15.
//
//

import UIKit

class GuideLineView: UIView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clearColor()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
    override func drawRect(rect: CGRect) {
        // Drawing code
      super.drawRect(rect)
//      backgroundColor = UIColor.clearColor()
    GuideLineTool.drawGuideLine(rect)
      
    }
}
