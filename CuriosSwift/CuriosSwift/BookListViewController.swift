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
import ReachabilitySwift

protocol BookListViewControllerDelegate: NSObjectProtocol {
  
  func viewController(controller: UIViewController, needHiddenStateBar hidden: Bool)
  
}

class BookListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
  
  let reachability = Reachability.reachabilityForInternetConnection()
  var bookList = [BookListModel]()
  var delegate: BookListViewControllerDelegate?
  var needRefresh = true
  
    override func viewDidLoad() {
        super.viewDidLoad()
      addRefreshControl()
    }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = false
    delegate?.viewController(self, needHiddenStateBar: false)
    
    if needRefresh {
      needRefresh = false
      tableView.header.beginRefreshing()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let viewController: AnyObject = segue.destinationViewController
    
    if viewController is UserViewController {
      delegate?.viewController(self, needHiddenStateBar: false)
    } else if let aviewController = viewController as? ThemeViewController {
      aviewController.delegate = self
      delegate?.viewController(self, needHiddenStateBar: true)
    } else {
      delegate?.viewController(self, needHiddenStateBar: false)
    }
  }
  
  func addRefreshControl() {
    
    tableView.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refreshBooklist")
//    tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "appendBooklist")
  }
  
  func needFooter() {
    
    if tableView.contentSize.height >= tableView.bounds.height {
      tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "appendBooklist")
    } else {
      tableView.footer = nil
    }
    
  }
  
  func refreshBooklist() {
    
    let userID = UsersManager.shareInstance.getUserID()
    let count = bookList.count <= 20 ? 20 : bookList.count
    UserListManager.shareInstance.getList(userID, start:0, size: count) { [unowned self](books) -> () in
      self.cleanBooks()
      self.appBooks(books)
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        self.tableView.header.endRefreshing()
        self.needFooter()
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



// MARK: - ThemeDelegate
extension BookListViewController: ThemeViewControllerDelegate {
  
  func viewController(controller: UIViewController, aNeedRefresh: Bool) {
    needRefresh = aNeedRefresh
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
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.item;
        let publishID = bookList[index].publishID
      deleteBook(publishID, completed: { [unowned self](success) -> () in
        
        if success {
          self.bookList.removeAtIndex(indexPath.item)
          self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
          self.needFooter()
        } else {
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
      let time = Int(floor(NSDate().timeIntervalSince1970 * 1000))
      let aurl = bookitem.publishResURL + "?v=\(time)"
      
      // Fetch Request
      needRefresh = true
      Alamofire.request(.POST, aurl, parameters: nil)
        .validate(statusCode: 200..<300)
        .responseJSON{ (request, response, JSON, error) in
          
          if (error == nil)
          {
            if let jsondic = JSON as? [NSObject : AnyObject] {
              
              let bookModel = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: jsondic as [NSObject : AnyObject] , error: nil) as! BookModel
              
              self.showEditViewControllerWithBook(bookModel, begainThemeID: nil, isUploaded: true)
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
      
      if reachability.currentReachabilityStatus == .NotReachable {
        self.needConnectNet()
      } else if reachability.currentReachabilityStatus != .ReachableViaWiFi  {
        self.needChangeToWiFi()
      } else {
        showThemes()
      }
    }

    @IBAction func logoutAction(sender: UIBarButtonItem) {
        LoginModel.shareInstance.logout();
    }
}

// MARK: - Private Method
// MARK: -
extension BookListViewController {
  
  func showThemes() {
    if let themeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ThemeViewController") as? ThemeViewController {
      
      themeVC.delegate = self
      delegate?.viewController(self, needHiddenStateBar: true)
      navigationController?.pushViewController(themeVC, animated: true)
    }
  }
  
  func needConnectNet() {
    
    let alert = AlertHelper.alert_needConnected()
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func needChangeToWiFi() {
    
   let alert = AlertHelper.alert_internetconnection {[unowned self] (confirmed) -> () in
      
      if confirmed {
        self.showThemes()
      }
    }
    presentViewController(alert, animated: true, completion: nil)
  }
  
  
  
  func deleteBook(publishID: String, completed: (Bool) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let string = DELETE_PUBLISH_FILE_paras(userID, publishID)
    DeletePublishFileRequest.requestWithComponents(DELETE_PUBLISH_FILE, aJsonParameter: string) { (json) -> Void in
      if let re = json["resultType"] as? String where re == "success" {
        completed(true)
      } else {
        completed(false)
      }
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
      bookList.append(book)
    }
  }
}

