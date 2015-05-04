//
//  DataManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class BookManager: NSObject {
    
    
    class func createBookTo(path: String) -> BookModel {
        
        
        return BookModel()
    }
    
    class func createPageTo(path: String) -> PageModel {
        
        
        return PageModel()
    }
    
    class func deleteBookWith(path: String) -> Bool {
        
        
        return true
    }
    
    class func deletePageWith(path: String) -> Bool {
        
        return true
    }
   
    
   class func bookWith(path: String) -> BookModel {
    
        return BookModel()
    }
    
    class func pageWith(file: String) -> PageModel {
        
        return PageModel()
    }
}
