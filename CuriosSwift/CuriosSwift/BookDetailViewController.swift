//
//  BookDetailViewController.swift
//  
//
//  Created by Emiaostein on 6/18/15.
//
//

import UIKit

class BookDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var bookModel: BookModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "BookDetailImageCell", bundle: nil), forCellReuseIdentifier: "BookDetailImageCell")
        tableView.registerNib(UINib(nibName: "BookDetailInfoCell", bundle: nil), forCellReuseIdentifier: "BookDetailInfoCell")
        tableView.rowHeight = 72
    }
    @IBAction func backAction(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - DataSource and Delegate
// MARK: -

// MARK: - IBAction
// MARK: -

// MARK: - Private Method
// MARK: -
extension BookDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            if row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
                cell.titleLabel.text = ""
                return cell
            } else if row == 1{
                let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailInfoCell") as! BookDetailInfoCell
                cell.titleLabel.
                return cell
            }
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
            return cell
        }
    }
}