//
//  AuthButton.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 2/11/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlue
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
