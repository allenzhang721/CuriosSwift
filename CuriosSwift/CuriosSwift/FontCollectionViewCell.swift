//
//  FontCollectionViewCell.swift
//  
//
//  Created by Emiaostein on 7/3/15.
//
//

import UIKit

class FontCollectionViewCell: UICollectionViewCell {
    
    let fontLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = label.font.fontWithSize(17)
        label.text = "字体"
        label.textAlignment = NSTextAlignment.Center
        return label
        }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = label.font.fontWithSize(10)
        label.text = "Title"
        label.textAlignment = NSTextAlignment.Center
        return label
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(fontLabel)
        addSubview(titleLabel)
        
        setupConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FontCollectionViewCell {
    
    func setupConstraints() {
        
        fontLabel.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.centerX.equalTo(self.contentView.snp_centerX)
            make.top.equalTo(self.snp_top).offset(10)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(10)
            make.centerX.equalTo(self.contentView.snp_centerX)
            make.top.equalTo(fontLabel.snp_bottom).offset(5)
        }
    }
}
