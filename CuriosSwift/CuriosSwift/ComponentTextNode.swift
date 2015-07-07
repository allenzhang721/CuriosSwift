//
//  ComponentTextNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentTextNode: ASTextNode, ITextComponent, ASEditableTextNodeDelegate {
   
    var componentModel: ComponentModel
    var contentText: String = "New Text" {
        didSet {
            componentModel.attributes["contentText"] = contentText
            setAttributeText()
        }
    }
    
    var fontsName: String = "RTWSYueGoG0v1-UltLight" {
        
        didSet {
            componentModel.attributes["FontsName"] = fontsName
            setAttributeText()
        }
    }
    
    var textAligement: Int = 0 {
        
        didSet {
            componentModel.attributes["aligement"] = textAligement
            setAttributeText()
        }
    }
    
    var fontsSize: CGFloat = 30 {
        didSet {
            componentModel.attributes["fontSize"] = fontsSize
            setAttributeText()
        }
    }
    
    var fontColor: String = "#FFFFFF" {
        
        didSet {
            componentModel.attributes["fontColor"] = fontColor
            setAttributeText()
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
            fontsSize = 30
        }
        if let aTextAligement = componentModel.attributes["aligement"] as? Int {
            textAligement = aTextAligement
        } else {
            textAligement = 0
        }
        
        if let aFontsName = componentModel.attributes["FontsName"] as? String {
            fontsName = aFontsName
        }
        
        if let aFontsColor = componentModel.attributes["fontColor"] as? String {
            fontColor = aFontsColor
            
        }
        
        setAttributeText()
    }
    
// MARK: - ITextComponent
    
    func iBecomeFirstResponder() {
        userInteractionEnabled = true
    }
    func iResignFirstResponder() {
        userInteractionEnabled = false
    }
    func iIsFirstResponder() -> Bool {
        return false
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
    
    func settFontsName(name: String) -> CGSize {
        
        fontsName = name
        
        return textSize()
    }
    
    func setTextContent(text: String) -> CGSize {
        
        contentText = text
        
        return textSize()
    }
    
    func resizeScale(scale: CGFloat) {
        
        fontsSize = fontsSize * scale
        
        
    }
    
    func setNeedUpload(needUpload: Bool) {
        
        componentModel.needUpload = needUpload
    }
    
    func getTextColor() -> String {
        
        return fontColor
    }
    
    func getAttributeText() -> NSAttributedString {
        
        let style = NSMutableParagraphStyle()
        if textAligement == 0 {
            style.alignment = NSTextAlignment.Left
        } else if textAligement == 1 {
            style.alignment = NSTextAlignment.Center
        } else {
            style.alignment = NSTextAlignment.Right
        }
        
        let attribute = [NSFontAttributeName: UIFont(name: fontsName, size: 20)!,
            NSParagraphStyleAttributeName: style]
        let aAttributedString = NSAttributedString(string: componentModel.attributes["contentText"] as! String, attributes: attribute)
        
        return aAttributedString
    }
    
    func textSize() -> CGSize {
        
        let size = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        let aSize = attributedString.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size
        return aSize
    }
    
    func setTextColor(colorHex: String) {
        
        fontColor = colorHex
    }
    
    func setAttributeText() {
        
        let style = NSMutableParagraphStyle()
        if textAligement == 0 {
            style.alignment = NSTextAlignment.Left
        } else if textAligement == 1 {
            style.alignment = NSTextAlignment.Center
        } else {
            style.alignment = NSTextAlignment.Right
        }
        
        let color = UIColor(hexString: fontColor)!
        
        let attribute = [NSFontAttributeName: UIFont(name: fontsName, size: fontsSize)!,
            NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: color]
        attributedString = NSAttributedString(string: componentModel.attributes["contentText"] as! String, attributes: attribute)
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
