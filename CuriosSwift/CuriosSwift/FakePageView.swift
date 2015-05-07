//
//  FakePageView.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/4/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class FakePageView: UIView {
    
    var dataArray: [PageViewModel] = []
    weak var selectedItem: PageViewModel!
    
    class func fakePageViewWith(snapshot: UIView, array: [PageViewModel]) -> FakePageView {
        
        let fakePageView = FakePageView(frame: snapshot.bounds)
        fakePageView.dataArray = array
        fakePageView.selectedItem = array[0]
        fakePageView.addSubview(snapshot)
        return fakePageView
    }
}
