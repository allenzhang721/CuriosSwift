//
//  BookListViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class BookListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - DataSource and Delegate
// MARK: - 

extension BookListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UsersManager.shareInstance.bookList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BookListCell") as! BookListTableViewCell
        let bookModel = UsersManager.shareInstance.bookList[indexPath.item]
        cell.setBookMode(bookModel)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.item;
        let result = UsersManager.shareInstance.deleteBook(index);
        if result {
             tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!{
        return "删除";
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      // open a book
      getBookWithBookID("", getBookHandler: { [unowned self] (book) -> () in
        self.showEditViewControllerWithBook(book)
      })
    }
}

// MARK: - IBAction
// MARK: - 

extension BookListViewController {
    
    @IBAction func addBookAction(sender: UIBarButtonItem) {
        
//        createBook()
    }

    @IBAction func logoutAction(sender: UIBarButtonItem) {
        LoginModel.shareInstance.logout();
    }
}

// MARK: - Private Method
// MARK: - 

extension BookListViewController {
    
    func createBook() {
       let templateViewController = storyboard?.instantiateViewControllerWithIdentifier("TemplateViewController") as! TemplateViewController
        
        navigationController!.presentViewController(templateViewController, animated: true, completion: nil)
    }
    
}
