//
//  ViewController+Extension.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit
import Mantle

extension UIViewController {
  
   func getBookWithBookID(bookID: String, getBookHandler: (BookModel) -> ()) {
    
    let book = demoBook()
    book.Id = bookID
    
    getBookHandler(book)
  }
  
  private func demoBook() -> BookModel {
    
    let mainURL = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("main.json")
    let data = NSData(contentsOfURL: mainURL)
    let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(0), error: nil)
    
    println("demoBookJson = \(json)")
    
    let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
    
    return book
  }
  
   func showEditViewControllerWithBook(book: BookModel) {
    
    let edit = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editViewController") as! EditViewController
    edit.bookModel = book
    navigationController?.presentViewController(edit, animated: true, completion: nil)
  }
}