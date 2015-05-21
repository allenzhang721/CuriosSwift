//
//  FakePageView.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/4/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class FakePageView: UIView {
    
    private var pageArray: [PageModel] = []
    var fromTemplate = false
    private weak var selectedItem: PageModel!
    
    class func fakePageViewWith(snapshot: UIView, array: [PageModel]) -> FakePageView {
        
        let fakePageView = FakePageView(frame: snapshot.bounds)
        fakePageView.pageArray = array
        fakePageView.selectedItem = array[0]
        fakePageView.addSubview(snapshot)
        return fakePageView
    }
    
    func clearnPageArray() {
        pageArray = []
    }
    
    func getPageArray() -> [PageModel] {
        return pageArray
    }
    
    func getPlaceholderPage() -> PageModel {
        return selectedItem
    }
}
