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

        if !UserManager.shareInstance.existDirectoryWithUserName(UserManager.shareInstance.defaultUserName) {
            if UserManager.shareInstance.CreateUserDirectoryWithUserName(UserManager.shareInstance.defaultUserName) {
                println("Create Default user Directory success")
            }
        } else {
            println("default user directory exist")
        }
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
        
        return UserManager.shareInstance.bookCount()
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BookListCell") as! BookListTableViewCell
        
        return cell
    }
}
// MARK: - IBAction
// MARK: - 


// MARK: - Private Method
// MARK: - 

extension BookListViewController {
    
    
    
}
