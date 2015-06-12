//
//  TemplateCollectionViewCell.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/11/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class TemplateCollectionViewCell: UICollectionViewCell {
    
    var templateModel:TemplateListModel?
    
    @IBOutlet weak var templateCellImg: UIImageView!
    @IBOutlet weak var templateCelllabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if self.templateModel != nil {
            let imgIconURL = self.templateModel!.iconUrl
            if imgIconURL != nil && imgIconURL != "" {
                //templateCellImg.image = UIImage(contentsOfFile: imgIconURL!);
            }else{
                
            }
            templateCelllabel.text = self.templateModel!.bookName;
        }
    }
    
    func setModel(value:TemplateListModel){
        self.templateModel = value;
    }
}
