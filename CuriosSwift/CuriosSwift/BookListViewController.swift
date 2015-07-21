//
//  BookListViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Alamofire
import Mantle
import MJRefresh

let publishHOST = "http://7wy3u8.com2.z0.glb.qiniucdn.com/"

class BookListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
  
  var bookList = [BookListModel]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      let userID = UsersManager.shareInstance.getUserID()
      
      UserListManager.shareInstance.getList(userID, start:0, size: 20) { [unowned self](books) -> () in
        
        self.appBooks(books)
        self.tableView.reloadData()
      }
    }
}





















// MARK: - DataSource and Delegate
// MARK: - 

extension BookListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bookList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BookListCell") as! BookListTableViewCell
//        let bookModel = UsersManager.shareInstance.bookList[indexPath.item]
//        cell.setBookMode(bookModel)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.item;
//        let result = UsersManager.shareInstance.deleteBook(index);
//        if result {
//             tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!{
        return "删除";
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      // open a book
      let bookitem = bookList[indexPath.row]
      let aurl = bookitem.publishResURL
      // Fetch Request
      Alamofire.request(.POST, aurl, parameters: nil)
        .validate(statusCode: 200..<300)
        .responseJSON{ (request, response, JSON, error) in
          if (error == nil)
          {
            if let jsondic = JSON as? [NSObject : AnyObject] {
              
              let bookModel = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: jsondic as [NSObject : AnyObject] , error: nil) as! BookModel
              
              self.showEditViewControllerWithBook(bookModel)
            }
          }
          else
          {
            if let aError = error{
              
            }
            println("HTTP HTTP Request failed: \(error)")
          }
      }
      
      
      
      
      
//      PublishIDRequest.requestWithComponents(getPublishID, aJsonParameter: nil) {[unowned self] (json) -> Void in
//        
//        if let publishID = json["newID"] as? String {
//          self.getBookWithBookID(publishID, getBookHandler: { [unowned self] (book) -> () in
//            self.showEditViewControllerWithBook(book)
//            })
//        }
//      }.sendRequest()
    }
}

// MARK: - IBAction
// MARK: - 

extension BookListViewController {
    
    @IBAction func addBookAction(sender: UIBarButtonItem) {
      
      
    }

    @IBAction func logoutAction(sender: UIBarButtonItem) {
        LoginModel.shareInstance.logout();
    }
}

// MARK: - Private Method
// MARK: -
extension BookListViewController {

  
  func appBooks(books: [BookListModel]) {
    
    if books.count <= 0 {
      return
    }
    
    for book in books {
      bookList.append(book)
    }
  }
}

