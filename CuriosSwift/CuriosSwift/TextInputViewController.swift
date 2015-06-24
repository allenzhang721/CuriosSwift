//
//  TextInputViewController.swift
//  
//
//  Created by Emiaostein on 6/24/15.
//
//

import UIKit

protocol textInputViewControllerProtocol: NSObjectProtocol {
    
    func textInputViewControllerTextDidEnd(inputViewController: TextInputViewController, text: String)
//    func textInputViewControllerTextDidEnd(text: String)
}

class TextInputViewController: UIViewController {

    var text = ""
    var ID = ""
    weak var delegate: textInputViewControllerProtocol?
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = text
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let aDelegate = delegate {
            aDelegate.textInputViewControllerTextDidEnd(self, text:textView.text)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

