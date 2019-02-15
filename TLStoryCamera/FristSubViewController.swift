//
//  FirstSubViewController.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/27.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import TLStoryCameraFramework

class FirstSubViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tipLabel = UILabel.init()
        tipLabel.text = "Scroll left open>>>"
        tipLabel.textColor = UIColor.white
        self.view.addSubview(tipLabel)
        tipLabel.sizeToFit()
        tipLabel.center = CGPoint.init(x: self.view.width / 2, y: self.view.height / 2)
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionOpen))
        tipLabel.isUserInteractionEnabled = true
        tipLabel.addGestureRecognizer(tap)
        
        self.view.backgroundColor = UIColor.gray
        
    }
    
    @objc fileprivate func actionOpen() {
        let c = TLStoryViewController()
        self.present(c, animated: true, completion: nil)
    }

}
