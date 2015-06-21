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

}

// MARK: - DataSource and Delegate
// MARK: -



// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
extension BookDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.item == 0 || indexPath == 4 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailInfoCell
            return cell
        }
    }
}