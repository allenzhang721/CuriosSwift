//
//  TextInputView.swift
//  
//
//  Created by Emiaostein on 7/2/15.
//
//

import UIKit

class TextInputView: UIView {
    
    typealias textInputViewCompeletedBlock = (String) -> ()

    var compeletedBlock: textInputViewCompeletedBlock?
    @IBOutlet weak var textView: UITextView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func setAttributeText(attributeText: NSAttributedString, confirmHander: textInputViewCompeletedBlock?) {
        
        textView.becomeFirstResponder()
        textView.attributedText = attributeText
        compeletedBlock = confirmHander
    }
    
    func confirm() {
        
        textView.resignFirstResponder()
    }

    @IBAction func confirmAction(sender: UIButton) {
        
        
        let string = textView.attributedText.string
        compeletedBlock?(string)
        textView.resignFirstResponder()
    }
}
