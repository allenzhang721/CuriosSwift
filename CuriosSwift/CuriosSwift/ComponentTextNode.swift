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
    
    required init(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        super.init()
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
//        self.attributedPlaceholderText = NSAttributedString(string: "Input Your Text")
        self.attributedText = NSAttributedString(string: componentModel.attributes["contentText"] as! String)
        delegate = self
        atextAligement = NSTextAlignment.Center
    }
    
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
}

extension ComponentTextNode {
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode!) {
        if let attributeString = editableTextNode.attributedText {
            let aString = attributeString.string
            contentText = aString
            println(contentText)
        }
//        println(editableTextNode.attributedText.string)
    }
}
