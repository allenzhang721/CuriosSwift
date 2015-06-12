//
//  AnimationPannel.swift
//  
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

class AnimationPannel: Pannel {

    
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewLayout())
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }
}

// MARK: - DataSource and Delegate
// MARK: -
extension AnimationPannel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("animationPannel", forIndexPath: indexPath) as! UICollectionViewCell
        
        return cell
    }
}


// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
