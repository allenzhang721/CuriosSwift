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
      
      addRefreshControl()
    }
  
  override func viewWillAppear(animated: Bool) {
     tableView.header.beginRefreshing()
  }
  
  func addRefreshControl() {
    
    tableView.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refreshBooklist")
    tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "appendBooklist")
  }
  
  func refreshBooklist() {
    
    let userID = UsersManager.shareInstance.getUserID()
    let count = bookList.count <= 0 ? 20 : bookList.count
    UserListManager.shareInstance.getList(userID, start:0, size: count) { [unowned self](books) -> () in
      self.cleanBooks()
      self.appBooks(books)
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        self.tableView.header.endRefreshing()
      })
    }
  }
  
  func appendBooklist() {
    
    let userID = UsersManager.shareInstance.getUserID()
    let count = bookList.count
    UserListManager.shareInstance.getList(userID, start:count, size: 20) { [unowned self](books) -> () in
      self.appBooks(books)
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        self.tableView.footer.endRefreshing()
      })
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
        let bookModel = bookList[indexPath.item]
//        cell.setBookMode(bookModel)
      cell.configWithModel(bookModel)
      cell.layer.cornerRadius = 8
      cell.clipsToBounds = true
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.item;
        let publishID = bookList[index].publishID
      deleteBook(publishID, completed: { [unowned self](success) -> () in
        
        if success {
          self.bookList.removeAtIndex(indexPath.item)
          self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        } else {
          println("delete book fail")
        }
        
      })
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!{
        return "删除";
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      
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
  
  func deleteBook(publishID: String, completed: (Bool) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let string = DELETE_PUBLISH_FILE_paras(userID, publishID)
    DeletePublishFileRequest.requestWithComponents(DELETE_PUBLISH_FILE, aJsonParameter: string) { (json) -> Void in
      if let re = json["resultType"] as? String where re == "success" {
        completed(true)
      } else {
        completed(false)
      }
      println("Delete a book = \(json)")
    }.sendRequest()
    
  }
  
  func cleanBooks() {
    
    if bookList.count <= 0 {
      return
    }
    
    bookList.removeAll(keepCapacity: false)
  }

  
  func appBooks(books: [BookListModel]) {
    if books.count <= 0 {
      return
    }
    
    for book in books {
      println("booklistitem = \(book)")
      bookList.append(book)
    }
  }
}

