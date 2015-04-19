//
//  Models.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class Model: MTLModel {
   
}

class BookModel: Model {
    var pages: [PageModel] = []
}

class PageModel: Model {
    var items: [ItemModel] = []
}


class ItemModel: Model {

    enum animations {
        case None, FadeIn, FadeOut
    }
    
    var center = CGPointZero
    var size = CGSizeZero
    var rotation: CGFloat = 0
    var editable = true
    var animation :animations = .None
    var content = NoneContentModel()
}

class ContentModel: Model {
    
}

class NoneContentModel: ContentModel {
    
}

class ImageContentModel: ContentModel {
    var image = UIImage()
}

class TextContentModel: ContentModel {
    var text = ""
}


