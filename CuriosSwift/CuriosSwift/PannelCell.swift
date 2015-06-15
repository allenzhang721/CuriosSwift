//
//  PannelCell.swift
//  
//
//  Created by Emiaostein on 6/15/15.
//
//

import UIKit

class PannelCell: UICollectionViewCell {
    
    let selectedView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Editor_Selected"))
        return imageView
    }()
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
        addSubview(iconView)
        addSubview(selectedView)
        addSubview(titleLabel)
        
        setupConstraints()
//        setupColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(image: UIImage, title: String) {
        
        iconView.image = image
        titleLabel.text = title
    }
    
    func updateSelected() {
        selectedView.hidden = !selected
    }
}

// MARK: - DataSource and Delegate
// MARK: -



// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -

extension PannelCell {
    
    private func setupConstraints() {
        
        iconView.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.centerX.equalTo(self.contentView.snp_centerX)
            make.top.equalTo(self.snp_top).offset(10)
        }
        
        selectedView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(iconView)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(10)
            make.centerX.equalTo(self.contentView.snp_centerX)
            make.top.equalTo(iconView.snp_bottom).offset(5)
        }
    }
    
    private func setupColor() {
        iconView.backgroundColor = UIColor.blueColor()
    }
}
