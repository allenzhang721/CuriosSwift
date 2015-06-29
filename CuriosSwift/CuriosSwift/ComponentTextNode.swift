//
//  ComponentTextNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentTextNode: ASEditableTextNode, ITextComponent, ASEditableTextNodeDelegate {
   
    var componentModel: ComponentModel
    var contentText: String = "New Text" {
        didSet {
            componentModel.attributes["contentText"] = contentText
            self.attributedText = NSAttributedString(string: contentText)
        }
    }
    
    var textAligement: Int = 0 {
        
        didSet {
            componentModel.attributes["aligement"] = textAligement
            let style = NSMutableParagraphStyle()
            if textAligement == 0 {
                style.alignment = NSTextAlignment.Left
            } else if textAligement == 1 {
                style.alignment = NSTextAlignment.Center
            } else {
                style.alignment = NSTextAlignment.Right
            }
            
            let attribute = [NSFontAttributeName: UIFont.systemFontOfSize(fontsSize),
                NSParagraphStyleAttributeName: style]
            attributedText = NSAttributedString(string: componentModel.attributes["contentText"] as! String, attributes: attribute)
        }
    }
    
    var fontsSize: CGFloat = 12 {
        didSet {
            componentModel.attributes["fontSize"] = fontsSize
            let style = NSMutableParagraphStyle()
            if textAligement == 0 {
                style.alignment = NSTextAlignment.Left
            } else if textAligement == 1 {
                style.alignment = NSTextAlignment.Center
            } else {
                style.alignment = NSTextAlignment.Right
            }
            let attribute = [NSFontAttributeName: UIFont.systemFontOfSize(fontsSize),
                NSParagraphStyleAttributeName: style]
            attributedText = NSAttributedString(string: componentModel.attributes["contentText"] as! String, attributes: attribute)
        }
    }
    
    var fontName: String = "" {
        didSet {
            componentModel.attributes["fontName"] = fontName
            let style = NSMutableParagraphStyle()
            if textAligement == 0 {
                style.alignment = NSTextAlignment.Left
            } else if textAligement == 1 {
                style.alignment = NSTextAlignment.Center
            } else {
                style.alignment = NSTextAlignment.Right
            }
            let attribute = [NSFontAttributeName: UIFont.systemFontOfSize(fontsSize),
                NSParagraphStyleAttributeName: style]
            attributedText = NSAttributedString(string: componentModel.attributes["contentText"] as! String, attributes: attribute)
        }
        
    }
    
    
    
    required init(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        super.init()
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
//        self.attributedPlaceholderText = NSAttributedString(string: "Input Your Text")
        if let afontsSize = componentModel.attributes["fontSize"] as? CGFloat {
            fontsSize = afontsSize
        } else {
            fontsSize = 14
        }
        if let aTextAligement = componentModel.attributes["aligement"] as? Int {
            textAligement = aTextAligement
        } else {
            textAligement = 0
        }
        
        let style = NSMutableParagraphStyle()
        if textAligement == 0 {
            style.alignment = NSTextAlignment.Left
        } else if textAligement == 1 {
            style.alignment = NSTextAlignment.Center
        } else {
            style.alignment = NSTextAlignment.Right
        }
        let attribute = [NSFontAttributeName: UIFont.systemFontOfSize(fontsSize),
            NSParagraphStyleAttributeName: style]
        
        self.attributedText = NSAttributedString(string: componentModel.attributes["contentText"] as! String, attributes: attribute)
        delegate = self
    }
    
// MARK: - ITextComponent
    
    func iBecomeFirstResponder() {
        userInteractionEnabled = true
        becomeFirstResponder()
    }
    func iResignFirstResponder() {
        userInteractionEnabled = false
        resignFirstResponder()
    }
    func iIsFirstResponder() -> Bool {
        return isFirstResponder()
    }
    
    func setFontAligement(aligement: Int) {
        
        textAligement = aligement
    }
    
    func setFontSize(plus: Bool) {
        
        if plus {
            
            fontsSize += 1.0
        } else {
            fontsSize -= 1.0
        }
    }
    
    private func myString(fontSize: Int) {
        
        
        
    }
}

extension ComponentTextNode {
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode!) {
        if let attributeString = editableTextNode.attributedText {
            let aString = attributeString.string
            contentText = aString
        }
    }
}
