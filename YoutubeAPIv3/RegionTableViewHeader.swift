//
//  RegionTableViewHeader.swift
//  YoutubeAPIv3
//
//  Created by 涂安廷 on 2016/7/18.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

import UIKit

class RegionTableViewHeader:UIView {
    
    @IBOutlet weak var label: UILabel!    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var expandButton: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func xibSetup() {
        
        view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor.clearColor()
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "RegionTableViewHeader", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
}